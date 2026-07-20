# ============================================================================
# Sitecore Template Discovery Script
# Purpose: List all templates with their IDs for mapping
# Run in: Sitecore PowerShell Extensions (SPE) Console
# ============================================================================
# QUICK START:
# 1. Edit lines 12-15 below with your template paths
# 2. Copy entire script
# 3. Paste into SPE console
# 4. Click Run
# ============================================================================

# 👇 EDIT THESE - Your template paths
$SourceTemplatePath = "/sitecore/templates/Project/HartmannDirectES"
$TargetTemplatePath = ""

# ============================================================================

Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║        SITECORE TEMPLATE DISCOVERY SCRIPT                      ║" -ForegroundColor Cyan
Write-Host "║         Tenant to Global Migration Process - Step 1            ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

# Validate source path
if ([string]::IsNullOrWhiteSpace($SourceTemplatePath)) {
    Write-Host "ERROR: SourceTemplatePath is empty!" -ForegroundColor Red
    Write-Host "`nEdit line 12 of this script:" -ForegroundColor Yellow
    Write-Host '  $SourceTemplatePath = "/sitecore/templates/Project/YourPath"' -ForegroundColor Cyan
    exit
}

$SourceTemplatePath = $SourceTemplatePath.TrimEnd('/')
$TargetTemplatePath = $TargetTemplatePath.TrimEnd('/')

Write-Host "Scanning templates..." -ForegroundColor Green
Write-Host "SOURCE: $SourceTemplatePath" -ForegroundColor White
if (-not [string]::IsNullOrWhiteSpace($TargetTemplatePath)) {
    Write-Host "TARGET: $TargetTemplatePath" -ForegroundColor White
}
Write-Host ""

function Get-TemplatesFromPath {
    param(
        [string]$Path,
        [string]$Label
    )

    try {
        $templates = Get-ChildItem -Path "master:$Path" -Recurse -ErrorAction SilentlyContinue |
            Where-Object { $_.TemplateName -eq "Template" } |
            Select-Object -Property @{
                N="TemplateID"
                E={$_.ID.ToString()}
            },
            @{
                N="TemplateName"
                E={$_.Name}
            },
            @{
                N="FullPath"
                E={$_.ItemPath}
            },
            @{
                N="Location"
                E={$Label}
            },
            @{
                N="FieldCount"
                E={@($_.Fields | Measure-Object).Count}
            } | Sort-Object TemplateName

        return $templates
    } catch {
        Write-Host "  ⚠ Error: $($_.Exception.Message)" -ForegroundColor Yellow
        return @()
    }
}

try {
    # Get templates from source path
    $sourceTemplates = Get-TemplatesFromPath -Path $SourceTemplatePath -Label "SOURCE"

    if ($sourceTemplates.Count -eq 0) {
        Write-Host "❌ No templates found at: $SourceTemplatePath" -ForegroundColor Red
        Write-Host "`nTroubleshooting:" -ForegroundColor Yellow
        Write-Host "  1. Check the path (edit line 12)" -ForegroundColor White
        Write-Host "  2. Try: /sitecore/templates/Project/" -ForegroundColor White
        Write-Host "  3. Or: /sitecore/templates" -ForegroundColor White
        exit
    }

    Write-Host "✓ Found $($sourceTemplates.Count) source templates`n" -ForegroundColor Green

    $allTemplates = $sourceTemplates

    # Get templates from target path if provided
    if (-not [string]::IsNullOrWhiteSpace($TargetTemplatePath)) {
        $globalTemplates = Get-TemplatesFromPath -Path $TargetTemplatePath -Label "TARGET"

        if ($globalTemplates.Count -gt 0) {
            Write-Host "✓ Found $($globalTemplates.Count) target templates`n" -ForegroundColor Green
            $allTemplates = @($sourceTemplates) + @($globalTemplates)
        }
    }

    # Display results
    Write-Host "TEMPLATES FOUND:" -ForegroundColor Green
    Write-Host "───────────────────────────────────────────────────────────────`n"
    $allTemplates | Format-Table -AutoSize -Property TemplateID, TemplateName, Location, FullPath, FieldCount

    # Export to clipboard format
    Write-Host "`n───────────────────────────────────────────────────────────────" -ForegroundColor Cyan
    Write-Host "COPY-PASTE TO EXCEL (Tab-separated):" -ForegroundColor Cyan
    Write-Host "───────────────────────────────────────────────────────────────`n"

    Write-Host "TemplateID`tTemplateName`tLocation`tFullPath`tFieldCount"
    $allTemplates | ForEach-Object {
        "{0}`t{1}`t{2}`t{3}`t{4}" -f $_.TemplateID, $_.TemplateName, $_.Location, $_.FullPath, $_.FieldCount
    }

    # Summary
    Write-Host "`n───────────────────────────────────────────────────────────────" -ForegroundColor Green
    Write-Host "✓ Total Templates: $($allTemplates.Count)" -ForegroundColor Green
    Write-Host "───────────────────────────────────────────────────────────────`n" -ForegroundColor Green

    Write-Host "NEXT STEPS:" -ForegroundColor Yellow
    Write-Host "1. Copy tab-separated output above" -ForegroundColor White
    Write-Host "2. Paste into: Mappings\Template-Mapping.xlsx" -ForegroundColor White
    Write-Host "3. Run: 02_ExportItems.ps1" -ForegroundColor White

} catch {
    Write-Host "ERROR: $($_)" -ForegroundColor Red
}
