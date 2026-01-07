BeforeAll {
    # Import the module
    $modulePath = "$PSScriptRoot\..\..\MSGraphPermissions\MSGraphPermissions.psd1"
    Import-Module $modulePath -Force
    
    # Initialize permissions cache once for all tests
    Initialize-GraphPermissions
}

Describe "Get-GraphPermissions" {
    
    Context "Valid Input - Basic Functionality" {
        It "Returns all permissions for specific path, method, and scheme" {
            $result = Get-GraphPermissions -Path "/me/messages" -Method GET -Scheme DelegatedWork
            
            $result | Should -Not -BeNullOrEmpty
            ($result | Measure-Object).Count | Should -BeGreaterThan 1
            $result[0].Path | Should -Be "/me/messages"
            $result[0].Method | Should -Be "GET"
            $result[0].Scheme | Should -Be "DelegatedWork"
        }
        
        It "Returns permissions for multiple schemes when scheme not specified" {
            $result = Get-GraphPermissions -Path "/me/messages" -Method GET
            
            $result | Should -Not -BeNullOrEmpty
            $result.Scheme | Should -Contain "DelegatedWork"
            $result.Scheme | Should -Contain "Application"
        }
        
        It "Returns permissions for multiple methods when method not specified" {
            $result = Get-GraphPermissions -Path "/me/messages"
            
            $result | Should -Not -BeNullOrEmpty
            $result.Method | Should -Contain "GET"
            $result.Method | Should -Contain "POST"
        }
        
        It "Includes IsLeastPrivileged indicator" {
            $result = Get-GraphPermissions -Path "/me/messages" -Method GET -Scheme DelegatedWork
            
            $result | Should -Not -BeNullOrEmpty
            $result[0].PSObject.Properties.Name | Should -Contain "IsLeastPrivileged"
            $result[0].IsLeastPrivileged | Should -BeOfType [bool]
        }
        
        It "Returns both least privileged and higher permissions" {
            $result = Get-GraphPermissions -Path "/me/messages" -Method GET -Scheme DelegatedWork
            
            $leastPrivileged = $result | Where-Object { $_.IsLeastPrivileged -eq $true }
            $higherPrivileged = $result | Where-Object { $_.IsLeastPrivileged -eq $false }
            
            $leastPrivileged | Should -Not -BeNullOrEmpty
            $higherPrivileged | Should -Not -BeNullOrEmpty
        }
    }
    
    Context "Pipeline Input" {
        It "Accepts path from pipeline" {
            $result = "/me/messages" | Get-GraphPermissions -Method GET -Scheme DelegatedWork
            
            $result | Should -Not -BeNullOrEmpty
            $result[0].Path | Should -Be "/me/messages"
        }
        
        It "Processes multiple paths from pipeline" {
            $paths = @("/me/messages", "/me/authentication/methods")
            $result = $paths | Get-GraphPermissions -Method GET -Scheme DelegatedWork
            
            $result | Should -Not -BeNullOrEmpty
            $result.Path | Should -Contain "/me/messages"
            $result.Path | Should -Contain "/me/authentication/methods"
        }
    }
    
    Context "Output Structure" {
        It "Returns objects with required properties" {
            $result = Get-GraphPermissions -Path "/me" -Method GET -Scheme DelegatedWork | Select-Object -First 1
            
            $result.PSObject.Properties.Name | Should -Contain "Path"
            $result.PSObject.Properties.Name | Should -Contain "Method"
            $result.PSObject.Properties.Name | Should -Contain "Scheme"
            $result.PSObject.Properties.Name | Should -Contain "Permission"
            $result.PSObject.Properties.Name | Should -Contain "IsLeastPrivileged"
        }
        
        It "Includes AlsoRequires property for dependencies" {
            $result = Get-GraphPermissions -Path "/me" -Method GET -Scheme DelegatedWork
            
            $result[0].PSObject.Properties.Name | Should -Contain "AlsoRequires"
        }
    }
    
    Context "Comparison with Find-GraphLeastPrivilege" {
        It "Returns more permissions than Find-GraphLeastPrivilege" {
            $allPerms = Get-GraphPermissions -Path "/me" -Method GET -Scheme DelegatedWork
            $leastPerms = Find-GraphLeastPrivilege -Path "/me" -Method GET -Scheme DelegatedWork
            
            ($allPerms | Measure-Object).Count | Should -BeGreaterOrEqual ($leastPerms | Measure-Object).Count
        }
        
        It "Least privileged results match Find-GraphLeastPrivilege" {
            $allPerms = Get-GraphPermissions -Path "/me/messages" -Method GET -Scheme DelegatedWork
            $leastFromAll = ($allPerms | Where-Object { $_.IsLeastPrivileged }).Permission
            
            $leastPerms = Find-GraphLeastPrivilege -Path "/me/messages" -Method GET -Scheme DelegatedWork
            
            $leastPerms.Permission | Should -BeIn $leastFromAll
        }
    }
    
    Context "Filtering and Analysis" {
        It "Can filter to only least privileged permissions" {
            $result = Get-GraphPermissions -Path "/me/messages" -Method GET -Scheme DelegatedWork |
                Where-Object { $_.IsLeastPrivileged }
            
            $result | Should -Not -BeNullOrEmpty
            $result | ForEach-Object { $_.IsLeastPrivileged | Should -Be $true }
        }
        
        It "Can filter to only higher privileged permissions" {
            $result = Get-GraphPermissions -Path "/me/messages" -Method GET -Scheme DelegatedWork |
                Where-Object { -not $_.IsLeastPrivileged }
            
            $result | Should -Not -BeNullOrEmpty
            $result | ForEach-Object { $_.IsLeastPrivileged | Should -Be $false }
        }
        
        It "Can group permissions by scheme" {
            $result = Get-GraphPermissions -Path "/me/messages" -Method GET |
                Group-Object Scheme
            
            $result | Should -Not -BeNullOrEmpty
            $result.Name | Should -Contain "DelegatedWork"
        }
    }
    
    Context "Edge Cases" {
        It "Warns when path is not found" {
            $result = Get-GraphPermissions -Path "/invalid/path/xyz123" -Method GET -WarningVariable warnings -WarningAction SilentlyContinue
            
            $result | Should -BeNullOrEmpty
            $warnings | Should -Not -BeNullOrEmpty
        }
        
        It "Handles case-insensitive path matching" {
            $result1 = Get-GraphPermissions -Path "/me/messages" -Method GET -Scheme DelegatedWork
            $result2 = Get-GraphPermissions -Path "/ME/MESSAGES" -Method GET -Scheme DelegatedWork
            
            ($result1 | Measure-Object).Count | Should -Be ($result2 | Measure-Object).Count
        }
    }
    
    Context "HTTP Methods" {
        It "Returns permissions for GET" {
            $result = Get-GraphPermissions -Path "/me" -Method GET -Scheme DelegatedWork
            $result | Should -Not -BeNullOrEmpty
            $result[0].Method | Should -Be "GET"
        }
        
        It "Returns permissions for POST" {
            $result = Get-GraphPermissions -Path "/me/messages" -Method POST -Scheme DelegatedWork
            $result | Should -Not -BeNullOrEmpty
            $result[0].Method | Should -Be "POST"
        }
        
        It "Returns permissions for PATCH" {
            $result = Get-GraphPermissions -Path "/me/profile/account/{id}" -Method PATCH -Scheme DelegatedWork
            $result | Should -Not -BeNullOrEmpty
            $result[0].Method | Should -Be "PATCH"
        }
    }
    
    Context "Authentication Schemes" {
        It "Returns Application permissions" {
            $result = Get-GraphPermissions -Path "/users" -Method GET -Scheme Application
            $result | Should -Not -BeNullOrEmpty
            $result[0].Scheme | Should -Be "Application"
        }
        
        It "Returns DelegatedWork permissions" {
            $result = Get-GraphPermissions -Path "/me" -Method GET -Scheme DelegatedWork
            $result | Should -Not -BeNullOrEmpty
            $result[0].Scheme | Should -Be "DelegatedWork"
        }
    }
    
    Context "Cache Interaction" {
        It "Works with initialized cache" {
            # Cache is already initialized in BeforeAll
            $result = Get-GraphPermissions -Path "/me" -Method GET -Scheme DelegatedWork
            $result | Should -Not -BeNullOrEmpty
        }
        
        It "Returns consistent results across multiple calls" {
            $result1 = Get-GraphPermissions -Path "/me/messages" -Method GET -Scheme DelegatedWork
            $result2 = Get-GraphPermissions -Path "/me/messages" -Method GET -Scheme DelegatedWork
            
            ($result1 | Measure-Object).Count | Should -Be ($result2 | Measure-Object).Count
        }
    }
}
