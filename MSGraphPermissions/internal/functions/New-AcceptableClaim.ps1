function New-AcceptableClaim {
    <#
    .SYNOPSIS
        Creates a new AcceptableClaim object representing a permission claim.

    .DESCRIPTION
        Internal factory function that creates a standardized PSCustomObject representing
        a permission claim with all necessary metadata. The claim object tracks:
        - The permission name
        - Whether it's marked as least privileged
        - Any additional required permissions (dependencies)
        - The authentication scheme it applies to
        
        The object includes a custom type name (GraphPermissions.AcceptableClaim) for
        type identification and potential future formatting customization.

    .PARAMETER Permission
        The name of the Graph API permission (e.g., "Mail.Read", "User.ReadBasic.All").

    .PARAMETER Least
        Boolean indicating whether this permission is explicitly marked as least privileged
        in the Microsoft Graph metadata.

    .PARAMETER AlsoRequires
        Array of additional permission names that must be granted alongside this permission
        for it to function. Most permissions don't have dependencies and will be empty.

    .PARAMETER Scheme
        The authentication scheme this claim applies to (DelegatedWork, DelegatedPersonal, Application).

    .OUTPUTS
        PSCustomObject
        Returns a claim object with properties: Permission, Least, AlsoRequires, Scheme, and PSTypeName.

    .EXAMPLE
        New-AcceptableClaim -Permission 'Mail.Read' -Least $true -AlsoRequires @() -Scheme 'DelegatedWork'
        
        Creates a new permission claim object with the specified properties.
        New-AcceptableClaim -Permission 'Mail.Read' -Least $true -AlsoRequires @() -Scheme 'DelegatedWork'
        # Creates a new claim object for a least privileged permission

    .NOTES
        This is an internal function not exported from the module. It's used during the
        permissions index building process to create standardized claim objects.
    #>
    param(
        [string]$Permission,
        [bool]$Least,
        [string[]]$AlsoRequires,
        [string]$Scheme
    )
    
    return [PSCustomObject]@{
        Permission   = $Permission
        Least        = $Least
        AlsoRequires = $AlsoRequires
        Scheme       = $Scheme
        PSTypeName   = 'GraphPermissions.AcceptableClaim'
    }
}
