function Get-SupportedMethods {
    <#
    .SYNOPSIS
        Determines which HTTP methods a permission supports for a given resource and scheme.

    .DESCRIPTION
        Internal helper function that searches through a resource's method/scheme structure
        to identify all HTTP methods where a specific permission claim is valid. This is
        used during disambiguation to understand the scope of a permission's applicability.

        For example, if Mail.Read supports both GET and POST methods but Mail.ReadBasic
        only supports GET, this function helps identify those differences.

    .PARAMETER Resource
        The ProtectedResource object containing all permissions organized by method and scheme.

    .PARAMETER Claim
        The claim object to search for, containing at minimum a Permission property.

    .PARAMETER Scheme
        The authentication scheme to check within (DelegatedWork, DelegatedPersonal, Application).

    .OUTPUTS
        String[]
        Returns an array of HTTP method names (GET, POST, etc.) where the claim is valid
        for the specified scheme. Returns an empty array if the permission is not found.

    .EXAMPLE
        Get-SupportedMethods -Resource $resource -Claim $claim -Scheme 'DelegatedWork'
        
        Returns array of HTTP methods supported by this permission.

    .NOTES
        This is an internal function not exported from the module. It's used by
        Invoke-Disambiguate to help select between multiple least privileged options
        based on their method coverage.

    .EXAMPLE
        Get-SupportedMethods -Resource $resource -Claim $claim -Scheme 'DelegatedWork'
        # Returns array of HTTP methods supported by this permission
    #>
    param(
        [Parameter(Mandatory)]
        $Resource,
        [Parameter(Mandatory)]
        $Claim,
        [Parameter(Mandatory)]
        [string]$Scheme
    )
    
    $methods = [System.Collections.Generic.List[string]]::new()
    foreach ($m in $Resource.Methods.Keys) {
        if ($Resource.Methods[$m].ContainsKey($Scheme)) {
            $schemeClaims = $Resource.Methods[$m][$Scheme]
            if ($schemeClaims | Where-Object { $_.Permission -eq $Claim.Permission }) {
                $methods.Add($m)
            }
        }
    }
    return $methods.ToArray()
}
