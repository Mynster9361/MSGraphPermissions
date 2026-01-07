---
layout: default
title: Home
---

# MSGraphPermissions

A PowerShell module for finding least privileged Microsoft Graph API permissions.

## Installation

```powershell
Install-Module MSGraphPermissions -Scope CurrentUser
Import-Module MSGraphPermissions
```

## Quick Start

```powershell
# Initialize (downloads latest permissions)
Initialize-GraphPermissions

# Find least privileged permission
Find-GraphLeastPrivilege -Path "/users/{id}" -Method GET -Scheme DelegatedWork
```

## Commands

- [Find-GraphLeastPrivilege](docs/MSGraphPermissions/Find-GraphLeastPrivilege.html) - Find least privileged permissions for an endpoint
- [Find-GraphPath](docs/MSGraphPermissions/Find-GraphPath.html) - Search for Graph API paths
- [Get-GraphPermissions](docs/MSGraphPermissions/Get-GraphPermissions.html) - Get all permissions for an endpoint
- [Initialize-GraphPermissions](docs/MSGraphPermissions/Initialize-GraphPermissions.html) - Download latest permissions data

## Links

- [GitHub Repository](https://github.com/microsoftgraph/kibali-powershell)
- [PowerShell Gallery](https://www.powershellgallery.com/packages/MSGraphPermissions)
- [Full Documentation](docs/MSGraphPermissions/MSGraphPermissions.html)
