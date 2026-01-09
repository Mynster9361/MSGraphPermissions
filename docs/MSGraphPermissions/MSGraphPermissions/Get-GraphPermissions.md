---
document type: cmdlet
external help file: MSGraphPermissions-Help.xml
HelpUri: https://mynster9361.github.io/MSGraphPermissions/docs/MSGraphPermissions/Get-GraphPermissions.html
Locale: en-US
Module Name: MSGraphPermissions
ms.date: 01/09/2026
PlatyPS schema version: 2024-05-01
title: Get-GraphPermissions
---

# Get-GraphPermissions

## SYNOPSIS

Retrieves all permissions (including non-least privileged) for a Microsoft Graph API endpoint.

## SYNTAX

### __AllParameterSets

```
Get-GraphPermissions [-Path] <string> [[-Method] <string>] [[-Scheme] <string>] [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}}

## DESCRIPTION

The Get-GraphPermissions function returns comprehensive permission information for a
Microsoft Graph API endpoint, including all available permissions regardless of whether
they are marked as least privileged.
This provides a complete view of all permissions
that can access an endpoint.

Unlike Find-GraphLeastPrivilege which only returns minimal permissions, this function
shows every permission that grants access, along with indicators showing which are
least privileged and what additional permissions they may require.

Use this function when you need to:
- Understand the full permission landscape for an endpoint
- See what higher-privileged alternatives exist
- Audit existing permissions against available options
- Understand permission dependencies (AlsoRequires)

## EXAMPLES

### EXAMPLE 1

```
Get-GraphPermissions -Path "/users/{id}" -Method GET

Returns all permissions (least privileged and higher) that can be used to read
a user object, across all authentication schemes.

Output shows IsLeastPrivileged column to identify minimal permissions:
Path        Method Scheme      Permission           IsLeastPrivileged
----        ------ ------      ----------           -----------------
/users/{id} GET    Application User.Read.All        False
/users/{id} GET    Application User.ReadBasic.All   True
/users/{id} GET    Application Directory.Read.All   False
```

### EXAMPLE 2

```
Get-GraphPermissions -Path "/me/messages" -Method GET -Scheme DelegatedWork

Returns all delegated work permissions that can read the current user's messages,
showing both least privileged and broader permissions.

Output:
Path         Method Scheme        Permission      IsLeastPrivileged
----         ------ ------        ----------      -----------------
/me/messages GET    DelegatedWork Mail.ReadBasic  True
/me/messages GET    DelegatedWork Mail.Read       False
/me/messages GET    DelegatedWork Mail.ReadWrite  False
```

### EXAMPLE 3

```
Get-GraphPermissions -Path "/users/{id}/messages" -Method GET |
    Where-Object { $_.IsLeastPrivileged } |
    Format-Table Permission, Scheme

Gets all permissions for reading user messages, then filters to show only
the least privileged options across all schemes.
```

### EXAMPLE 4

```
Get-GraphPermissions -Path "/me/calendar/events" -Method POST -Scheme Application |
    Select-Object Permission, IsLeastPrivileged, AlsoRequires

Shows all application permissions that can create calendar events, including
any additional permissions required (AlsoRequires column).
```

### EXAMPLE 5

```
"/me/messages", "/me/calendar" | Get-GraphPermissions -Method GET |
    Group-Object Permission | Sort-Object Count -Descending

Compares permissions across multiple endpoints to identify which permissions
grant access to multiple resources.
```

### EXAMPLE 6

```
Get-GraphPermissions -Path "/groups/{id}/members" -Method GET |
    Format-Table Scheme, Permission, IsLeastPrivileged -GroupBy Scheme

Displays permissions grouped by authentication scheme for better readability.
```

## PARAMETERS

### -Method

The HTTP method to filter by.
Valid values are: GET, POST, PUT, PATCH, DELETE

If not specified, returns permissions for all available methods on the path.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 1
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Path

The Microsoft Graph API path to query.
Path matching is case-insensitive.
Use {id} placeholders for dynamic segments (e.g., "/users/{id}/messages").

This parameter accepts pipeline input, allowing you to query multiple paths at once.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 0
  IsRequired: true
  ValueFromPipeline: true
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Scheme

The authentication scheme to filter by.
Valid values are:
- DelegatedWork: Delegated permissions for work/school accounts
- DelegatedPersonal: Delegated permissions for personal Microsoft accounts
- Application: Application permissions (app-only access)

If not specified, returns permissions for all available schemes.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 2
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

### System.String

{{ Fill in the Description }}

## OUTPUTS

### PSCustomObject
Returns objects with the following properties:
- Path: The API path queried
- Method: The HTTP method
- Scheme: The authentication scheme
- Permission: The permission name
- IsLeastPrivileged: Boolean indicating if this is a least privileged permission
- AlsoRequires: Comma-separated list of additional required permissions (usually empty)

{{ Fill in the Description }}

## NOTES

- Returns ALL permissions, not just least privileged ones
- Use the IsLeastPrivileged property to identify minimal permissions
- If a path is not found, a warning is displayed and no output is returned
- The permissions cache is automatically initialized on first use
- To refresh the permissions data, run: Initialize-GraphPermissions -Force
- The AlsoRequires property indicates permission dependencies; most permissions
  don't have dependencies and will show an empty string


## RELATED LINKS

- [](https://mynster9361.github.io/MSGraphPermissions/docs/MSGraphPermissions/Get-GraphPermissions.html)
