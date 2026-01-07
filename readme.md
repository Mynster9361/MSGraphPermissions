# GraphPermissions PowerShell Module

A PowerShell implementation of [Kibali](https://github.com/microsoftgraph/kibali) for finding least privileged Microsoft Graph API permissions. This module automatically downloads the latest permissions data from the Microsoft Graph repository and provides cmdlets to query permissions for any Graph API endpoint.

## Features

- **Automatic Permission Download**: Fetches the latest permissions directly from Microsoft Graph's GitHub repository
- **Least Privilege Finder**: Identifies the minimal required permission for any Graph API endpoint
- **Multiple Query Options**: Search by path, HTTP method, and authentication scheme
- **Path Discovery**: Find API paths using wildcard patterns
- **Pipeline Support**: Full PowerShell pipeline compatibility
- **Format Conversion**: Convert old GraphPermissions.json format to new Kibali format with `least=` metadata

## Installation

### Option 1: Direct Import
```powershell
Import-Module .\GraphPermissions.psd1
```

### Option 2: Install to PowerShell Modules Path
```powershell
# Copy module to user modules directory
$modulePath = "$HOME\Documents\PowerShell\Modules\GraphPermissions"
New-Item -ItemType Directory -Path $modulePath -Force
Copy-Item .\* -Destination $modulePath -Recurse
Import-Module GraphPermissions
```

## Requirements

- **PowerShell 7.0+** (PowerShell Core)
- Internet connection (for downloading permissions data)

## Quick Start

```powershell
# Import the module
Import-Module .\GraphPermissions.psd1

# Initialize and download permissions (happens automatically on first use)
Initialize-GraphPermissions

# Find the least privileged permission for an endpoint
Find-GraphLeastPrivilege -Path "/users/{id}/messages" -Method GET -Scheme DelegatedWork
```

<details>
<summary>Output:</summary>

```
Path                 Method Scheme        Permission
----                 ------ ------        ----------
/users/{id}/messages GET    DelegatedWork Mail.ReadBasic
```

</details>


## Core Cmdlets

### `Initialize-GraphPermissions`

Downloads and caches the latest Microsoft Graph permissions data.

```powershell
# Download permissions (caches for subsequent calls)
Initialize-GraphPermissions

# Force a fresh download
Initialize-GraphPermissions -Force
```

### `Find-GraphLeastPrivilege`

Finds the least privileged permission(s) required for a specific endpoint.

```powershell
# Find least privileged permission for specific method and scheme
Find-GraphLeastPrivilege -Path "/accessreviews" -Method GET -Scheme DelegatedWork
```
<details>
<summary>Output:</summary>

```
Path           Method Scheme        Permission
----           ------ ------        ----------
/accessreviews GET    DelegatedWork AccessReview.Read.All
```

</details>

```powershell
# Find for all methods
Find-GraphLeastPrivilege -Path "/me/messages"
```

<details>
<summary>Output:</summary>

```
Path         Method Scheme            Permission
----         ------ ------            ----------
/me/messages POST   Application       Mail.ReadWrite
/me/messages POST   DelegatedWork     Mail.ReadWrite
/me/messages POST   DelegatedPersonal Mail.ReadWrite
/me/messages GET    Application       Mail.ReadBasic.All
/me/messages GET    DelegatedWork     Mail.ReadBasic
/me/messages GET    DelegatedPersonal Mail.ReadBasic
```

</details>


# Pipeline usage (Will throw a warning if it was unable to find the path)
```powershell
"/me/messages", "/me/calendar" | Find-GraphLeastPrivilege -Method GET -Scheme DelegatedWork
```

<details>
<summary>Output:</summary>

```
WARNING: Path '/me/calendar' not found in permissions data
Path         Method Scheme        Permission
----         ------ ------        ----------
/me/messages GET    DelegatedWork Mail.ReadBasic
```

</details>


**Parameters:**
- `-Path` (required): Graph API path (e.g., `/users/{id}/messages`)
- `-Method` (optional): HTTP method (GET, POST, PUT, PATCH, DELETE)
- `-Scheme` (optional): Authentication scheme (DelegatedWork, DelegatedPersonal, Application)

### `Get-GraphPermissions`

Returns all permissions (not just least privileged) for an endpoint.

```powershell
# Get all permissions for a path
Get-GraphPermissions -Path "/users/{id}" -Method GET
```
<details>
<summary>Output:</summary>

```
Path        Method Scheme            Permission                                   IsLeastPrivileged AlsoRequires
----        ------ ------            ----------                                   ----------------- ------------
/users/{id} GET    Application       AgentIdUser.ReadWrite.All                                False
/users/{id} GET    Application       AgentIdUser.ReadWrite.IdentityParentedBy                 False
/users/{id} GET    Application       DeviceManagementApps.Read.All                            False
/users/{id} GET    Application       DeviceManagementApps.ReadWrite.All                       False
/users/{id} GET    Application       DeviceManagementConfiguration.Read.All                   False
/users/{id} GET    Application       DeviceManagementConfiguration.ReadWrite.All              False
/users/{id} GET    Application       DeviceManagementManagedDevices.Read.All                  False
/users/{id} GET    Application       DeviceManagementManagedDevices.ReadWrite.All             False
/users/{id} GET    Application       DeviceManagementServiceConfig.Read.All                   False
/users/{id} GET    Application       DeviceManagementServiceConfig.ReadWrite.All              False
/users/{id} GET    Application       Directory.Read.All                                       False
/users/{id} GET    Application       Directory.ReadWrite.All                                  False
/users/{id} GET    Application       User.Read.All                                            False
/users/{id} GET    Application       User.ReadBasic.All                                        True
/users/{id} GET    Application       User.ReadWrite.All                                        True
/users/{id} GET    Application       User.ReadWrite.CrossCloud                                False
/users/{id} GET    DelegatedPersonal User.Read                                                 True
/users/{id} GET    DelegatedPersonal User.ReadWrite                                            True
/users/{id} GET    DelegatedWork     AgentIdUser.ReadWrite.All                                False
/users/{id} GET    DelegatedWork     AgentIdUser.ReadWrite.IdentityParentedBy                 False
/users/{id} GET    DelegatedWork     DeviceManagementApps.Read.All                            False
/users/{id} GET    DelegatedWork     DeviceManagementApps.ReadWrite.All                       False
/users/{id} GET    DelegatedWork     DeviceManagementConfiguration.Read.All                   False
/users/{id} GET    DelegatedWork     DeviceManagementConfiguration.ReadWrite.All              False
/users/{id} GET    DelegatedWork     DeviceManagementManagedDevices.Read.All                  False
/users/{id} GET    DelegatedWork     DeviceManagementManagedDevices.ReadWrite.All             False
/users/{id} GET    DelegatedWork     DeviceManagementServiceConfig.Read.All                   False
/users/{id} GET    DelegatedWork     DeviceManagementServiceConfig.ReadWrite.All              False
/users/{id} GET    DelegatedWork     Directory.Read.All                                       False
/users/{id} GET    DelegatedWork     Directory.ReadWrite.All                                  False
/users/{id} GET    DelegatedWork     User.Read                                                False
/users/{id} GET    DelegatedWork     User.Read.All                                            False
/users/{id} GET    DelegatedWork     User.ReadBasic.All                                        True
/users/{id} GET    DelegatedWork     User.ReadWrite                                           False
/users/{id} GET    DelegatedWork     User.ReadWrite.All                                        True
```

</details>


**Parameters:**
- `-Path` (required): Graph API path
- `-Method` (optional): Filter by HTTP method
- `-Scheme` (optional): Filter by authentication scheme

### `Find-GraphPath`

Searches for API paths matching a wildcard pattern.

```powershell
# Find all access review paths
Find-GraphPath -Pattern "*accessreviews*"
```
<details>
<summary>Output:</summary>

```
Path                                                                                                                    Methods
----                                                                                                                    -------
/identitygovernance/accessreviews/definitions/{id}                                                                      DELETE, PUT, GET
/accessreviews/{id}/applydecisions                                                                                      POST
/identitygovernance/accessreviews/definitions/{id}/instances/{id}/stages                                                GET
/identitygovernance/accessreviews/definitions/{id}/instances/{id}                                                       PUT, GET
/identitygovernance/accessreviews/definitions/{id}/instances/{id}/acceptrecommendations                                 POST
/accessreviews/{id}/stop                                                                                                POST
/accessreviews/{id}/mydecisions                                                                                         GET
/identitygovernance/accessreviews/historydefinitions/{id}/instances                                                     GET
/accessreviews/{id}/reviewers/{id}                                                                                      DELETE
/identitygovernance/accessreviews/definitions/{id}/instances/{id}/stop                                                  POST
/identitygovernance/accessreviews/definitions/{id}/instances/{id}/stages/{id}/decisions/filterbycurrentuser(on={value}) GET
/accessreviews                                                                                                          POST, GET
/identitygovernance/accessreviews/definitions/{id}/instances/filterbycurrentuser(on={value})                            GET
/identitygovernance/accessreviews/historydefinitions/{id}/instances/{id}/generatedownloaduri                            POST
/identitygovernance/accessreviews/decisions/filterbycurrentuser(on={value})/recordalldecisions                          POST
/identitygovernance/accessreviews/definitions                                                                           POST, GET
/accessreviews/{id}/reviewers                                                                                           POST, GET
/identitygovernance/accessreviews/definitions/{id}/instances/{id}/stages/{id}                                           PATCH, GET
/identitygovernance/accessreviews/definitions/{id}/instances/{id}/batchrecorddecisions                                  POST
/identitygovernance/accessreviews/definitions/{id}/instances/{id}/stages/filterbycurrentuser(on={value})                GET
/identitygovernance/accessreviews/definitions/{id}/instances/{id}/applydecisions                                        POST
/identitygovernance/accessreviews/definitions/{id}/instances                                                            GET
/identitygovernance/accessreviews/definitions/{id}/instances/{id}/stages/{id}/decisions/{id}                            PATCH, GET
/identitygovernance/accessreviews/definitions/{id}/instances/{id}/resetdecisions                                        POST
/identitygovernance/accessreviews/definitions/{id}/instances/{id}/decisions/{id}                                        PATCH, GET
/identitygovernance/accessreviews/definitions/{id}/instances/{id}/stages/{id}/decisions                                 GET
/identitygovernance/accessreviews/definitions/{id}/instances/{id}/contactedreviewers                                    GET
/identitygovernance/accessreviews/definitions/filterbycurrentuser(on={value})                                           GET
/identitygovernance/accessreviews/historydefinitions                                                                    POST, GET
/accessreviews/{id}/decisions                                                                                           GET
/identitygovernance/accessreviews/definitions/{id}/instances/{id}/decisions                                             GET
/identitygovernance/accessreviews/definitions/{id}/instances/{id}/decisions/filterbycurrentuser(on={value})             GET
/identitygovernance/accessreviews/policy                                                                                PATCH, GET
/accessreviews/{id}                                                                                                     DELETE, PATCH, GET
/identitygovernance/accessreviews/definitions/{id}/instances/{id}/stages/{id}/stop                                      POST
/accessreviews/{id}/sendreminder                                                                                        POST
/identitygovernance/accessreviews/historydefinitions/{id}                                                               GET
/accessreviews/{id}/resetdecisions                                                                                      POST
/identitygovernance/accessreviews/definitions/{id}/instances/{id}/sendreminder                                          POST
```

</details>

# Find paths under /me
```powershell
Find-GraphPath -Pattern "/me/*"
```
<details>
<summary>Output:</summary>

```
Path                                                                                                               Methods
----                                                                                                               -------
/me/adhoccalls/{id}/transcripts                                                                                    GET
/me/authentication/windowshelloforbusinessmethods/{id}                                                             DELETE, GET
/me/drive/items/{id}/workbook/worksheets/{id}/charts/{id}/setdata                                                  POST
/me/mailfolders/{id}/operations                                                                                    GET
/me/onlinemeetings/{id}/attendeereport                                                                             GET
/me/drive/items/{id}/workbook/tables/{id}/columns/{id}/range/clear                                                 POST
/me/analytics/settings                                                                                             GET
/me/drive/items/{id}/workbook/worksheets/{id}/range(address={value})/format/fill                                   PATCH, GET
/me/drive/items/{id}/workbook/worksheets/{id}/range/rowsabove(count={value})                                       GET
/me/outlook/taskfolders/{id}                                                                                       DELETE, PATCH, GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/charts/{id}/format/fill/clear                                       POST
/me/drive/items/{id}/workbook/worksheets/{id}/charts/{id}/image(width={value})                                     GET
/me/drive/items/{id}/streams                                                                                       GET
/me/profile/webaccounts/{id}                                                                                       DELETE, PATCH, GET
/me/cloudclipboard/items                                                                                           GET
/me/cloudlicensing/waitingmembers/{id}                                                                             GET
/me/drive/items/{item-id}/media/reactions                                                                          DELETE, POST, GET
/me/drive/items/{id}/workbook/worksheets/{id}/charts/{id}/axes/categoryaxis                                        PATCH, GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/range(address={value})/visibleview/rows                             GET
/me/profile/interests                                                                                              POST, GET
/me/calendargroups/{id}/calendars                                                                                  POST, GET
/me/events/{id}/attachments/createuploadsession                                                                    POST
/me/drive/root:/{id}:/workbook/tables/{id}/columns/{id}/range/format/font                                          PATCH, GET
/me/datasecurityandgovernance/protectionscopes/compute                                                             POST
/me/drive/root:/{id}:/workbook/worksheets/{id}/usedrange                                                           GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/tables/{id}/sort/clear                                              POST
/me/drive/root:/{id}:/workbook/tables/{id}/columns/{id}/range/clear                                                POST
/me/drive/items/{id}/workbook/names/{id}/range/entirerow                                                           GET
/me/activities/{id}                                                                                                DELETE, PUT
/me/drive/items/{id}/workbook/worksheets/{id}/charts/{id}/legend/format/fill/setsolidcolor                         POST
/me/drive/root:/{id}:/workbook/worksheets/{id}/range(address={value})/format/borders/{id}                          PATCH, GET
/me/drive/items/{id}/workbook/tables/{id}/columns/{id}/databodyrange                                               GET
/me/drive/items/{id}/workbook/worksheets/{id}/tables/{id}/sort/reapply                                             POST
/me/mailfolders/{id}/userconfigurations                                                                            POST
/me/drive/items/{id}/workbook/tables/{id}/rows/{id}/range                                                          GET
/me/profile/phones/{id}                                                                                            DELETE, PATCH, GET
/me/drive/items/{id}/workbook/names/{id}/range/lastcell                                                            GET
/me/mailboxsettings/automaticrepliessetting                                                                        GET
/me/calendar/permanentdelete                                                                                       POST
/me/drive/items/{id}/workbook/worksheets/{id}/charts/{id}/legend                                                   PATCH, GET
/me/cloudpcs/{id}/troubleshoot                                                                                     POST
/me/outlook/taskgroups/{id}/taskfolders/{id}/tasks/{id}/permanentdelete                                            POST
/me/drive/items/{id}/workbook/tables/{id}/columns/{id}/range/boundingrect                                          GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/names/add                                                           POST
/me/calendar/events/{id}/snoozereminder                                                                            POST
/me/drive/root:/{id}:/workbook/worksheets/{id}/charts/{id}/setposition                                             POST
/me/drive/root:/{id}:/workbook/tables/{id}/columns/add                                                             POST
/me/calendargroups/{id}/calendars/{id}/events/{id}/accept                                                          POST
/me/onlinemeetings/{id}/alternativerecording                                                                       GET
/me/drive/items/{id}/workbook/names/{id}/range/column                                                              GET
/me/drive/items/{id}/workbook/tables/{id}/columns/{id}/range/intersection                                          GET
/me/findrooms(roomlist={value})                                                                                    GET
/me/pendingaccessreviewinstances/{id}/acceptrecommendations                                                        POST
/me/drive/root:/{id}:/workbook/worksheets/{id}/charts/{id}/image(width={value})                                    GET
/me/communications/callsettings/delegators/{delegatorid}                                                           GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/range(address={value})/entirerow                                    GET
/me/drive                                                                                                          GET
/me/settings/storage/quota                                                                                         GET
/me/calendars/{id}/events/{id}/decline                                                                             POST
/me/outlook/taskgroups/{id}/taskfolders/{id}/permanentdelete                                                       POST
/me/drive/items/{id}/versions                                                                                      GET
/me/onlinemeetings/{id}/transcripts/{id}                                                                           GET
/me/drive/items/{id}/workbook/worksheets/{id}/protection                                                           GET
/me/drive/items/{id}/workbook/tables/add                                                                           POST
/me/getmailtips                                                                                                    POST
/me/drive/root:/{id}:/workbook/tables/{id}/reapplyfilters                                                          POST
/me/security/informationprotection/sensitivitylabels/evaluateapplication                                           POST
/me/todo/lists/{id}                                                                                                DELETE, PATCH, GET
/me/drive/items/{id}/createlink                                                                                    POST
/me/cloudlicensing/assignments/{id}/assignedto/$ref                                                                PUT
/me/drive/root:/{id}:/workbook/worksheets/{id}/charts/{id}/series/{id}                                             PATCH, GET
/me/cloudpcs/{id}/getcloudpclaunchinfo                                                                             GET
/me/drive/items/{id}/workbook/tables/{id}/columns/{id}/range/format/font                                           PATCH, GET
/me/drive/items/{id}/workbook/worksheets/{id}/tables/{id}/range                                                    GET
/me/authentication/qrcodepinmethod/pin                                                                             DELETE, PATCH, GET
/me/drive/root/children                                                                                            POST, GET
/me/memberof/{id}                                                                                                  GET
/me/events                                                                                                         POST, GET
/me/drive/root:/{id}:/workbook/worksheets                                                                          POST, GET
/me/drive/items/{id}/workbook/worksheets/{id}/charts/{id}/axes/seriesaxis/majorgridlines                           PATCH, GET
/me/drive/items/{id}/permissions                                                                                   GET
/me/todo/lists/{id}/tasks/{id}/attachments/{id}                                                                    DELETE, GET
/me/profile/notes                                                                                                  POST, GET
/me/mailfolders/{id}/childfolders/{id}/.../messages/{id}/attachments/{id}                                          POST, GET
/me/settings/contactmergesuggestions                                                                               PATCH, GET
/me/drive/items/{id}/officeactivities                                                                              PATCH, GET
/me/drive/root:/{id}:/streams/{id}                                                                                 GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/charts/{id}/axes/categoryaxis/format/line/clear                     POST
/me/pendingaccessreviewinstances/{id}/decisions                                                                    GET
/me/photos/{id}                                                                                                    GET
/me/profile/emails                                                                                                 POST, GET
/me/drive/items/{id}/workbook/refreshsession                                                                       POST
/me/drive/items/{id}/workbook/names/{id}/range/usedrange                                                           GET
/me/drive/items/{id}/permissions/{id}                                                                              DELETE, PATCH, GET
/me/changepassword                                                                                                 POST
/me/drive/root:/{id}:/workbook/worksheets/{id}/names/{id}                                                          DELETE
/me/drive/root:/{id}:/workbook/worksheets/{id}/range(address={value})/entirecolumn                                 GET
/me/drive/items/{id}/workbook/worksheets/{id}/charts/{id}/axes/seriesaxis/format/line                              PATCH, GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/charts/{id}/axes/seriesaxis/majorgridlines                          PATCH, GET
/me/cloudlicensing/assignments/{id}/allotment                                                                      GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/cell(row={value},column={value})                                    GET
/me/tasks/lists/{id}/tasks/{id}/checklistitems/{id}                                                                DELETE, PATCH, GET
/me/drive/items/{id}/workbook/worksheets/{id}/range/rowsbelow(count={value})                                       GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/tables/{id}/rows                                                    POST, GET
/me/authentication/qrcodepinmethod                                                                                 DELETE, PUT, PATCH, GET
/me/drive/root:/{id}:/workbook/tables/{id}/totalrowrange                                                           GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/range/columnsbefore(count={value})                                  GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/charts/{id}/axes/seriesaxis/format/font                             PATCH, GET
/me/people                                                                                                         GET
/me/drive/items/{id}/workbook/worksheets/{id}/tables/{id}/columns/{id}/headerrowrange                              GET
/me/mailfolders/{id}                                                                                               DELETE, PATCH, GET
/me/outlook/tasks/{id}/attachments                                                                                 POST, GET
/me/drive/root:/{id}:/workbook/names/{id}/range/lastcolumn                                                         GET
/me/messages/{id}/send                                                                                             POST
/me/mailboxsettings/dateformat                                                                                     GET
/me/mailfolders/{id}/operations/{id}                                                                               GET
/me/drive/items/{id}/versions/{id}/streams/{id}/content                                                            GET
/me/calendargroups/{id}/calendars/{id}/events/{id}/attachments                                                     POST, GET
/me/drive/root:/{id}:/workbook/names/{id}/range/offsetrange                                                        GET
/me/calendars                                                                                                      POST, GET
/me/drive/root:/{id}:/workbook/tables/{id}/sort/apply                                                              POST
/me/drive/items/{id}/thumbnails/{id}/{id}/content                                                                  GET
/me/drive/items/{id}/workbook/worksheets/{id}/range(address={value})/unmerge                                       POST
/me/drive/items/{id}/workbook/worksheets/{id}/range(address={value})/sort/apply                                    POST
/me/invalidateallrefreshtokens                                                                                     POST
/me/checkmembergroups                                                                                              POST
/me/drive/items/{id}/workbook/worksheets/{id}/charts/{id}/axes/categoryaxis/format/font                            PATCH, GET
/me/onlinemeetings/{id}/sendvirtualappointmentsms                                                                  POST
/me/drive/items/{id}/thumbnails/{id}/{id}                                                                          GET
/me/drive/items/{id}/workbook/worksheets/{id}/charts/{id}/image(width={value},height={value})                      GET
/me/onenote/pages/{id}/copytosection                                                                               POST
/me/drive/items/{id}/versions/streams/{id}/content                                                                 GET
/me/homesite                                                                                                       GET
/me/drive/items/{id}/workbook/worksheets/{id}/tables/{id}/columns/add                                              POST
/me/profile/emails/{id}                                                                                            DELETE, PATCH, GET
/me/settings/storage/quota/services/{id}                                                                           GET
/me/contactfolders/{id}/contacts/{id}/permanentdelete                                                              POST
/me/mailboxsettings                                                                                                PATCH, GET
/me/authentication/fido2methods                                                                                    POST, GET
/me/drive/items/{id}/workbook/names/{id}/range/format/font                                                         PATCH, GET
/me/todo/lists/{id}/tasks/delta                                                                                    GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/tables/{id}/totalrowrange                                           GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/tables/{id}/columns/add                                             POST
/me/drive/root:/{id}:/workbook/worksheets/{id}/charts/{id}/axes/categoryaxis/title                                 PATCH, GET
/me/translateexchangeids                                                                                           POST
/me/drive/root:/{id}:/workbook/tables/{id}/rows/itemat                                                             POST
/me/contactfolders/{id}/childfolders/{id}/.../contacts/{id}                                                        DELETE, PATCH, GET
/me/drive/items/{id}/workbook/names/{id}/range/format/borders(sideindex={value})                                   PATCH, GET
/me/drive/items/{id}/workbook/names/{id}/range/unmerge                                                             POST
/me/drive/items/{id}/workbook/worksheets/{id}/charts/{id}/format/fill/setsolidcolor                                POST
/me/calendar/events                                                                                                POST, GET
/me/informationprotection/policy/labels/{id}                                                                       GET
/me/drive/root:/{id}:/workbook/names/{id}/range/sort/apply                                                         POST
/me/drive/root:/{id}:/workbook/names/{id}/range/lastcell                                                           GET
/me/drive/items/{id}/workbook/tables/{id}/columns/{id}/range/format/autofitrows                                    POST
/me/drive/root:/{id}:/workbook/names/{id}/range/row                                                                POST
/me/drive/items/{id}/workbook/worksheets/{id}/charts/{id}/image                                                    GET
/me/drive/root:/{id}:/workbook/names/{id}/range/format/fill/clear                                                  POST
/me/contactfolders/{id}/contacts/delta                                                                             GET
/me/planner/tasks                                                                                                  GET
/me/calendargroups/{id}/calendars/{id}/events/delta                                                                GET
/me/todo/lists/{id}/tasks/{id}/attachments/createuploadsession                                                     POST
/me/drive/root:/{id}:/workbook/worksheets/{id}/tables/add                                                          POST
/me/todo/lists/{id}/tasks                                                                                          POST, GET
/me/mailfolders/{id}/messages/{id}/copy                                                                            POST
/me/drive/root:/{id}:/workbook/application                                                                         GET
/me/cloudpcs/{id}/reprovision                                                                                      POST
/me/sponsors                                                                                                       GET
/me/drive/items/{id}/content                                                                                       PUT, GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/pivottables/refreshall                                              POST
/me/calendars/{id}/events/{id}/accept                                                                              POST
/me/insights/trending                                                                                              GET
/me/drive/items/{id}/workbook/worksheets/{id}/protection/unprotect                                                 POST
/me/onlinemeetings/{id}/recordings                                                                                 GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/range(address={value})/lastrow                                      GET
/me/drive/root/delta                                                                                               GET
/me/profile/anniversaries                                                                                          POST, GET
/me/cloudpcs/{id}/getfrontlinecloudpcaccessstate                                                                   GET
/me/profile/projects/{id}                                                                                          DELETE, PATCH, GET
/me/contacts/{id}/permanentdelete                                                                                  POST
/me/authentication/emailmethods                                                                                    POST, GET
/me/drive/items/{id}/restore                                                                                       POST
/me/drive/root:/{id}:/workbook/tables/{id}/rows/add                                                                POST
/me/contactfolders/{id}                                                                                            DELETE, PATCH, GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/charts/{id}/axes/seriesaxis/format/line/clear                       POST
/me/insights/trending/{id}/resource                                                                                GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/charts/add                                                          POST
/me/drive/special/{id}/children                                                                                    GET
/me/cloudlicensing/usagerights/{id}                                                                                GET
/me/onenote/notebooks                                                                                              POST, GET
/me/drive/items/{id}/workbook/worksheets/{id}/tables/{id}/rows/add                                                 POST
/me/mailboxsettings/timezone                                                                                       GET
/me/onenote/pages/{id}                                                                                             DELETE, GET
/me/drive/items/{id}/versions/current                                                                              GET
/me/drive/items/{id}/workbook/operations/{id}                                                                      GET
/me/messages/{id}/forward                                                                                          POST
/me/drive/items/{id}/checkin                                                                                       POST
/me/cloudlicensing/assignments/reprocessassignments                                                                POST
/me/mailboxsettings/workinghours                                                                                   GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/pivottables/{id}                                                    GET
/me/events/delta                                                                                                   GET
/me/drive/items/{id}/workbook/worksheets/{id}/tables/{id}/columns/{id}/range                                       GET
/me/drive/items/{id}/workbook/worksheets/{id}/charts/{id}                                                          DELETE, PATCH, GET
/me/drive/items/{id}/workbook/names/{id}/range/boundingrect                                                        GET
/me/drive/root:/{id}:/workbook/tables/{id}/sort/clear                                                              POST
/me/drive/root:/{id}:/workbook/names/{id}/range/lastrow                                                            GET
/me/drive/items/{id}/workbook/tables/{id}/columns/{id}/range/column                                                GET
/me/drive/items/{id}/workbook/names/{id}/range/format/borders                                                      POST, GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/range(address={value})                                              PATCH, GET
/me/tasks/lists/{id}/tasks/{id}                                                                                    DELETE, PATCH, GET
/me/calendargroups/{id}/calendars/{id}/events/{id}/decline                                                         POST
/me/drive/items/{id}/workbook/worksheets/{id}/cell(row={value},column={value})                                     GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/tables/{id}/columns/{id}                                            DELETE, PATCH, GET
/me/authentication/requirements                                                                                    PATCH, GET
/me/drive/items/{id}/children                                                                                      POST, GET
/me/drive/root:/{id}:/content                                                                                      GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/charts/{id}/format/fill/setsolidcolor                               POST
/me/calendars/delta                                                                                                GET
/me/drive/items/{id}/workbook/worksheets/{id}/charts/{id}/axes/valueaxis/minorgridlines                            PATCH, GET
/me/profile/awards/{id}                                                                                            DELETE, PATCH, GET
/me/drive/items/{id}/workbook/comments/{id}                                                                        GET
/me/mailfolders/{id}/messages/{id}/mentions/{id}                                                                   DELETE
/me/authentication/methods/{id}                                                                                    GET
/me/todo/lists/{id}/tasks/{id}/linkedresources/{id}                                                                DELETE, PATCH, GET
/me/drive/items/{id}/workbook/worksheets/{id}/range(address={value})/format/autofitcolumns                         POST
/me/outlook/taskfolders                                                                                            POST, GET
/me/mailfolders/{id}/messages/{id}/forward                                                                         POST
/me/authentication/hardwareoathmethods/{id}                                                                        DELETE, GET
/me/drive/items/{id}/workbook/worksheets/{id}/charts/{id}/axes/valueaxis/format/font                               PATCH, GET
/me/drive/items/{id}/workbook/worksheets/{id}/range(address={value})/format/font                                   PATCH, GET
/me/drive/root:/{id}:/workbook/tables/{id}/columns/itemat                                                          POST
/me/profile/positions                                                                                              POST, GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/charts/{id}/series                                                  POST, GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/tables/{id}/rows/{id}                                               DELETE, PATCH, GET
/me/drive/root:/{id}:/workbook/tables/{id}/columns/{id}/range/lastcolumn                                           GET
/me/authentication/hardwareoathmethods/assignandactivate                                                           POST
/me/messages/{id}/move                                                                                             POST
/me/drive/items/{id}/workbook/worksheets/{id}/range(address={value})/usedrange                                     GET
/me/calendargroups/{id}/calendars/{id}/calendarview                                                                GET
/me/contactfolders/delta                                                                                           GET
/me/drive/items/{id}:/{id}:/content                                                                                PUT
/me/drive/root:/{id}:/workbook/worksheets/{id}/charts/{id}/axes/seriesaxis/title                                   PATCH, GET
/me/outlook/tasks/{id}/complete                                                                                    POST
/me/drive/items/{id}/streams/{id}/appendcontent                                                                    POST
/me/drive/root:/{id}:/workbook/worksheets/{id}/range(address={value})/format/font                                  PATCH, GET
/me/drive/root:/{id}:/workbook/names/{id}/range/delete                                                             POST
/me/drive/root:/{id}:/workbook/tables/{id}/columns/{id}/range/merge                                                POST
/me/profile/skills/{id}                                                                                            DELETE, PATCH, GET
/me/mailboxsettings/userpurpose                                                                                    GET
/me/profile/addresses/{id}                                                                                         DELETE, PATCH, GET
/me/drive/items/{id}/workbook/worksheets/{id}/charts/{id}/series/itemat                                            POST
/me/drive/items/{id}/workbook/names/{id}/range/format/borders/{id}                                                 PATCH, GET
/me/profile/certifications/{id}                                                                                    DELETE, PATCH, GET
/me/drive/items/{id}/workbook/worksheets/{id}/tables/{id}/sort                                                     GET
/me/drive/items/{id}/workbook/worksheets                                                                           POST, GET
/me/onlinemeetings/{id}/attendancereports                                                                          GET
/me/messages/{id}/reportmessage                                                                                    POST
/me/drive/root:/{id}:/workbook/worksheets/{id}/range(address={value})/format/borders                               POST, GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/pivottables                                                         GET
/me/drive/root:/{id}:/streams                                                                                      GET
/me/calendars/{id}                                                                                                 DELETE
/me/drive/items/{id}/workbook/worksheets/{id}/tables/{id}/clearfilters                                             POST
/me/drive/items/{id}/workbook/tables/{id}/rows/add                                                                 POST
/me/contacts/{id}/onpremisessyncbehavior                                                                           PATCH, GET
/me/drive/root:/{id}:/workbook/tables/{id}/columns/{id}/range/format/autofitcolumns                                POST
/me/onlinemeetings/{id}/registration/microsoft.graph.meetingregistration/customquestions                           POST, GET
/me/authentication/temporaryaccesspassmethods                                                                      POST, GET
/me/drive/items/{id}/workbook/worksheets/{id}/usedrange                                                            GET
/me/drive/items/{id}/workbook/worksheets/{id}/range(address={value})/format/borders/{id}                           PATCH, GET
/me/adhoccalls/{id}/recordings/{id}                                                                                GET
/me/onlinemeetings/{id}/recording                                                                                  GET
/me/drive/root:/{id}:/workbook/application/calculate                                                               POST
/me/drive/items/{id}/workbook/worksheets/{id}/tables/{id}/converttorange                                           POST
/me/tasks/lists/{id}/tasks/{id}/linkedresources                                                                    POST, GET
/me/calendar/events/{id}/dismissreminder                                                                           POST
/me/drive/root:/{id}:/workbook/worksheets/{id}/protection/unprotect                                                POST
/me/todo/lists                                                                                                     POST, GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/charts/{id}/axes/categoryaxis                                       PATCH, GET
/me/messages/{id}/createforward                                                                                    POST
/me/drive/root:/{id}:/workbook/tables/{id}/columns/{id}/databodyrange                                              GET
/me/drive/root:/{id}:/workbook/tables/{id}/columns/{id}/range/column                                               GET
/me/drive/root:/{id}:/streams/{id}/content                                                                         GET
/me/calendar/events/delta                                                                                          GET
/me/adhoccalls/{id}/transcripts/{id}/metadatacontent                                                               GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/tables/{id}/rows/{id}/range                                         GET
/me/onlinemeetings/{id}/registration/registrants/{id}                                                              DELETE
/me/drive/root:/{id}:/workbook/worksheets/{id}/tables/{id}/range                                                   GET
/me/authentication/phonemethods                                                                                    POST, GET
/me/settings/windows                                                                                               GET
/me/authentication/qrcodepinmethod/standardqrcode                                                                  DELETE, PATCH, GET
/me/drive/items/{id}/workbook/tables/{id}/columns/{id}/range/offsetrange                                           GET
/me/revokesigninsessions                                                                                           POST
/me/scopedrolememberof                                                                                             GET
/me/drive/items/{id}/workbook/worksheets/{id}/pivottables/{id}/refresh                                             POST
/me/settings/workhoursandlocations                                                                                 PATCH, GET
/me/drive/root:/{id}:/workbook/tables/{id}/columns/{id}/range/boundingrect                                         GET
/me/directreports                                                                                                  GET
/me/drive/root:/{id}:/workbook/tables/{id}/headerrowrange                                                          GET
/me/sponsorof                                                                                                      GET
/me/events/{id}/cancel                                                                                             POST
/me/notifications                                                                                                  POST
/me/drive/items/{id}/streams/{id}                                                                                  POST, GET
/me/contacts/onpremisessyncbehavior                                                                                PATCH, GET
/me/drive/root:/{id}:/workbook/createsession                                                                       POST
/me/drive/items/{id}/workbook/names/{id}/range/offsetrange                                                         GET
/me/drive/root:/{item-path}/media/reactions                                                                        DELETE, POST, GET
/me/drive/root:/{id}:/workbook/names/{id}/range/unmerge                                                            POST
/me/authentication/microsoftauthenticatormethods/{id}                                                              DELETE, GET
/me/drive/items/{id}/workbook/worksheets/{id}/tables/{id}/sort/fields/icon                                         PATCH, GET
/me/drive/items/{id}/workbook/worksheets/{id}/charts/{id}/axes/categoryaxis/title                                  PATCH, GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/charts/{id}                                                         DELETE, PATCH, GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/charts/{id}/title                                                   PATCH, GET
/me/drive/root:/{id}:/workbook/tables/{id}/rows/itemat(index={value})/range                                        GET
/me/onenote/sections/{id}                                                                                          GET
/me/profile/positions/{id}                                                                                         DELETE, PATCH, GET
/me/todo/lists/{id}/tasks/{id}                                                                                     DELETE, PATCH, GET
/me/security/informationprotection/labelpolicysettings                                                             GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/tables/{id}/columns/itemat                                          POST
/me/contactfolders/{id}/permanentdelete                                                                            POST
/me/onenote/sectiongroups/{id}/sections                                                                            POST, GET
/me/drive/items/{id}/workbook/tables/{id}/columns/{id}/filter/apply                                                POST
/me/outlook/supportedlanguages                                                                                     GET
/me/drive/root:/{id}:/workbook/tables/{id}/columns/{id}/filter/clear                                               POST
/me/drive/items/{id}/versions/streams                                                                              GET
/me/calendar/events/{id}/forward                                                                                   POST
/me/drive/root:/{id}:/workbook/tables/{id}/columns/{id}/range/sort/apply                                           POST
/me/drives                                                                                                         GET
/me/settings/workhoursandlocations/occurrencesview(startdatetime={value},enddatetime={value})                      GET
/me/drive/root:/{id}:/workbook/tables/{id}/clearfilters                                                            POST
/me/licensedetails                                                                                                 GET
/me/drive/items/{id}/workbook/tables/{id}/reapplyfilters                                                           POST
/me/informationprotection/policy/labels                                                                            GET
/me/chats/{id}/messages/{id}                                                                                       GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/charts/{id}/axes/categoryaxis/format/line                           PATCH, GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/charts/{id}/axes/seriesaxis                                         PATCH, GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/charts/{id}/image                                                   GET
/me/drive/items/{id}/workbook/tables/{id}/columns/{id}/totalrowrange                                               GET
/me/drive/root:/{id}:/workbook/tables/{id}/rows                                                                    POST, GET
/me/events/{id}/instances                                                                                          GET
/me/inferenceclassification/overrides                                                                              POST, GET
/me/drive/root:/{id}:/workbook/names/{id}/range                                                                    PATCH, GET
/me/mailfolders/{id}/messages/{id}/permanentdelete                                                                 POST
/me/profile/educationalactivities                                                                                  POST, GET
/me/onenote/notebooks/{id}                                                                                         GET
/me/todo/lists/delta                                                                                               GET
/me/authentication/passwordlessmicrosoftauthenticatormethods/{id}                                                  DELETE, GET
/me/drive/root:/{id}:/workbook/names/{id}/range/format/autofitcolumns                                              POST
/me/todo/lists/{id}/tasks/{id}/attachments                                                                         POST, GET
/me/calendars/{id}/events/{id}/cancel                                                                              POST
/me/drive/items/{id}/workbook/tables/{id}/sort/clear                                                               POST
/me/drive/root:/{id}:/workbook/tables/{id}/columns/{id}/range/entirecolumn                                         GET
/me/drive/items/{id}/workbook/createsession                                                                        POST
/me/drive/root:/{id}:/workbook/tables/{id}/columns/{id}/range/row                                                  POST
/me/drive/root:/{id}:/workbook/names/{id}/range/format/font                                                        PATCH, GET
/me/authentication/fido2methods/{id}                                                                               DELETE, PATCH, GET
/me/drive/root:/{id}                                                                                               PUT, GET
/me/onlinemeetings/{id}/registration/customquestions/{id}                                                          DELETE, PATCH, GET
/me/calendargroups/{id}/calendars/{id}/events/{id}/snoozereminder                                                  POST
/me/cloudlicensing/waitingmembers                                                                                  GET
/me/drive/root:/{id}:/workbook/names/{id}/range/merge                                                              POST
/me/outlook/taskfolders/{id}/tasks                                                                                 POST, GET
/me/drive/items/{id}/workbook/names/{id}/range/merge                                                               POST
/me/drive/root:/{id}:/workbook/names/{id}/range/clear                                                              POST
/me/onlinemeetings/{id}/recordings/{id}/content                                                                    GET
/me/drive/items/{id}/workbook/names/{id}/range/lastcolumn                                                          GET
/me/drive/items/{id}/workbook/names/{id}/range/lastrow                                                             GET
/me/drive/root:/{id}:/workbook/tables/{id}/columns/{id}/range/insert                                               POST
/me/communications/callsettings/delegates                                                                          POST, GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/range(address={value})/format/borders/itemat                        POST
/me/drive/items/{id}/workbook/worksheets/{id}/charts/{id}/axes/seriesaxis/majorgridlines/format/line               PATCH, GET
/me/security/informationprotection/sensitivitylabels/{id}                                                          GET
/me/authentication/passwordlessmicrosoftauthenticatormethods                                                       GET
/me/drive/items/{id}/workbook/tables/{id}/add                                                                      POST
/me/profile/anniversaries/{id}                                                                                     DELETE, PATCH, GET
/me/messages/{id}/mentions/{id}                                                                                    DELETE
/me/drive/items/{id}/workbook/names/{id}/range/format/fill                                                         PATCH, GET
/me/cloudpcs                                                                                                       GET
/me/drive/items/{id}/workbook/worksheets/{id}/pivottables                                                          GET
/me/drive/items/{id}/workbook/worksheets/{id}/names                                                                GET
/me/authentication/qrcodepinmethod/pin/updatepin                                                                   PATCH
/me/drive/items/{id}/workbook/worksheets/{id}/range(address={value})/lastcell                                      GET
/me/drive/items/{id}/invite                                                                                        POST
/me/drive/root:/{id}:/workbook/worksheets/{id}/range(address={value})/format/autofitrows                           POST
/me/datasecurityandgovernance/processcontent                                                                       POST
/me/drive/items/{id}/workbook/tables/{id}/columns/{id}/range/entirerow                                             GET
/me/drive/root:/{id}:/workbook/tables/{id}/columns/{id}/range/delete                                               POST
/me/calendars/{id}/events/{id}/snoozereminder                                                                      POST
/me/drive/items/{id}/workbook/worksheets/{id}/charts/itemat                                                        POST
/me/drive/root:/{id}:/workbook/worksheets/{id}/pivottables/{id}/refresh                                            POST
/me/mailfolders/{id}/messages/{id}/createreply                                                                     POST
/me/drive/root:/{id}:/workbook/worksheets/{id}/tables/{id}                                                         DELETE, PATCH, GET
/me/outlook/taskgroups/{id}/taskfolders/{id}/tasks                                                                 POST, GET
/me/profile/interests/{id}                                                                                         DELETE, PATCH, GET
/me/drive/items/{id}/workbook/worksheets/{id}/tables/{id}/rows/itemat(index={value})range                          GET
/me/drive/items/{id}/workbook/worksheets/{id}/charts/{id}/axes/seriesaxis                                          PATCH, GET
/me/tasks/lists/{id}                                                                                               DELETE, PATCH, GET
/me/mailfolders/{id}/messages/{id}/createreplyall                                                                  POST
/me/profile                                                                                                        DELETE, GET
/me/drive/items/{id}/workbook/worksheets/{id}/tables/{id}/columns/{id}                                             DELETE, PATCH, GET
/me/onlinemeetings/{id}/getvirtualappointmentjoinweburl                                                            GET
/me/mailfolders/{id}/messages/{id}/createforward                                                                   POST
/me/events/{id}/permanentdelete                                                                                    POST
/me/drive/root:/{id}:/workbook/tables/{id}/columns/{id}/range/format/borders(sideindex={value})                    PATCH, GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/charts/{id}/image(width={value},height={value},fittingmode={value}) GET
/me/drive/items/{id}/workbook/worksheets/{id}/charts/{id}/axes/seriesaxis/title                                    PATCH, GET
/me/drive/items/{id}/workbook/worksheets/{id}/charts/add                                                           POST
/me/drive/items/{id}/workbook/worksheets/{id}/names/add                                                            POST
/me/drive/root:/{id}:/workbook/tables/add                                                                          POST
/me/drive/root:/foldera/fileb.txt:/content                                                                         PUT
/me/drive/items/{id}/workbook/worksheets/{id}/charts/{id}/datalabels                                               PATCH, GET
/me/drive/items/{id}/workbook/names/{id}/range/format/protection                                                   PATCH, GET
/me/tasks/lists/delta                                                                                              GET
/me/onlinemeetings/{id}/transcripts/{id}/metadatacontent                                                           GET
/me/authentication/phonemethods/{id}/enablesmssignin                                                               POST
/me/checkmemberobjects                                                                                             POST
/me/drive/root:/{id}:/workbook/worksheets/{id}/range(address={value})/format/autofitcolumns                        POST
/me/drive/root:/{id}:/workbook/worksheets/{id}/charts/{id}/axes/valueaxis/minorgridlines                           PATCH, GET
/me/drive/root:/{id}:/workbook/tables/{id}/columns/{id}/range/format/borders/{id}                                  PATCH, GET
/me/drive/items/{id}/workbook/worksheets/{id}/tables/{id}/columns/{id}/databodyrange                               GET
/me/onenote/notebooks/{id}/sectiongroups                                                                           POST, GET
/me/tasks/lists/{id}/tasks/delta                                                                                   GET
/me/mailfolders/{id}/messages/{id}                                                                                 DELETE, PATCH, GET
/me/drive/items/{id}/workbook/worksheets/{id}/tables/{id}/columns/{id}/totalrowrange                               GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/protection                                                          GET
/me/mailfolders/{id}/messages/{id}/replyall                                                                        POST
/me/cloudpcs/{id}                                                                                                  GET
/me/manager                                                                                                        GET
/me/drive/items/{id}/workbook/worksheets/{id}/range(address={value})/intersection                                  GET
/me/drive/items/{id}:/{id}:/createuploadsession                                                                    POST
/me/drive/items/{id}/workbook/worksheets/{id}/range(address={value})/row                                           POST
/me/calendars/{id}/events/{id}/forward                                                                             POST
/me/drive/items/{id}/workbook/tables/{id}/columns/{id}/range/format/fill                                           PATCH, GET
/me/drive/root                                                                                                     GET
/me/drive/root:/{id}:/workbook/comments/{id}                                                                       GET
/me/drive/items/{id}/versions/{id}/streams/{id}                                                                    POST, GET
/me/drive/items/{id}/workbook/tables/{id}/rows/itemat(index={value})/range                                         GET
/me/contactfolders/{id}/childfolders/{id}/.../contacts                                                             GET
/me/trendingaround                                                                                                 GET
/me/drive/items/{id}/workbook/closesession                                                                         POST
/me/contactfolders/{id}/contacts/{id}                                                                              DELETE, PATCH, GET
/me/drive/items/{id}/workbook/tables/{id}/rows                                                                     POST, GET
/me/authentication/softwareoathmethods/{id}                                                                        DELETE, GET
/me/contactfolders/{id}/childfolders/{id}/permanentdelete                                                          POST
/me/mailfolders/{id}/messages/{id}/move                                                                            POST
/me/profile/account/{id}                                                                                           DELETE, PATCH, GET
/me/pendingaccessreviewinstances                                                                                   GET
/me/contacts                                                                                                       POST, GET
/me/onlinemeetings/{id}/transcripts                                                                                GET
/me/drive/root:/{id}:/workbook/tables/{id}/columns/{id}/range/format/autofitrows                                   POST
/me/activities/{id}/historyitems/{id}                                                                              DELETE, PUT
/me/drive/root:/{id}:/workbook/worksheets/{id}/range/rowsbelow(count={value})                                      GET
/me/mailfolders/{id}/permanentdelete                                                                               POST
/me/drive/root:/{id}:/workbook/worksheets/{id}/range/columnsafter(count={value})                                   GET
/me/onlinemeetings/createorget                                                                                     POST
/me/drive/root:/{id}:/workbook/tables/{id}/columns/{id}/range/unmerge                                              POST
/me/drive/root:/{id}:/workbook/worksheets/{id}/tables/{id}/rows/itemat                                             POST
/me/onenote/sections/{id}/pages                                                                                    POST, GET
/me/drive/root:/{id}:/workbook/tables/{id}/add                                                                     POST
/me/drive/items/{id}/workbook/tables/{id}/columns/itemat                                                           POST
/me/drive/root:/{id}:/workbook/worksheets/{id}/range(address={value})/visibleview/range                            GET
/me/drive/root:/{id}:/workbook/names/{id}/range/format                                                             PATCH, GET
/me/drive/items/{id}/workbook/worksheets/{id}/tables/{id}/sort/apply                                               POST
/me/calendars/{id}/events/{id}/attachments                                                                         POST, GET
/me/drive/root:/{id}:/workbook/comments/{id}/replies                                                               POST, GET
/me/drive/root:/{id}:/workbook/tables/{id}/columns/{id}/range/format                                               PATCH, GET
/me/drive/items/{id}/workbook/worksheets/{id}/tables/{id}/databodyrange                                            GET
/me/drive/items/{id}/workbook/worksheets/{id}/range(address={value})/merge                                         POST
/me/mailfolders/{id}/move                                                                                          POST
/me/drive/root:/{id}:/workbook/worksheets/{id}/range(address={value})/lastcell                                     GET
/me/mailboxsettings/delegatemeetingmessagedeliveryoptions                                                          GET
/me/findrooms                                                                                                      GET
/me/mailfolders/{id}/messages/delta                                                                                GET
/me/mailfolders/{id}/userconfigurations/{id}                                                                       DELETE, PATCH, GET
/me/drive/root:/{id}:/workbook/tables/{id}/databodyrange                                                           GET
/me/drive/items/{id}/workbook/tables/{id}/columns/{id}/range/format/borders                                        POST, GET
/me/drive/items/{id}/workbook/names/{id}/range/format                                                              PATCH, GET
/me/outlook/tasks/{id}/permanentdelete                                                                             POST
/me/tasks/lists/{id}/tasks/{id}/move                                                                               POST
/me/drive/following/{id}                                                                                           DELETE
/me/profile/skills                                                                                                 POST, GET
/me/drive/items/{id}/follow                                                                                        POST
/me/drive/items/{id}/workbook/worksheets/{id}/tables/{id}/columns/itemat                                           POST
/me/drive/items/{id}/workbook/worksheets/{id}/charts/{id}/axes/seriesaxis/format/font                              PATCH, GET
/me/drive/root:/{id}:/workbook/tables/{id}/converttorange                                                          POST
/me/cloudlicensing/usagerights                                                                                     GET
/me/cloudpcs/{id}/retrievecloudpclaunchdetail                                                                      GET
/me/drive/root:/{id}/assignsensitivitylabel                                                                        POST
/me/drive/root:/{id}:/workbook/worksheets/{id}/tables/{id}/databodyrange                                           GET
/me/drive/items/{id}/workbook/worksheets/{id}/range(address={value})/column                                        GET
/me/drive/root:/{id}:/workbook/names/{id}                                                                          DELETE, PATCH, GET
/me/drive/items/{id}/workbook/worksheets/{id}/range(address={value})/format/fill/clear                             POST
/me/contactfolders/{id}/contacts                                                                                   POST, GET
/me/authentication/passwordmethods/{id}                                                                            GET
/me/outlook/taskgroups                                                                                             POST, GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/charts/{id}/axes/valueaxis/title                                    PATCH, GET
/me/calendar/getschedule                                                                                           POST
/me/oauth2permissiongrants                                                                                         GET
/me/planner/mydaytasks                                                                                             GET
/me/drive/items/{id}/workbook/tables/{id}/columns/{id}/range/cell                                                  GET
/me/mailfolders/{id}/updateallmessagesreadstate                                                                    POST
/me/drive/items/{id}/workbook/worksheets/{id}/tables/{id}/columns/{id}/filter/clear                                POST
/me/drive/items/{id}/workbook/worksheets/{id}/charts/{id}/title                                                    PATCH, GET
/me/drive/root:/{id}:/workbook/tables/{id}/columns/{id}/range/format/borders/itemat                                POST
/me/drive/items/{id}                                                                                               DELETE, PATCH, GET
/me/mailfolders/{id}/messages/{id}/attachments                                                                     POST, GET
/me/drive/items/{id}/workbook/worksheets/{id}/charts/{id}/series/{id}                                              PATCH, GET
/me/followedsites                                                                                                  GET
/me/joinedteams                                                                                                    GET
/me/messages/{id}/createreply                                                                                      POST
/me/drive/items/{id}/workbook/worksheets/{id}/range(address={value})/visibleview                                   GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/charts/itemat                                                       POST
/me/drive/items/{id}/workbook/worksheets/{id}/charts/{id}/axes/categoryaxis/format/line                            PATCH, GET
/me/calendar/events/{id}/instances                                                                                 GET
/me/planner/favoriteplans                                                                                          GET
/me/drive/root:/{id}:/workbook/tables/{id}/columns/{id}/headerrowrange                                             GET
/me/drive/root/subscriptions/socketio                                                                              GET
/me/drive/root:/{id}:/workbook/names/{id}/range/insert                                                             POST
/me/drive/items/{id}/workbook/worksheets/{id}/charts/{id}/axes/valueaxis                                           PATCH, GET
/me/drive/items/{id}/workbook/tables/{id}/columns/{id}/range/format/borders/itemat                                 POST
/me/drive/root:/{id}:/workbook/worksheets/{id}/charts/{id}/axes/valueaxis/majorgridlines                           PATCH, GET
/me/drive/items/{id}/workbook/tables/{id}/columns/{id}/range/unmerge                                               POST
/me/owneddevices                                                                                                   GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/range(address={value})/format/protection                            PATCH, GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/tables/{id}/columns                                                 POST, GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/charts/{id}/series/itemat                                           POST
/me/authentication/methods                                                                                         GET
/me/onenote/sectiongroups/{id}/sectiongroups                                                                       POST, GET
/me/drive/items/{id}/workbook/tables/{id}/sort/apply                                                               POST
/me/drive/root:/{id}:/workbook/worksheets/{id}/tables/{id}/headerrowrange                                          GET
/me/cloudlicensing/assignments                                                                                     POST, GET
/me/mailboxsettings/timeformat                                                                                     GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/tables/{id}/columns/{id}/headerrowrange                             GET
/me/drive/items/{id}/assignsensitivitylabel                                                                        POST
/me/extensions                                                                                                     GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/range(address={value})/format/fill                                  PATCH, GET
/me/messages/{id}/createreplyall                                                                                   POST
/me/profile/phones                                                                                                 POST, GET
/me/drive/items/{id}/workbook/names/{id}/range/format/borders/itemat                                               POST
/me/drive/items/{id}/unfollow                                                                                      POST
/me/devices/{id}/commands                                                                                          POST
/me/onenote/sections/{id}/copytosectiongroup                                                                       POST
/me/drive/items/{id}/workbook/worksheets/{id}/range/columnsafter(count={value})                                    GET
/me/drive/items/{id}/versions/{id}/streams/{id}/appendcontent                                                      POST
/me/drive/items/{id}/createuploadsession                                                                           POST
/me/authentication/methods/{id}/isupdatesupported                                                                  GET
/me/authentication/temporaryaccesspassmethods/{id}                                                                 DELETE, GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/range(address={value})/clear                                        POST
/me/events/{id}/decline                                                                                            POST
/me/onenote/notebooks/getrecentnotebooks(includepersonalnotebooks={value})                                         GET
/me/drive/root:/{id}:/workbook/names/add                                                                           POST
/me/drive/root:/{id}:/workbook/worksheets/{id}/range(address={value})/sort/apply                                   POST
/me/drive/items/{id}/workbook/tables/{id}/columns/{id}/range/lastcell                                              GET
/me/tasks/lists                                                                                                    POST, GET
/me/drive/items/{id}/workbook/comments/{id}/replies/{id}                                                           GET
/me/drive/items/{id}/permissions/{id}/revokegrants                                                                 POST
/me/drive/items/{id}/workbook/worksheets/{id}/charts/{id}/series/{id}/points                                       POST, GET
/me/drive/items/{id}/copy                                                                                          POST
/me/drive/items/{id}/workbook/names/{id}                                                                           DELETE, PATCH, GET
/me/onenote                                                                                                        GET
/me/drive/items/{id}/workbook/names/{id}/range/cell                                                                GET
/me/drive/items/{id}/workbook/tables/{id}/sort                                                                     GET
/me/agreementacceptances                                                                                           GET
/me/drive/root:/{id}:/workbook/names/{id}/range/column                                                             GET
/me/drive/items/{id}/workbook/tables/{id}/clearfilters                                                             POST
/me/contactfolders                                                                                                 POST, GET
/me/calendars/{id}/events/{id}/instances                                                                           GET
/me/chats/{id}/messages                                                                                            GET
/me/onlinemeetings/{id}/registration/registrants                                                                   POST, GET
/me/drive/root:/{id}:/workbook/names/{id}/range/format/protection                                                  PATCH, GET
/me/sendmail                                                                                                       POST
/me/contacts/{id}/photo                                                                                            PUT, PATCH, GET
/me/calendargroups/{id}/calendars/{id}/events/{id}                                                                 DELETE, PATCH, GET
/me/analytics/activitystatistics                                                                                   GET
/me/responsibilities/{id}                                                                                          DELETE, PATCH, GET
/me/onlinemeetings/{id}/attendancereports/{id}/attendancerecords                                                   GET
/me/drive/items/{id}/extensions                                                                                    DELETE, PATCH, POST, GET
/me/drive/items/{id}/workbook/worksheets/{id}/tables/{id}/columns/{id}/filter/apply                                POST
/me/drive/root:/{id}:/workbook/names/{id}/range/format/borders(sideindex={value})                                  PATCH, GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/charts/{id}/title/format/fill/clear                                 POST
/me/calendars/{id}/events/delta                                                                                    GET
/me/drive/items/{id}/workbook/worksheets/{id}/tables/{id}/headerrowrange                                           GET
/me/drive/root:/{id}:/workbook/names/{id}/range/format/borders                                                     POST, GET
/me/authentication/microsoftauthenticatormethods                                                                   GET
/me/insights/used                                                                                                  GET
/me/drive/items/{id}/workbook/worksheets/{id}/range(address={value})/entirecolumn                                  GET
/me/drive/root:/{id}:/workbook/comments/{id}/replies/{id}                                                          GET
/me/drive/items/{id}/workbook/application/calculate                                                                POST
/me/drive/root:/{id}:/workbook/worksheets/{id}/charts/{id}/series/{id}/points                                      POST, GET
/me/drive/items/{id}/workbook/tables/{id}/columns/{id}/range/lastcolumn                                            GET
/me/drive/items/{id}/workbook/names/{id}/range/clear                                                               POST
/me/cloudpcs/{id}/rename                                                                                           POST
/me/drive/items/{id}/workbook/worksheets/{id}/charts/{id}/series/{id}/points/itemat                                POST
/me/drive/root:/{id}:/workbook/names/{id}/range/cell                                                               GET
/me/getmembergroups                                                                                                POST
/me/drive/items/{id}/workbook/tables/{id}/rows/{id}                                                                DELETE, PATCH, GET
/me/drive/root:/{id}:/workbook/tables/{id}                                                                         DELETE, PATCH, GET
/me/createdobjects                                                                                                 GET
/me/drive/items/{id}/workbook/comments                                                                             POST, GET
/me/activities                                                                                                     GET
/me/drive/items/{id}/workbook/worksheets/{id}/charts/{id}/axes/seriesaxis/majorgridlines/format/line/clear         POST
/me/drive/root:/{id}:/workbook/worksheets/{id}/tables/{id}/columns/{id}/databodyrange                              GET
/me/cloudlicensing/waitingmembers/{id}/allotment                                                                   GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/range(address={value})/boundingrect                                 GET
/me/drive/root:/{id}:/workbook/tables                                                                              GET
/me/calendargroups/{id}                                                                                            DELETE, PATCH, GET
/me/calendars/{id}/calendarview/delta                                                                              GET
/me/onlinemeetings/{id}/aiinsights/{id}                                                                            GET
/me/settings/iteminsights                                                                                          PATCH, GET
/me/authentication/softwareoathmethods                                                                             GET
/me/drive/items/{id}/workbook/tables/{id}/columns/{id}/range/format/autofitcolumns                                 POST
/me/drive/root:/{id}:/workbook/worksheets/{id}/range(address={value})/column                                       GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/charts/{id}/series/{id}/points/itemat                               POST
/me/findroomlists                                                                                                  GET
/me/cloudpcs/{id}/start                                                                                            POST
/me/drive/items/{id}/checkout                                                                                      POST
/me/drive/items/{id}/workbook/worksheets/{id}/tables/{id}/sort/clear                                               POST
/me/planner/tasks/delta                                                                                            GET
/me/drive/items/{id}/workbook/worksheets/{id}/tables/{id}/columns                                                  POST, GET
/me/drive/items/{id}/workbook/worksheets/{id}/pivottables/{id}                                                     GET
/me/onlinemeetings/{id}/meetingattendancereport                                                                    GET
/me/calendar/events/{id}/tentativelyaccept                                                                         POST
/me/onenote/resources/{id}/content                                                                                 GET
/me/settings/windows/{id}/instances                                                                                GET
/me/drive/root:/{id}:/permissions                                                                                  GET
/me/profile/notes/{id}                                                                                             DELETE, PATCH, GET
/me/messages/{id}/reply                                                                                            POST
/me/drive/root:/{id}:/workbook/worksheets/{id}/range(address={value})/insert                                       POST
/me/tasks/lists/{id}/tasks/{id}/checklistitems                                                                     POST, GET
/me/events/{id}/snoozereminder                                                                                     POST
/me/authentication/hardwareoathmethods/deactivate                                                                  POST
/me/drive/root:/{id}:/workbook/tables/{id}/columns/{id}/range/format/borders                                       POST, GET
/me/calendar/events/{id}                                                                                           DELETE, PATCH, GET
/me/drive/items/{id}/workbook/worksheets/{id}/tables/{id}                                                          DELETE, PATCH, GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/range                                                               GET
/me/profile/educationalactivities/{id}                                                                             DELETE, PATCH, GET
/me/drive/items/{id}/discardcheckout                                                                               POST
/me/drive/root:/{id}:/workbook/names/{id}/range/format/autofitrows                                                 POST
/me/profile/patents/{id}                                                                                           DELETE, PATCH, GET
/me/onlinemeetings/{meetingid}/attendancereports/{reportid}/attendancerecords                                      GET
/me/onlinemeetings/{id}/virtualappointment                                                                         DELETE, PUT, PATCH, GET
/me/getmemberobjects                                                                                               POST
/me/onenote/operations/{id}                                                                                        GET
/me/onenote/sections/{id}/copytonotebook                                                                           POST
/me/drive/items/{id}/workbook/tables/{id}/columns/{id}/range/usedrange                                             GET
/me/drive/items/{id}/workbook/worksheets/{id}/charts/{id}/setposition                                              POST
/me/cloudlicensing/assignmenterrors                                                                                GET
/me/messages/{id}                                                                                                  DELETE, PATCH, GET
/me/planner/recentplans                                                                                            GET
/me/drive/items/{id}/workbook/names/{id}/range/insert                                                              POST
/me/drive/items/{id}/workbook/tables/{id}/range                                                                    GET
/me/onlinemeetings                                                                                                 POST, GET
/me/authentication/fido2methods/creationoptions                                                                    POST, GET
/me/authentication/hardwareoathmethods                                                                             POST, GET
/me/authentication/phonemethods/{id}                                                                               DELETE, PATCH, GET
/me/settings/workhoursandlocations/occurrences                                                                     POST
/me/outlook/taskfolders/{id}/permanentdelete                                                                       POST
/me/drive/root:/{id}:/workbook/names/{id}/range/entirecolumn                                                       GET
/me/drive/root:/{id}:/workbook/names/{id}/range/intersection                                                       GET
/me/drive/root:/{id}:/workbook/tables/{id}/sort                                                                    GET
/me/drive/items/{id}/workbook/tables/{id}/columns/{id}/range/format/borders(sideindex={value})                     PATCH, GET
/me/calendar/events/{id}/cancel                                                                                    POST
/me/onlinemeetings/{meetingid}/attendancereports                                                                   GET
/me/calendar/events/{id}/attachments                                                                               POST, GET
/me/authentication/windowshelloforbusinessmethods                                                                  GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/tables/{id}/sort/apply                                              POST
/me/drive/root:/{id}:/workbook/worksheets/add                                                                      POST
/me/mailfolders                                                                                                    POST, GET
/me/drive/root:/{id}:/workbook/names/{id}/range/format/borders/{id}                                                PATCH, GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/charts/{id}/axes/seriesaxis/format/line                             PATCH, GET
/me/mailfolders/{id}/reportmessage                                                                                 POST
/me/todo/lists/{id}/tasks/{id}/linkedresources                                                                     POST, GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/tables/{id}/sort                                                    GET
/me/drive/root:/{id}:/workbook/tables/{id}/columns/{id}/range/format/fill                                          PATCH, GET
/me/drive/items/{id}/workbook/worksheets/{id}/charts/{id}/series                                                   POST, GET
/me/drive/root:/{id}:/workbook/tables/{id}/columns/{id}/range/lastcell                                             GET
/me/profile/publications/{id}                                                                                      DELETE, PATCH, GET
/me/drive/items/{id}/workbook/names/{id}/range/format/autofitrows                                                  POST
/me/mailfolders/{id}/messages                                                                                      POST, GET
/me/drive/root:/{id}:/workbook/tables/{id}/columns/{id}/range/cell                                                 GET
/me/drive/items/{id}/workbook/worksheets/{id}/charts/{id}/axes/categoryaxis/format/line/clear                      POST
/me/drive/root:/{id}:/workbook/worksheets/{id}/tables/{id}/sort/fields/icon                                        PATCH, GET
/me/onlinemeetings/{id}/recordings/{id}                                                                            GET
/me/communications/callsettings/delegates/{delegateid}                                                             DELETE, PATCH, GET
/me/devices                                                                                                        GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/tables/{id}/reapplyfilters                                          POST
/me/drive/items/{id}/workbook/worksheets/{id}/protection/protect                                                   POST
/me/drive/root:/{id}:/workbook/worksheets/{id}/charts/{id}/axes/seriesaxis/majorgridlines/format/line              PATCH, GET
/me/adhoccalls/{id}/recordings/{id}/content                                                                        GET
/me/settings                                                                                                       PATCH, GET
/me/calendargroups                                                                                                 POST, GET
/me/drive/items/{id}/workbook/worksheets/add                                                                       POST
/me/drive/items/{id}/workbook/worksheets/{id}/range(address={value})/visibleview/range                             GET
/me/drive/items/{id}/workbook/worksheets/{id}/charts/{id}/format/fill/clear                                        POST
/me/onenote/sections                                                                                               GET
/me/outlook/tasks/{id}                                                                                             DELETE, PATCH, GET
/me/mailfolders/delta                                                                                              GET
/me/drive/items/{id}/workbook/worksheets/{id}/range(address={value})/format/borders                                POST, GET
/me/settings/windows/{id}                                                                                          GET
/me/drive/items/{id}/workbook/tables/{id}/columns/{id}/range/format/fill/clear                                     POST
/me/findmeetingtimes                                                                                               POST, GET
/me/settings/windows/{id}/instances/{id}                                                                           GET
/me/contactfolders/{id}/childfolders                                                                               POST, GET
/me/profile/awards                                                                                                 POST, GET
/me/messages/{id}/attachments                                                                                      POST, GET
/me/drive/recent                                                                                                   GET
/me/profile/languages/{id}                                                                                         DELETE, PATCH, GET
/me/drive/items/{id}/capabilities                                                                                  GET
/me/drive/items/{id}/workbook/tables/{id}/columns/{id}/headerrowrange                                              GET
/me/drive/root:/{id}:/workbook/tables/{id}/rows/{id}                                                               DELETE, PATCH, GET
/me/drive/root:/{id}:/workbook/tables/{id}/columns/{id}/range/format/protection                                    PATCH, GET
/me/settings/workhoursandlocations/recurrences/{id}                                                                DELETE, PUT
/me/drive/items/{id}/workbook/worksheets/{id}                                                                      DELETE, PATCH, GET
/me/onenote/notebooks/getnotebookfromweburl                                                                        POST
/me/drive/root:/{id}:/workbook/tables/{id}/columns/{id}/range/intersection                                         GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/tables/{id}/converttorange                                          POST
/me/drive/items/{id}/workbook/worksheets/{id}/range(address={value})/delete                                        POST
/me/drive/root:/{id}:/workbook/tables/{id}/range                                                                   GET
/me/drive/items/{id}/versions/{id}                                                                                 GET
/me/drive/items/{id}/workbook/tables/{id}/columns/{id}                                                             DELETE, PATCH, GET
/me/cloudlicensing/usagerights/{id}/assignments                                                                    GET
/me/events/{id}/attachments                                                                                        POST, GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/range(address={value})/unmerge                                      POST
/me/security/informationprotection/sensitivitylabels                                                               GET
/me/calendar/events/{id}/permanentdelete                                                                           POST
/me/drive/items/{id}/workbook/worksheets/{id}/tables/{id}/rows/{id}/range                                          GET
/me/drive/items/{id}/workbook/worksheets/{id}/charts/{id}/axes/valueaxis/majorgridlines                            PATCH, GET
/me/onenote/sectiongroups                                                                                          GET
/me/cloudlicensing/assignmenterrors/{id}                                                                           GET
/me/registereddevices                                                                                              GET
/me/drive/items/{id}/workbook/names                                                                                GET
/me/messages/{id}/copy                                                                                             POST
/me/drive/root:/{id}:/workbook/names/{id}/range/boundingrect                                                       GET
/me/drive/items/{id}/workbook/worksheets/{id}/range                                                                GET
/me/events/{id}/dismissreminder                                                                                    POST
/me/tasks/lists/{id}/tasks                                                                                         POST, GET
/me/drive/items/{id}/workbook/comments/{id}/replies                                                                POST, GET
/me/profile/names/{id}                                                                                             DELETE, PATCH, GET
/me/events/{id}/accept                                                                                             POST
/me/devices/{id}/commands/{id}/responsepayload                                                                     GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/protection/protect                                                  POST
/me/drive/root:/{id}:/workbook/worksheets/{id}/tables/{id}/columns/{id}/filter/apply                               POST
/me/events/{id}/forward                                                                                            POST
/me/outlook/mastercategories                                                                                       POST, GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/tables/{id}/columns/{id}/range                                      GET
/me/events/{id}                                                                                                    DELETE, PATCH, GET
/me/outlook/tasks                                                                                                  POST, GET
/me/calendargroups/{id}/calendars/{id}/events                                                                      GET
/me/calendars/{id}/events/{id}                                                                                     DELETE, PATCH, GET
/me/drive/items/{id}/workbook/worksheets/{id}/pivottables/refreshall                                               POST
/me/profile/publications                                                                                           POST, GET
/me/profile/account                                                                                                POST, GET
/me/calendars/{id}/events/{id}/permanentdelete                                                                     POST
/me/drive/items/{id}/workbook/worksheets/{id}/tables                                                               GET
/me/deleteddatetime                                                                                                GET
/me/events/{id}/tentativelyaccept                                                                                  POST
/me/calendargroups/{id}/calendars/{id}/events/{id}/tentativelyaccept                                               POST
/me/drive/items/{id}/workbook/tables/{id}/columns/{id}/range/entirecolumn                                          GET
/me/drive/root:/{id}:/workbook/comments                                                                            POST, GET
/me/profile/certifications                                                                                         POST, GET
/me/onenote/notebooks/{id}/copynotebook                                                                            POST
/me/calendar/events/{id}/accept                                                                                    POST
/me/drive/root:/{id}:/workbook/worksheets/{id}/range(address={value})/offsetrange                                  GET
/me/drive/root:/{id}:/workbook/tables/{id}/columns/{id}/range/format/fill/clear                                    POST
/me/calendargroups/{id}/calendars/{id}/events/{id}/permanentdelete                                                 POST
/me/drive/items/{id}/workbook/names/{id}/range/format/autofitcolumns                                               POST
/me/exportpersonaldata                                                                                             GET
/me/mailboxsettings/language                                                                                       GET
/me/drive/items/{id}/workbook/tables                                                                               GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/charts/{id}/legend                                                  PATCH, GET
/me/drive/root:/{id}:/contentstream                                                                                GET
/me/settings/workhoursandlocations/occurrences/{id}                                                                DELETE, PUT
/me/drive/items/{id}/workbook/tables/{id}/headerrowrange                                                           GET
/me/drive/items/{id}/workbook/worksheets/{id}/charts/{id}/title/format/fill/clear                                  POST
/me/mailfolders/inbox/messagerules/{id}                                                                            DELETE, PATCH, GET
/me/onlinemeetings/{id}                                                                                            DELETE, PATCH, GET
/me/authentication/hardwareoathmethods/{id}/activate                                                               POST
/me/onlinemeetings/getactivemeetingdetails(callconversationid={conversationid})                                    GET
/me/contactfolders/{id}/contacts/{id}/photo                                                                        PUT, PATCH, GET
/me/outlook/taskgroups/{id}/taskfolders/{id}                                                                       DELETE, PATCH, GET
/me/drive/items/{id}/workbook/worksheets/{id}/tables/{id}/rows/itemat                                              POST
/me/drive/root:/{id}:/workbook/worksheets/{id}/charts/{id}/axes/seriesaxis/majorgridlines/format/line/clear        POST
/me/mailfolders/inbox/messagerules                                                                                 POST, GET
/me/photos                                                                                                         GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/range(address={value})/format/fill/clear                            POST
/me/cloudlicensing/assignments/{id}/allotment/$ref                                                                 PUT
/me/authentication/qrcodepinmethod/temporaryqrcode                                                                 DELETE, PATCH, GET
/me/communications/callsettings/delegators                                                                         GET
/me/drive/items/{id}/workbook/worksheets/{id}/range(address={value})/insert                                        POST
/me/profile/webaccounts                                                                                            POST, GET
/me/outlook/supportedtimezones                                                                                     GET
/me/drive/items/{id}:/{id}:/contentstream                                                                          PUT
/me/drive/items/{id}/versions/{id}/restoreversion                                                                  POST
/me/drive/items/{id}/workbook/tables/{id}/columns/{id}/range/sort/apply                                            POST
/me/devices/{id}/commands/{id}                                                                                     GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/charts/{id}/series/{id}/points/{id}                                 GET
/me/profile/languages                                                                                              POST, GET
/me/drive/items/{id}/workbook/tables/{id}/sort/reapply                                                             POST
/me/cloudlicensing/assignments/{id}                                                                                DELETE, PATCH, GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/charts/{id}/legend/format/fill/clear                                POST
/me/drive/items/{id}/workbook/worksheets/{id}/charts/{id}/title/format/fill/setsolidcolor                          POST
/me/cloudpcs/{id}/stop                                                                                             POST
/me/print/recentprintershares                                                                                      GET
/me/calendars/{id}/events/{id}/dismissreminder                                                                     POST
/me/drive/root:/{id}:/workbook/tables/{id}/columns                                                                 POST, GET
/me/calendargroups/{id}/calendars/{id}/events/{id}/instances                                                       GET
/me/drive/items/{id}/versions/streams/{id}                                                                         GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/tables/{id}/columns/{id}/totalrowrange                              GET
/me/onlinemeetings/{id}/transcripts/{id}/content                                                                   GET
/me/employeeexperience/learningcourseactivities/{id}                                                               GET
/me/planner/all/delta                                                                                              GET
/me/calendar/calendarview                                                                                          GET
/me/onlinemeetings/{id}/registration                                                                               DELETE, PATCH, POST, GET
/me/drive/items/{id}/workbook/worksheets/{id}/range(address={value})/offsetrange                                   GET
/me/drive/items/{id}/workbook/worksheets/{id}/tables/{id}/totalrowrange                                            GET
/me/drive/items/{id}/workbook/names/{id}/range/row                                                                 POST
/me/profile/names                                                                                                  POST, GET
/me/mailfolders/{id}/childfolders                                                                                  POST, GET
/me/messages/{id}/attachments/createuploadsession                                                                  POST
/me/drive/root:/{id}:/workbook/names                                                                               GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/range(address={value})/cell                                         GET
/me/drive/items/{id}/workbook/tables/{id}/columns/{id}/range/lastrow                                               GET
/me/drive/items/{id}/workbook/tables/{id}/columns/{id}/range/delete                                                POST
/me/drive/items/{id}/workbook/tables/{id}/columns                                                                  POST, GET
/me/drive/items/{id}/workbook/worksheets/{id}/range(address={value})/format/borders/itemat                         POST
/me/calendargroups/{id}/calendars/{id}                                                                             DELETE
/me/drive/root:/{id}:/workbook/worksheets/{id}/range/rowsabove(count={value})                                      GET
/me/insights/shared                                                                                                GET
/me/drive/items/{id}/workbook/worksheets/{id}/range(address={value})/visibleview/rows                              GET
/me/drive/root/search(q={value})                                                                                   GET
/me/drive/root:/{id}:/workbook/tables/{id}/columns/{id}/range/usedrange                                            GET
/me/drive/items/{id}/thumbnails                                                                                    GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/range(address={value})/row                                          POST
/me/drive/root:/foldera/fileb.txt:/contentstream                                                                   PUT
/me/drive/items/{id}/workbook/worksheets/{id}/charts/{id}/image(width={value},height={value},fittingmode={value})  GET
/me/profile/patents                                                                                                POST, GET
/me/profile/websites                                                                                               POST, GET
/me/authentication/emailmethods/{id}                                                                               DELETE, PATCH, GET
/me/tasks/alltasks/{id}/move                                                                                       POST
/me/drive/items/{id}/workbook/tables/{id}/columns/{id}/range/merge                                                 POST
/me/todo/lists/{id}/tasks/{id}/checklistitems                                                                      POST, GET
/me/onenote/sectiongroups/{id}                                                                                     GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/charts/{id}/legend/format/fill/setsolidcolor                        POST
/me/drive/items/{id}/workbook/worksheets/{id}/range(address={value})/lastcolumn                                    GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/range(address={value})/usedrange                                    GET
/me/drive/items/{id}/workbook/tables/{id}                                                                          DELETE, PATCH, GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/tables/{id}/columns/{id}/filter/clear                               POST
/me/chats                                                                                                          GET
/me/calendargroups/{id}/calendars/{id}/events/{id}/forward                                                         POST
/me/profile/addresses                                                                                              POST, GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/range(address={value})/delete                                       POST
/me/onlinemeetings/{meetingid}/attendancereports/{reportid}                                                        GET
/me/calendargroups/{id}/calendars/{id}/events/{id}/dismissreminder                                                 POST
/me/planner/plans                                                                                                  GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/range(address={value})/intersection                                 GET
/me/drive/items/{id}/workbook/worksheets/{id}/range(address={value})/format/autofitrows                            POST
/me/drive/root:/{id}:/workbook/tables/{id}/columns/{id}/totalrowrange                                              GET
/me/drive/items/{id}/workbook/names/{id}/range/delete                                                              POST
/me/drive/root:/{id}:/workbook/tables/{id}/columns/{id}                                                            DELETE, PATCH, GET
/me/drive/items/{id}/workbook/tables/{id}/columns/add                                                              POST
/me/drive/root:/{id}:/workbook/names/{id}/range/format/fill                                                        PATCH, GET
/me/outlook/taskgroups/{id}/taskfolders                                                                            POST, GET
/me/drive/items/{id}/workbook/worksheets/{id}/range(address={value})/boundingrect                                  GET
/me/adhoccalls/{id}/recordings                                                                                     GET
/me/drive/items/{id}/contentstream                                                                                 PUT, GET
/me/drive/items/{id}/workbook/worksheets/{id}/range/columnsbefore(count={value})                                   GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/charts                                                              POST, GET
/me/chats/{id}                                                                                                     GET
/me/drive/items/{id}/workbook/tables/{id}/columns/{id}/range/format/borders/{id}                                   PATCH, GET
/me/pendingaccessreviewinstances/{id}/batchrecorddecisions                                                         POST
/me/transitivememberof                                                                                             GET
/me/drive/items/{id}/workbook/worksheets/{id}/charts/{id}/legend/format/fill/clear                                 POST
/me/drive/items/{id}/preview                                                                                       POST
/me/drive/root:/{id}:/workbook/names/{id}/range/format/borders/itemat                                              POST
/me/authentication/phonemethods/{id}/disablesmssignin                                                              POST
/me/drive/root:/{id}:/workbook/worksheets/{id}/tables/{id}/clearfilters                                            POST
/me/drive/root:/{id}:/workbook/worksheets/{id}/range(address={value})/merge                                        POST
/me/outlook/taskgroups/{id}                                                                                        DELETE, PATCH, GET
/me/calendars/{id}/events/{id}/tentativelyaccept                                                                   POST
/me/drive/items/{id}/workbook/tables/{id}/columns/{id}/range/insert                                                POST
/me/drive/items/{id}/workbook/tables/{id}/columns/{id}/range/format                                                PATCH, GET
/me/drive/root:/{id}:/workbook/refreshsession                                                                      POST
/me/drive/items/{id}/workbook/application                                                                          GET
/me/adhoccalls/{id}/transcripts/{id}                                                                               GET
/me/drive/items/{id}/workbook/worksheets/{id}/range/resizedrange(deltarows={value}, deltacolumns={value})          POST
/me/tasks/lists/{id}/tasks/{id}/linkedresources/{id}                                                               DELETE, PATCH, GET
/me/drive/items/{id}/workbook/tables/{id}/columns/{id}/filter/clear                                                POST
/me/drive/sharedwithme                                                                                             GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/charts/{id}/datalabels                                              PATCH, GET
/me/drive/items/{id}/workbook/names/{id}/range/intersection                                                        GET
/me/tasks/alltasks/{id}                                                                                            DELETE, PATCH, GET
/me/authentication/passwordmethods/{id}/isupdatesupported                                                          GET
/me/drive/items/{id}/workbook/worksheets/{id}/range(address={value})/entirerow                                     GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/tables/{id}/rows/itemat(index={value})/range                        GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/charts/{id}/setdata                                                 POST
/me/authentication/platformcredentialmethods/{id}                                                                  DELETE, GET
/me/drive/items/{id}/workbook/worksheets/{id}/tables/add                                                           POST
/me/settings/workhoursandlocations/occurrences/setcurrentlocation                                                  POST
/me/drive/items/{id}/workbook/names/{id}/range/sort/apply                                                          POST
/me/profile/projects                                                                                               POST, GET
/me/onlinemeetings/{id}/aiinsights                                                                                 GET
/me/drive/root:/{id}:/createuploadsession                                                                          POST
/me/drive/items/{id}/workbook/worksheets/{id}/tables/{id}/reapplyfilters                                           POST
/me/drive/root:/{id}:/workbook/worksheets/{id}/range(address={value})/visibleview                                  GET
/me/drive/root:/{id}:/workbook/tables/{id}/columns/{id}/range/offsetrange                                          GET
/me/onenote/pages/{id}/content                                                                                     PATCH, GET
/me/onenote/notebooks/{id}/sections                                                                                POST, GET
/me/employeeexperience/assignedroles                                                                               GET
/me/drive/items/{id}/versions/{id}/content                                                                         GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/charts/{id}/image(width={value},height={value})                     GET
/me/drive/root:/{id}:/workbook/tablerowoperationresult(key={value})                                                GET
/me/settings/storage/quota/services                                                                                GET
/me/outlook                                                                                                        GET
/me/ownedobjects                                                                                                   GET
/me/drive/root:/{id}:/workbook/tables/{id}/columns/{id}/range                                                      PATCH, GET
/me/drive/items/{id}/workbook/tables/{id}/columns/{id}/range/format/protection                                     PATCH, GET
/me/onlinemeetings/{id}/attendancereports/{id}                                                                     GET
/me/drive/root:/{id}:/workbook/tables/{id}/columns/{id}/range/lastrow                                              GET
/me/calendars/{id}/calendarview                                                                                    GET
/me/drive/items/{id}/workbook/worksheets/{id}/range(address={value})                                               PATCH, GET
/me/onenote/pages                                                                                                  POST, GET
/me/drive/items/{id}/workbook/worksheets/{id}/range(address={value})/cell                                          GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/charts/{id}/axes/valueaxis/format/font                              PATCH, GET
/me/drive/items/{id}/extractsensitivitylabels                                                                      POST
/me/settings/workhoursandlocations/recurrences                                                                     POST, GET
/me/contacts/{id}                                                                                                  DELETE, PATCH, GET
/me/drive/special/{id}                                                                                             GET
/me/todo/lists/{id}/tasks/{id}/checklistitems/{id}                                                                 DELETE, PATCH, GET
/me/activities/recent                                                                                              GET
/me/drive/root:/{id}:/workbook/worksheets/{id}                                                                     DELETE, PATCH, GET
/me/outlook/supportedtimezones(timezonestandard={value})                                                           GET
/me/drive/items/{id}/workbook/worksheets/{id}/range(address={value})/format                                        PATCH, GET
/me/drive/items/{id}/workbook/tables/{id}/totalrowrange                                                            GET
/me/drive/root:/{id}:/workbook/tables/{id}/sort/reapply                                                            POST
/me/drive/items/{id}/workbook/worksheets/{id}/range(address={value})/format/protection                             PATCH, GET
/me/cloudclipboard/items/{id}                                                                                      GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/range/resizedrange(deltarows={value}, deltacolumns={value})         POST
/me/drive/root:/{id}:/workbook/worksheets/{id}/tables/{id}/sort/reapply                                            POST
/me/drive/items/{id}/versions/{id}/streams                                                                         GET
/me/drive/items/{id}/workbook/tables/{id}/rows/itemat                                                              POST
/me/drive/items/{id}/workbook/tables/{id}/databodyrange                                                            GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/charts/{id}/title/format/fill/setsolidcolor                         POST
/me/cloudpcs/{id}/reboot                                                                                           POST
/me/drive/items/{id}/workbook/tables/{id}/columns/{id}/range                                                       PATCH, GET
/me/drive/items/{id}/workbook/tables/{id}/columns/{id}/range/row                                                   POST
/me/approleassignedresources                                                                                       GET
/me/mailfolders/{id}/messages/{id}/reply                                                                           POST
/me/drive/items/{id}/workbook/names/add                                                                            POST
/me/drive/items/{id}/workbook/worksheets/{id}/names/{id}                                                           DELETE
/me/drive/items/{id}/workbook/tables/{id}/sort/fields/icon                                                         PATCH, GET
/me/planner                                                                                                        PATCH, GET
/me/drive/root:/{id}:/workbook/tables/{id}/columns/{id}/filter/apply                                               POST
/me/presence                                                                                                       GET
/me/mailfolders/{id}/copy                                                                                          POST
/me/drive/items/{id}/workbook/names/{id}/range/entirecolumn                                                        GET
/me/drive/items/{id}/workbook/worksheets/{id}/charts/{id}/axes/seriesaxis/format/line/clear                        POST
/me/inferenceclassification/overrides/{id}                                                                         DELETE, PATCH
/me/adhoccalls/{id}/transcripts/{id}/content                                                                       GET
/me/photo                                                                                                          DELETE, PUT, PATCH, GET
/me/insights/used/{id}/resource                                                                                    GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/tables/{id}/rows/add                                                POST
/me/messages                                                                                                       POST, GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/range(address={value})/lastcolumn                                   GET
/me/calendarview/delta                                                                                             GET
/me/authentication/passwordmethods                                                                                 GET
/me/drive/root:/{id}:/workbook/tables/{id}/sort/fields/icon                                                        PATCH, GET
/me/drive/items/{id}/extensions/{id}                                                                               DELETE, PATCH, POST, GET
/me/drive/root:/{id}:/workbook/names/{id}/range/entirerow                                                          GET
/me/drive/root:/{id}:/workbook/tables/{id}/columns/{id}/range/entirerow                                            GET
/me/drive/items/{id}/workbook/names/{id}/range/format/fill/clear                                                   POST
/me/drive/items/{id}/workbook/worksheets/{id}/tables/{id}/rows/{id}                                                DELETE, PATCH, GET
/me/responsibilities                                                                                               POST, GET
/me/profile/websites/{id}                                                                                          DELETE, PATCH, GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/names                                                               GET
/me/onlinemeetings/{id}/sendvirtualappointmentremindersms                                                          POST
/me/drive/items/{id}/workbook/worksheets/{id}/charts/{id}/axes/valueaxis/title                                     PATCH, GET
/me/findmeetinglocations                                                                                           POST
/me/drive/items/{id}/workbook/tablerowoperationresult(key={value})                                                 GET
/me/drive/items/{id}/workbook/worksheets/{id}/charts/{id}/series/{id}/points/{id}                                  GET
/me/drive/root:/{id}/extractsensitivitylabels                                                                      POST
/me/calendars/{id}/events                                                                                          POST, GET
/me/drive/items/{id}/streams/{id}/content                                                                          GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/charts/{id}/axes/categoryaxis/format/font                           PATCH, GET
/me/messages/{id}/permanentdelete                                                                                  POST
/me/drive/root:/{id}:/workbook/closesession                                                                        POST
/me/drive/root:/{id}:/workbook/tables/{id}/rows/{id}/range                                                         GET
/me/drive/root:/{id}:/workbook/names/{id}/range/usedrange                                                          GET
/me/memberof                                                                                                       GET
/me/drive/items/{id}/workbook/worksheets/{id}/range(address={value})/clear                                         POST
/me/drive/items/{id}/workbook/tables/{id}/converttorange                                                           POST
/me/drive/items/{id}/workbook/names/{id}/range                                                                     PATCH, GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/tables                                                              GET
/me/drive/root:/{id}:/workbook/worksheets/{id}/charts/{id}/axes/valueaxis                                          PATCH, GET
/me/communications/meetingtemplates                                                                                GET
/me/authentication/platformcredentialmethods                                                                       GET
/me/drive/items/{id}/workbook/worksheets/{id}/tables/{id}/rows                                                     POST, GET
/me/drive/items/{id}/workbook/worksheets/{id}/charts                                                               POST, GET
/me/drive/items/{id}/workbook/worksheets/{id}/range(address={value})/lastrow                                       GET
/me/informationprotection/policy/labels/evaluateapplication                                                        POST
/me/calendargroups/{id}/calendars/{id}/events/{id}/cancel                                                          POST
/me/drive/root:/{id}:/workbook/worksheets/{id}/range(address={value})/format                                       PATCH, GET
/me/outlook/mastercategories/{id}                                                                                  DELETE, PATCH, GET
/me/drive/following                                                                                                GET
/me/authentication/hardwareoathmethods/assignandactivatebyserialnumber                                             POST
/me/calendar/events/{id}/decline                                                                                   POST
```

</details>

# Find specific endpoints
```powershell
Find-GraphPath -Pattern "*/messages"
```
<details>
<summary>Output:</summary>

```
Path                                            Methods
----                                            -------
/users/{id}/messages                            POST, GET
/users/{id}/mailfolders/{id}/messages           POST, GET
/chats/{id}/messages                            POST, GET
/admin/serviceannouncement/messages             GET
/users/{id}/chats/{id}/messages                 GET
/teams/{id}/channels/{id}/messages              POST, GET
/me/chats/{id}/messages                         GET
/me/mailfolders/{id}/messages                   POST, GET
/employeeexperience/conversations/{id}/messages POST
/me/messages                                    POST, GET
```

</details>


## Usage Examples

### Example 1: Basic Least Privilege Lookup

```powershell
# What's the least privileged permission to read my messages?
Find-GraphLeastPrivilege -Path "/me/messages" -Method GET -Scheme DelegatedWork
```
<details>
<summary>Output:</summary>

```
Path         Method Scheme        Permission
----         ------ ------        ----------
/me/messages GET    DelegatedWork Mail.ReadBasic
```

</details>

### Example 2: Compare Delegated vs Application Permissions

```powershell
# Delegated permission
Find-GraphLeastPrivilege -Path "/users/{id}/messages" -Method GET -Scheme DelegatedWork
```
<details>
<summary>Output:</summary>

```
Path                 Method Scheme        Permission
----                 ------ ------        ----------
/users/{id}/messages GET    DelegatedWork Mail.ReadBasic
```

</details>

# Application permission
```powershell
Find-GraphLeastPrivilege -Path "/users/{id}/messages" -Method GET -Scheme Application
```
<details>
<summary>Output:</summary>

```
Path                 Method Scheme      Permission
----                 ------ ------      ----------
/users/{id}/messages GET    Application Mail.ReadBasic.All
```

</details>


### Example 3: Find All Permissions for an Endpoint

```powershell
# See all available permissions and which are least privileged
Get-GraphPermissions -Path "/users/{id}/messages" -Method GET | Format-Table Permission, Scheme, IsLeastPrivileged
```
<details>
<summary>Output:</summary>

```
Permission         Scheme            IsLeastPrivileged
----------         ------            -----------------
Mail.Read          Application                   False
Mail.ReadBasic.All Application                    True
Mail.ReadWrite     Application                    True
Mail.Read          DelegatedPersonal             False
Mail.ReadBasic     DelegatedPersonal              True
Mail.ReadWrite     DelegatedPersonal              True
Mail.Read          DelegatedWork                 False
Mail.ReadBasic     DelegatedWork                  True
Mail.ReadWrite     DelegatedWork                  True
```

</details>


### Example 4: Bulk Query Multiple Endpoints

```powershell
$endpoints = @(
    "/me/messages",
    "/me/calendar/events",
    "/me/drive/root/children"
)

$results = $endpoints | Find-GraphLeastPrivilege -Method GET -Scheme DelegatedWork
$results | Format-Table Path, Permission
```
<details>
<summary>Output:</summary>

```
Path                    Permission
----                    ----------
/me/messages            Mail.ReadBasic
/me/calendar/events     Calendars.ReadBasic
/me/drive/root/children Files.Read
```

</details>



### Example 5: Discovery - Find Related Paths

```powershell
# Find all mailboxprotectionunits-related endpoints
Find-GraphPath -Pattern "*mailboxprotectionunits*"
```
<details>
<summary>Output:</summary>

```
Path                                                                                                            Methods
----                                                                                                            -------
/backuprestore/mailboxprotectionunits                                                                           GET
/backuprestore/exchangeprotectionpolicies/{policyid}/mailboxprotectionunitsbulkadditionjobs/{bulkadditionjobid} GET
/backuprestore/exchangeprotectionpolicies/{policyid}/mailboxprotectionunitsbulkadditionjobs                     POST, GET
/backuprestore/exchangeprotectionpolicies/{policyid}/mailboxprotectionunits                                     GET
```

</details>

# Find all paths under identity governance lifecycleworkflows workflows
```powershell
Find-GraphPath -Pattern "/identitygovernance/lifecycleworkflows/workflows*"
```
<details>
<summary>Output:</summary>

```
Path                                                                                                                           Methods
----                                                                                                                           -------
/identitygovernance/lifecycleworkflows/workflows/{id}/runs                                                                     GET
/identitygovernance/lifecycleworkflows/workflows/{id}/versions/{id}/tasks/{id}                                                 GET
/identitygovernance/lifecycleworkflows/workflows({id})/previewscope                                                            GET
/identitygovernance/lifecycleworkflows/workflows/{id}/runs/{id}                                                                GET
/identitygovernance/lifecycleworkflows/workflows/{id}/activate                                                                 POST
/identitygovernance/lifecycleworkflows/workflows/{id}/userprocessingresults/summary(startdatetime={value},enddatetime={value}) GET
/identitygovernance/lifecycleworkflows/workflows/{id}/taskreports                                                              GET
/identitygovernance/lifecycleworkflows/workflows/{id}/runs/{id}/userprocessingresults/{id}                                     GET
/identitygovernance/lifecycleworkflows/workflows/{id}/taskreports/summary(startdatetime={value},enddatetime={value})           GET
/identitygovernance/lifecycleworkflows/workflows/{id}/tasks/{id}                                                               PATCH, GET
/identitygovernance/lifecycleworkflows/workflows/{id}                                                                          DELETE, PATCH, GET
/identitygovernance/lifecycleworkflows/workflows                                                                               POST, GET
/identitygovernance/lifecycleworkflows/workflows/{id}/tasks/{id}/taskprocessingresults                                         GET
/identitygovernance/lifecycleworkflows/workflows/{id}/versions/{id}/tasks                                                      GET
/identitygovernance/lifecycleworkflows/workflows/{id}/runs/{id}/userprocessingresults/{id}/taskprocessingresults               GET
/identitygovernance/lifecycleworkflows/workflows/{id}/userprocessingresults                                                    GET
/identitygovernance/lifecycleworkflows/workflows({id})/previewtaskfailures                                                     GET
/identitygovernance/lifecycleworkflows/workflows/{id}/runs/{id}/userprocessingresults                                          GET
/identitygovernance/lifecycleworkflows/workflows({id})/previewworkflow                                                         POST
/identitygovernance/lifecycleworkflows/workflows/{id}/versions                                                                 GET
/identitygovernance/lifecycleworkflows/workflows/{id}/tasks/{id}/taskprocessingresults/{id}/resume                             POST
/identitygovernance/lifecycleworkflows/workflows/{id}/tasks                                                                    GET
/identitygovernance/lifecycleworkflows/workflows/{id}/taskreports/{id}/taskprocessingresults                                   GET
/identitygovernance/lifecycleworkflows/workflows/{id}/executionscope                                                           GET
/identitygovernance/lifecycleworkflows/workflows/{id}/createnewversion                                                         POST
/identitygovernance/lifecycleworkflows/workflows/{id}/runs/{id}/taskprocessingresults                                          GET
/identitygovernance/lifecycleworkflows/workflows/{id}/userprocessingresults/{id}/taskprocessingresults                         GET
/identitygovernance/lifecycleworkflows/workflows/{id}/versions/{id}                                                            GET
/identitygovernance/lifecycleworkflows/workflows/{id}/runs/summary(startdatetime={value},enddatetime={value})                  GET
```

</details>



## Data Source

Permissions are automatically downloaded from:
```
https://raw.githubusercontent.com/microsoftgraph/microsoft-graph-devx-content/refs/heads/master/permissions/new/permissions.json
```

This ensures you always have the latest Microsoft Graph permissions metadata.

If you need it refreshed imeadiatly you can run
```powershell
Initialize-GraphPermissions -Force
```

## Common Use Cases

### Security Auditing
```powershell
# Check if an app is using least privileged permissions
$appPaths = @("/users", "/groups/{id}/organizationalUnitParent", "/applications")
foreach ($path in $appPaths) {
    $least = Find-GraphLeastPrivilege -Path $path -Method GET -Scheme Application
    "$path requires: $($least.Permission)"
}
```
<details>
<summary>Output:</summary>

```
/users requires: User.ReadBasic.All
/groups/{id}/organizationalUnitParent requires: Group.Read.All
/applications requires: Application.Read.All
```

</details>


### Documentation Generation
```powershell
# Generate permission requirements for API documentation
$apiPaths = Find-GraphPath -Pattern "/users/{id}/profile/*"
foreach ($path in $apiPaths) {
    foreach ($pathMethod in $path.Methods.Split(",").trim()) {
        $perms = Find-GraphLeastPrivilege -Path $path.Path -Method $pathMethod
        [PSCustomObject]@{
            Endpoint = $path.Path
            Permission = $perms.Permission
            Scheme = $perms.Scheme
        }
    }
}
```
<details>
<summary>Output:</summary>

```
Endpoint                                       Permission                                           Scheme
--------                                       ----------                                           ------
/users/{id}/profile/publications/{id}          {User.ReadWrite.All, User.ReadWrite, User.ReadWrite} {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/publications/{id}          {User.ReadWrite.All, User.ReadWrite, User.ReadWrite} {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/publications/{id}          {User.Read.All, User.Read, User.Read}                {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/languages                  {User.ReadWrite.All, User.ReadWrite, User.ReadWrite} {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/languages                  {User.Read.All, User.Read, User.Read}                {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/publications               {User.ReadWrite.All, User.ReadWrite, User.ReadWrite} {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/publications               {User.Read.All, User.Read, User.Read}                {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/projects                   {User.ReadWrite.All, User.ReadWrite, User.ReadWrite} {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/projects                   {User.Read.All, User.Read, User.Read}                {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/awards                     {User.ReadWrite.All, User.ReadWrite, User.ReadWrite} {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/awards                     {User.Read.All, User.Read, User.Read}                {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/names/{id}                 {User.ReadWrite.All, User.ReadWrite, User.ReadWrite} {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/names/{id}                 {User.ReadWrite.All, User.ReadWrite, User.ReadWrite} {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/names/{id}                 {User.Read.All, User.Read, User.Read}                {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/skills/{id}                {User.ReadWrite.All, User.ReadWrite, User.ReadWrite} {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/skills/{id}                {User.ReadWrite.All, User.ReadWrite, User.ReadWrite} {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/skills/{id}                {User.Read.All, User.Read, User.Read}                {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/languages/{id}             {User.ReadWrite.All, User.ReadWrite, User.ReadWrite} {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/languages/{id}             {User.ReadWrite.All, User.ReadWrite, User.ReadWrite} {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/languages/{id}             {User.Read.All, User.Read, User.Read}                {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/positions/{id}             {User.ReadWrite.All, User.ReadWrite, User.ReadWrite} {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/positions/{id}             {User.ReadWrite.All, User.ReadWrite, User.ReadWrite} {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/positions/{id}             {User.Read.All, User.Read, User.Read}                {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/educationalactivities/{id} {User.ReadWrite.All, User.ReadWrite, User.ReadWrite} {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/educationalactivities/{id} {User.ReadWrite.All, User.ReadWrite, User.ReadWrite} {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/educationalactivities/{id} {User.Read.All, User.Read, User.Read}                {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/webaccounts                {User.ReadWrite.All, User.ReadWrite, User.ReadWrite} {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/webaccounts                {User.Read.All, User.Read, User.Read}                {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/notes/{id}                 {User.Read.All, User.Read, User.Read}                {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/notes/{id}                 {User.Read.All, User.Read, User.Read}                {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/notes/{id}                 {User.Read.All, User.Read, User.Read}                {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/anniversaries              {User.ReadWrite.All, User.ReadWrite, User.ReadWrite} {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/anniversaries              {User.Read.All, User.Read, User.Read}                {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/account/{id}               {User.ReadWrite.All, User.ReadWrite, User.ReadWrite} {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/account/{id}               {User.ReadWrite.All, User.ReadWrite, User.ReadWrite} {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/account/{id}               {User.Read.All, User.Read, User.Read}                {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/emails/{id}                {User.ReadWrite.All, User.ReadWrite, User.ReadWrite} {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/emails/{id}                {User.ReadWrite.All, User.ReadWrite, User.ReadWrite} {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/emails/{id}                {User.Read.All, User.Read, User.Read}                {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/projects/{id}              {User.ReadWrite.All, User.ReadWrite, User.ReadWrite} {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/projects/{id}              {User.ReadWrite.All, User.ReadWrite, User.ReadWrite} {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/projects/{id}              {User.Read.All, User.Read, User.Read}                {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/anniversaries/{id}         {User.ReadWrite.All, User.ReadWrite, User.ReadWrite} {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/anniversaries/{id}         {User.ReadWrite.All, User.ReadWrite, User.ReadWrite} {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/anniversaries/{id}         {User.Read.All, User.Read, User.Read}                {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/educationalactivities      {User.ReadWrite.All, User.ReadWrite, User.ReadWrite} {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/educationalactivities      {User.Read.All, User.Read, User.Read}                {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/websites                   {User.ReadWrite.All, User.ReadWrite, User.ReadWrite} {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/websites                   {User.Read.All, User.Read, User.Read}                {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/skills                     {User.ReadWrite.All, User.ReadWrite, User.ReadWrite} {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/skills                     {User.Read.All, User.Read, User.Read}                {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/positions                  {User.ReadWrite.All, User.ReadWrite, User.ReadWrite} {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/positions                  {User.Read.All, User.Read, User.Read}                {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/webaccounts/{id}           {User.ReadWrite.All, User.ReadWrite, User.ReadWrite} {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/webaccounts/{id}           {User.ReadWrite.All, User.ReadWrite, User.ReadWrite} {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/webaccounts/{id}           {User.Read.All, User.Read, User.Read}                {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/patents                    {User.ReadWrite.All, User.ReadWrite, User.ReadWrite} {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/patents                    {User.Read.All, User.Read, User.Read}                {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/phones/{id}                {User.ReadWrite.All, User.ReadWrite, User.ReadWrite} {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/phones/{id}                {User.ReadWrite.All, User.ReadWrite, User.ReadWrite} {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/phones/{id}                {User.Read.All, User.Read, User.Read}                {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/phones                     {User.ReadWrite.All, User.ReadWrite, User.ReadWrite} {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/phones                     {User.Read.All, User.Read, User.Read}                {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/notes                      {User.ReadWrite.All, User.ReadWrite, User.ReadWrite} {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/notes                      {User.Read.All, User.Read, User.Read}                {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/awards/{id}                {User.ReadWrite.All, User.ReadWrite, User.ReadWrite} {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/awards/{id}                {User.ReadWrite.All, User.ReadWrite, User.ReadWrite} {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/awards/{id}                {User.Read.All, User.Read, User.Read}                {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/addresses/{id}             {User.ReadWrite.All, User.ReadWrite, User.ReadWrite} {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/addresses/{id}             {User.ReadWrite.All, User.ReadWrite, User.ReadWrite} {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/addresses/{id}             {User.Read.All, User.Read, User.Read}                {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/patents/{id}               {User.ReadWrite.All, User.ReadWrite, User.ReadWrite} {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/patents/{id}               {User.ReadWrite.All, User.ReadWrite, User.ReadWrite} {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/patents/{id}               {User.Read.All, User.Read, User.Read}                {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/certifications/{id}        {User.ReadWrite.All, User.ReadWrite, User.ReadWrite} {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/certifications/{id}        {User.ReadWrite.All, User.ReadWrite, User.ReadWrite} {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/certifications/{id}        {User.Read.All, User.Read, User.Read}                {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/interests                  {User.ReadWrite.All, User.ReadWrite, User.ReadWrite} {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/interests                  {User.Read.All, User.Read, User.Read}                {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/websites/{id}              {User.ReadWrite.All, User.ReadWrite, User.ReadWrite} {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/websites/{id}              {User.ReadWrite.All, User.ReadWrite, User.ReadWrite} {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/websites/{id}              {User.Read.All, User.Read, User.Read}                {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/emails                     {User.ReadWrite.All, User.ReadWrite, User.ReadWrite} {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/emails                     {User.Read.All, User.Read, User.Read}                {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/names                      {User.Read.All, User.Read, User.Read}                {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/names                      {User.Read.All, User.Read, User.Read}                {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/addresses                  {User.ReadWrite.All, User.ReadWrite, User.ReadWrite} {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/addresses                  {User.Read.All, User.Read, User.Read}                {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/certifications             {User.ReadWrite.All, User.ReadWrite, User.ReadWrite} {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/certifications             {User.Read.All, User.Read, User.Read}                {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/account                    {User.ReadWrite.All, User.ReadWrite, User.ReadWrite} {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/account                    {User.Read.All, User.Read, User.Read}                {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/interests/{id}             {User.ReadWrite.All, User.ReadWrite, User.ReadWrite} {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/interests/{id}             {User.ReadWrite.All, User.ReadWrite, User.ReadWrite} {Application, DelegatedWork, DelegatedPersonal}
/users/{id}/profile/interests/{id}             {User.Read.All, User.Read, User.Read}                {Application, DelegatedWork, DelegatedPersonal}

```
</details>

### Application Registration Planning
```powershell
# Plan minimal permissions for a new app
$requiredPaths = @(
    "/me/messages",
    "/me/calendar/events",
    "/me/contacts"
)

$permissions = $requiredPaths | 
    Find-GraphLeastPrivilege -Method GET -Scheme DelegatedWork |
    Select-Object -ExpandProperty Permission -Unique

"Required permissions: $($permissions -join ', ')"
```
<details>
<summary>Output:</summary>

```
Required permissions: Mail.ReadBasic, Calendars.ReadBasic, Contacts.Read
```

</details>

### Permissions Not Found
```powershell
# Force fresh download
Initialize-GraphPermissions -Force

# Check if path exists
Find-GraphPath -Pattern "*your-path*"

# Paths are case-insensitive, but check exact format
Get-GraphPermissions -Path "/users/{id}" -Verbose

# Note that some paths does not have an explicit least privileged permission in the source data and 
# if there are more than 1 available permission and none is defined as least then it is unable to determine least privileged permission

```

### Download Fails
```powershell
# Use -Verbose to see download details
Initialize-GraphPermissions -Force -Verbose
```
<details>
<summary>Output:</summary>

```
VERBOSE: Downloading permissions from https://raw.githubusercontent.com/microsoftgraph/microsoft-graph-devx-content/refs/heads/master/permissions/new/permissions.json
VERBOSE: Requested HTTP/1.1 GET with 0-byte payload
VERBOSE: Received HTTP/1.1 response of content type text/plain of unknown size
VERBOSE: Successfully loaded permissions data with 6950 paths
```

</details>


## Contributing

This module replicates the functionality of [Kibali](https://github.com/microsoftgraph/kibali). For issues with the underlying permissions data, please refer to the upstream Microsoft Graph repository:
[microsoft-graph-devx-content](https://github.com/microsoftgraph/microsoft-graph-devx-content)


## Related Projects

- [Kibali](https://github.com/microsoftgraph/kibali) - Original C# implementation
- [microsoft-graph-devx-content](https://github.com/microsoftgraph/microsoft-graph-devx-content)
- [Microsoft Graph Documentation](https://learn.microsoft.com/graph/)
- [Microsoft Graph Permissions Reference](https://learn.microsoft.com/graph/permissions-reference)
