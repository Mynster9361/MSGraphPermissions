BeforeAll {
    # Import the module
    $modulePath = "$PSScriptRoot\..\..\MSGraphPermissions\MSGraphPermissions.psd1"
    Import-Module $modulePath -Force
    
    # Initialize permissions cache once for all tests
    Initialize-GraphPermissions
}

Describe "Find-GraphPath" {
    
    Context "Wildcard Pattern Matching" {
        It "Finds paths with asterisk wildcard" {
            $result = Find-GraphPath -Pattern "*messages*"
            
            $result | Should -Not -BeNullOrEmpty
            ($result | Measure-Object).Count | Should -BeGreaterThan 1
            $result.Path | Should -Contain "/me/messages"
        }
        
        It "Finds paths with leading wildcard" {
            $result = Find-GraphPath -Pattern "*/messages"
            
            $result | Should -Not -BeNullOrEmpty
            $result.Path | Where-Object { $_ -like "*/messages" } | Should -Not -BeNullOrEmpty
        }
        
        It "Finds paths with trailing wildcard" {
            $result = Find-GraphPath -Pattern "/me/*"
            
            $result | Should -Not -BeNullOrEmpty
            ($result | Measure-Object).Count | Should -BeGreaterThan 10
            $result.Path | Should -Contain "/me/messages"
        }
        
        It "Supports question mark wildcard for single character" {
            $result = Find-GraphPath -Pattern "/m?"
            
            $result | Should -Not -BeNullOrEmpty
            $result.Path | Should -Contain "/me"
        }
        
        It "Performs case-insensitive pattern matching" {
            $result1 = Find-GraphPath -Pattern "*messages*"
            $result2 = Find-GraphPath -Pattern "*MESSAGES*"
            
            ($result1 | Measure-Object).Count | Should -Be ($result2 | Measure-Object).Count
        }
    }
    
    Context "Exact Pattern Matching" {
        It "Finds exact path without wildcards" {
            $result = Find-GraphPath -Pattern "/me/messages"
            
            $result | Should -Not -BeNullOrEmpty
            ($result | Measure-Object).Count | Should -Be 1
            $result.Path | Should -Be "/me/messages"
        }
    }
    
    Context "Domain-Specific Searches" {
        It "Finds calendar-related paths" {
            $result = Find-GraphPath -Pattern "*calendar*"
            
            $result | Should -Not -BeNullOrEmpty
            ($result | Measure-Object).Count | Should -BeGreaterThan 5
            $result.Path | Where-Object { $_ -like "*calendar*" } | Should -Not -BeNullOrEmpty
        }
        
        It "Finds user-related paths" {
            $result = Find-GraphPath -Pattern "/users/*"
            
            $result | Should -Not -BeNullOrEmpty
            ($result | Measure-Object).Count | Should -BeGreaterThan 20
        }
        
        It "Finds group-related paths" {
            $result = Find-GraphPath -Pattern "*/groups/*"
            
            $result | Should -Not -BeNullOrEmpty
        }
    }
    
    Context "Output Structure" {
        It "Returns objects with Path property" {
            $result = Find-GraphPath -Pattern "/me/messages"
            
            $result.Path | Should -Not -BeNullOrEmpty
            $result.Path | Should -BeOfType [string]
        }
        
        It "Returns objects with Methods property" {
            $result = Find-GraphPath -Pattern "/me/messages"
            
            $result.Methods | Should -Not -BeNullOrEmpty
            $result.Methods | Should -BeOfType [string]
        }
        
        It "Methods property contains comma-separated HTTP methods" {
            $result = Find-GraphPath -Pattern "/me/messages"
            
            $result.Methods | Should -Match "(GET|POST|PUT|PATCH|DELETE)"
        }
        
        It "Returns multiple methods for endpoints with multiple operations" {
            $result = Find-GraphPath -Pattern "/me/messages"
            
            $result.Methods | Should -Match "GET"
            $result.Methods | Should -Match "POST"
        }
    }
    
    Context "Edge Cases" {
        It "Returns empty for non-existent pattern" {
            $result = Find-GraphPath -Pattern "/completely/invalid/path/that/does/not/exist/xyz123"
            
            $result | Should -BeNullOrEmpty
        }
        
        It "Handles very broad patterns" {
            $result = Find-GraphPath -Pattern "*"
            
            $result | Should -Not -BeNullOrEmpty
            ($result | Measure-Object).Count | Should -BeGreaterThan 100
        }
        
        It "Handles patterns with special characters" {
            $result = Find-GraphPath -Pattern "/users/{id}"
            
            $result | Should -Not -BeNullOrEmpty
        }
    }
    
    Context "Result Filtering" {
        It "Can be filtered with Where-Object" {
            $result = Find-GraphPath -Pattern "/me/*" | Where-Object { $_.Methods -match "POST" }
            
            $result | Should -Not -BeNullOrEmpty
            $result | ForEach-Object { $_.Methods | Should -Match "POST" }
        }
        
        It "Can be limited with Select-Object" {
            $result = Find-GraphPath -Pattern "/me/*" | Select-Object -First 5
            
            ($result | Measure-Object).Count | Should -Be 5
        }
    }
    
    Context "Cache Interaction" {
        It "Works with initialized cache" {
            # Cache is already initialized in BeforeAll
            $result = Find-GraphPath -Pattern "/me"
            $result | Should -Not -BeNullOrEmpty
        }
        
        It "Returns consistent results across multiple calls" {
            $result1 = Find-GraphPath -Pattern "*messages*"
            $result2 = Find-GraphPath -Pattern "*messages*"
            
            ($result1 | Measure-Object).Count | Should -Be ($result2 | Measure-Object).Count
        }
    }
    
    Context "Common Use Cases" {
        It "Discovers API surface for a feature area" {
            $result = Find-GraphPath -Pattern "*mail*"
            
            $result | Should -Not -BeNullOrEmpty
            ($result | Measure-Object).Count | Should -BeGreaterThan 10
        }
        
        It "Lists all endpoints under a root path" {
            $result = Find-GraphPath -Pattern "/me/*"
            
            $result | Should -Not -BeNullOrEmpty
            $result.Path | ForEach-Object { $_ | Should -Match "^/me/" }
        }
    }
}
