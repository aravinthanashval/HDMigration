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
        $exportData += [PSCustomObject]@{
            ItemID      = $item.ID.ToString()
            ItemName    = $item.Name
            ItemPath    = $item.ItemPath
            Template    = $item.TemplateName
            TemplateID  = $item.TemplateID.ToString()
            Children    = @($item | Get-ChildItem | Measure-Object).Count
            Versions    = @($item.Versions | Measure-Object).Count
            Fields      = $item.Fields.Count
        }
    }

    # Build report for ListView
    $report = $exportData | Select-Object @(
        @{ Name = "Item ID"; Expression = { $_.ItemID } }
        @{ Name = "Item Name"; Expression = { $_.ItemName } }
        @{ Name = "Item Path"; Expression = { $_.ItemPath } }
        @{ Name = "Template"; Expression = { $_.Template } }
        @{ Name = "Template ID"; Expression = { $_.TemplateID } }
        @{ Name = "Children"; Expression = { $_.Children } }
        @{ Name = "Versions"; Expression = { $_.Versions } }
        @{ Name = "Fields"; Expression = { $_.Fields } }
    )

    # Show ListView
    if ($report) {
        $report | Show-ListView -Title "Items Export - Copy and Paste into Excel" -Property @(
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

    Write-Host "`n✓ Total Items Exported: $($report.Count)" -ForegroundColor Green
    Write-Host "`nINSTRUCTIONS:" -ForegroundColor Yellow
    Write-Host "1. Select all rows in the ListView (Ctrl+A)" -ForegroundColor White
    Write-Host "2. Copy (Ctrl+C)" -ForegroundColor White
    Write-Host "3. Paste into Excel" -ForegroundColor White
    Write-Host "4. Add TARGET PATH and TARGET TEMPLATE columns" -ForegroundColor White
    Write-Host "5. Run: 03_ExecuteMigration.ps1" -ForegroundColor White

} catch {
    Write-Host "ERROR: $($_)" -ForegroundColor Red
    Write-Host $_.Exception.Message
}
