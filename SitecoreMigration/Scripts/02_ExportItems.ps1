# ============================================================================
# Sitecore Item Export Script
# Purpose: Export items from tenant node with template & field information
# Run in: Sitecore PowerShell Extensions (SPE) Console
# ============================================================================

Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║        SITECORE ITEM EXPORT SCRIPT                             ║" -ForegroundColor Cyan
Write-Host "║         Tenant to Global Migration Process - Step 2            ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

# Show dialog to get input
$result = Read-Variable -Parameters @(
    @{ Name = "SourcePath"; Title = "Source Item Path"; Value = "/Tenant/HartmannDirectES"; }
    @{ Name = "RecurseChildren"; Title = "Include Child Items"; Value = $true; Editor = "bool"; }
) -Title "Item Export - Enter Paths" -Width 600 -Height 250 -OkButtonName "Export" -CancelButtonName "Cancel"

if ($result -ne "ok") {
    Write-Host "Cancelled by user."
    return
}

# Validate source path
if ([string]::IsNullOrWhiteSpace($SourcePath)) {
    Write-Host "❌ ERROR: Source Item Path cannot be empty!" -ForegroundColor Red
    return
}

Write-Host "Preparing item export..." -ForegroundColor Green
$SourcePath = $SourcePath.TrimEnd('/')

Write-Host "✓ Source Path: $SourcePath" -ForegroundColor White
Write-Host "✓ Recurse Children: $RecurseChildren" -ForegroundColor White
Write-Host ""

try {
    # Get items from source path
    Write-Host "Exporting items..." -ForegroundColor Green
    Write-Host ""

    $items = @()

    if ($RecurseChildren) {
        $items = Get-ChildItem -Path "master:$SourcePath" -Recurse
    } else {
        $items = Get-ChildItem -Path "master:$SourcePath"
    }

    if ($items.Count -eq 0) {
        Write-Host "⚠ No items found at: $SourcePath" -ForegroundColor Yellow
        return
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
