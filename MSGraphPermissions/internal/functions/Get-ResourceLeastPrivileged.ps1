function Get-ResourceLeastPrivileged {
    <#
    .SYNOPSIS
        Extracts least privileged permissions from a resource object.

    .DESCRIPTION
        Internal function that filters and extracts only the least privileged permissions
        from a ProtectedResource object. It processes the nested Method -> Scheme -> Claims
        structure and returns only permissions marked as least privileged.

        The function implements smart fallback logic:
        - Prefers claims explicitly marked with Least = $true
        - If no explicit least privileged claim exists but only one permission is available,
          treats that single permission as implicitly least privileged
        - Calls Invoke-Disambiguate when multiple least privileged options exist to handle
          edge cases and select the most appropriate permission

        Supports optional filtering by HTTP method and/or authentication scheme to narrow
        results to specific scenarios.

    .PARAMETER Resource
        The ProtectedResource object containing the full set of permissions organized by
        method and scheme.

    .PARAMETER Method
        Optional HTTP method to filter results (GET, POST, PUT, PATCH, DELETE, etc.).
        If not specified, returns least privileged permissions for all methods.

    .PARAMETER Scheme
        Optional authentication scheme to filter results (DelegatedWork, DelegatedPersonal, Application).

    .EXAMPLE
        Get-ResourceLeastPrivileged -Resource $resource -Method 'GET' -Scheme 'DelegatedWork'
        
        Returns the least privileged permissions for the specified method and scheme.
        If not specified, returns least privileged permissions for all schemes.

    .OUTPUTS
        Hashtable
        Returns a nested hashtable structure: Method -> Scheme -> List[String] of permission names.
        Only includes methods/schemes that have least privileged permissions available.

    .NOTES
        This is an internal function not exported from the module. It is called by
        Find-GraphLeastPrivilege to extract the minimal permissions from cached data.

        The implicit least privilege fallback (single permission treated as least privileged)
        handles cases where Microsoft's metadata doesn't explicitly mark a permission as
        "least" but it's the only option available.

    .EXAMPLE
        Get-ResourceLeastPrivileged -Resource $resource -Method 'GET' -Scheme 'DelegatedWork'
        # Extracts least privileged permissions from resource
    #>
    param(
        [Parameter(Mandatory)]
        $Resource,
        [string]$Method,
        [string]$Scheme
    )

    $result = @{}

    if ($Method -and $Resource.Methods.ContainsKey($Method)) {
        $methodData = @{ $Method = $Resource.Methods[$Method] }
    }
    elseif ($Method) {
        return $result
    }
    else {
        $methodData = $Resource.Methods
    }

    foreach ($m in $methodData.Keys) {
        if ($Scheme -and $methodData[$m].ContainsKey($Scheme)) {
            $schemes = @{ $Scheme = $methodData[$m][$Scheme] }
        }
        elseif ($Scheme) {
            continue
        }
        else {
            $schemes = $methodData[$m]
        }

        foreach ($s in $schemes.Keys) {
            $claims = $schemes[$s] | Where-Object { $_.Least }

            # If no explicit least privileged permissions, check if there's only one permission total
            if (-not $claims) {
                $allClaims = $schemes[$s]
                if ($allClaims.Count -eq 1) {
                    # Only one permission exists, treat it as implicitly least privileged
                    $claims = $allClaims
                }
                elseif ($allClaims.Count -eq 2) {
                    # Exactly 2 permissions - check if they follow X.Read.All and X.ReadWrite.All pattern
                    $permissions = $allClaims | Select-Object -ExpandProperty Permission
                    $readPerm = $permissions | Where-Object { $_ -match '^(.+)\.Read\.All$' }
                    $readWritePerm = $permissions | Where-Object { $_ -match '^(.+)\.ReadWrite\.All$' }

                    if ($readPerm -and $readWritePerm) {
                        # Extract prefix before .Read.All and .ReadWrite.All
                        $readPerm -match '^(.+)\.Read\.All$' | Out-Null
                        $readPrefix = $Matches[1]
                        
                        $readWritePerm -match '^(.+)\.ReadWrite\.All$' | Out-Null
                        $readWritePrefix = $Matches[1]

                        # If prefixes match, the Read permission is less privileged
                        if ($readPrefix -eq $readWritePrefix) {
                            $claims = $allClaims | Where-Object { $_.Permission -eq $readPerm }
                        }
                    }

                    # If pattern didn't match, fall through to path count logic below
                    if (-not $claims) {
                        # Multiple permissions exist with no explicit least privilege marking
                        # Select the permission(s) with the fewest paths (least scope)
                        $permissionPathCounts = @{}
                        
                        foreach ($claim in $allClaims) {
                            $permName = $claim.Permission
                            if (-not $permissionPathCounts.ContainsKey($permName)) {
                                # Count paths for this permission across the entire permissions data
                                $pathCount = 0
                                if ($script:PermissionsData -and $script:PermissionsData.permissions.ContainsKey($permName)) {
                                    $permData = $script:PermissionsData.permissions[$permName]
                                    foreach ($pathSet in $permData.pathSets) {
                                        $pathCount += $pathSet.paths.Count
                                    }
                                }
                                $permissionPathCounts[$permName] = $pathCount
                            }
                        }
                        
                        # Find minimum path count
                        $minPathCount = ($permissionPathCounts.Values | Measure-Object -Minimum).Minimum
                        
                        # Select all permissions with the minimum path count
                        $leastBroadPermissions = $permissionPathCounts.GetEnumerator() |
                        Where-Object { $_.Value -eq $minPathCount } |
                        Select-Object -ExpandProperty Key

                        # Filter claims to only include those with minimum path count
                        $claims = $allClaims | Where-Object { $_.Permission -in $leastBroadPermissions }
                    }
                }
                elseif ($allClaims.Count -gt 2) {
                    # Multiple permissions exist with no explicit least privilege marking
                    # Select the permission(s) with the fewest paths (least scope)
                    $permissionPathCounts = @{}
                    
                    foreach ($claim in $allClaims) {
                        $permName = $claim.Permission
                        if (-not $permissionPathCounts.ContainsKey($permName)) {
                            # Count paths for this permission across the entire permissions data
                            $pathCount = 0
                            if ($script:PermissionsData -and $script:PermissionsData.permissions.ContainsKey($permName)) {
                                $permData = $script:PermissionsData.permissions[$permName]
                                foreach ($pathSet in $permData.pathSets) {
                                    $pathCount += $pathSet.paths.Count
                                }
                            }
                            $permissionPathCounts[$permName] = $pathCount
                        }
                    }
                    
                    # Find minimum path count
                    $minPathCount = ($permissionPathCounts.Values | Measure-Object -Minimum).Minimum
                    
                    # Select all permissions with the minimum path count
                    $leastBroadPermissions = $permissionPathCounts.GetEnumerator() |
                    Where-Object { $_.Value -eq $minPathCount } |
                    Select-Object -ExpandProperty Key

                    # Filter claims to only include those with minimum path count
                    $claims = $allClaims | Where-Object { $_.Permission -in $leastBroadPermissions }
                }
            }
            
            if ($claims) {
                $disambiguated = Invoke-Disambiguate -Resource $Resource -Method $m -Scheme $s -Claims $claims
                
                if (-not $result.ContainsKey($m)) {
                    $result[$m] = @{}
                }
                if (-not $result[$m].ContainsKey($s)) {
                    $result[$m][$s] = [System.Collections.Generic.List[string]]::new()
                }
                
                foreach ($perm in $disambiguated) {
                    $result[$m][$s].Add($perm)
                }
            }
        }
    }

    return $result
}
