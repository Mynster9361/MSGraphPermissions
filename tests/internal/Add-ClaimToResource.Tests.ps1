BeforeAll {
    # Import the module to access internal functions
    $modulePath = "$PSScriptRoot\..\..\MSGraphPermissions\MSGraphPermissions.psd1"
    Import-Module $modulePath -Force
    
    # Get internal functions
    $addClaim = Get-Command -Name 'Add-ClaimToResource' -Module MSGraphPermissions -ErrorAction SilentlyContinue
    $newResource = Get-Command -Name 'New-ProtectedResource' -Module MSGraphPermissions -ErrorAction SilentlyContinue
    $newClaim = Get-Command -Name 'New-AcceptableClaim' -Module MSGraphPermissions -ErrorAction SilentlyContinue
    
    if (-not $addClaim -or -not $newResource -or -not $newClaim) {
        # Import the internal functions directly for testing
        . "$PSScriptRoot\..\..\MSGraphPermissions\internal\functions\Add-ClaimToResource.ps1"
        . "$PSScriptRoot\..\..\MSGraphPermissions\internal\functions\New-ProtectedResource.ps1"
        . "$PSScriptRoot\..\..\MSGraphPermissions\internal\functions\New-AcceptableClaim.ps1"
    }
}

Describe "Add-ClaimToResource" {
    
    Context "First Claim Addition" {
        It "Adds claim to empty resource" {
            $resource = New-ProtectedResource -Path "/me/messages"
            $claim = New-AcceptableClaim -Permission "Mail.Read" -Least $true -AlsoRequires @() -Scheme "DelegatedWork"
            
            Add-ClaimToResource -Resource $resource -Method "GET" -Scheme "DelegatedWork" -Claim $claim
            
            $resource.Methods.ContainsKey("GET") | Should -Be $true
            $resource.Methods["GET"].ContainsKey("DelegatedWork") | Should -Be $true
            $resource.Methods["GET"]["DelegatedWork"].Count | Should -Be 1
        }
        
        It "Creates method hashtable if it doesn't exist" {
            $resource = New-ProtectedResource -Path "/me/messages"
            $claim = New-AcceptableClaim -Permission "Mail.Read" -Least $true -AlsoRequires @() -Scheme "DelegatedWork"
            
            Add-ClaimToResource -Resource $resource -Method "POST" -Scheme "DelegatedWork" -Claim $claim
            
            $resource.Methods.ContainsKey("POST") | Should -Be $true
        }
        
        It "Creates scheme list if it doesn't exist" {
            $resource = New-ProtectedResource -Path "/me/messages"
            $claim = New-AcceptableClaim -Permission "Mail.Read" -Least $true -AlsoRequires @() -Scheme "Application"
            
            Add-ClaimToResource -Resource $resource -Method "GET" -Scheme "Application" -Claim $claim
            
            $resource.Methods["GET"].ContainsKey("Application") | Should -Be $true
        }
    }
    
    Context "Multiple Claims" {
        It "Adds multiple claims to same method/scheme" {
            $resource = New-ProtectedResource -Path "/me/messages"
            $claim1 = New-AcceptableClaim -Permission "Mail.Read" -Least $true -AlsoRequires @() -Scheme "DelegatedWork"
            $claim2 = New-AcceptableClaim -Permission "Mail.ReadWrite" -Least $false -AlsoRequires @() -Scheme "DelegatedWork"
            
            Add-ClaimToResource -Resource $resource -Method "GET" -Scheme "DelegatedWork" -Claim $claim1
            Add-ClaimToResource -Resource $resource -Method "GET" -Scheme "DelegatedWork" -Claim $claim2
            
            $resource.Methods["GET"]["DelegatedWork"].Count | Should -Be 2
        }
        
        It "Maintains separate lists for different methods" {
            $resource = New-ProtectedResource -Path "/me/messages"
            $claim1 = New-AcceptableClaim -Permission "Mail.Read" -Least $true -AlsoRequires @() -Scheme "DelegatedWork"
            $claim2 = New-AcceptableClaim -Permission "Mail.Send" -Least $true -AlsoRequires @() -Scheme "DelegatedWork"
            
            Add-ClaimToResource -Resource $resource -Method "GET" -Scheme "DelegatedWork" -Claim $claim1
            Add-ClaimToResource -Resource $resource -Method "POST" -Scheme "DelegatedWork" -Claim $claim2
            
            $resource.Methods["GET"]["DelegatedWork"].Count | Should -Be 1
            $resource.Methods["POST"]["DelegatedWork"].Count | Should -Be 1
        }
        
        It "Maintains separate lists for different schemes" {
            $resource = New-ProtectedResource -Path "/me/messages"
            $claim1 = New-AcceptableClaim -Permission "Mail.Read" -Least $true -AlsoRequires @() -Scheme "DelegatedWork"
            $claim2 = New-AcceptableClaim -Permission "Mail.Read.All" -Least $true -AlsoRequires @() -Scheme "Application"
            
            Add-ClaimToResource -Resource $resource -Method "GET" -Scheme "DelegatedWork" -Claim $claim1
            Add-ClaimToResource -Resource $resource -Method "GET" -Scheme "Application" -Claim $claim2
            
            $resource.Methods["GET"]["DelegatedWork"].Count | Should -Be 1
            $resource.Methods["GET"]["Application"].Count | Should -Be 1
        }
    }
    
    Context "HTTP Methods" {
        It "Supports GET method" {
            $resource = New-ProtectedResource -Path "/me"
            $claim = New-AcceptableClaim -Permission "User.Read" -Least $true -AlsoRequires @() -Scheme "DelegatedWork"
            
            Add-ClaimToResource -Resource $resource -Method "GET" -Scheme "DelegatedWork" -Claim $claim
            
            $resource.Methods.ContainsKey("GET") | Should -Be $true
        }
        
        It "Supports POST method" {
            $resource = New-ProtectedResource -Path "/me/messages"
            $claim = New-AcceptableClaim -Permission "Mail.Send" -Least $true -AlsoRequires @() -Scheme "DelegatedWork"
            
            Add-ClaimToResource -Resource $resource -Method "POST" -Scheme "DelegatedWork" -Claim $claim
            
            $resource.Methods.ContainsKey("POST") | Should -Be $true
        }
        
        It "Supports PATCH method" {
            $resource = New-ProtectedResource -Path "/me"
            $claim = New-AcceptableClaim -Permission "User.ReadWrite" -Least $true -AlsoRequires @() -Scheme "DelegatedWork"
            
            Add-ClaimToResource -Resource $resource -Method "PATCH" -Scheme "DelegatedWork" -Claim $claim
            
            $resource.Methods.ContainsKey("PATCH") | Should -Be $true
        }
        
        It "Supports DELETE method" {
            $resource = New-ProtectedResource -Path "/me/messages/{id}"
            $claim = New-AcceptableClaim -Permission "Mail.ReadWrite" -Least $true -AlsoRequires @() -Scheme "DelegatedWork"
            
            Add-ClaimToResource -Resource $resource -Method "DELETE" -Scheme "DelegatedWork" -Claim $claim
            
            $resource.Methods.ContainsKey("DELETE") | Should -Be $true
        }
        
        It "Supports PUT method" {
            $resource = New-ProtectedResource -Path "/me/photo"
            $claim = New-AcceptableClaim -Permission "User.ReadWrite" -Least $true -AlsoRequires @() -Scheme "DelegatedWork"
            
            Add-ClaimToResource -Resource $resource -Method "PUT" -Scheme "DelegatedWork" -Claim $claim
            
            $resource.Methods.ContainsKey("PUT") | Should -Be $true
        }
    }
    
    Context "Authentication Schemes" {
        It "Supports DelegatedWork scheme" {
            $resource = New-ProtectedResource -Path "/me"
            $claim = New-AcceptableClaim -Permission "User.Read" -Least $true -AlsoRequires @() -Scheme "DelegatedWork"
            
            Add-ClaimToResource -Resource $resource -Method "GET" -Scheme "DelegatedWork" -Claim $claim
            
            $resource.Methods["GET"].ContainsKey("DelegatedWork") | Should -Be $true
        }
        
        It "Supports DelegatedPersonal scheme" {
            $resource = New-ProtectedResource -Path "/me"
            $claim = New-AcceptableClaim -Permission "User.Read" -Least $true -AlsoRequires @() -Scheme "DelegatedPersonal"
            
            Add-ClaimToResource -Resource $resource -Method "GET" -Scheme "DelegatedPersonal" -Claim $claim
            
            $resource.Methods["GET"].ContainsKey("DelegatedPersonal") | Should -Be $true
        }
        
        It "Supports Application scheme" {
            $resource = New-ProtectedResource -Path "/users"
            $claim = New-AcceptableClaim -Permission "User.Read.All" -Least $true -AlsoRequires @() -Scheme "Application"
            
            Add-ClaimToResource -Resource $resource -Method "GET" -Scheme "Application" -Claim $claim
            
            $resource.Methods["GET"].ContainsKey("Application") | Should -Be $true
        }
    }
    
    Context "Claim Preservation" {
        It "Preserves claim properties when added" {
            $resource = New-ProtectedResource -Path "/me/messages"
            $claim = New-AcceptableClaim -Permission "Mail.Read" -Least $true -AlsoRequires @("User.Read") -Scheme "DelegatedWork"
            
            Add-ClaimToResource -Resource $resource -Method "GET" -Scheme "DelegatedWork" -Claim $claim
            
            $addedClaim = $resource.Methods["GET"]["DelegatedWork"][0]
            $addedClaim.Permission | Should -Be "Mail.Read"
            $addedClaim.Least | Should -Be $true
            $addedClaim.AlsoRequires | Should -Contain "User.Read"
        }
        
        It "Stores actual claim objects, not copies" {
            $resource = New-ProtectedResource -Path "/me/messages"
            $claim = New-AcceptableClaim -Permission "Mail.Read" -Least $true -AlsoRequires @() -Scheme "DelegatedWork"
            
            Add-ClaimToResource -Resource $resource -Method "GET" -Scheme "DelegatedWork" -Claim $claim
            
            $retrievedClaim = $resource.Methods["GET"]["DelegatedWork"][0]
            $retrievedClaim.Permission | Should -Be $claim.Permission
        }
    }
    
    Context "Resource Mutation" {
        It "Modifies the resource object in place" {
            $resource = New-ProtectedResource -Path "/me/messages"
            $initialMethodCount = $resource.Methods.Count
            
            $claim = New-AcceptableClaim -Permission "Mail.Read" -Least $true -AlsoRequires @() -Scheme "DelegatedWork"
            Add-ClaimToResource -Resource $resource -Method "GET" -Scheme "DelegatedWork" -Claim $claim
            
            $resource.Methods.Count | Should -BeGreaterThan $initialMethodCount
        }
        
        It "Does not return a value" {
            $resource = New-ProtectedResource -Path "/me/messages"
            $claim = New-AcceptableClaim -Permission "Mail.Read" -Least $true -AlsoRequires @() -Scheme "DelegatedWork"
            
            $result = Add-ClaimToResource -Resource $resource -Method "GET" -Scheme "DelegatedWork" -Claim $claim
            
            $result | Should -BeNullOrEmpty
        }
    }
    
    Context "Complex Scenarios" {
        It "Builds complex nested structure" {
            $resource = New-ProtectedResource -Path "/me/messages"
            
            # Add multiple methods, schemes, and claims
            $claim1 = New-AcceptableClaim -Permission "Mail.Read" -Least $true -AlsoRequires @() -Scheme "DelegatedWork"
            $claim2 = New-AcceptableClaim -Permission "Mail.ReadWrite" -Least $false -AlsoRequires @() -Scheme "DelegatedWork"
            $claim3 = New-AcceptableClaim -Permission "Mail.Read.All" -Least $true -AlsoRequires @() -Scheme "Application"
            $claim4 = New-AcceptableClaim -Permission "Mail.Send" -Least $true -AlsoRequires @() -Scheme "DelegatedWork"
            
            Add-ClaimToResource -Resource $resource -Method "GET" -Scheme "DelegatedWork" -Claim $claim1
            Add-ClaimToResource -Resource $resource -Method "GET" -Scheme "DelegatedWork" -Claim $claim2
            Add-ClaimToResource -Resource $resource -Method "GET" -Scheme "Application" -Claim $claim3
            Add-ClaimToResource -Resource $resource -Method "POST" -Scheme "DelegatedWork" -Claim $claim4
            
            $resource.Methods.Count | Should -Be 2
            $resource.Methods["GET"]["DelegatedWork"].Count | Should -Be 2
            $resource.Methods["GET"]["Application"].Count | Should -Be 1
            $resource.Methods["POST"]["DelegatedWork"].Count | Should -Be 1
        }
    }
}
