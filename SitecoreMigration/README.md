# Sitecore Tenant to Global Content Migration Process

This folder contains a complete PowerShell-based migration process for moving items from Sitecore tenant nodes to the Global node with template remapping.

## 📁 Folder Structure

```
SitecoreMigration/
├── Scripts/               # PowerShell scripts (run in SPE)
│   ├── 01_DiscoverTemplates.ps1
│   ├── 02_ExportItems.ps1
│   └── 03_ExecuteMigration.ps1
├── Templates/            # Excel templates for mapping
│   └── (templates will be created as needed)
├── Mappings/            # Your mapping files (created by you)
│   ├── Template-Mapping.xlsx
│   └── Item-Export.xlsx
├── Outputs/             # Migration results and logs
└── README.md            # This file
```

---

## 🚀 Quick Start Process

### **Step 1: Discover Templates**

1. Open **Sitecore PowerShell Extensions** (SPE) console in your Sitecore admin UI
2. Copy the contents of `01_DiscoverTemplates.ps1`
3. Paste into SPE console and run
4. The script will list all templates with their GUIDs

**Output:**
- Table showing: `TemplateID | TemplateName | FullPath | FieldCount`
- Tab-separated list for copying to Excel

**Action:**
- Copy the tab-separated output
- Paste into `Mappings\Template-Mapping.xlsx`
- Create your mapping: **Source Template → Target Template ID**

Example mapping:
```
Source Template         Target Template ID (GUID)
ES Home                 {GUID-of-Global-Home}
ES Product              {GUID-of-Global-Product}
ES Category             {GUID-of-Global-Category}
```

---

### **Step 2: Export Items**

1. Edit `02_ExportItems.ps1` and set the correct `$SourcePath`:
   ```powershell
   [string]$SourcePath = "/Tenant/NodeName"  # Change this
   ```

2. Copy the script into SPE and run
3. The script will list all items at that path recursively

**Output:**
- Table showing: `ItemID | ItemName | ItemPath | TemplateName | ChildCount | VersionCount`
- Full field details for reference
- Tab-separated list for copying to Excel

**Action:**
- Copy the tab-separated data
- Paste into `Mappings\Item-Export.xlsx`
- Add two new columns:
  - **TargetPath**: Where the item should go in `/Global/...`
  - **TargetTemplate**: The template GUID from Step 1 mapping
  - **TargetName**: New name (or same as source if not changing)
  - **MigrateChildren**: Y/N (move child items?)

Example item mapping:
```
ItemID                          ItemName    TemplateName    TargetTemplate              TargetPath          MigrateChildren
{GUID-123}                      Home        ES Home         {GUID-of-Global-Home}       /Global             Y
{GUID-456}                      Products    ES Product      {GUID-of-Global-Product}    /Global/Content     Y
```

---

### **Step 3: Execute Migration**

1. Save your completed mapping file as CSV (if using Excel, Export as CSV)
2. Edit `03_ExecuteMigration.ps1` with your CSV path:
   ```powershell
   03_ExecuteMigration.ps1 -MappingFile "C:\path\to\mapping.csv"
   ```

3. **Test First (Preview Mode):**
   ```powershell
   03_ExecuteMigration.ps1 -MappingFile "C:\path\to\mapping.csv" -Preview
   ```
   This shows what WOULD happen without making changes

4. **Execute Migration:**
   ```powershell
   03_ExecuteMigration.ps1 -MappingFile "C:\path\to\mapping.csv"
   ```

**Output:**
- Real-time migration status for each item
- Summary report (Success/Failed counts)
- Results saved to `Outputs\Migration_Results_[timestamp].csv`

---

## 📋 Mapping File Format

Your `Item-Export.xlsx` should have these columns:

| ItemID | ItemName | ItemPath | TemplateName | TemplateID | ChildCount | VersionCount | FieldCount | **TargetPath** | **TargetTemplate** | **TargetName** | **MigrateChildren** |
|--------|----------|----------|--------------|------------|-----------|--------------|-----------|-----------|----------|-----------|----------|
| {GUID} | Home | /Tenant/Home | ES Home | {GUID} | 5 | 1 | 45 | /Global | {GUID-target} | Home | Y |

**Bold columns** = You add these based on your template mapping

---

## ✅ Validation Checklist

Before running Step 3, verify:

- [ ] Template Mapping is complete (all source templates have target templates)
- [ ] All TargetPath locations exist in /Global (or will be created)
- [ ] All TargetTemplate GUIDs are correct and exist
- [ ] Source item permissions allow reading
- [ ] Target locations allow creating new items
- [ ] You have a backup of your content database
- [ ] You tested on a lower environment first (dev/staging)

---

## 🔍 Running in Preview Mode

Always run migration in **preview mode first** to validate:

```powershell
03_ExecuteMigration.ps1 -MappingFile "C:\mapping.csv" -Preview
```

This will:
- Show what WOULD be migrated
- Validate all source items exist
- Validate all target templates exist
- Validate target paths exist
- **NOT make any changes**

---

## 📊 Understanding the Output

### Success Example:
```
Processing: Home
  Source: /Tenant/Home
  Target: /Global/Home
  Template: ES Home → Global Home
  ✓ MIGRATED
```

### Failure Example:
```
Processing: Products
  Source: /Tenant/Products
  Target: /Global/Products
  Template: ES Product → Global Product
  ✗ FAILED: Target template not found: {invalid-GUID}
```

---

## 🆘 Troubleshooting

### "No templates found"
- Verify the template root path (default: `/sitecore/templates`)
- Check your Sitecore version supports PowerShell

### "Source item not found"
- Verify ItemID GUID is correct
- Confirm item exists in source database

### "Target parent path not found"
- Create the parent path in `/Global` first
- Or use an existing `/Global` location

### "Target template not found"
- Verify the template GUID in your mapping
- Ensure the template exists in Sitecore
- Run `01_DiscoverTemplates.ps1` again to get correct GUIDs

### Migration runs slow
- Items with many children take longer
- Large field values take time to copy
- Consider batching in smaller groups

---

## 📝 Logging & Results

After each migration, a results file is saved:
- Location: `Outputs\Migration_Results_[timestamp].csv`
- Contains: SourceID, SourceName, TargetPath, Status, Message
- Use for audit trail and troubleshooting

---

## 🔐 Best Practices

1. **Always test first** on dev/staging environment
2. **Backup before migration** - test restore process too
3. **Run in preview mode** first to validate
4. **Start with small batches** (10-20 items)
5. **Publish items** after successful migration
6. **Verify links** aren't broken after move
7. **Document exceptions** - items that failed and why
8. **Keep mapping files** for future reference/rollback

---

## 🛠️ Advanced Options

### Running from File System (if you gain access):
```powershell
& "D:\Project\Hartmann\HDGlobalTenantTool\SitecoreMigration\Scripts\01_DiscoverTemplates.ps1"
```

### Limiting items by template:
Edit `02_ExportItems.ps1` to add filtering:
```powershell
| Where-Object { $_.TemplateName -like "*ES*" }
```

### Migrating with children:
Set `$MigrateChildren = "Y"` in your mapping for items with child items

---

## 📞 Support

For issues or questions:
1. Check the **Troubleshooting** section above
2. Review the PowerShell error messages in detail
3. Run `01_DiscoverTemplates.ps1` again to verify template GUIDs
4. Test with a single item first before batch migration

---

## 📅 Change Log

- **2026-01-17** - Initial migration toolkit created
- Scripts: 01_Discover, 02_Export, 03_Execute
- Templates: Mapping and item export templates

---

**Remember:** This is a semi-automated process. Excel is your control point for what gets migrated where.
