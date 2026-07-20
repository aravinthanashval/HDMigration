# ============================================================================
# Migration Config Setup Script
# Purpose: Create the config item structure and template in Sitecore
# Run in: Sitecore PowerShell Extensions (SPE) Console (once)
# ============================================================================
# EDIT line 14 below with your config values, then run this script
# ============================================================================

# 👇 EDIT THESE - Your migration configuration
$ConfigName = "Hartmann Direct ES to Global"
$SourceTemplatePath = "/sitecore/templates/Project/HartmannDirectES"
$TargetTemplatePath = "/sitecore/templates/Project/HartmannDirectGlobal"
$SourceItemPath = "/Tenant/HartmannDirectES"
$TargetItemPath = "/Global"
$IncludeChildren = "1"
$Description = "Migration of Hartmann Direct ES tenant to Global node"
$CreatedBy = "Migration Admin"

# ============================================================================

Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║        MIGRATION CONFIG SETUP SCRIPT                          ║" -ForegroundColor Cyan
Write-Host "║         Creates config item in Sitecore                       ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

try {
    # Get or create system folder
    Write-Host "Setting up config structure..." -ForegroundColor Green

    $systemFolder = Get-Item -Path "master:/sitecore/system"

    # Create/get MigrationConfigs folder
    $migrationFolder = $systemFolder | Get-ChildItem | Where-Object { $_.Name -eq "MigrationConfigs" }

    if (-not $migrationFolder) {
        Write-Host "  Creating MigrationConfigs folder..." -ForegroundColor Cyan
        $migrationFolder = New-Item -Parent $systemFolder -Name "MigrationConfigs" -ItemType "Folder"
        Write-Host "  ✓ Folder created" -ForegroundColor Green
    } else {
        Write-Host "  ✓ MigrationConfigs folder exists" -ForegroundColor Green
    }

    # Check if config item already exists
    $existingConfig = $migrationFolder | Get-ChildItem | Where-Object { $_.Name -eq $ConfigName }

    if ($existingConfig) {
        Write-Host "  ✓ Config item already exists: $ConfigName" -ForegroundColor Yellow
        $configItem = $existingConfig
    } else {
        Write-Host "  Creating config item: $ConfigName..." -ForegroundColor Cyan

        # Create item (using Standard Template - you can modify this)
        $configItem = New-Item -Parent $migrationFolder `
            -Name $ConfigName `
            -ItemType "Folder"

        Write-Host "  ✓ Config item created" -ForegroundColor Green
    }

    # Set field values
    Write-Host "  Setting field values..." -ForegroundColor Cyan
    $configItem.Editing.BeginEdit()

    $configItem["Source Template Path"] = $SourceTemplatePath
    $configItem["Target Template Path"] = $TargetTemplatePath
    $configItem["Source Item Path"] = $SourceItemPath
    $configItem["Target Item Path"] = $TargetItemPath
    $configItem["Include Children"] = $IncludeChildren
    $configItem["Description"] = $Description
    $configItem["Created By"] = $CreatedBy

    $configItem.Editing.EndEdit()

    Write-Host "  ✓ Fields updated" -ForegroundColor Green

    # Display summary
    Write-Host "`n✓ Configuration Setup Complete!`n" -ForegroundColor Green
    Write-Host "CONFIG ITEM DETAILS:" -ForegroundColor Green
    Write-Host "───────────────────────────────────────────────────────────────" -ForegroundColor Green
    Write-Host "  Path: $($configItem.ItemPath)"
    Write-Host "  Name: $($configItem.Name)"
    Write-Host "  Source Template Path: $SourceTemplatePath"
    Write-Host "  Target Template Path: $TargetTemplatePath"
    Write-Host "  Source Item Path: $SourceItemPath"
    Write-Host "  Target Item Path: $TargetItemPath"
    Write-Host "  Include Children: $IncludeChildren"
    Write-Host "  Description: $Description"
    Write-Host "───────────────────────────────────────────────────────────────`n" -ForegroundColor Green

    Write-Host "NOW YOU CAN USE:" -ForegroundColor Yellow
    Write-Host "  1. 01_DiscoverTemplates.ps1" -ForegroundColor White
    Write-Host "  2. 02_ExportItems.ps1" -ForegroundColor White
    Write-Host "`nThey will automatically read from this config item!" -ForegroundColor Cyan
    Write-Host "`nConfig item name to use in scripts: '$ConfigName'" -ForegroundColor Yellow

} catch {
    Write-Host "❌ ERROR: $($_)" -ForegroundColor Red
    Write-Host $_.Exception.Message
}
