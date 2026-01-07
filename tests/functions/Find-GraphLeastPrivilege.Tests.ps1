BeforeAll {
    # Import the module
    $modulePath = "$PSScriptRoot\..\..\MSGraphPermissions\MSGraphPermissions.psd1"
    Import-Module $modulePath -Force
    
    # Initialize permissions cache once for all tests
    Initialize-GraphPermissions
}

Describe "Find-GraphLeastPrivilege" {
    
    Context "Valid Input - Basic Functionality" {
        It "Returns least privileged permission for specific path, method, and scheme" {
            $result = Find-GraphLeastPrivilege -Path "/me/messages" -Method GET -Scheme DelegatedWork
            
            $result | Should -Not -BeNullOrEmpty
            $result.Path | Should -Be "/me/messages"
            $result.Method | Should -Be "GET"
            $result.Scheme | Should -Be "DelegatedWork"
            $result.Permission | Should -Not -BeNullOrEmpty
        }
        
        It "Returns permissions for multiple schemes when scheme not specified" {
            $result = Find-GraphLeastPrivilege -Path "/me/messages" -Method GET
            
            $result | Should -Not -BeNullOrEmpty
            ($result | Measure-Object).Count | Should -BeGreaterThan 1
            $result.Scheme | Should -Contain "DelegatedWork"
            $result.Scheme | Should -Contain "Application"
        }
        
        It "Returns permissions for multiple methods when method not specified" {
            $result = Find-GraphLeastPrivilege -Path "/me/messages"
            
            $result | Should -Not -BeNullOrEmpty
            ($result | Measure-Object).Count | Should -BeGreaterThan 1
            $result.Method | Should -Contain "GET"
            $result.Method | Should -Contain "POST"
        }
        
        It "Handles path with placeholder segments" {
            $result = Find-GraphLeastPrivilege -Path "/users/{id}/messages" -Method GET -Scheme Application
            
            $result | Should -Not -BeNullOrEmpty
            $result.Path | Should -Be "/users/{id}/messages"
            $result.Permission | Should -Not -BeNullOrEmpty
        }
        
        It "Performs case-insensitive path matching" {
            $result1 = Find-GraphLeastPrivilege -Path "/me/messages" -Method GET -Scheme DelegatedWork
            $result2 = Find-GraphLeastPrivilege -Path "/ME/MESSAGES" -Method GET -Scheme DelegatedWork
            
            $result1.Permission | Should -Be $result2.Permission
        }
    }
    
    Context "Pipeline Input" {
        It "Accepts path from pipeline" {
            $result = "/me/messages" | Find-GraphLeastPrivilege -Method GET -Scheme DelegatedWork
            
            $result | Should -Not -BeNullOrEmpty
            $result.Path | Should -Be "/me/messages"
        }
        
        It "Processes multiple paths from pipeline" {
            $paths = @("/me/messages", "/me/authentication/methods")
            $result = $paths | Find-GraphLeastPrivilege -Method GET -Scheme DelegatedWork
            
            ($result | Measure-Object).Count | Should -BeGreaterOrEqual 2
            $result.Path | Should -Contain "/me/messages"
            $result.Path | Should -Contain "/me/authentication/methods"
        }
    }
    
    Context "Edge Cases" {
        It "Warns when path is not found" {
            $result = Find-GraphLeastPrivilege -Path "/invalid/path/that/does/not/exist" -Method GET -WarningVariable warnings -WarningAction SilentlyContinue
            
            $result | Should -BeNullOrEmpty
            $warnings | Should -Not -BeNullOrEmpty
        }
        
        It "Handles empty results gracefully" {
            $result = Find-GraphLeastPrivilege -Path "/invalid/path" -Method GET -Scheme Application -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
            
            $result | Should -BeNullOrEmpty
        }
    }
    
    Context "HTTP Methods" {
        It "Supports GET method" {
            $result = Find-GraphLeastPrivilege -Path "/me" -Method GET -Scheme DelegatedWork
            $result.Method | Should -Be "GET"
        }
        
        It "Supports POST method" {
            $result = Find-GraphLeastPrivilege -Path "/me/messages" -Method POST -Scheme DelegatedWork
            $result | Should -Not -BeNullOrEmpty
            $result.Method | Should -Be "POST"
        }
        
        It "Supports PATCH method" {
            $result = Find-GraphLeastPrivilege -Path "/me/profile/account/{id}" -Method PATCH -Scheme DelegatedWork
            $result | Should -Not -BeNullOrEmpty
            $result.Method | Should -Be "PATCH"
        }
    }
    
    Context "Authentication Schemes" {
        It "Supports Application scheme" {
            $result = Find-GraphLeastPrivilege -Path "/users" -Method GET -Scheme Application
            $result.Scheme | Should -Be "Application"
        }
        
        It "Supports DelegatedWork scheme" {
            $result = Find-GraphLeastPrivilege -Path "/me" -Method GET -Scheme DelegatedWork
            $result.Scheme | Should -Be "DelegatedWork"
        }
        
        It "Supports DelegatedPersonal scheme" {
            $result = Find-GraphLeastPrivilege -Path "/me" -Method GET -Scheme DelegatedPersonal
            $result.Scheme | Should -Be "DelegatedPersonal"
        }
    }
    
    Context "Output Structure" {
        It "Returns objects with correct properties" {
            $result = Find-GraphLeastPrivilege -Path "/me" -Method GET -Scheme DelegatedWork
            
            $result.PSObject.Properties.Name | Should -Contain "Path"
            $result.PSObject.Properties.Name | Should -Contain "Method"
            $result.PSObject.Properties.Name | Should -Contain "Scheme"
            $result.PSObject.Properties.Name | Should -Contain "Permission"
        }
        
        It "Returns only least privileged permissions" {
            $allPerms = Get-GraphPermissions -Path "/me" -Method GET -Scheme DelegatedWork
            $leastPerms = Find-GraphLeastPrivilege -Path "/me" -Method GET -Scheme DelegatedWork
            
            ($leastPerms | Measure-Object).Count | Should -BeLessOrEqual ($allPerms | Measure-Object).Count
        }
    }
    
    Context "Cache Interaction" {
        It "Works with initialized cache" {
            # Cache is already initialized in BeforeAll
            $result = Find-GraphLeastPrivilege -Path "/me" -Method GET -Scheme DelegatedWork
            $result | Should -Not -BeNullOrEmpty
        }
        
        It "Returns consistent results across multiple calls" {
            $result1 = Find-GraphLeastPrivilege -Path "/me/messages" -Method GET -Scheme DelegatedWork
            $result2 = Find-GraphLeastPrivilege -Path "/me/messages" -Method GET -Scheme DelegatedWork
            
            $result1.Permission | Should -Be $result2.Permission
        }
    }
}