function Get-LeastPrivilegeScheme {
    <#
    .SYNOPSIS
        Gets the least privileged scheme identifiers from Microsoft Graph path value metadata.

    .DESCRIPTION
        Internal function that retrieves authentication scheme identifiers from the "least="
        metadata embedded in Microsoft Graph permissions data path values. This metadata
        indicates which authentication schemes are considered least privileged for a
        specific permission on a specific path.

        The "least=" format supports comma-separated lists of scheme identifiers, for example:
        - "least=DelegatedWork" - Single scheme marked as least privileged
        - "least=DelegatedWork,Application" - Multiple schemes marked as least privileged
        - No "least=" metadata - Returns empty array (no explicit least privileged marking)

        This extraction is a critical part of the index building process, as it determines
        which permissions get marked with Least = $true in the claim objects.

    .PARAMETER PathValue
        The raw path value string from the Microsoft Graph permissions JSON, potentially
        containing "least=" metadata. Can be empty string.

    .OUTPUTS
        String[]
        Returns an array of scheme identifiers that are marked as least privileged.
        Returns empty array if no "least=" metadata is found.

    .EXAMPLE
        Get-LeastPrivilegeScheme -PathValue "least=DelegatedWork"
        
        Returns: @("DelegatedWork")

    .EXAMPLE
        Get-LeastPrivilegeScheme -PathValue "least=DelegatedWork,Application"
        
        Returns: @("DelegatedWork", "Application")

    .EXAMPLE
        Get-LeastPrivilegeScheme -PathValue ""
        
        Returns: @()

    .NOTES
        This is an internal function not exported from the module. It's called by
        Build-PermissionsIndex during the permissions data processing phase.
        
        The regex pattern matches "least=" followed by one or more scheme names
        separated by commas, stopping at the next comma or whitespace to handle
        cases where multiple metadata attributes are present.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string]$PathValue
    )

    if ($PathValue -match 'least=([^,\s]+(?:,[^,\s]+)*)') {
        return $matches[1] -split ','
    }

    # Default: no schemes marked as least privileged
    return @()
}
