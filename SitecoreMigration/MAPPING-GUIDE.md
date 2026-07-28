# Mapping Guide: Region to Global Migration

Create mapping in a single Excel sheet with formulas that auto-fetch IDs.

---

## 📊 Mapping Excel Structure

### **Region Section (Columns A-E)**
| A | B | C | D | E |
|---|---|---|---|---|
| **Region Page ID** | **Region Page Name** | **Region Page Path** | **Region Template** | **Region Template ID** |
| {877...} | Products | /sitecore/... | HD Product... | {7729...} |

### **Global Section (Columns F-J)**
| F | G | H | I | J |
|---|---|---|---|---|
| **Global Page ID** | **Global Page Name** | **Global Page Path** | **Global Template** | **Global Template ID** |
| {543...} | Products | /sitecore/... | HD Product... | {7729...} |

### **Mapping Section (Columns K-O)**
| K | L | M | N | O |
|---|---|---|---|---|
| **Move to Local** | **New Path** | **Old Path ID** | **New Path ID** |

---

## 🔧 How to Build This

### **Step 1: Create Base Excel Sheet**
Open Excel and create columns A through O with headers shown above.

### **Step 2: Paste Region Data**
1. Run `02_ExportItems.ps1` for Region
   - Root: `/sitecore/content/HartmannDirect/ES/Home`
   - Result: ES_Region.xlsx

2. Copy from ES_Region.xlsx:
   - Item ID → Column A (Region Page ID)
   - Item Name → Column B (Region Page Name)
   - Item Path → Column C (Region Page Path)
   - Template → Column D (Region Template)
   - Template ID → Column E (Region Template ID)

### **Step 3: Paste Global Data**
Copy from ES_Global.xlsx:
- Item ID → Column F (Global Page ID)
- Item Name → Column G (Global Page Name)
- Item Path → Column H (Global Page Path)
- Template → Column I (Global Template)
- Template ID → Column J (Global Template ID)

**Match rows by name** - Same items should be in same row.

### **Step 4: Add Formulas**

#### **Column K: Move to Local** (Manual - No Formula)
Leave empty or enter "L":
- **"L"** = Item will be moved to local folder
- **Blank** = Item stays in global

#### **Column L: New Path** (Formula)
In cell L2, enter this formula and copy down to all rows:
```excel
=IF(K2="L", SUBSTITUTE(H2, "/Global/", "/Local/"), H2)
```

**How it works:**
- If K2 = "L" → Replace "/Global/" with "/Local/" in path H2
- Otherwise → Keep path H2 as-is
- This calculates the final destination path

**Example:**
- K2 = "L", H2 = `/sitecore/.../Global/.../Products`
- L2 = `/sitecore/.../Local/.../Products`

#### **Column M: Old Path ID** (Formula - Auto Fetch)
In cell M2, enter this formula and copy down:
```excel
=A2
```

**How it works:**
- Simply references the Region Page ID from column A
- This is the "from" item ID for migration
- For each row, Excel auto-adjusts: =A2, =A3, =A4, etc.

#### **Column N: New Path ID** (Formula - Auto Fetch)
In cell N2, enter this formula and copy down:
```excel
=F2
```

**How it works:**
- Simply references the Global Page ID from column F
- This is the "to" item ID for migration
- For each row, Excel auto-adjusts: =F2, =F3, =F4, etc.

---

## 📋 Copy Down Formulas

After entering formulas in row 2:

1. **Select cell L2** (New Path formula)
2. **Copy** (Ctrl+C)
3. **Select range L3:L[LastRow]**
4. **Paste** (Ctrl+V)

Repeat for columns M and N.

**Excel will auto-adjust row numbers:** L2→L3→L4, A2→A3→A4, F2→F3→F4, etc.

---

## 📝 Real Example

```
Row 2:
A2: {877ED844-30E5-4D7B-B7BF-D9222BB9F20F}  ← Region Page ID
B2: Products
C2: /sitecore/content/HartmannDirect/ES/Home/Products
D2: HD Product Main Listing Page
E2: {7729CF78-C90F-4BDC-AB7D-2FBC9CCC4E96}

F2: {54389452-891C-48CA-8202-140B254D25D4}  ← Global Page ID
G2: Products
H2: /sitecore/content/HartmannDirect/Global/Home/Products
I2: HD Product Main Listing Page
J2: {7729CF78-C90F-4BDC-AB7D-2FBC9CCC4E96}

K2: [blank - stays global]
L2: =IF(K2="L", SUBSTITUTE(H2, "/Global/", "/Local/"), H2)
    Result: /sitecore/content/HartmannDirect/Global/Home/Products
M2: =A2
    Result: {877ED844-30E5-4D7B-B7BF-D9222BB9F20F}
N2: =F2
    Result: {54389452-891C-48CA-8202-140B254D25D4}
```

---

## 🎯 Key Formulas

| Column | Formula | Fetches From |
|--------|---------|--------------|
| **L** (New Path) | `=IF(K2="L", SUBSTITUTE(H2, "/Global/", "/Local/"), H2)` | Global Path (H) + Move to Local (K) |
| **M** (Old Path ID) | `=A2` | Region Page ID (A) |
| **N** (New Path ID) | `=F2` | Global Page ID (F) |

---

## ✨ Why This Works

✅ **All IDs auto-fetched from columns** - No manual copy-paste errors
✅ **Formulas handle local/global logic** - Automatic path calculation
✅ **Simple references** - =A2 and =F2 just point to existing columns
✅ **Easy to verify** - Can see source IDs and results side-by-side

---

## 🚀 Complete Process

1. Create Excel with headers A-N
2. Copy Region data (columns A-E)
3. Copy Global data (columns F-J)
4. Match rows by name
5. **Add formula in L2:** `=IF(K2="L", SUBSTITUTE(H2, "/Global/", "/Local/"), H2)`
6. **Add formula in M2:** `=A2`
7. **Add formula in N2:** `=F2`
8. Copy all 3 formulas down to all data rows
9. Fill Move to Local (K) with "L" or blank
10. Save as CSV
11. Use in `03_ExecuteMigration.ps1`

---

**Done!** Formulas will auto-fetch all the IDs you need! ✅
