function Format-PermissionString {
    <#
    .SYNOPSIS
        Formats a permission claim into a human-readable string.

    .DESCRIPTION
        Internal helper function that converts a permission claim object into a formatted
        string representation. If the claim has dependencies (AlsoRequires), they are
        included in the output joined with "and".

        Examples:
        - Simple permission: "Mail.Read"
        - With dependencies: "Mail.Read and Calendars.Read and Contacts.Read"

    .PARAMETER Claim
        The claim object containing Permission and optionally AlsoRequires properties.

    .OUTPUTS
        String
        Returns a formatted permission string with any dependencies included.

    .EXAMPLE
        Format-PermissionString -Claim $claim
        
        Returns formatted permission string like 'Mail.Read and User.Read'.

    .NOTES
        This is an internal function not exported from the module. It's used for
        formatting permission output in a consistent, readable way.
    #>
    param([Parameter(Mandatory)]$Claim)
    
    if ($Claim.AlsoRequires -and $Claim.AlsoRequires.Count -gt 0) {
        return "$($Claim.Permission) and $($Claim.AlsoRequires -join ' and ')"
    }
    return $Claim.Permission
}
