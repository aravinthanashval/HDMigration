# ============================================================================
# Sitecore Template Discovery Script
# Purpose: List all templates with their IDs for mapping
# Run in: Sitecore PowerShell Extensions (SPE) Console
# ============================================================================

Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║        SITECORE TEMPLATE DISCOVERY SCRIPT                      ║" -ForegroundColor Cyan
Write-Host "║         Tenant to Global Migration Process - Step 1            ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

# Ask user for template root path
Write-Host "STEP 1: Specify Template Folder Path" -ForegroundColor Yellow
Write-Host "───────────────────────────────────────────────────────────────" -ForegroundColor Yellow
Write-Host "Enter the root folder where your templates are located.`n" -ForegroundColor White

Write-Host "Examples:" -ForegroundColor Cyan
Write-Host "  • /sitecore/templates/Project/HartmannDirectES/Pages" -ForegroundColor Gray
Write-Host "  • /sitecore/templates/Project/HartmannDirectES" -ForegroundColor Gray
Write-Host "  • /sitecore/templates/User Defined" -ForegroundColor Gray
Write-Host "  • /sitecore/templates  (all templates)" -ForegroundColor Gray
Write-Host ""

$TemplateRoot = Read-Host "Enter template path"

# Validate input
if ([string]::IsNullOrWhiteSpace($TemplateRoot)) {
    Write-Host "Error: Path cannot be empty" -ForegroundColor Red
    exit
}

# Normalize path (remove trailing slash)
$TemplateRoot = $TemplateRoot.TrimEnd('/')

Write-Host "`nScanning template folder: $TemplateRoot`n" -ForegroundColor Green

function Get-TemplatesFromPath {
    param(
        [string]$Path,
        [string]$Label
    )

    Write-Host "Scanning: $Label" -ForegroundColor Cyan

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
        Write-Host "  ⚠ Could not scan: $_" -ForegroundColor Yellow
        return @()
    }
}

try {
    # Get templates from first path
    $sourceTemplates = Get-TemplatesFromPath -Path $TemplateRoot -Label "SOURCE"

    if ($sourceTemplates.Count -eq 0) {
        Write-Host "No templates found at $TemplateRoot" -ForegroundColor Red
        exit
    }

    # Ask if they want to also discover target/global templates
    Write-Host "`n───────────────────────────────────────────────────────────────" -ForegroundColor Yellow
    Write-Host "STEP 2: Discover Target Templates? (Optional)" -ForegroundColor Yellow
    Write-Host "───────────────────────────────────────────────────────────────`n" -ForegroundColor Yellow
    Write-Host "Do you want to also scan for GLOBAL/TARGET templates now?" -ForegroundColor White
    Write-Host "Examples:" -ForegroundColor Cyan
    Write-Host "  • /sitecore/templates/Project/HartmannDirectGlobal" -ForegroundColor Gray
    Write-Host "  • /sitecore/templates/Global" -ForegroundColor Gray

    $scanGlobal = Read-Host "`nScan Global templates? (Y/N)"

    $allTemplates = $sourceTemplates

    if ($scanGlobal -eq "Y" -or $scanGlobal -eq "y") {
        $globalPath = Read-Host "`nEnter Global/Target template path"

        if (-not [string]::IsNullOrWhiteSpace($globalPath)) {
            $globalPath = $globalPath.TrimEnd('/')
            $globalTemplates = Get-TemplatesFromPath -Path $globalPath -Label "TARGET"

            if ($globalTemplates.Count -gt 0) {
                $allTemplates = @($sourceTemplates) + @($globalTemplates)
                Write-Host "✓ Both SOURCE and TARGET templates loaded`n" -ForegroundColor Green
            }
        }
    }

    # Display as formatted table
    Write-Host "TEMPLATES FOUND:" -ForegroundColor Green
    Write-Host "───────────────────────────────────────────────────────────────`n"
    $allTemplates | Format-Table -AutoSize -Property TemplateID, TemplateName, Location, FullPath, FieldCount

    # Export to clipboard-friendly format
    Write-Host "`n───────────────────────────────────────────────────────────────" -ForegroundColor Cyan
    Write-Host "COPY-PASTE TO EXCEL (Tab-separated format):" -ForegroundColor Cyan
    Write-Host "───────────────────────────────────────────────────────────────`n"

    Write-Host "TemplateID`tTemplateName`tLocation`tFullPath`tFieldCount"
    $allTemplates | ForEach-Object {
        "{0}`t{1}`t{2}`t{3}`t{4}" -f $_.TemplateID, $_.TemplateName, $_.Location, $_.FullPath, $_.FieldCount
    }

    # Summary
    Write-Host "`n───────────────────────────────────────────────────────────────" -ForegroundColor Green
    Write-Host "✓ Total Templates Found: $($allTemplates.Count)" -ForegroundColor Green
    Write-Host "───────────────────────────────────────────────────────────────`n" -ForegroundColor Green

    Write-Host "NEXT STEPS:" -ForegroundColor Yellow
    Write-Host "1. Copy the tab-separated output above" -ForegroundColor White
    Write-Host "2. Paste into: Mappings\Template-Mapping.xlsx" -ForegroundColor White
    Write-Host "3. Create your SOURCE → TARGET template mapping" -ForegroundColor White
    Write-Host "4. Run: 02_ExportItems.ps1" -ForegroundColor White

} catch {
    Write-Host "ERROR: $_" -ForegroundColor Red
    Write-Host $_.Exception.Message
}
