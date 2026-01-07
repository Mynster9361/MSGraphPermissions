BeforeAll {
    # Import the module to access internal functions
    $modulePath = "$PSScriptRoot\..\..\MSGraphPermissions\MSGraphPermissions.psd1"
    Import-Module $modulePath -Force
    
    # Get internal function
    $internalFunction = Get-Command -Name 'New-AcceptableClaim' -Module MSGraphPermissions -ErrorAction SilentlyContinue
    
    if (-not $internalFunction) {
        # Import the internal function directly for testing
        . "$PSScriptRoot\..\..\MSGraphPermissions\internal\functions\New-AcceptableClaim.ps1"
    }
}

Describe "New-AcceptableClaim" {
    
    Context "Basic Object Creation" {
        It "Creates claim object with all required properties" {
            $claim = New-AcceptableClaim -Permission "Mail.Read" -Least $true -AlsoRequires @() -Scheme "DelegatedWork"
            
            $claim | Should -Not -BeNullOrEmpty
            $claim.Permission | Should -Be "Mail.Read"
            $claim.Least | Should -Be $true
            $claim.Scheme | Should -Be "DelegatedWork"
        }
        
        It "Handles Least property variations" {
            $claimTrue = New-AcceptableClaim -Permission "Mail.Read" -Least $true -AlsoRequires @() -Scheme "DelegatedWork"
            $claimFalse = New-AcceptableClaim -Permission "Mail.ReadWrite" -Least $false -AlsoRequires @() -Scheme "DelegatedWork"
            
            $claimTrue.Least | Should -Be $true
            $claimFalse.Least | Should -Be $false
        }
    }
    
    Context "AlsoRequires Property" {
        It "Handles empty AlsoRequires array" {
            $claim = New-AcceptableClaim -Permission "Mail.Read" -Least $true -AlsoRequires @() -Scheme "DelegatedWork"
            
            $claim.AlsoRequires | Should -BeOfType [array]
            $claim.AlsoRequires.Count | Should -Be 0
        }
        
        It "Handles single dependency in AlsoRequires" {
            $claim = New-AcceptableClaim -Permission "Mail.Read" -Least $true -AlsoRequires @("User.Read") -Scheme "DelegatedWork"
            
            $claim.AlsoRequires | Should -Contain "User.Read"
            $claim.AlsoRequires.Count | Should -Be 1
        }
        
        It "Handles multiple dependencies in AlsoRequires" {
            $dependencies = @("User.Read", "Calendars.Read", "Contacts.Read")
            $claim = New-AcceptableClaim -Permission "Mail.Read" -Least $true -AlsoRequires $dependencies -Scheme "DelegatedWork"
            
            $claim.AlsoRequires.Count | Should -Be 3
            $claim.AlsoRequires | Should -Contain "User.Read"
            $claim.AlsoRequires | Should -Contain "Calendars.Read"
            $claim.AlsoRequires | Should -Contain "Contacts.Read"
        }
    }
    
    Context "Authentication Schemes" {
        It "Creates claim with DelegatedWork scheme" {
            $claim = New-AcceptableClaim -Permission "Mail.Read" -Least $true -AlsoRequires @() -Scheme "DelegatedWork"
            
            $claim.Scheme | Should -Be "DelegatedWork"
        }
        
        It "Creates claim with DelegatedPersonal scheme" {
            $claim = New-AcceptableClaim -Permission "Mail.Read" -Least $true -AlsoRequires @() -Scheme "DelegatedPersonal"
            
            $claim.Scheme | Should -Be "DelegatedPersonal"
        }
        
        It "Creates claim with Application scheme" {
            $claim = New-AcceptableClaim -Permission "Mail.Read.All" -Least $true -AlsoRequires @() -Scheme "Application"
            
            $claim.Scheme | Should -Be "Application"
        }
    }
    
    Context "Object Type" {
        It "Returns PSCustomObject" {
            $claim = New-AcceptableClaim -Permission "Mail.Read" -Least $true -AlsoRequires @() -Scheme "DelegatedWork"
            
            $claim | Should -BeOfType [PSCustomObject]
        }
        
        It "Has custom type name" {
            $claim = New-AcceptableClaim -Permission "Mail.Read" -Least $true -AlsoRequires @() -Scheme "DelegatedWork"
            
            $claim.PSObject.TypeNames | Should -Contain "GraphPermissions.AcceptableClaim"
        }
    }
    
    Context "Real-World Scenarios" {
        It "Creates permission with dependencies" {
            $claim = New-AcceptableClaim -Permission "ComplexPermission" -Least $true -AlsoRequires @("BasePermission", "OtherPermission") -Scheme "Application"
            
            $claim.Permission | Should -Be "ComplexPermission"
            $claim.AlsoRequires.Count | Should -Be 2
            $claim.Least | Should -Be $true
        }
    }
}
