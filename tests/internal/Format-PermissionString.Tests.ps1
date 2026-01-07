BeforeAll {
    # Import the module to access internal functions
    $modulePath = "$PSScriptRoot\..\..\MSGraphPermissions\MSGraphPermissions.psd1"
    Import-Module $modulePath -Force
    
    # Get internal function
    $internalFunction = Get-Command -Name 'Format-PermissionString' -Module MSGraphPermissions -ErrorAction SilentlyContinue
    
    if (-not $internalFunction) {
        # Import the internal function directly for testing
        . "$PSScriptRoot\..\..\MSGraphPermissions\internal\functions\Format-PermissionString.ps1"
    }
}

Describe "Format-PermissionString" {
    
    Context "Simple Permissions Without Dependencies" {
        It "Formats permission without dependencies" {
            $withEmpty = [PSCustomObject]@{ Permission = "Mail.Read"; AlsoRequires = @() }
            $withNull = [PSCustomObject]@{ Permission = "User.Read"; AlsoRequires = $null }
            
            $resultEmpty = Format-PermissionString -Claim $withEmpty
            $resultNull = Format-PermissionString -Claim $withNull
            
            $resultEmpty | Should -Be "Mail.Read"
            $resultNull | Should -Be "User.Read"
        }
    }
    
    Context "Permissions With Single Dependency" {
        It "Formats permission with one dependency using 'and'" {
            $claim = [PSCustomObject]@{
                Permission = "Mail.Read"
                AlsoRequires = @("User.Read")
            }
            
            $result = Format-PermissionString -Claim $claim
            
            $result | Should -Be "Mail.Read and User.Read"
            $result | Should -Match " and "
        }
    }
    
    Context "Permissions With Multiple Dependencies" {
        It "Formats permission with two dependencies" {
            $claim = [PSCustomObject]@{
                Permission = "Mail.Send"
                AlsoRequires = @("User.Read", "Mail.Read")
            }
            
            $result = Format-PermissionString -Claim $claim
            
            $result | Should -Be "Mail.Send and User.Read and Mail.Read"
        }
        
        It "Formats permission with three dependencies" {
            $claim = [PSCustomObject]@{
                Permission = "ComplexPermission"
                AlsoRequires = @("Dependency1", "Dependency2", "Dependency3")
            }
            
            $result = Format-PermissionString -Claim $claim
            
            $result | Should -Be "ComplexPermission and Dependency1 and Dependency2 and Dependency3"
        }
        
        It "Joins all dependencies with 'and'" {
            $claim = [PSCustomObject]@{
                Permission = "MainPermission"
                AlsoRequires = @("Dep1", "Dep2", "Dep3", "Dep4")
            }
            
            $result = Format-PermissionString -Claim $claim
            
            ($result -split " and ").Count | Should -Be 5  # MainPermission + 4 dependencies
        }
    }
    
    Context "Return Type" {
        It "Returns string type" {
            $claim = [PSCustomObject]@{
                Permission = "Mail.Read"
                AlsoRequires = @()
            }
            
            $result = Format-PermissionString -Claim $claim
            
            $result | Should -BeOfType [string]
        }
    }
    
    Context "Real-World Graph Permissions" {
        It "Formats basic Mail permission" {
            $claim = [PSCustomObject]@{
                Permission = "Mail.ReadBasic"
                AlsoRequires = @()
            }
            
            $result = Format-PermissionString -Claim $claim
            
            $result | Should -Be "Mail.ReadBasic"
        }
        
        It "Formats User permission with dependency" {
            $claim = [PSCustomObject]@{
                Permission = "User.Export.All"
                AlsoRequires = @("User.Read.All")
            }
            
            $result = Format-PermissionString -Claim $claim
            
            $result | Should -Be "User.Export.All and User.Read.All"
        }
        
        It "Formats complex permission chain" {
            $claim = [PSCustomObject]@{
                Permission = "Directory.Write.All"
                AlsoRequires = @("Directory.Read.All", "User.ReadWrite.All")
            }
            
            $result = Format-PermissionString -Claim $claim
            
            $result | Should -Contain "Directory.Write.All"
            $result | Should -Contain "Directory.Read.All"
            $result | Should -Contain "User.ReadWrite.All"
        }
    }
    
    Context "Edge Cases" {
        It "Handles permission names with special characters and dots" {
            $withDots = [PSCustomObject]@{ Permission = "Sites.Read.All"; AlsoRequires = @() }
            $complex = [PSCustomObject]@{ Permission = "IdentityRiskEvent.Read.All"; AlsoRequires = @() }
            
            (Format-PermissionString -Claim $withDots) | Should -Be "Sites.Read.All"
            (Format-PermissionString -Claim $complex) | Should -Be "IdentityRiskEvent.Read.All"
        }
    }
}
