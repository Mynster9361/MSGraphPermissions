BeforeAll {
    # Import the module to access internal functions
    $modulePath = "$PSScriptRoot\..\..\MSGraphPermissions\MSGraphPermissions.psd1"
    Import-Module $modulePath -Force
    
    # Get internal function
    $internalFunction = Get-Command -Name 'Get-LeastPrivilegeScheme' -Module MSGraphPermissions -ErrorAction SilentlyContinue
    
    if (-not $internalFunction) {
        # Import the internal function directly for testing
        . "$PSScriptRoot\..\..\MSGraphPermissions\internal\functions\Get-LeastPrivilegeSchemes.ps1"
    }
}

Describe "Get-LeastPrivilegeScheme" {
    
    Context "Single Scheme Extraction" {
        It "Extracts single scheme" {
            $delegatedWork = Get-LeastPrivilegeScheme -PathValue "least=DelegatedWork"
            $application = Get-LeastPrivilegeScheme -PathValue "least=Application"
            $delegatedPersonal = Get-LeastPrivilegeScheme -PathValue "least=DelegatedPersonal"
            
            $delegatedWork.Count | Should -Be 1
            $application.Count | Should -Be 1
            $delegatedPersonal.Count | Should -Be 1
            $delegatedWork[0] | Should -Be "DelegatedWork"
            $application[0] | Should -Be "Application"
            $delegatedPersonal[0] | Should -Be "DelegatedPersonal"
        }
    }
    
    Context "Multiple Schemes Extraction" {
        It "Extracts two comma-separated schemes" {
            $result = Get-LeastPrivilegeScheme -PathValue "least=DelegatedWork,Application"
            
            $result | Should -Not -BeNullOrEmpty
            $result.Count | Should -Be 2
            $result | Should -Contain "DelegatedWork"
            $result | Should -Contain "Application"
        }
        
        It "Extracts three schemes" {
            $result = Get-LeastPrivilegeScheme -PathValue "least=DelegatedWork,DelegatedPersonal,Application"
            
            $result.Count | Should -Be 3
            $result | Should -Contain "DelegatedWork"
            $result | Should -Contain "DelegatedPersonal"
            $result | Should -Contain "Application"
        }
        
        It "Preserves scheme order" {
            $result = Get-LeastPrivilegeScheme -PathValue "least=Application,DelegatedWork"
            
            $result[0] | Should -Be "Application"
            $result[1] | Should -Be "DelegatedWork"
        }
    }
    
    Context "No Metadata Cases" {
        It "Returns empty array when no least= metadata found" {
            $emptyString = Get-LeastPrivilegeScheme -PathValue ""
            $otherMetadata = Get-LeastPrivilegeScheme -PathValue "someOtherMetadata=value"
            $pathWithoutMetadata = Get-LeastPrivilegeScheme -PathValue "/users/{id}/messages"
            
            $emptyString.Count | Should -Be 0
            $otherMetadata.Count | Should -Be 0
            $pathWithoutMetadata.Count | Should -Be 0
        }
    }
    
    Context "Complex Metadata Strings" {
        It "Extracts least= from string with multiple metadata fields" {
            $result = Get-LeastPrivilegeScheme -PathValue "least=DelegatedWork,alsoRequires=User.Read"
            
            $result.Count | Should -Be 1
            $result[0] | Should -Be "DelegatedWork"
        }
        
        It "Handles least= at end of string" {
            $result = Get-LeastPrivilegeScheme -PathValue "someData=value least=Application"
            
            $result.Count | Should -Be 1
            $result[0] | Should -Be "Application"
        }
        
        It "Handles least= in middle of complex metadata" {
            $result = Get-LeastPrivilegeScheme -PathValue "data1=value1 least=DelegatedWork,Application data2=value2"
            
            $result.Count | Should -Be 2
            $result | Should -Contain "DelegatedWork"
            $result | Should -Contain "Application"
        }
    }
    
    Context "Return Type" {
        It "Returns array of strings" {
            $result = Get-LeastPrivilegeScheme -PathValue "least=DelegatedWork,Application"
            
            $result | Should -BeOfType [array]
            $result | ForEach-Object { $_ | Should -BeOfType [string] }
        }
    }
    
    Context "Edge Cases" {
        It "Handles whitespace boundaries and partial matches correctly" {
            $withSpace = Get-LeastPrivilegeScheme -PathValue "least=DelegatedWork other=value"
            $partialMatch = Get-LeastPrivilegeScheme -PathValue "atleast=DelegatedWork"
            
            $withSpace.Count | Should -Be 1
            $withSpace[0] | Should -Be "DelegatedWork"
            $partialMatch.Count | Should -Be 0
        }
        
        It "Returns consistent results" {
            $result1 = Get-LeastPrivilegeScheme -PathValue "least=DelegatedWork,Application"
            $result2 = Get-LeastPrivilegeScheme -PathValue "least=DelegatedWork,Application"
            
            $result1.Count | Should -Be $result2.Count
            $result1[0] | Should -Be $result2[0]
            $result1[1] | Should -Be $result2[1]
        }
    }
}
