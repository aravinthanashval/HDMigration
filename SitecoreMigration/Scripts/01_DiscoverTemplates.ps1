# ============================================================================
# Sitecore Template Discovery Script
# Purpose: List all templates with their IDs for mapping
# Run in: Sitecore PowerShell Extensions (SPE) Console
# ============================================================================

Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║        SITECORE TEMPLATE DISCOVERY SCRIPT                      ║" -ForegroundColor Cyan
Write-Host "║         Tenant to Global Migration Process - Step 1            ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

# Show dialog to get input
$result = Read-Variable -Parameters @(
    @{ Name = "SourceTemplatePath"; Title = "Source Template Path"; Value = "/sitecore/templates/Project/HartmannDirectES"; }
    @{ Name = "TargetTemplatePath"; Title = "Target Template Path (optional)"; Value = ""; }
) -Title "Template Discovery - Enter Paths" -Width 600 -Height 250 -OkButtonName "Discover" -CancelButtonName "Cancel"

if ($result -ne "ok") {
    Write-Host "Cancelled by user."
    return
}

# Validate source path
if ([string]::IsNullOrWhiteSpace($SourceTemplatePath)) {
    Write-Host "❌ ERROR: Source Template Path cannot be empty!" -ForegroundColor Red
    return
}

Write-Host "Discovering templates..." -ForegroundColor Green
$SourceTemplatePath = $SourceTemplatePath.TrimEnd('/')
$TargetTemplatePath = $TargetTemplatePath.TrimEnd('/')

function Get-TemplatesFromPath {
    param(
        [string]$Path,
        [string]$Label
    )

    try {
        $templates = Get-ChildItem -Path "master:$Path" -Recurse -ErrorAction SilentlyContinue |
            Where-Object { $_.TemplateName -eq "Template" } |
            ForEach-Object {
                [PSCustomObject]@{
                    'Template Name' = $_.Name
                    'Template ID' = $_.ID.ToString()
                    'Location' = $Label
                    'Full Path' = $_.ItemPath
                    'Field Count' = @($_.Fields | Measure-Object).Count
                }
            } | Sort-Object 'Template Name'

        return $templates
    } catch {
        Write-Host "  ⚠ Error scanning $Label : $($_.Exception.Message)" -ForegroundColor Yellow
        return @()
    }
}

try {
    # Get templates from source path
    Write-Host "Scanning source templates..." -ForegroundColor Cyan
    $sourceTemplates = @(Get-TemplatesFromPath -Path $SourceTemplatePath -Label "SOURCE")

    if ($sourceTemplates.Count -eq 0) {
        Write-Host "❌ No templates found at: $SourceTemplatePath" -ForegroundColor Red
        Write-Host "`nTroubleshooting:" -ForegroundColor Yellow
        Write-Host "  • Check the path spelling" -ForegroundColor White
        Write-Host "  • Try: /sitecore/templates/Project/" -ForegroundColor White
        return
    }

    Write-Host "✓ Found $($sourceTemplates.Count) source templates" -ForegroundColor Green

    $allTemplates = $sourceTemplates

    # Get templates from target path if provided
    if (-not [string]::IsNullOrWhiteSpace($TargetTemplatePath)) {
        Write-Host "Scanning target templates..." -ForegroundColor Cyan
        $globalTemplates = @(Get-TemplatesFromPath -Path $TargetTemplatePath -Label "TARGET")

        if ($globalTemplates.Count -gt 0) {
            Write-Host "✓ Found $($globalTemplates.Count) target templates" -ForegroundColor Green
            $allTemplates = @($sourceTemplates) + @($globalTemplates)
        }
    }

    Write-Host "`n✓ Total Templates Found: $($allTemplates.Count)" -ForegroundColor Green

    # Show ListView
    if ($allTemplates -and $allTemplates.Count -gt 0) {
        $allTemplates | Show-ListView -Title "Templates Discovery - Copy and Paste into Excel" -Property @(
            @{ Name = "Template Name"; Width = 200 }
            @{ Name = "Template ID"; Width = 300 }
            @{ Name = "Location"; Width = 100 }
            @{ Name = "Full Path"; Width = 350 }
            @{ Name = "Field Count"; Width = 80 }
        )
    }

    Write-Host "`nINSTRUCTIONS:" -ForegroundColor Yellow
    Write-Host "1. Select all rows in the ListView (Ctrl+A)" -ForegroundColor White
    Write-Host "2. Copy (Ctrl+C)" -ForegroundColor White
    Write-Host "3. Paste into Excel" -ForegroundColor White
    Write-Host "4. Run: 02_ExportItems.ps1" -ForegroundColor White

} catch {
    Write-Host "❌ ERROR: $($_)" -ForegroundColor Red
    Write-Host "Details: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Stack: $($_.ScriptStackTrace)" -ForegroundColor Gray
}
