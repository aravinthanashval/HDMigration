# ============================================================================
# Sitecore Item Export Script
# Purpose: Export items from tenant node with template & field information
# Run in: Sitecore PowerShell Extensions (SPE) Console
# ============================================================================

Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║        SITECORE ITEM EXPORT SCRIPT                             ║" -ForegroundColor Cyan
Write-Host "║         Tenant to Global Migration Process - Step 2            ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

# Ask user for source path
Write-Host "STEP 1: Specify Source Item Path" -ForegroundColor Yellow
Write-Host "───────────────────────────────────────────────────────────────" -ForegroundColor Yellow
Write-Host "Enter the root item path you want to export/migrate.`n" -ForegroundColor White

Write-Host "Examples:" -ForegroundColor Cyan
Write-Host "  • /Tenant/Node1" -ForegroundColor Gray
Write-Host "  • /Tenant/HartmannDirectES" -ForegroundColor Gray
Write-Host "  • /Tenant/HartmannDirectES/Home" -ForegroundColor Gray
Write-Host "  • /Tenant  (entire tenant)" -ForegroundColor Gray
Write-Host ""

$SourcePath = Read-Host "Enter source path"

# Validate input
if ([string]::IsNullOrWhiteSpace($SourcePath)) {
    Write-Host "Error: Path cannot be empty" -ForegroundColor Red
    exit
}

# Normalize path
$SourcePath = $SourcePath.TrimEnd('/')

# Ask if should recurse
Write-Host "`nInclude child items recursively? (Y/N)" -ForegroundColor Yellow
$recurseInput = Read-Host "Recurse children"
$RecurseChildren = $recurseInput -eq "Y" -or $recurseInput -eq "y"

Write-Host "`nSource Path: $SourcePath" -ForegroundColor Green
Write-Host "Recurse Children: $RecurseChildren`n" -ForegroundColor Green

try {
    # Get all items from source path
    $items = @()

    if ($RecurseChildren -eq $true) {
        $items = Get-ChildItem -Path "master:$SourcePath" -Recurse
    } else {
        $items = Get-ChildItem -Path "master:$SourcePath"
    }

    if ($items.Count -eq 0) {
        Write-Host "No items found at $SourcePath" -ForegroundColor Red
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
    Write-Host "ITEMS FOUND:" -ForegroundColor Green
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
    Write-Host "3. Add TARGET PATH column for each item (where it goes in Global)" -ForegroundColor White
    Write-Host "4. Add TARGET TEMPLATE column (using your template mapping)" -ForegroundColor White
    Write-Host "5. Review and validate all mappings" -ForegroundColor White
    Write-Host "6. Run: 03_ExecuteMigration.ps1" -ForegroundColor White

} catch {
    Write-Host "ERROR: $_" -ForegroundColor Red
    Write-Host $_.Exception.Message
}
