function New-ProtectedResource {
    <#
    .SYNOPSIS
        Creates a new ProtectedResource object representing a Graph API endpoint.

    .DESCRIPTION
        Internal factory function that creates a standardized PSCustomObject representing
        a Microsoft Graph API resource (endpoint). The resource object serves as a container
        for organizing all permissions associated with an API path.
        
        The Methods property is initialized as an empty hashtable that will be populated
        with nested structures: Method -> Scheme -> Claims during the index building process.
        
        The object includes a custom type name (GraphPermissions.ProtectedResource) for
        type identification and potential future formatting customization.

    .PARAMETER Path
        The normalized (lowercase) API path for this resource (e.g., "/me/messages", "/users/{id}").

    .OUTPUTS
        PSCustomObject
        Returns a resource object with properties: Path, Methods (empty hashtable), and PSTypeName.

    .EXAMPLE
        New-ProtectedResource -Path '/me/messages'
        
        Creates a new resource container for the /me/messages endpoint.

    .NOTES
        This is an internal function not exported from the module. It's used by
        Build-PermissionsIndex to create resource containers as API paths are discovered
        in the permissions data.
    #>
    param([string]$Path)
    
    return [PSCustomObject]@{
        Path       = $Path
        Methods    = @{}
        PSTypeName = 'GraphPermissions.ProtectedResource'
    }
}
