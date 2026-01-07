function Find-GraphPath {
    <#
    .SYNOPSIS
        Searches for Microsoft Graph API paths matching a wildcard pattern.

    .DESCRIPTION
        The Find-GraphPath function searches through all available Microsoft Graph API paths
        in the permissions cache and returns those that match the specified wildcard pattern.
        This is useful for discovering available endpoints, exploring the API surface, or
        finding related endpoints by naming patterns.

        The function performs case-insensitive pattern matching using PowerShell's -like operator,
        supporting standard wildcards (* and ?).

    .PARAMETER Pattern
        A wildcard pattern to match against API paths. Pattern matching is case-insensitive.
        
        Supports PowerShell wildcard syntax:
        - * matches zero or more characters
        - ? matches exactly one character
        
        Examples:
        - "*messages*" finds all paths containing "messages"
        - "/me/*" finds all paths under /me
        - "/users/{id}/mail*" finds mail-related endpoints under users

    .EXAMPLE
        ```
        Find-GraphPath -Pattern "*messages*"
        
        Finds all API paths containing the word "messages" anywhere in the path.
        
        Output:
        Path                                    Methods
        ----                                    -------
        /me/messages                            POST, GET
        /users/{id}/messages                    POST, GET
        /me/mailfolders/{id}/messages           POST, GET
        /chats/{id}/messages                    POST, GET
        ```

    .EXAMPLE
        ```
        Find-GraphPath -Pattern "/me/*"
        
        Finds all API paths directly under the /me endpoint. Returns hundreds of paths
        showing all available operations for the current user context.
        ```

    .EXAMPLE
        ```
        Find-GraphPath -Pattern "*accessreviews*"
        
        Discovers all access review-related endpoints across the API.
        
        Output:
        Path                                                    Methods
        ----                                                    -------
        /accessreviews                                          POST, GET
        /accessreviews/{id}                                     DELETE, PATCH, GET
        /identitygovernance/accessreviews/definitions           POST, GET
        /identitygovernance/accessreviews/policy                PATCH, GET
        ```

    .EXAMPLE
        ```
        Find-GraphPath -Pattern "/users/{id}/mail*" | Format-Table -AutoSize
        
        Finds all mail-related endpoints for a specific user and formats the output
        as a compact table.
        ```

    .EXAMPLE
        ```
        $calendarPaths = Find-GraphPath -Pattern "*calendar*"
        $calendarPaths | Select-Object -First 10
        
        Finds all calendar-related paths and displays the first 10 results.
        ```

    .EXAMPLE
        ```
        Find-GraphPath -Pattern "/identitygovernance/lifecycleworkflows/workflows*" |
            Measure-Object | Select-Object -ExpandProperty Count
        
        Counts how many workflow-related endpoints exist under lifecycle workflows.
        ```

    .OUTPUTS
        PSCustomObject
        Returns objects with the following properties:
        - Path: The API path that matched the pattern
        - Methods: Comma-separated list of HTTP methods available for this path

    .NOTES
        - Pattern matching is case-insensitive
        - The permissions cache is automatically initialized on first use
        - To refresh the permissions data, run: Initialize-GraphPermissions -Force
        - Use wildcards strategically to narrow down results, as some patterns may
          return hundreds of paths (e.g., "/me/*" returns 1000+ paths)
        - The Methods property shows all available HTTP methods; use Find-GraphLeastPrivilege
          to determine required permissions for specific methods
    .LINK
        https://mynster9361.github.io/MSGraphPermissions/docs/MSGraphPermissions/Find-GraphPath.html
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Pattern
    )

    if (-not $script:PermissionsCache) {
        Initialize-GraphPermissions
    }

    $normalizedPattern = $Pattern.ToLowerInvariant()
    
    $script:PermissionsCache.Keys | Where-Object { $_ -like $normalizedPattern } | ForEach-Object {
        [PSCustomObject]@{
            Path    = $_
            Methods = ($script:PermissionsCache[$_].Methods.Keys -join ', ')
        }
    }
}
