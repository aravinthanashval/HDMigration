# ============================================================================
# Sitecore Item Export Script
# Purpose: Export items by template IDs in Excel format
# Run in: Sitecore PowerShell Extensions (SPE) Console
# ============================================================================

Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║        SITECORE ITEM EXPORT SCRIPT                             ║" -ForegroundColor Cyan
Write-Host "║         Tenant to Global Migration Process - Step 2            ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

# Show dialog to get input
$result = Read-Variable -Parameters @(
    @{ Name = "RootPath"; Title = "Root Item Path (e.g. /sitecore/content/HartmannDirect/Global/Home)"; Value = "/sitecore/content/HartmannDirect/Global/Home"; }
    @{ Name = "TemplateIds"; Title = "Template IDs (comma-separated from previous step)"; Value = "{GUID-1},{GUID-2}"; }
) -Title "Item Export - Filter by Templates" -Width 800 -Height 300 -OkButtonName "Export" -CancelButtonName "Cancel"

if ($result -ne "ok") {
    Write-Host "Cancelled by user."
    return
}

# Validate inputs
if ([string]::IsNullOrWhiteSpace($RootPath)) {
    Write-Host "❌ ERROR: Root Item Path cannot be empty!" -ForegroundColor Red
    return
}

if ([string]::IsNullOrWhiteSpace($TemplateIds)) {
    Write-Host "❌ ERROR: Template IDs cannot be empty!" -ForegroundColor Red
    return
}

Write-Host "Exporting items..." -ForegroundColor Green
$RootPath = $RootPath.TrimEnd('/')

# Parse template IDs
$templateIdList = @($TemplateIds -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" })

Write-Host "Searching for items with $($templateIdList.Count) template(s)..." -ForegroundColor Cyan
Write-Host "Root Path: $RootPath`n" -ForegroundColor White

try {
    # Get root item
    $rootItem = Get-Item -Path "master:$RootPath" -ErrorAction SilentlyContinue

    if (-not $rootItem) {
        Write-Host "❌ Root item not found at: $RootPath" -ForegroundColor Red
        return
    }

    Write-Host "✓ Root item found: $($rootItem.Name)`n" -ForegroundColor Green

    # Get all items under root and filter by template IDs
    Write-Host "Scanning and filtering items..." -ForegroundColor Cyan

    $report = Get-ChildItem -Path "master:$RootPath" -Recurse -ErrorAction SilentlyContinue |
        Where-Object { $templateIdList -contains $_.TemplateID.ToString() } |
        ForEach-Object {
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
        Write-Host "❌ No items found matching the template IDs" -ForegroundColor Red
        return
    }

    Write-Host "✓ Found $($report.Count) items`n" -ForegroundColor Green

    # Show ListView
    if ($report) {
        $report | Show-ListView -Title "Items Export - Copy to Excel"
    }

    # Output item IDs to console for reference
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "Item IDs (for reference):" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════════`n" -ForegroundColor Yellow

    $report | ForEach-Object { Write-Host $_.('Item ID') }

    Write-Host "`n═══════════════════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host "NEXT STEPS:" -ForegroundColor Yellow
    Write-Host "1. Copy all data from ListView (Ctrl+A → Ctrl+C)" -ForegroundColor White
    Write-Host "2. Paste into Excel" -ForegroundColor White
    Write-Host "3. Create your mapping based on business requirements" -ForegroundColor White

} catch {
    Write-Host "❌ ERROR: $($_)" -ForegroundColor Red
    Write-Host "Details: $($_.Exception.Message)" -ForegroundColor Red
}
