---
document type: cmdlet
external help file: MSGraphPermissions-Help.xml
HelpUri: https://mynster9361.github.io/MSGraphPermissions/docs/MSGraphPermissions/Initialize-GraphPermissions.html
Locale: en-US
Module Name: MSGraphPermissions
ms.date: 01/09/2026
PlatyPS schema version: 2024-05-01
title: Initialize-GraphPermissions
---

# Initialize-GraphPermissions

## SYNOPSIS

Downloads and initializes the Microsoft Graph permissions cache.

## SYNTAX

### __AllParameterSets

```
Initialize-GraphPermissions [-Force] [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}}

## DESCRIPTION

The Initialize-GraphPermissions function downloads the latest Microsoft Graph API
permissions metadata from the official Microsoft Graph GitHub repository and builds
an in-memory cache for fast lookups.

The permissions data is automatically cached in memory after the first download,
so subsequent calls are instantaneous.
The cache persists for the duration of the
PowerShell session.

This function is automatically called by other module functions (Find-GraphLeastPrivilege,
Get-GraphPermissions, Find-GraphPath) if the cache is not already initialized, so you
typically don't need to call it explicitly unless you want to force a refresh.

## EXAMPLES

### EXAMPLE 1

```
Initialize-GraphPermissions

Downloads permissions data if not already cached.
If data is already in memory,
does nothing and returns immediately.
```

### EXAMPLE 2

```
Initialize-GraphPermissions -Force

Forces a fresh download of the latest permissions data, replacing any existing cache.
Use this when you need to ensure you have the most recent permissions metadata.
```

### EXAMPLE 3

```
Initialize-GraphPermissions -Force -Verbose

Forces a refresh and shows detailed progress information about the download
and indexing process.
```

## PARAMETERS

### -Force

Forces a fresh download of permissions data from the remote source, even if the
cache is already populated.
Use this to refresh the data with the latest permissions
from Microsoft Graph.

Without this switch, the function will use existing cached data if available.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable,
-ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### None
This function does not return any output. It populates the internal module cache.

{{ Fill in the Description }}

## NOTES

- Downloads from: https://raw.githubusercontent.com/microsoftgraph/microsoft-graph-devx-content/refs/heads/master/permissions/new/permissions.json
- Data is cached in memory for the current PowerShell session only
- Cache is automatically initialized by other module functions if needed
- Use -Force to refresh data without restarting PowerShell
- Requires internet connectivity to download permissions data
- The permissions file is typically several MB in size
- First download may take a few seconds depending on connection speed
- Cached lookups are instantaneous after initialization


## RELATED LINKS

- [](https://mynster9361.github.io/MSGraphPermissions/docs/MSGraphPermissions/Initialize-GraphPermissions.html)
