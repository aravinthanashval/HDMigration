# ============================================================================
# Sitecore Item Migration Execution Script
# Purpose: Migrate items based on mapping file (template remapping + moving)
# Run in: Sitecore PowerShell Extensions (SPE) Console
# ============================================================================

param(
    [string]$MappingFile = "",  # Will be prompted if not provided
    [switch]$Preview = $false   # Preview changes without executing
)

Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║        SITECORE ITEM MIGRATION EXECUTION SCRIPT                ║" -ForegroundColor Cyan
Write-Host "║         Tenant to Global Migration Process - Step 3            ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

if ([string]::IsNullOrEmpty($MappingFile)) {
    Write-Host "MAPPING FILE REQUIRED" -ForegroundColor Yellow
    Write-Host "Provide your mapping CSV/Excel export file with these columns:" -ForegroundColor White
    Write-Host "  - ItemID (source item GUID)" -ForegroundColor White
    Write-Host "  - ItemName (source item name)" -ForegroundColor White
    Write-Host "  - SourceTemplate (current template)" -ForegroundColor White
    Write-Host "  - TargetTemplate (new template GUID)" -ForegroundColor White
    Write-Host "  - TargetPath (destination path in /Global)" -ForegroundColor White
    Write-Host "  - TargetName (new item name, or same as source)" -ForegroundColor White
    Write-Host "  - MigrateChildren (Y/N - move child items)" -ForegroundColor White
    Write-Host "`nExample: 03_ExecuteMigration.ps1 -MappingFile 'C:\migration_mapping.csv'`n" -ForegroundColor Green
    exit
}

# Validate mapping file exists
if (-not (Test-Path $MappingFile)) {
    Write-Host "ERROR: Mapping file not found: $MappingFile" -ForegroundColor Red
    exit
}

try {
    # Import mapping data
    $mapping = Import-Csv -Path $MappingFile

    if ($mapping.Count -eq 0) {
        Write-Host "No items in mapping file" -ForegroundColor Red
        exit
    }

    Write-Host "Mapping File: $MappingFile" -ForegroundColor Green
    Write-Host "Items to Migrate: $($mapping.Count)`n" -ForegroundColor Cyan

    if ($Preview) {
        Write-Host "[PREVIEW MODE] - No changes will be made`n" -ForegroundColor Yellow
    }

    $successCount = 0
    $failureCount = 0
    $results = @()

    foreach ($row in $mapping) {
        $sourceID = $row.ItemID
        $sourceName = $row.ItemName
        $sourceTemplate = $row.SourceTemplate
        $targetTemplate = $row.TargetTemplate
        $targetPath = $row.TargetPath
        $targetName = if ([string]::IsNullOrEmpty($row.TargetName)) { $sourceName } else { $row.TargetName }
        $migrateChildren = $row.MigrateChildren -eq "Y"

        try {
            # Get source item
            $sourceItem = Get-Item -Path "master:" -ID $sourceID -ErrorAction SilentlyContinue

            if ($null -eq $sourceItem) {
                throw "Source item not found: $sourceID"
            }

            # Get target parent
            $targetParent = Get-Item -Path "master:$targetPath" -ErrorAction SilentlyContinue

            if ($null -eq $targetParent) {
                throw "Target parent path not found: $targetPath"
            }

            # Get target template
            $targetTemplateItem = Get-Item -Path "master:" -ID $targetTemplate -ErrorAction SilentlyContinue

            if ($null -eq $targetTemplateItem) {
                throw "Target template not found: $targetTemplate"
            }

            Write-Host "Processing: $sourceName" -ForegroundColor Cyan
            Write-Host "  Source: $($sourceItem.ItemPath)" -ForegroundColor Gray
            Write-Host "  Target: $targetPath/$targetName" -ForegroundColor Gray
            Write-Host "  Template: $sourceTemplate → $($targetTemplateItem.Name)" -ForegroundColor Gray

            if (-not $Preview) {
                # MIGRATION LOGIC HERE
                # Option 1: Copy item with new template
                # Option 2: Move item and change template
                # This depends on your Sitecore version and requirements

                # Example: Create new item at target location with target template
                $newItem = New-Item -Parent $targetParent -Name $targetName -ItemType $targetTemplateItem

                if ($null -ne $newItem) {
                    # Copy field values from source
                    foreach ($field in $sourceItem.Fields) {
                        $targetField = $newItem.Fields | Where-Object { $_.Name -eq $field.Name }
                        if ($null -ne $targetField) {
                            $newItem.Editing.BeginEdit() | Out-Null
                            $newItem.Fields[$field.Name].Value = $field.Value
                            $newItem.Editing.EndEdit() | Out-Null
                        }
                    }

                    Write-Host "  ✓ MIGRATED" -ForegroundColor Green
                    $successCount++
                    $status = "SUCCESS"
                } else {
                    throw "Failed to create target item"
                }
            } else {
                Write-Host "  [PREVIEW] Would migrate to: $targetPath/$targetName" -ForegroundColor Yellow
                $status = "PREVIEW"
            }

            $results += [PSCustomObject]@{
                SourceID      = $sourceID
                SourceName    = $sourceName
                TargetPath    = $targetPath
                TargetName    = $targetName
                Status        = $status
                Message       = "OK"
            }

        } catch {
            Write-Host "  ✗ FAILED: $($_.Exception.Message)" -ForegroundColor Red
            $failureCount++

            $results += [PSCustomObject]@{
                SourceID      = $sourceID
                SourceName    = $sourceName
                TargetPath    = $targetPath
                TargetName    = $targetName
                Status        = "FAILED"
                Message       = $_.Exception.Message
            }
        }

        Write-Host ""
    }

    # Summary Report
    Write-Host "───────────────────────────────────────────────────────────────" -ForegroundColor Green
    Write-Host "MIGRATION SUMMARY" -ForegroundColor Green
    Write-Host "───────────────────────────────────────────────────────────────" -ForegroundColor Green
    Write-Host "Total Processed: $($mapping.Count)" -ForegroundColor White
    Write-Host "✓ Success: $successCount" -ForegroundColor Green
    Write-Host "✗ Failed: $failureCount" -ForegroundColor Red

    if ($Preview) {
        Write-Host "`n[PREVIEW MODE - No changes were made]" -ForegroundColor Yellow
    }

    Write-Host "`n───────────────────────────────────────────────────────────────" -ForegroundColor Green
    Write-Host "DETAILED RESULTS:" -ForegroundColor Green
    Write-Host "───────────────────────────────────────────────────────────────`n" -ForegroundColor Green

    $results | Format-Table -AutoSize -Property SourceName, TargetPath, Status, Message

    # Save results
    $resultsFile = "$PSScriptRoot\..\Outputs\Migration_Results_$(Get-Date -Format 'yyyy-MM-dd_HHmmss').csv"
    $results | Export-Csv -Path $resultsFile -NoTypeInformation
    Write-Host "Results saved to: $resultsFile`n" -ForegroundColor Cyan

} catch {
    Write-Host "CRITICAL ERROR: $_" -ForegroundColor Red
    Write-Host $_.Exception.Message
}
