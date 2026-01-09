<#
.SYNOPSIS
    Builds module documentation using PlatyPS.

.DESCRIPTION
    This script generates and updates documentation for the MSGraphPermissions module:
    - Generates/updates Markdown documentation from comment-based help
    - Compiles Markdown into MAML help files for Get-Help
    - Validates the generated documentation

.PARAMETER UpdateMarkdown
    Updates existing Markdown files instead of creating new ones.

.PARAMETER Force
    Forces regeneration of all documentation files.

.EXAMPLE
    .\Build-Documentation.ps1
    Generates initial documentation files.

.EXAMPLE
    .\Build-Documentation.ps1 -UpdateMarkdown
    Updates existing Markdown documentation with any changes from comment-based help.
#>
param(
    [switch]$UpdateMarkdown,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

# Module paths
$ModuleRoot = Split-Path $PSScriptRoot -Parent
$ModuleName = 'MSGraphPermissions'
$ModulePath = Join-Path $ModuleRoot "$ModuleName\$ModuleName.psd1"
$DocsPath = Join-Path $ModuleRoot 'docs'
$ExternalHelpPath = Join-Path $ModuleRoot "$ModuleName\en-US"

# Ensure PlatyPS is available
if (-not (Get-Module -ListAvailable -Name Microsoft.PowerShell.PlatyPS)) {
    Write-Warning "PlatyPS module not found. Installing..."
    Install-Module -Name Microsoft.PowerShell.PlatyPS -Scope CurrentUser -Force
}

Import-Module Microsoft.PowerShell.PlatyPS -Force

# Create directories if they don't exist
if (-not (Test-Path $DocsPath)) {
    New-Item -Path $DocsPath -ItemType Directory -Force | Out-Null
    "Created docs directory: $DocsPath"
}

if (-not (Test-Path $ExternalHelpPath)) {
    New-Item -Path $ExternalHelpPath -ItemType Directory -Force | Out-Null
    "Created en-US directory: $ExternalHelpPath"
}

# Import the module to get latest help
"Importing module from: $ModulePath"
Import-Module $ModulePath -Force

# Generate or update Markdown documentation
$moduleDocsPath = Join-Path $DocsPath $ModuleName

# Check if module docs folder exists and has markdown files
$existingDocs = $null
if (Test-Path $moduleDocsPath) {
    $existingDocs = Get-ChildItem -Path $moduleDocsPath -Filter "*.md" -ErrorAction SilentlyContinue
}

if ($UpdateMarkdown -and $existingDocs) {
    "`nUpdating Markdown documentation..."
    
    # Update existing markdown files
    Update-MarkdownCommandHelp -Path $moduleDocsPath
    
    # Update module page
    $moduleMdPath = Join-Path $moduleDocsPath "$ModuleName.md"
    if (Test-Path $moduleMdPath) {
        Update-MarkdownModuleFile -Path $moduleMdPath
    }
    
    "Markdown documentation updated successfully!"
}
else {
    "`nGenerating new Markdown documentation..."
    
    # Ensure the module docs directory exists
    if (-not (Test-Path $moduleDocsPath)) {
        New-Item -Path $moduleDocsPath -ItemType Directory -Force | Out-Null
        "Created module docs directory: $moduleDocsPath"
    }
    
    # Generate markdown for all exported commands
    $commands = Get-Command -Module $ModuleName
    New-MarkdownCommandHelp -CommandInfo $commands -OutputFolder $moduleDocsPath -Force -WithModulePage
    
    "Markdown documentation generated successfully!"
}

# Compile Markdown to MAML (external help XML)
"`nCompiling Markdown to MAML help files..."

if (Test-Path $moduleDocsPath) {
    $markdownFiles = Get-ChildItem -Path $moduleDocsPath -Filter "*.md" | Where-Object Name -ne "MSGraphPermissions.md"
    
    if ($markdownFiles) {
        $commandHelp = $markdownFiles | Import-MarkdownCommandHelp
        if ($commandHelp) {
            Export-MamlCommandHelp -CommandHelp $commandHelp -OutputFolder $ExternalHelpPath -Force
            "MAML help files generated in: $ExternalHelpPath"
        }
        else {
            Write-Warning "No command help was imported from markdown files"
        }
    }
    else {
        Write-Warning "No command markdown files found in $moduleDocsPath"
    }
}
else {
    Write-Warning "Module docs path not found: $moduleDocsPath"
}

# Validate the documentation
"`nValidating documentation..."
try {
    $issues = Test-MarkdownCommandHelp -Path $moduleDocsPath -ErrorAction Stop
    
    if ($issues) {
        Write-Warning "Documentation validation found issues:"
        $issues | Format-Table -AutoSize
    }
    else {
        "Documentation validation passed!"
    }
}
catch {
    Write-Warning "Documentation validation skipped: $_"
}

"`n=== Documentation build complete ==="
"Markdown files: $moduleDocsPath"
"MAML help files: $ExternalHelpPath"
"`nTest with: Get-Help <CommandName> -Full"