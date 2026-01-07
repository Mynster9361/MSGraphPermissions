function Find-GraphLeastPrivilege {
    <#
    .SYNOPSIS
        Finds the least privileged permission(s) required for a Microsoft Graph API endpoint.

    .DESCRIPTION
        The Find-GraphLeastPrivilege function identifies the minimal permissions needed to access
        a specific Microsoft Graph API endpoint. It queries the permissions cache (automatically
        initialized if needed) and returns only those permissions explicitly marked as least
        privileged in the Microsoft Graph permissions metadata.

        This function helps implement the principle of least privilege by identifying the minimum
        permission scope required for your application to function.

    .PARAMETER Path
        The Microsoft Graph API path to query. Path matching is case-insensitive.
        Use {id} placeholders for dynamic segments (e.g., "/users/{id}/messages").
        
        This parameter accepts pipeline input, allowing you to query multiple paths at once.

    .PARAMETER Method
        The HTTP method to filter by. Valid values are: GET, POST, PUT, PATCH, DELETE
        
        If not specified, returns least privileged permissions for all available methods on the path.

    .PARAMETER Scheme
        The authentication scheme to filter by. Valid values are:
        - DelegatedWork: Delegated permissions for work/school accounts
        - DelegatedPersonal: Delegated permissions for personal Microsoft accounts
        - Application: Application permissions (app-only access)

        If not specified, returns least privileged permissions for all available schemes.

    .EXAMPLE
        ```
        Find-GraphLeastPrivilege -Path "/me/messages" -Method GET -Scheme DelegatedWork
        
        Returns the least privileged permission needed to read the current user's messages
        using delegated work/school account permissions.
        
        Output:
        Path         Method Scheme        Permission
        ----         ------ ------        ----------
        /me/messages GET    DelegatedWork Mail.ReadBasic
        ```

    .EXAMPLE
        ```
        Find-GraphLeastPrivilege -Path "/users/{id}/messages" -Method GET
        
        Returns the least privileged permissions for reading a user's messages across all
        authentication schemes.
        
        Output:
        Path                 Method Scheme            Permission
        ----                 ------ ------            ----------
        /users/{id}/messages GET    Application       Mail.ReadBasic.All
        /users/{id}/messages GET    DelegatedWork     Mail.ReadBasic
        /users/{id}/messages GET    DelegatedPersonal Mail.ReadBasic
        ```

    .EXAMPLE
        ```
        Find-GraphLeastPrivilege -Path "/me/messages"
        
        Returns least privileged permissions for all HTTP methods and schemes available
        for the /me/messages endpoint.
        ```

    .EXAMPLE
        ```
        "/me/messages", "/me/calendar/events" | Find-GraphLeastPrivilege -Method GET -Scheme DelegatedWork
        
        Demonstrates pipeline usage to query multiple endpoints at once. Returns the least
        privileged delegated work permission for reading messages and calendar events.
        
        Output:
        Path                Method Scheme        Permission
        ----                ------ ------        ----------
        /me/messages        GET    DelegatedWork Mail.ReadBasic
        /me/calendar/events GET    DelegatedWork Calendars.ReadBasic
        ```

    .EXAMPLE
        ```
        $paths = @("/users/{id}", "/groups/{id}", "/applications")
        $paths | Find-GraphLeastPrivilege -Method GET -Scheme Application | Select-Object Path, Permission
        
        Queries multiple paths and displays only the path and permission, useful for
        generating permission requirement documentation.
        ```

    .OUTPUTS
        PSCustomObject
        Returns objects with the following properties:
        - Path: The API path queried
        - Method: The HTTP method
        - Scheme: The authentication scheme
        - Permission: The least privileged permission name

    .NOTES
        - If a path is not found, a warning is displayed and no output is returned for that path
        - If no least privileged permissions are defined for the specified method/scheme combination,
          a warning is displayed
        - The permissions cache is automatically initialized on first use by calling
          Initialize-GraphPermissions
        - To refresh the permissions data, run: Initialize-GraphPermissions -Force
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('^/.*')]
        [string]$Path,

        [ValidateSet('GET', 'POST', 'PUT', 'PATCH', 'DELETE')]
        [string]$Method,

        [ValidateSet('DelegatedWork', 'DelegatedPersonal', 'Application')]
        [string]$Scheme
    )

    begin {
        if (-not $script:PermissionsCache) {
            Initialize-GraphPermissions
        }
    }

    process {
        $normalizedPath = $Path.ToLowerInvariant()

        if (-not $script:PermissionsCache.ContainsKey($normalizedPath)) {
            Write-Warning "Path '$Path' not found in permissions data"
            return
        }

        $resource = $script:PermissionsCache[$normalizedPath]
        $leastPrivileged = Get-ResourceLeastPrivileged -Resource $resource -Method $Method -Scheme $Scheme

        if ($leastPrivileged.Count -eq 0) {
            Write-Warning "No least privileged permissions found for path '$Path'"
            return
        }

        foreach ($m in $leastPrivileged.Keys) {
            foreach ($s in $leastPrivileged[$m].Keys) {
                foreach ($perm in $leastPrivileged[$m][$s]) {
                    [PSCustomObject]@{
                        Path       = $Path
                        Method     = $m
                        Scheme     = $s
                        Permission = $perm
                    }
                }
            }
        }
    }
}
