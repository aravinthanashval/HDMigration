# 🚀 Quick Start Guide - Sitecore Migration (3 Steps)

## Step 1️⃣: Discover Templates (5 minutes)

**What:** Find all template GUIDs in your Sitecore instance

**Where:** `Scripts\01_DiscoverTemplates.ps1`

**How:**
1. **Edit the script first:**
   - Open `01_DiscoverTemplates.ps1` in any text editor
   - Line 12: Change path to your source templates
   - Line 13: (Optional) Add target template path
   - Save the file

2. **Copy-paste entire script** into Sitecore PowerShell console
3. **Run it**
4. **Copy the tab-separated output** at the bottom

**Example edit:**
```powershell
$SourceTemplatePath = "/sitecore/templates/Project/HartmannDirectES"
$TargetTemplatePath = "/sitecore/templates/Project/HartmannDirectGlobal"
```

**Result:** 
- You'll see all templates with their GUIDs
- You need the GUIDs to map source → target templates

---

## Step 2️⃣: Export Items (5 minutes)

**What:** List all items in your tenant node that need migration

**Where:** `Scripts\02_ExportItems.ps1`

**How:**
1. **Edit the script first:**
   - Change line 12: `$SourcePath = "/Tenant/NodeName"`
   - Replace `NodeName` with your actual tenant path
   
2. Copy-paste the script into SPE
3. Run it
4. Copy the **tab-separated output**

**Result:**
- Full list of items with their names, paths, templates
- Shows field count and child count

---

## Step 3️⃣: Create Your Mapping (15 minutes)

**What:** Tell the system WHERE each item should go and WHAT template it should use

**How:**

### 3a: Template Mapping
1. Open `Templates\Template-Mapping-BLANK.csv` in Excel
2. From Step 1 output, fill in:
   - **SourceTemplateName** (e.g., "ES Home")
   - **SourceTemplateID** (GUID from Step 1)
   - **TargetTemplateName** (e.g., "Global Home")
   - **TargetTemplateID** (GUID you found in Step 1)

Save as: `Mappings\Template-Mapping.xlsx`

### 3b: Item Mapping
1. Open `Templates\Item-Export-BLANK.csv`
2. Paste the tab-separated data from Step 2
3. Add these columns (copy from your template mapping):
   - **TargetPath** - where in `/Global/...` should it go?
   - **TargetTemplate** - which template GUID? (from template mapping)
   - **TargetName** - what should it be called? (usually same as source)
   - **MigrateChildren** - Y or N

Save as: `Mappings\Item-Export.xlsx`

**Example:**
```
Item Name: Home
TargetPath: /Global
TargetTemplate: {GUID-of-Global-Home-template}
TargetName: Home
MigrateChildren: Y
```

---

## Step 4️⃣: Test Migration (2 minutes)

**What:** Simulate the migration to check for errors

**Where:** `Scripts\03_ExecuteMigration.ps1`

**How:**
1. Convert your Excel to CSV (Save As → CSV)
2. Run in **PREVIEW MODE** first:
   ```powershell
   03_ExecuteMigration.ps1 -MappingFile "C:\path\to\mapping.csv" -Preview
   ```

3. Check the output - does it look correct?
4. Any errors? Fix in your mapping file

---

## Step 5️⃣: Execute Migration (5-30 minutes)

**What:** Actually move the items

**How:**
1. When preview looks good, run:
   ```powershell
   03_ExecuteMigration.ps1 -MappingFile "C:\path\to\mapping.csv"
   ```

2. Watch the progress output
3. When done, check `Outputs\Migration_Results_[timestamp].csv`
4. Verify all items show **SUCCESS**

---

## ✅ Validation

After migration:
1. ✓ Check items exist in `/Global` at correct paths
2. ✓ Verify templates were applied correctly
3. ✓ Check field values copied over
4. ✓ Publish items to web database
5. ✓ Test links/references still work

---

## 🆘 Common Issues

| Problem | Solution |
|---------|----------|
| "Template not found" | Re-run Step 1, copy GUID carefully |
| "Target path not found" | Create the `/Global/path` first |
| "Item not found" | Check ItemID GUID is correct |
| Nothing happens | Use absolute file path for mapping CSV |

---

## 📁 Files You'll Create

```
Mappings/
├── Template-Mapping.xlsx          ← You create (from Step 1)
├── Item-Export.xlsx               ← You create (from Step 2+3)
└── Item-Export.csv                ← Exported from Excel (for Step 4-5)

Outputs/
└── Migration_Results_[date].csv   ← Auto-created by script
```

---

## 💡 Pro Tips

- **Start small:** Test with 5 items first
- **Use PREVIEW:** Never skip preview mode
- **Backup first:** Always backup your content DB
- **Document:** Keep your mapping files for audit trail
- **Publish:** Don't forget to publish migrated items!

---

**Total Time:** ~30 minutes for full process (varies by item count)

Ready? Start with **Step 1**: `Scripts\01_DiscoverTemplates.ps1` 🎯
