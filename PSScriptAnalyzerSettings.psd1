@{
    # Severity levels: Error, Warning, Information
    Severity = @('Error', 'Warning')
    
    # Rules to exclude
    ExcludeRules = @(
        # These function names use plural nouns appropriately as they deal with collections
        # Get-GraphPermissions returns multiple permissions, not a single permission
        # Initialize-GraphPermissions initializes a cache of multiple permissions
        # Get-SupportedMethods returns multiple methods, not a single method
        'PSUseSingularNouns'
        
        # New-AcceptableClaim and New-ProtectedResource are factory functions that create objects
        # They don't change system state, so ShouldProcess is not needed
        'PSUseShouldProcessForStateChangingFunctions'
    )
    
    # Custom rules
    Rules = @{
        PSUseOutputTypeCorrectly = @{
            Enable = $false  # Disable for now as it flags valid return types
        }
    }
}
