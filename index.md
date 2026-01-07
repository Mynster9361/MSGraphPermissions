---
layout: default
title: MSGraphPermissions
---

## 🚀 Installation

`powershell
Install-Module MSGraphPermissions -Scope CurrentUser

Import-Module MSGraphPermissions
```


## ⚡ Quick Start

Get up and running in seconds:

```powershell
# Initialize (downloads latest permissions)
Initialize-GraphPermissions

# Find least privileged permission
Find-GraphLeastPrivilege -Path "/users/{id}" -Method GET -Scheme DelegatedWork
```

## 📚 Commands

<div class="command-card">
  <a href="docs/MSGraphPermissions/Find-GraphLeastPrivilege.html">Find-GraphLeastPrivilege</a>
  <p>Find least privileged permissions for a Microsoft Graph API endpoint</p>
</div>

<div class="command-card">
  <a href="docs/MSGraphPermissions/Find-GraphPath.html">Find-GraphPath</a>
  <p>Search for Microsoft Graph API paths and endpoints</p>
</div>

<div class="command-card">
  <a href="docs/MSGraphPermissions/Get-GraphPermissions.html">Get-GraphPermissions</a>
  <p>Get all available permissions for a specific endpoint</p>
</div>

<div class="command-card">
  <a href="docs/MSGraphPermissions/Initialize-GraphPermissions.html">Initialize-GraphPermissions</a>
  <p>Download and initialize the latest permissions data from Microsoft</p>
</div>

## 🔗 Resources

<div class="links-grid">
  <div class="link-card">
    <a href="https://github.com/Mynster9361/MSGraphPermissions">📦 GitHub Repository</a>
  </div>
  <div class="link-card">
    <a href="https://www.powershellgallery.com/packages/MSGraphPermissions">💎 PowerShell Gallery</a>
  </div>
  <div class="link-card">
    <a href="docs/MSGraphPermissions/MSGraphPermissions.html">📖 Full Documentation</a>
  </div>
</div>

## 💡 Features

- **Least Privilege**: Find the minimum required permissions for any Graph API endpoint
- **Always Current**: Downloads the latest permission data directly from Microsoft
- **Multiple Schemes**: Support for Delegated Work, Delegated Personal, and Application permissions
- **Easy Search**: Quickly search and discover Graph API paths
- **PowerShell Native**: Built for PowerShell users with intuitive cmdlets
