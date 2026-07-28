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

try {
    # Build report from source templates
    Write-Host "Scanning source templates..." -ForegroundColor Cyan

    $report = Get-ChildItem -Path "master:$SourceTemplatePath" -Recurse -ErrorAction SilentlyContinue |
        Where-Object { $_.TemplateName -eq "Template" } |
        ForEach-Object {
            [PSCustomObject]@{
                'Template Name' = $_.Name
                'Template ID' = $_.ID.ToString()
                'Location' = 'SOURCE'
                'Full Path' = $_.ItemPath
                'Field Count' = @($_.Fields | Measure-Object).Count
            }
        } | Sort-Object 'Template Name'

    if (-not $report -or $report.Count -eq 0) {
        Write-Host "❌ No templates found at: $SourceTemplatePath" -ForegroundColor Red
        return
    }

    Write-Host "✓ Found $($report.Count) source templates" -ForegroundColor Green

    # Get templates from target path if provided
    if (-not [string]::IsNullOrWhiteSpace($TargetTemplatePath)) {
        Write-Host "Scanning target templates..." -ForegroundColor Cyan

        $targetReports = Get-ChildItem -Path "master:$TargetTemplatePath" -Recurse -ErrorAction SilentlyContinue |
            Where-Object { $_.TemplateName -eq "Template" } |
            ForEach-Object {
                [PSCustomObject]@{
                    'Template Name' = $_.Name
                    'Template ID' = $_.ID.ToString()
                    'Location' = 'TARGET'
                    'Full Path' = $_.ItemPath
                    'Field Count' = @($_.Fields | Measure-Object).Count
                }
            } | Sort-Object 'Template Name'

        if ($targetReports -and $targetReports.Count -gt 0) {
            Write-Host "✓ Found $($targetReports.Count) target templates" -ForegroundColor Green
            $report = @($report) + @($targetReports)
        }
    }

    Write-Host "`n✓ Total Templates Found: $($report.Count)" -ForegroundColor Green

    # Show ListView
    if ($report) {
        $report | Show-ListView -Title "Templates Discovery - Copy and Paste into Excel"
    }

    # Output template IDs to console for copy-paste
    Write-Host "`n═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "Template IDs (Copy and use in next steps):" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════════`n" -ForegroundColor Yellow

    $report | ForEach-Object { Write-Host $_.('Template ID') }

    Write-Host "`n═══════════════════════════════════════════════════════════════" -ForegroundColor Green

} catch {
    Write-Host "❌ ERROR: $($_)" -ForegroundColor Red
    Write-Host "Details: $($_.Exception.Message)" -ForegroundColor Red
}
