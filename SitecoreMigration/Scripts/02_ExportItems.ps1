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
    Write-Host "Scanning items..." -ForegroundColor Cyan

    # Build report
    $report = if ($RecurseChildren) {
        Get-ChildItem -Path "master:$SourcePath" -Recurse -ErrorAction SilentlyContinue
    } else {
        Get-ChildItem -Path "master:$SourcePath" -ErrorAction SilentlyContinue
    } | ForEach-Object {
        [PSCustomObject]@{
            'Item ID' = $_.ID.ToString()
            'Item Name' = $_.Name
            'Item Path' = $_.ItemPath
            'Template' = $_.TemplateName
            'Template ID' = $_.TemplateID.ToString()
            'Children' = @($_.Children | Measure-Object).Count
            'Versions' = @($_.Versions | Measure-Object).Count
            'Fields' = @($_.Fields | Measure-Object).Count
        }
    }

    if (-not $report -or $report.Count -eq 0) {
        Write-Host "⚠ No items found at: $SourcePath" -ForegroundColor Yellow
        return
    }

    Write-Host "✓ Found $($report.Count) items" -ForegroundColor Green
    Write-Host "`n✓ Total Items Exported: $($report.Count)" -ForegroundColor Green

    # Show ListView
    if ($report) {
        $report | Show-ListView -Title "Items Export - Copy and Paste into Excel"
    }

    Write-Host "`nINSTRUCTIONS:" -ForegroundColor Yellow
    Write-Host "1. Select all rows (Ctrl+A)" -ForegroundColor White
    Write-Host "2. Copy (Ctrl+C)" -ForegroundColor White
    Write-Host "3. Paste into Excel" -ForegroundColor White
    Write-Host "4. Add TARGET PATH and TARGET TEMPLATE columns" -ForegroundColor White
    Write-Host "5. Run: 03_ExecuteMigration.ps1" -ForegroundColor White

} catch {
    Write-Host "❌ ERROR: $($_)" -ForegroundColor Red
    Write-Host "Details: $($_.Exception.Message)" -ForegroundColor Red
}
