function Invoke-Disambiguate {
    <#
    .SYNOPSIS
        Selects the most appropriate permission when multiple least privileged options exist.

    .DESCRIPTION
        Internal function that implements disambiguation logic to choose between multiple
        permissions that are all marked as least privileged for a given endpoint. This
        handles edge cases in the Microsoft Graph permissions metadata where multiple
        permissions are equally valid.

        The disambiguation algorithm uses a three-tier strategy:
        
        1. Single Option: If only one claim exists, return it immediately
        
        2. Exclusive Method Match: Prefer permissions that only work for the specific
           HTTP method being queried (most specific scope)
           
        3. Narrowest Scope: Choose the permission that supports the fewest total methods
           across the resource (most restrictive permission)
           
        4. First Match Fallback: If all else fails, return the first claim
        
        This ensures that when multiple "least privileged" options exist, the most
        contextually appropriate one is selected based on the specific method being used.

    .PARAMETER Resource
        The ProtectedResource object containing all permissions for the endpoint.

    .PARAMETER Method
        The HTTP method being queried (GET, POST, PUT, PATCH, DELETE, etc.).

    .PARAMETER Scheme
        The authentication scheme (DelegatedWork, DelegatedPersonal, Application).

    .PARAMETER Claims
        Array of claim objects that are all marked as least privileged and need
        to be disambiguated.

    .OUTPUTS
        String[]
        Returns an array containing a single formatted permission string (may include
        "and" clauses if the permission has dependencies via AlsoRequires).

    .NOTES
        This is an internal function not exported from the module. It's called by
        Get-ResourceLeastPrivileged when multiple least privileged permissions exist.
        
        The algorithm prioritizes context-specific permissions (exclusive to the method)
        over broader permissions that work across multiple methods, following the
        principle of least privilege most strictly.

    .EXAMPLE
        Invoke-Disambiguate -Resource $resource -Method 'GET' -Scheme 'DelegatedWork' -Claims $claims
        
        Selects the most appropriate permission from multiple least privileged candidates.
    #>
    param(
        [Parameter(Mandatory)]
        $Resource,
        [Parameter(Mandatory)]
        [string]$Method,
        [Parameter(Mandatory)]
        [string]$Scheme,
        [Parameter(Mandatory)]
        [array]$Claims
    )
    
    if ($Claims.Count -eq 1) {
        return @(Format-PermissionString -Claim $Claims[0])
    }

    # Try to find permissions exclusive to this method
    foreach ($claim in $Claims) {
        $supportedMethods = Get-SupportedMethods -Resource $Resource -Claim $claim -Scheme $Scheme
        if ($supportedMethods.Count -eq 1 -and $supportedMethods[0] -eq $Method) {
            return @(Format-PermissionString -Claim $claim)
        }
    }

    # Find permission with fewest supported methods (narrowest scope)
    $minMethodCount = [int]::MaxValue
    $bestClaim = $null

    foreach ($claim in $Claims) {
        $supportedMethods = Get-SupportedMethods -Resource $Resource -Claim $claim -Scheme $Scheme
        if ($supportedMethods.Count -lt $minMethodCount) {
            $minMethodCount = $supportedMethods.Count
            $bestClaim = $claim
        }
    }

    if ($bestClaim) {
        return @(Format-PermissionString -Claim $bestClaim)
    }

    return @(Format-PermissionString -Claim $Claims[0])
}
