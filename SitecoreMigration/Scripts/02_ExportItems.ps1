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
    @{ Name = "RootPath"; Title = "Root Item Path"; Value = "/sitecore/content/HartmannDirect/Global/Home"; }
    @{ Name = "TemplateIds"; Title = "Template IDs to INCLUDE (paste one per line)"; Value = "{GUID-1}`n{GUID-2}`n{GUID-3}"; Lines = 15; }
    @{ Name = "ExcludeTemplateIds"; Title = "Template IDs to EXCLUDE + children (optional, paste one per line)"; Value = "{8C58B2C2-DF3E-4802-9AE8-9A425A0EC544}"; Lines = 5; }
) -Title "Item Export - Filter by Templates" -Width 800 -Height 700 -OkButtonName "Export" -CancelButtonName "Cancel"

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

# Parse template IDs to include (split by newline or comma)
$templateIdList = @($TemplateIds -split '[,\r\n]' | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" })

# Parse template IDs to exclude (split by newline or comma)
$excludeTemplateIdList = @($ExcludeTemplateIds -split '[,\r\n]' | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" })

Write-Host "Searching for items with $($templateIdList.Count) template(s)..." -ForegroundColor Cyan
if ($excludeTemplateIdList.Count -gt 0) {
    Write-Host "Excluding items with $($excludeTemplateIdList.Count) template(s) and their children..." -ForegroundColor Yellow
}
Write-Host "Root Path: $RootPath`n" -ForegroundColor White

try {
    # Get root item
    $rootItem = Get-Item -Path "master:$RootPath" -ErrorAction SilentlyContinue

    if (-not $rootItem) {
        Write-Host "❌ Root item not found at: $RootPath" -ForegroundColor Red
        return
    }

    Write-Host "✓ Root item found: $($rootItem.Name)`n" -ForegroundColor Green

    # Get all items under root
    Write-Host "Scanning and filtering items..." -ForegroundColor Cyan
    $allItems = Get-ChildItem -Path "master:$RootPath" -Recurse -ErrorAction SilentlyContinue

    # Identify items to exclude (those with excluded template IDs and their descendants)
    $excludeItemIds = @()
    if ($excludeTemplateIdList.Count -gt 0) {
        $itemsToExclude = $allItems | Where-Object { $excludeTemplateIdList -contains $_.TemplateID.ToString() }
        foreach ($excludeItem in $itemsToExclude) {
            $excludeItemIds += $excludeItem.ID.ToString()
            # Also mark all descendants for exclusion
            $descendants = $allItems | Where-Object { $_.ItemPath -like "$($excludeItem.ItemPath)/*" }
            $excludeItemIds += @($descendants | ForEach-Object { $_.ID.ToString() })
        }
    }

    # Filter items: include matching templates AND exclude excluded items/children
    $report = $allItems |
        Where-Object {
            ($templateIdList -contains $_.TemplateID.ToString()) -and
            ($excludeItemIds -notcontains $_.ID.ToString())
        } |
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
