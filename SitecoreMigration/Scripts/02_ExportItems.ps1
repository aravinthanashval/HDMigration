# ============================================================================
# Sitecore Item Export Script
# Purpose: Read migration config from Sitecore and export items
# Run in: Sitecore PowerShell Extensions (SPE) Console
# ============================================================================
# SETUP:
# 1. Create config item at: /sitecore/system/MigrationConfigs/[ConfigName]
# 2. Set fields: Source Item Path, Include Children
# 3. Edit line 12 below with your config item name
# 4. Copy entire script, paste into SPE, run
# ============================================================================

# 👇 EDIT THIS - Name of your config item
$ConfigItemName = "Hartmann Direct ES to Global"

# ============================================================================

Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║        SITECORE ITEM EXPORT SCRIPT                             ║" -ForegroundColor Cyan
Write-Host "║         Reading Config from Sitecore Item                      ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

# Function to read migration config from Sitecore
function Get-MigrationConfigItem {
    param([string]$ConfigName)

    $configPath = "master:/sitecore/system/MigrationConfigs/$ConfigName"
    $configItem = Get-Item -Path $configPath -ErrorAction SilentlyContinue

    if (-not $configItem) {
        Write-Host "❌ ERROR: Config item not found!" -ForegroundColor Red
        Write-Host "   Path: $configPath" -ForegroundColor Yellow
        Write-Host "`n   Create the config item first:" -ForegroundColor Yellow
        Write-Host "   1. Go to /sitecore/system/MigrationConfigs/" -ForegroundColor White
        Write-Host "   2. Create item: $ConfigName" -ForegroundColor White
        Write-Host "   3. Fill in fields: Source Item Path, Include Children" -ForegroundColor White
        exit
    }

    return $configItem
}

# Read config from Sitecore
Write-Host "Reading config: $ConfigItemName" -ForegroundColor Green
$configItem = Get-MigrationConfigItem -ConfigName $ConfigItemName

$SourcePath = $configItem["Source Item Path"]
$RecurseChildrenValue = $configItem["Include Children"]
$RecurseChildren = $RecurseChildrenValue -eq "1" -or $RecurseChildrenValue -eq "true"
$description = $configItem["Description"]

# Validate path
if ([string]::IsNullOrWhiteSpace($SourcePath)) {
    Write-Host "❌ ERROR: Source Item Path is empty!" -ForegroundColor Red
    Write-Host "   Fill in 'Source Item Path' field in config item" -ForegroundColor Yellow
    exit
}

Write-Host "✓ Config loaded successfully`n" -ForegroundColor Green
Write-Host "Description: $description" -ForegroundColor Cyan
Write-Host "Source Items: $SourcePath" -ForegroundColor White
Write-Host "Recurse Children: $RecurseChildren" -ForegroundColor White
Write-Host ""

$SourcePath = $SourcePath.TrimEnd('/')

try {
    # Get items from source path
    Write-Host "Exporting items..." -ForegroundColor Green
    Write-Host "Source: $SourcePath" -ForegroundColor White
    Write-Host ""

    $items = @()

    if ($RecurseChildren) {
        $items = Get-ChildItem -Path "master:$SourcePath" -Recurse
    } else {
        $items = Get-ChildItem -Path "master:$SourcePath"
    }

    if ($items.Count -eq 0) {
        Write-Host "⚠ No items found at: $SourcePath" -ForegroundColor Yellow
        exit
    }

    # Process items and extract data
    $exportData = @()
    foreach ($item in $items) {
        $fieldList = @()
        foreach ($field in $item.Fields) {
            $fieldList += "$($field.Name):$($field.Value)"
        }

        $exportData += [PSCustomObject]@{
            ItemID          = $item.ID.ToString()
            ItemName        = $item.Name
            ItemPath        = $item.ItemPath
            TemplateName    = $item.TemplateName
            TemplateID      = $item.TemplateID.ToString()
            ChildCount      = @($item | Get-ChildItem | Measure-Object).Count
            VersionCount    = @($item.Versions | Measure-Object).Count
            FieldCount      = $item.Fields.Count
            Fields          = ($fieldList -join " | ")
        }
    }

    # Display summary
    Write-Host "ITEMS FOUND: $($exportData.Count)" -ForegroundColor Green
    Write-Host "───────────────────────────────────────────────────────────────`n"
    $exportData | Format-Table -AutoSize -Property ItemID, ItemName, TemplateName, ChildCount, VersionCount

    # Export data in copy-paste format
    Write-Host "`n───────────────────────────────────────────────────────────────" -ForegroundColor Cyan
    Write-Host "COPY-PASTE TO EXCEL (Tab-separated):" -ForegroundColor Cyan
    Write-Host "───────────────────────────────────────────────────────────────`n"

    Write-Host "ItemID`tItemName`tItemPath`tTemplateName`tTemplateID`tChildCount`tVersionCount`tFieldCount"
    $exportData | ForEach-Object {
        "{0}`t{1}`t{2}`t{3}`t{4}`t{5}`t{6}`t{7}" -f `
            $_.ItemID, $_.ItemName, $_.ItemPath, $_.TemplateName, `
            $_.TemplateID, $_.ChildCount, $_.VersionCount, $_.FieldCount
    }

    # Field details
    Write-Host "`n───────────────────────────────────────────────────────────────" -ForegroundColor Yellow
    Write-Host "FIELD DETAILS (for reference):" -ForegroundColor Yellow
    Write-Host "───────────────────────────────────────────────────────────────`n"

    $exportData | ForEach-Object {
        Write-Host "[$($_.ItemName)] - $($_.ItemPath)" -ForegroundColor Cyan
        Write-Host $_.Fields
        Write-Host ""
    }

    # Summary
    Write-Host "───────────────────────────────────────────────────────────────" -ForegroundColor Green
    Write-Host "✓ Total Items Exported: $($exportData.Count)" -ForegroundColor Green
    Write-Host "───────────────────────────────────────────────────────────────`n" -ForegroundColor Green

    Write-Host "NEXT STEPS:" -ForegroundColor Yellow
    Write-Host "1. Copy the tab-separated data above" -ForegroundColor White
    Write-Host "2. Paste into: Mappings\Item-Export.xlsx" -ForegroundColor White
    Write-Host "3. Add TARGET PATH and TARGET TEMPLATE columns" -ForegroundColor White
    Write-Host "4. Run: 03_ExecuteMigration.ps1" -ForegroundColor White

} catch {
    Write-Host "ERROR: $($_)" -ForegroundColor Red
    Write-Host $_.Exception.Message
}
