# ============================================================================
# Sitecore Item Export & Mapper Script
# Purpose: Export items by template IDs and create source→target mapping
# Run in: Sitecore PowerShell Extensions (SPE) Console
# ============================================================================

Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║        SITECORE ITEM EXPORT & MAPPER SCRIPT                    ║" -ForegroundColor Cyan
Write-Host "║         Tenant to Global Migration Process - Step 2            ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

# Show dialog to get input
$result = Read-Variable -Parameters @(
    @{ Name = "SourcePath"; Title = "Root Item Path (e.g. /sitecore/content/HartmannDirect/Global/Home)"; Value = "/sitecore/content/HartmannDirect/Global/Home"; }
    @{ Name = "TemplateIds"; Title = "Template IDs (comma-separated GUIDs from previous step)"; Value = "{GUID-1},{GUID-2}"; }
) -Title "Item Export - Filter by Templates" -Width 800 -Height 300 -OkButtonName "Export" -CancelButtonName "Cancel"

if ($result -ne "ok") {
    Write-Host "Cancelled by user."
    return
}

# Validate inputs
if ([string]::IsNullOrWhiteSpace($SourcePath)) {
    Write-Host "❌ ERROR: Source Item Path cannot be empty!" -ForegroundColor Red
    return
}

if ([string]::IsNullOrWhiteSpace($TemplateIds)) {
    Write-Host "❌ ERROR: Template IDs cannot be empty!" -ForegroundColor Red
    return
}

Write-Host "Exporting items by template..." -ForegroundColor Green
$SourcePath = $SourcePath.TrimEnd('/')

# Parse template IDs
$templateIdList = @($TemplateIds -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" })

Write-Host "Searching for $($templateIdList.Count) template(s)..." -ForegroundColor Cyan
Write-Host "Root Path: $SourcePath`n" -ForegroundColor White

try {
    # Get root item
    $rootItem = Get-Item -Path "master:$SourcePath" -ErrorAction SilentlyContinue

    if (-not $rootItem) {
        Write-Host "❌ Root item not found at: $SourcePath" -ForegroundColor Red
        return
    }

    Write-Host "✓ Root item found: $($rootItem.Name)`n" -ForegroundColor Green

    # Get all items under root
    Write-Host "Scanning items under root..." -ForegroundColor Cyan
    $allItems = @(Get-ChildItem -Path "master:$SourcePath" -Recurse -ErrorAction SilentlyContinue)

    Write-Host "✓ Found $($allItems.Count) total items`n" -ForegroundColor Green

    # Filter by template IDs
    Write-Host "Filtering by template IDs..." -ForegroundColor Cyan
    $matchedItems = @()

    foreach ($item in $allItems) {
        $itemTemplateId = $item.TemplateID.ToString()

        if ($templateIdList -contains $itemTemplateId) {
            $matchedItems += $item
        }
    }

    Write-Host "✓ Found $($matchedItems.Count) items matching the templates`n" -ForegroundColor Green

    if ($matchedItems.Count -eq 0) {
        Write-Host "⚠ No items found matching the template IDs" -ForegroundColor Yellow
        return
    }

    # Build mapping report
    Write-Host "Building mapping..." -ForegroundColor Cyan
    $report = @()

    foreach ($item in $matchedItems) {
        $report += [PSCustomObject]@{
            'Source Item ID' = $item.ID.ToString()
            'Source Item Name' = $item.Name
            'Source Item Path' = $item.ItemPath
            'Source Template' = $item.TemplateName
            'Source Template ID' = $item.TemplateID.ToString()
            'Target Item ID' = ""
            'Target Item Name' = ""
            'Target Item Path' = ""
            'Target Template' = ""
            'Target Template ID' = ""
            'Status' = "Pending"
        }
    }

    Write-Host "✓ Mapping created for $($report.Count) items`n" -ForegroundColor Green

    # Show ListView
    if ($report) {
        $report | Show-ListView -Title "Items Mapping - Source to Target"
    }

    # Output item IDs to console for copy-paste
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "Source Item IDs (Copy and reference in mapping):" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════════`n" -ForegroundColor Yellow

    $report | ForEach-Object { Write-Host $_.('Source Item ID') }

    Write-Host "`n═══════════════════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host "NEXT STEPS:" -ForegroundColor Yellow
    Write-Host "1. Note the Source Item IDs above" -ForegroundColor White
    Write-Host "2. Find matching items in the TARGET location" -ForegroundColor White
    Write-Host "3. Fill in Target columns (ID, Name, Path, Template, Template ID)" -ForegroundColor White
    Write-Host "4. Set Status = 'Ready' for items to migrate" -ForegroundColor White
    Write-Host "5. Export mapping to CSV and use in migration" -ForegroundColor White

} catch {
    Write-Host "❌ ERROR: $($_)" -ForegroundColor Red
    Write-Host "Details: $($_.Exception.Message)" -ForegroundColor Red
}
