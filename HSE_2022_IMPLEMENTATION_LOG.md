# HSE 2022 Implementation Log

**Package:** hseclean
**Version:** 1.15.0
**Date Started:** 2025-11-11
**Authors:** Maria and Charlie

---

## Overview

This document tracks all decisions, changes, and validations made when adding support for Health Survey for England (HSE) 2022 data to the hseclean package.

---

## 1. Key Data Structure Changes in HSE 2022

### 1.1 Survey Design Variables
- **Cluster variable changed:**
  - HSE 2021: `cluster214`
  - HSE 2022: `cluster302`
  - **Decision:** Updated read_2022.R to use `cluster302`

### 1.2 Variable Naming Convention
- **Suffix pattern:**
  - HSE 2021: `_19` suffix (carried over from 2019)
  - HSE 2022: `_22` suffix
  - **Decision:** Strip `_22` suffix in read_2022.R at line 83

### 1.3 Column Position Changes
| Variable Type | HSE 2021 Columns | HSE 2022 Columns | Shift |
|---|---|---|---|
| Smoking (col 1) | 119 | 124 | +5 |
| Smoking (col 2) | 120 | 125 | +5 |
| Smoking (range) | 1158-1353 | 696-893 | -462 |
| Alcohol (range) | 1354-1495 | 894-1084 | -460 |

---

## 2. MAJOR METHODOLOGICAL CHANGE: Cider Separation

### 2.1 Background
**Source:** NHS Digital Methodological Change Notice (2022)
- URL: https://digital.nhs.uk/data-and-information/find-data-and-publications/statement-of-administrative-sources/methodological-changes/health-survey-for-england-2022-alcohol-consumption-methodology-changes-to-alcohol-unit-conversion-factors

### 2.2 The Change
**Before HSE 2022:**
- Cider asked as single category (no strength separation)
- Generic variable names

**From HSE 2022 onwards:**
- Cider split into **Normal Strength Cider (NCid)** and **Strong Cider (SCid)**
- Matches beer format (normal beer vs strong beer)
- **Normal Strength Cider:** < 6% ABV
- **Strong Cider:** ≥ 6% ABV

### 2.3 New Variables Captured in read_2022.R

**Normal Cider (NCid) variables:**
```
ncidl7221, ncidl7222, ncidl7223, ncidl7224
ncider22, ncidm221, ncidm222, ncidm223, ncidm224
ncid22a, ncid22b, ncid22c, ncid22d
ncidpt7, ncidsm7, ncidlg7, ncidbt7
l7ncid, ncidbot, ncidwu
```

**Strong Cider (SCid) variables:**
```
scidl7221, scidl7222, scidl7223, scidl7224
scider22, scidm221, scidm222, scidm223, scidm224
scid22a, scid22b, scid22c, scid22d
scidpt7, scidsm7, scidlg7, scidbt7
l7scid, scidwu, stcidbot
```

**Derived unit variables:**
```
d7cidu      - normal cider units (7-day recall)
d7stcidu    - strong cider units (7-day recall) **NEW in 2022**
ncidwu      - normal cider weekly units
scidwu      - strong cider weekly units
```

### 2.4 Decisions Pending
- [ ] How to handle cider in `alc_sevenday_adult.R`?
- [ ] How to handle cider in `alc_weekmean_adult.R`?
- [ ] How to handle cider in `alc_volume_data.R`?
- [ ] Should we create `total_cider = ncid + scid` for backward compatibility?
- [ ] How to handle pre-2022 data (unified cider) vs 2022+ (split cider)?

---

## 3. Alcohol Unit Conversion Factor Changes

### 3.1 Background
HSE 2022 implemented revised alcohol unit conversion factors. This makes 2022+ data **not directly comparable** with previous years if using original derived variables and not hseclean methods.

### 3.2 Conversion Factor Changes

**Normal Strength Cider (< 6% ABV):**
| Container | Old Factor | New Factor | Change |
|---|---|---|---|
| Pint | 2.0 | 2.3 | +0.3 |
| Large can | 2.0 | 2.2 | +0.2 |
| Small can/bottle | - | - | No change |

**Strong Cider (≥ 6% ABV):**
| Container | Old Factor | New Factor | Change |
|---|---|---|---|
| Large can | 3.0 | 3.5 | +0.5 |
| Pint | - | - | No change |
| Small can/bottle | - | - | No change |

**Other beverages:** (TO BE DOCUMENTED)

### 3.3 Decisions Pending
- [ ] Where are conversion factors stored in hseclean?
- [ ] Check `data-raw/Alcoholic beverage assumptions/` files
- [ ] Do we need year-specific conversion factor tables?
- [ ] Should functions auto-detect year and apply correct factors?

---

## 4. Vaping Variables

### 4.1 Variables Identified in HSE 2022
```
VapePl211-VapePl2111    - Vaping places
WhchFrst19              - Which first (smoking or vaping)
VapeAffect              - Vaping affect on smoking
ecignw_19               - E-cig now
ecigst_19               - E-cig status
ecigfreq_19             - E-cig frequency
ecigfst_19              - E-cig first
ecigwe_19, ecigwkd_19   - E-cig weekday/weekend
ecigtyp_19              - E-cig type
ecigstrg_19             - E-cig strength
ecigstp_19              - E-cig stopped
eciguse_19, eciguse2_19 - E-cig use
kecigevd_19             - Kids e-cig ever daily
KVapeHr, KVapeReg       - Kids vaping
```

### 4.2 Current Status
- **Captured:** Yes (in smoking variable range 696-893)
- **Processed:** Unknown - need to check if there are vaping-specific processing functions

### 4.3 Decisions Pending
- [ ] Do we need a separate `clean_vaping.R` function?
- [ ] How should vaping relate to smoking status?
- [ ] Are there existing vaping processing functions in the package?

---

## 5. Beer Distribution Verification

### 5.1 Context
Similar to cider, beer is split into normal strength and strong beer. Need to verify distributions are as expected.

### 5.2 Variables to Check
```
d7beeru     - normal beer units
d7sbu       - strong beer units
nbeerwu     - normal beer weekly units
sbeerwu     - strong beer weekly units
```

### 5.3 Validation Plan
- [ ] Load 2022 data
- [ ] Check distribution of normal vs strong beer consumption
- [ ] Compare to 2021 patterns
- [ ] Verify no unexpected missingness or coding issues
- [ ] Check for logical consistency (e.g., units align with container sizes)

---

## 6. Processing Function Updates Required

### 6.1 Files to Review/Update

#### alc_weekmean_adult.R
- **Status:** Not reviewed
- **Expected changes:** Handle NCid/SCid split
- **Priority:** HIGH

#### alc_sevenday_adult.R
- **Status:** Not reviewed
- **Expected changes:** Handle NCid/SCid split, apply 2022 conversion factors
- **Priority:** HIGH

#### alc_volume_data.R
- **Status:** Not reviewed
- **Expected changes:** Update ABV/volume assumptions for cider split
- **Priority:** HIGH

#### alc_drink_freq.R
- **Status:** Not reviewed
- **Expected changes:** May need updates for cider
- **Priority:** MEDIUM

#### Other functions
- **Status:** To be determined
- **Priority:** To be assessed

---

## 7. Backward Compatibility Strategy

### 7.1 Challenge
Pre-2022 data has unified cider; 2022+ has split cider (NCid/SCid).

### 7.2 Options Under Consideration

**Option A: Year-conditional logic**
```r
if (year >= 2022) {
  # Use NCid and SCid separately
} else {
  # Use unified cider
}
```

**Option B: Harmonization**
```r
# For 2022+, create total_cider = ncid + scid
# For pre-2022, rename cider to total_cider
```

**Option C: Separate processing tracks**
- Create `alc_sevenday_adult_2022.R` for new methodology
- Keep old functions unchanged

### 7.3 Decision Pending
- [ ] Which option to pursue?
- [ ] Get input from package maintainers
- [ ] Consider impact on downstream analyses

---

## 8. Testing Plan

### 8.1 Unit Tests
- [ ] Test read_2022() loads data correctly
- [ ] Test cider variables present and properly named
- [ ] Test vaping variables present
- [ ] Test backward compatibility with read_2021()

### 8.2 Integration Tests
- [ ] Run full pipeline on 2022 data
- [ ] Compare 2021 vs 2022 output structure
- [ ] Verify calculations match expected values

### 8.3 Validation Tests
- [ ] Beer distribution checks
- [ ] Cider distribution checks (NCid vs SCid proportions)
- [ ] Total alcohol units calculation verification
- [ ] Survey weight application

---

## 9. Documentation Updates Needed

- [ ] Update package README with 2022 support
- [ ] Update vignettes with methodological changes
- [ ] Add 2022-specific notes to function documentation
- [ ] Create migration guide for users
- [ ] Document conversion factor changes

---

## 10. Implementation Log (Chronological)

### 2025-11-18

**14:00 - Initial Analysis**
- Examined HSE 2022 data structure
- Identified column position changes
- Found cluster variable change (cluster214 → cluster302)

**14:30 - Created read_2022.R**
- Based on read_2021.R template
- Updated column ranges: alc (125, 894:1084), smoking (124, 696:893)
- Set suffix removal to `_22`

**14:45 - Updated read_hse.R**
- Added 2019, 2021, 2022 support (2019 was missing!)

**15:00 - First Error**
- User reported: `column(s) not found: [cluster214]`
- **Fix:** Updated to `cluster302` in read_2022.R

**15:30 - Identified Cider Change**
- User asked about cider differences
- Researched NHS Digital documentation
- **FOUND:** Major methodological change - cider split into NCid/SCid

**16:00 - Created Implementation Log**
- Documented all findings
- Created systematic plan for processing function updates
- Identified vaping and beer distribution tasks

**NEXT STEPS:**
1. Review alc_weekmean_adult.R (user has opened this file)
2. Check how current functions handle cider
3. Design solution for NCid/SCid handling
4. Document conversion factor locations
5. Plan vaping variable processing

---

## 11. Questions for Package Maintainers

1. **Conversion factors:** Where are ABV/volume assumptions stored? Need to add 2022 factors.
2. **Cider strategy:** Preferred approach for handling NCid/SCid split?
3. **Backward compatibility:** How important is it to maintain identical output structure?
4. **Vaping:** Should this be integrated with smoking or processed separately?
5. **Testing:** Are there existing test datasets we should use?

---

## 12. References

- NHS Digital (2022). HSE 2022 Alcohol Consumption Methodology Changes
  https://digital.nhs.uk/data-and-information/areas-of-interest/public-health/health-survey-for-england-2022-alcohol-consumption-methodology-changes-to-alcohol-unit-conversion-factors

- UK Data Service. HSE 2022 Data Dictionary (RTF file in local directory)

---

**End of Log** (Last updated: 2025-11-18)
