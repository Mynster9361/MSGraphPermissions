function Add-ClaimToResource {
    <#
    .SYNOPSIS
        Adds a permission claim to a resource's method/scheme collection.

    .DESCRIPTION
        Internal helper function that adds a permission claim to the nested hashtable
        structure representing a Graph API resource. Ensures the proper hierarchy of
        Method -> Scheme -> Claims is maintained and initializes collections as needed.

        This function is used during the permissions index building process to organize
        permission data by HTTP method and authentication scheme.

    .PARAMETER Resource
        The resource hashtable object to modify. Must have a Methods property (hashtable).

    .PARAMETER Method
        The HTTP method (GET, POST, PUT, PATCH, DELETE, etc.) for this claim.

    .PARAMETER Scheme
        The authentication scheme (DelegatedWork, DelegatedPersonal, Application).

    .PARAMETER Claim
        The claim object to add, containing permission details (Permission, Least, AlsoRequires).

    .EXAMPLE
        Add-ClaimToResource -Resource $resource -Method 'GET' -Scheme 'DelegatedWork' -Claim $claim
        
        Adds a claim to the resource's nested method and scheme structure.

    .NOTES
        This is an internal function not exported from the module. It mutates the Resource
        parameter by adding the claim to the appropriate nested collection.
    #>
    param(
        [Parameter(Mandatory)]
        $Resource,
        [Parameter(Mandatory)]
        [string]$Method,
        [Parameter(Mandatory)]
        [string]$Scheme,
        [Parameter(Mandatory)]
        $Claim
    )
    
    if (-not $Resource.Methods.ContainsKey($Method)) {
        $Resource.Methods[$Method] = @{}
    }
    if (-not $Resource.Methods[$Method].ContainsKey($Scheme)) {
        $Resource.Methods[$Method][$Scheme] = [System.Collections.Generic.List[object]]::new()
    }
    $Resource.Methods[$Method][$Scheme].Add($Claim)
}
