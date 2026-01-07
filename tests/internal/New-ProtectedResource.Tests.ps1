BeforeAll {
    # Import the module to access internal functions
    $modulePath = "$PSScriptRoot\..\..\MSGraphPermissions\MSGraphPermissions.psd1"
    Import-Module $modulePath -Force
    
    # Get internal function
    $internalFunction = Get-Command -Name 'New-ProtectedResource' -Module MSGraphPermissions -ErrorAction SilentlyContinue
    
    if (-not $internalFunction) {
        # Import the internal function directly for testing
        . "$PSScriptRoot\..\..\MSGraphPermissions\internal\functions\New-ProtectedResource.ps1"
    }
}

Describe "New-ProtectedResource" {
    
    Context "Basic Object Creation" {
        It "Creates resource object with required properties" {
            $resource = New-ProtectedResource -Path "/me/messages"
            
            $resource | Should -Not -BeNullOrEmpty
            $resource.Path | Should -Be "/me/messages"
            $resource.Methods | Should -Not -BeNullOrEmpty
        }
        
        It "Sets Path property correctly" {
            $resource = New-ProtectedResource -Path "/users/{id}"
            
            $resource.Path | Should -Be "/users/{id}"
        }
        
        It "Initializes Methods as empty hashtable" {
            $resource = New-ProtectedResource -Path "/me"
            
            $resource.Methods | Should -BeOfType [hashtable]
            $resource.Methods.Count | Should -Be 0
        }
    }
    
    Context "Path Variations" {
        It "Handles various path formats" {
            $simplePath = New-ProtectedResource -Path "/me"
            $withPlaceholder = New-ProtectedResource -Path "/users/{id}/messages"
            $nested = New-ProtectedResource -Path "/me/mailfolders/{id}/messages"
            
            $simplePath.Path | Should -Be "/me"
            $withPlaceholder.Path | Should -Be "/users/{id}/messages"
            $nested.Path | Should -Be "/me/mailfolders/{id}/messages"
        }
    }
    
    Context "Object Type" {
        It "Returns PSCustomObject" {
            $resource = New-ProtectedResource -Path "/me"
            
            $resource | Should -BeOfType [PSCustomObject]
        }
        
        It "Has custom type name" {
            $resource = New-ProtectedResource -Path "/me"
            
            $resource.PSObject.TypeNames | Should -Contain "GraphPermissions.ProtectedResource"
        }
    }
    
    Context "Methods Hashtable Structure" {
        It "Methods property can be populated" {
            $resource = New-ProtectedResource -Path "/me/messages"
            $resource.Methods["GET"] = @{}
            
            $resource.Methods.ContainsKey("GET") | Should -Be $true
        }
        
        It "Supports nested structure for methods" {
            $resource = New-ProtectedResource -Path "/me/messages"
            $resource.Methods["GET"] = @{
                "DelegatedWork" = @()
            }
            
            $resource.Methods["GET"].ContainsKey("DelegatedWork") | Should -Be $true
        }
    }
    
    Context "Real-World Scenarios" {
        It "Creates resources for various endpoint types" {
            $userEndpoint = New-ProtectedResource -Path "/me/messages"
            $adminEndpoint = New-ProtectedResource -Path "/users/{id}"
            $groupEndpoint = New-ProtectedResource -Path "/groups/{id}/members"
            
            $userEndpoint.Path | Should -Be "/me/messages"
            $adminEndpoint.Path | Should -Be "/users/{id}"
            $groupEndpoint.Path | Should -Be "/groups/{id}/members"
            $userEndpoint.Methods | Should -Not -BeNullOrEmpty
        }
    }
}
