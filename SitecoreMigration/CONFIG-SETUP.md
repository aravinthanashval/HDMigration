# Migration Config Setup Guide

This guide explains how to set up and use the **Sitecore-based configuration system** for migrations.

---

## 🎯 How It Works

Instead of editing scripts, you:
1. **Create a config item in Sitecore** with your paths
2. **Run the migration scripts** - they automatically read from that item
3. **Reuse the same script** for multiple migrations (just change the config item name)

---

## 📋 Step 1: Create Config Item

### **Option A: Using PowerShell Script (Recommended)**

1. **Edit the setup script:**
   - File: `00_SetupMigrationConfig.ps1`
   - Edit lines 13-20 with your values:
   ```powershell
   $ConfigName = "Hartmann Direct ES to Global"
   $SourceTemplatePath = "/sitecore/templates/Project/HartmannDirectES"
   $TargetTemplatePath = "/sitecore/templates/Project/HartmannDirectGlobal"
   $SourceItemPath = "/Tenant/HartmannDirectES"
   $TargetItemPath = "/Global"
   ```

2. **Copy entire script**
3. **Paste into Sitecore SPE console**
4. **Run it** ✓ Done!

The script will create:
- `/sitecore/system/MigrationConfigs/` folder (if it doesn't exist)
- Your config item with all fields set

---

### **Option B: Manual Setup in Sitecore**

1. **Go to Content Editor**
2. **Navigate to:** `/sitecore/system/`
3. **Create a folder:** `MigrationConfigs`
4. **In MigrationConfigs folder, create an item:**
   - Name: `Hartmann Direct ES to Global` (or your migration name)
   - Template: Any template (recommend "Folder" or create custom)

5. **Add these fields to the item:**
   - Source Template Path: `/sitecore/templates/Project/HartmannDirectES`
   - Target Template Path: `/sitecore/templates/Project/HartmannDirectGlobal`
   - Source Item Path: `/Tenant/HartmannDirectES`
   - Target Item Path: `/Global`
   - Include Children: `1` (for true/yes)
   - Description: `Migration of Hartmann Direct ES tenant to Global node`
   - Created By: `Migration Admin`

---

## 🚀 Step 2: Run Migration Scripts

Now the scripts automatically read from your config item!

### **01_DiscoverTemplates.ps1**

```powershell
# Edit line 12:
$ConfigItemName = "Hartmann Direct ES to Global"

# Then copy → paste into SPE → run
```

**It will read from the config item:**
- Source Template Path
- Target Template Path

---

### **02_ExportItems.ps1**

```powershell
# Edit line 12:
$ConfigItemName = "Hartmann Direct ES to Global"

# Then copy → paste into SPE → run
```

**It will read from the config item:**
- Source Item Path
- Include Children

---

## 📊 Config Item Structure

```
/sitecore/system/MigrationConfigs/
├─ Hartmann Direct ES to Global (item)
│  ├─ Source Template Path: /sitecore/templates/...
│  ├─ Target Template Path: /sitecore/templates/...
│  ├─ Source Item Path: /Tenant/...
│  ├─ Target Item Path: /Global
│  ├─ Include Children: 1
│  ├─ Description: ...
│  ├─ Created By: ...
│  └─ Last Run Date: ... (auto-updated)
│
├─ Client A to Global (another migration)
│  └─ fields...
│
└─ Client B to Global (another migration)
   └─ fields...
```

---

## ✅ For Multiple Sites/Migrations

**Create one config item per migration:**

```
/sitecore/system/MigrationConfigs/
├─ Hartmann Direct ES to Global
├─ ClientA Staging to Production
├─ ClientB Dev to Global
└─ ClientC Migration 2024
```

Then just change the config item name when running scripts:
```powershell
$ConfigItemName = "ClientA Staging to Production"
```

---

## 🔄 Updating Config

To change paths for a migration:
1. Go to the config item in Content Editor
2. Edit the field values
3. Next time you run the script, it uses the updated values

---

## 💡 Advanced: PowerShell Config Update

Update config via PowerShell:

```powershell
$configItem = Get-Item -Path "master:/sitecore/system/MigrationConfigs/Hartmann Direct ES to Global"

$configItem.Editing.BeginEdit()
$configItem["Source Item Path"] = "/Tenant/NewPath"
$configItem["Last Run Date"] = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
$configItem.Editing.EndEdit()

Write-Host "✓ Config updated"
```

---

## 🎯 Quick Reference

| Task | Steps |
|------|-------|
| **Create new config** | Run `00_SetupMigrationConfig.ps1` with your values |
| **Run discovery** | Edit config name in `01_DiscoverTemplates.ps1` and run |
| **Export items** | Edit config name in `02_ExportItems.ps1` and run |
| **Change paths** | Edit fields in Sitecore config item |
| **New migration** | Create new config item, use same scripts |

---

## ✨ Benefits

✅ **No script editing needed** - just change config item  
✅ **Reusable** - one script template for all migrations  
✅ **Traceable** - all configs in one place in Sitecore  
✅ **Maintainable** - easy to update paths without touching code  
✅ **Scalable** - manage multiple migrations simultaneously  

---

**Ready to start?** Run `00_SetupMigrationConfig.ps1` first! 🚀
