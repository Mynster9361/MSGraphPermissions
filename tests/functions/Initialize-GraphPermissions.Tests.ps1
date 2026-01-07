BeforeAll {
    # Import the module
    $modulePath = "$PSScriptRoot\..\..\MSGraphPermissions\MSGraphPermissions.psd1"
    Import-Module $modulePath -Force
}

Describe "Initialize-GraphPermissions" {
    
    Context "First Initialization" {
        It "Does not throw errors during initialization" {
            { Initialize-GraphPermissions } | Should -Not -Throw
        }
    }
    
    Context "Subsequent Calls Without Force" {
        BeforeAll {
            Initialize-GraphPermissions
        }
        
        It "Uses cached data on subsequent calls" {
            $firstCount = $script:PermissionsCache.Count
            
            Initialize-GraphPermissions
            
            $script:PermissionsCache.Count | Should -Be $firstCount
        }
    }
    
    Context "Force Parameter" {
        BeforeAll {
            Initialize-GraphPermissions
        }
        
        It "Forces re-download when Force is specified" {
            { Initialize-GraphPermissions -Force } | Should -Not -Throw
        }
    }
       
    Context "Verbose Output" {
        It "Provides verbose output when requested" {
            $verboseOutput = Initialize-GraphPermissions -Force -Verbose 4>&1
            
            $verboseOutput | Should -Not -BeNullOrEmpty
        }
        
        It "Shows cache usage message when using cached data" {
            Initialize-GraphPermissions  # Ensure cache exists
            $verboseOutput = Initialize-GraphPermissions -Verbose 4>&1
            
            $verboseOutput | Where-Object { $_ -match "cached" } | Should -Not -BeNullOrEmpty
        }
        
        It "Shows download message when forcing refresh" {
            $verboseOutput = Initialize-GraphPermissions -Force -Verbose 4>&1
            
            $verboseOutput | Where-Object { $_ -match "Downloading|loaded" } | Should -Not -BeNullOrEmpty
        }
    }
    
    Context "Output Behavior" {
        It "Does not return output by default" {
            $result = Initialize-GraphPermissions
            
            $result | Should -BeNullOrEmpty
        }
    }
    
    Context "Integration with Other Functions" {
        It "Enables Find-GraphLeastPrivilege to work" {
            Initialize-GraphPermissions
            
            $result = Find-GraphLeastPrivilege -Path "/me" -Method GET -Scheme DelegatedWork
            $result | Should -Not -BeNullOrEmpty
        }
        
        It "Enables Find-GraphPath to work" {
            Initialize-GraphPermissions
            
            $result = Find-GraphPath -Pattern "/me"
            $result | Should -Not -BeNullOrEmpty
        }
        
        It "Enables Get-GraphPermissions to work" {
            Initialize-GraphPermissions
            
            $result = Get-GraphPermissions -Path "/me" -Method GET -Scheme DelegatedWork
            $result | Should -Not -BeNullOrEmpty
        }
    }
}
