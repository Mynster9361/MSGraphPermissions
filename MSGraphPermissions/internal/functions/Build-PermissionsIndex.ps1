function Build-PermissionsIndex {
    <#
    .SYNOPSIS
        Builds an indexed lookup structure from raw Microsoft Graph permissions data.

    .DESCRIPTION
        Internal function that transforms the raw permissions JSON data from Microsoft Graph
        into an optimized hashtable index for fast lookups. The index maps API paths to
        ProtectedResource objects containing all available permissions organized by HTTP
        method and authentication scheme.

        This function processes the complex nested structure of the permissions data:
        - Iterates through all permissions and their path sets
        - Parses "least=" metadata to identify least privileged permissions
        - Parses "alsoRequires=" metadata for permission dependencies
        - Creates claims for each method/scheme/path combination
        - Normalizes paths to lowercase for case-insensitive lookups
        - Builds a nested structure: Path -> Method -> Scheme -> Claims

        The resulting index enables O(1) lookups by path for the module's query functions.

    .PARAMETER PermissionsData
        The raw permissions data hashtable deserialized from the Microsoft Graph JSON file.
        Must contain a 'permissions' property with the permission definitions.

    .OUTPUTS
        Hashtable
        Returns a hashtable indexed by normalized (lowercase) API paths, where each value
        is a ProtectedResource object with Methods, Schemes, and Claims organized for
        efficient querying.

    .EXAMPLE
        $index = Build-PermissionsIndex -PermissionsData $rawData
        
        Builds a searchable index from raw Graph permissions data.

    .EXAMPLE
        $index = Build-PermissionsIndex -PermissionsData $jsonData
        # Builds indexed structure from raw permissions data

    .NOTES
        This is an internal function not exported from the module. It is called by
        Initialize-GraphPermissions during the cache initialization process.
        
        The function processes 6000+ API paths and tens of thousands of permission
        combinations, so performance is important. The indexed structure allows
        Find-GraphLeastPrivilege and Get-GraphPermissions to run efficiently.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory)]
        [object]$PermissionsData
    )

    $index = [System.Collections.Generic.Dictionary[string, object]]::new([StringComparer]::OrdinalIgnoreCase)

    foreach ($permissionName in $PermissionsData.permissions.Keys) {
        $permission = $PermissionsData.permissions[$permissionName]

        foreach ($pathSet in $permission.pathSets) {
            $schemeKeys = $pathSet.schemeKeys
            $methods = $pathSet.methods
            $paths = $pathSet.paths

            foreach ($pathKey in $paths.Keys) {
                $pathValue = $paths[$pathKey]
                
                # Get the "least=" metadata
                $leastPrivilegeSchemes = Get-LeastPrivilegeScheme $pathValue

                # Normalize path
                $normalizedPath = $pathKey.ToLowerInvariant()

                if (-not $index.ContainsKey($normalizedPath)) {
                    $index[$normalizedPath] = New-ProtectedResource -Path $normalizedPath
                }

                $resource = $index[$normalizedPath]

                foreach ($method in $methods) {
                    foreach ($schemeKey in $schemeKeys) {
                        $isLeast = $leastPrivilegeSchemes -contains $schemeKey
                        
                        # Parse alsoRequires if present
                        $alsoRequires = @()
                        if ($pathValue -match 'alsoRequires=([^,\s]+)') {
                            $alsoRequires = $matches[1] -split '\|'
                        }

                        $claim = New-AcceptableClaim -Permission $permissionName -Least $isLeast -AlsoRequires $alsoRequires -Scheme $schemeKey

                        Add-ClaimToResource -Resource $resource -Method $method -Scheme $schemeKey -Claim $claim
                    }
                }
            }
        }
    }

    return $index
}
