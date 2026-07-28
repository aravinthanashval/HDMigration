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

Write-Host "Exporting items..." -ForegroundColor Green
$SourcePath = $SourcePath.TrimEnd('/')

try {
    # Get items from source path
    Write-Host "Scanning items..." -ForegroundColor Cyan
    $items = @()

    if ($RecurseChildren) {
        $items = @(Get-ChildItem -Path "master:$SourcePath" -Recurse)
    } else {
        $items = @(Get-ChildItem -Path "master:$SourcePath")
    }

    if ($items.Count -eq 0) {
        Write-Host "⚠ No items found at: $SourcePath" -ForegroundColor Yellow
        return
    }

    Write-Host "✓ Found $($items.Count) items" -ForegroundColor Green

    # Process items and build report
    $exportData = @()
    foreach ($item in $items) {
        $childCount = @($item.Children | Measure-Object).Count
        $versionCount = @($item.Versions | Measure-Object).Count

        $exportData += [PSCustomObject]@{
            'Item ID' = $item.ID.ToString()
            'Item Name' = $item.Name
            'Item Path' = $item.ItemPath
            'Template' = $item.TemplateName
            'Template ID' = $item.TemplateID.ToString()
            'Children' = $childCount
            'Versions' = $versionCount
            'Fields' = $item.Fields.Count
        }
    }

    Write-Host "`n✓ Total Items Exported: $($exportData.Count)" -ForegroundColor Green

    # Show ListView
    if ($exportData -and $exportData.Count -gt 0) {
        $exportData | Show-ListView -Title "Items Export - Copy and Paste into Excel" -Property @(
            @{ Name = "Item ID"; Width = 300 }
            @{ Name = "Item Name"; Width = 150 }
            @{ Name = "Item Path"; Width = 350 }
            @{ Name = "Template"; Width = 180 }
            @{ Name = "Template ID"; Width = 300 }
            @{ Name = "Children"; Width = 70 }
            @{ Name = "Versions"; Width = 70 }
            @{ Name = "Fields"; Width = 70 }
        )
    }

    Write-Host "`nINSTRUCTIONS:" -ForegroundColor Yellow
    Write-Host "1. Select all rows in the ListView (Ctrl+A)" -ForegroundColor White
    Write-Host "2. Copy (Ctrl+C)" -ForegroundColor White
    Write-Host "3. Paste into Excel" -ForegroundColor White
    Write-Host "4. Add TARGET PATH and TARGET TEMPLATE columns" -ForegroundColor White
    Write-Host "5. Run: 03_ExecuteMigration.ps1" -ForegroundColor White

} catch {
    Write-Host "❌ ERROR: $($_)" -ForegroundColor Red
    Write-Host "Details: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Stack: $($_.ScriptStackTrace)" -ForegroundColor Gray
}
