# ============================================================================
# Sitecore Template Discovery Script
# Purpose: Read migration config from Sitecore item and discover templates
# Run in: Sitecore PowerShell Extensions (SPE) Console
# ============================================================================
# SETUP:
# 1. Create config item at: /sitecore/system/MigrationConfigs/[ConfigName]
# 2. Set fields: Source Template Path, Target Template Path
# 3. Edit line 12 below with your config item name
# 4. Copy entire script, paste into SPE, run
# ============================================================================

# 👇 EDIT THIS - Name of your config item
$ConfigItemName = "Hartmann Direct ES to Global"

# ============================================================================

Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║        SITECORE TEMPLATE DISCOVERY SCRIPT                      ║" -ForegroundColor Cyan
Write-Host "║         Reading Config from Sitecore Item                      ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

# Function to read migration config from Sitecore
function Get-MigrationConfigItem {
    param([string]$ConfigName)

    $configPath = "master:/sitecore/system/MigrationConfigs/$ConfigName"
    $configItem = Get-Item -Path $configPath -ErrorAction SilentlyContinue

    if (-not $configItem) {
        Write-Host "❌ ERROR: Config item not found!" -ForegroundColor Red
        Write-Host "   Path: $configPath" -ForegroundColor Yellow
        Write-Host "`n   Create the config item first:" -ForegroundColor Yellow
        Write-Host "   1. Go to /sitecore/system/MigrationConfigs/" -ForegroundColor White
        Write-Host "   2. Create item: $ConfigName" -ForegroundColor White
        Write-Host "   3. Fill in fields: Source/Target Template Paths" -ForegroundColor White
        exit
    }

    return $configItem
}

# Read config from Sitecore
Write-Host "Reading config: $ConfigItemName" -ForegroundColor Green
$configItem = Get-MigrationConfigItem -ConfigName $ConfigItemName

$SourceTemplatePath = $configItem["Source Template Path"]
$TargetTemplatePath = $configItem["Target Template Path"]
$description = $configItem["Description"]

# Validate paths
if ([string]::IsNullOrWhiteSpace($SourceTemplatePath)) {
    Write-Host "❌ ERROR: Source Template Path is empty!" -ForegroundColor Red
    Write-Host "   Fill in 'Source Template Path' field in config item" -ForegroundColor Yellow
    exit
}

Write-Host "✓ Config loaded successfully`n" -ForegroundColor Green
Write-Host "Description: $description" -ForegroundColor Cyan
Write-Host "Source Templates: $SourceTemplatePath" -ForegroundColor White
if (-not [string]::IsNullOrWhiteSpace($TargetTemplatePath)) {
    Write-Host "Target Templates: $TargetTemplatePath" -ForegroundColor White
}
Write-Host ""

# Normalize paths
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
    Write-Host "Scanning templates..." -ForegroundColor Green
    $sourceTemplates = Get-TemplatesFromPath -Path $SourceTemplatePath -Label "SOURCE"

    if ($sourceTemplates.Count -eq 0) {
        Write-Host "❌ No templates found at: $SourceTemplatePath" -ForegroundColor Red
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
