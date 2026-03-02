# Vacancy-Taxes

Stata code and data for analyzing the effect of Washington, D.C.'s vacancy tax on local housing prices using the Synthetic Control Method and Interrupted Time Series Analysis.

---

## Table of Contents

1. [Overview](#overview)
2. [Background & Motivation](#background--motivation)
3. [Repository Structure](#repository-structure)
4. [Requirements](#requirements)
5. [Setup](#setup)
6. [Usage / Quick Start](#usage--quick-start)
7. [Data](#data)
8. [Outputs](#outputs)
9. [Reproducibility](#reproducibility)
10. [Citation](#citation)
11. [License](#license)
12. [Contributing](#contributing)
13. [Contact](#contact)

---

## Overview

This repository contains the replication materials for a term project (PPD 647) that investigates whether Washington, D.C.'s **vacancy tax** — enacted to discourage owners from leaving properties unoccupied — had a measurable impact on local housing prices.

**Intended audience:** Public policy researchers, urban economists, and graduate students interested in causal inference methods applied to housing policy.

The core analysis relies on two complementary quasi-experimental methods:

- **Synthetic Control Method** (`synth2` / `synth_runner`) — constructs a weighted combination of comparison cities that closely tracks D.C.'s pre-treatment housing price trajectory, then compares post-treatment divergence.
- **Interrupted Time Series Analysis** (`itsa`) — models the level and trend change in D.C.'s housing index following the 2003 vacancy-tax implementation.

---

## Background & Motivation

Vacancy taxes are a policy tool used by local governments to penalize property owners who leave residential or commercial units unoccupied for extended periods. The rationale is that sustained vacancies reduce neighborhood vitality, suppress housing supply, and may depress surrounding property values.

Washington, D.C. introduced a heightened vacancy-tax regime in **2003**, making it a natural quasi-experiment for evaluating the policy's housing-market effects. By comparing D.C. against a synthetic control constructed from other U.S. cities, and by modelling the interrupted time series for D.C. alone, this project attempts to isolate the causal impact of the tax on the local housing price index.

> **Note:** The broader economic and policy context is inferred from the code and accompanying paper. Refer to `Vacancy_Tax___Synthetic_Control.pdf` for the full write-up and literature review.

---

## Repository Structure

```
Vacancy-Taxes/
├── dc_vacancy_do.do                  # Main Stata do-file (all analysis steps)
├── dc_vacancy.xlsx                   # Input dataset (panel of U.S. cities)
├── Vacancy_Tax___Synthetic_Control.pdf  # Term paper / write-up
├── housing_index_effects.jpg         # Placebo-in-space effects graph (output)
├── itsa_graph.jpg                    # Interrupted time series graph (output)
├── main_result.jpg                   # Main synthetic control result graph (output)
├── CITATION.cff                      # Machine-readable citation file
└── README.md                         # This file
```

### Key file: `dc_vacancy_do.do`

This single do-file performs the entire analysis in the following sequence:

| Section | Description |
|---|---|
| Install commands | Comment-gated `ssc install` / `net install` lines for required packages |
| Setup & import | Clears memory, sets working directory, imports `dc_vacancy.xlsx` |
| Panel setup | Encodes city strings to numerics, sets panel with `xtset city_num year` |
| Data cleaning | Generates log income, per-capita new units, differenced housing index, etc. |
| Descriptive plots | `xtline` plots of housing index for all cities and D.C. vs. U.S. average |
| Synthetic control | `synth2` with nested optimisation; leave-one-out robustness check |
| Placebo in space | `synth_runner` with `single_treatment_graphs` |
| ITSA | `itsa` with single-unit treatment and lagged terms |
| Time-series checks | Unit-root test, autocorrelation diagnostics for D.C. only |

---

## Requirements

### Stata

- **Stata 14 or later** recommended (uses `xtset`, `synth2`, `synth_runner`, `itsa`).
- Tested under Stata/IC and Stata/SE; MP is also supported.

### Required user-written packages

Install once by un-commenting the relevant lines at the top of `dc_vacancy_do.do`, or run manually:

```stata
ssc install synth, all replace
capture ado uninstall synth_runner
net install synth_runner, ///
  from(https://raw.github.com/bquistorff/synth_runner/master/) replace
ssc install allsynth
ssc install itsa
```

> **TODO:** Confirm exact package versions used in the original analysis and document them here.

### Optional

- `synth2` (enhanced wrapper around `synth`) — installed via the `allsynth` package above.
- Any standard Stata installation includes `xtunitroot`, `pwcorr`, and `ac`.

### Operating system

- No OS-specific dependencies. Stata is cross-platform (Windows, macOS, Linux).

---

## Setup

1. **Clone or download** this repository to your local machine.

2. **Update the working directory** in `dc_vacancy_do.do`. Near the top of the file, replace the hard-coded path:

   ```stata
   cd "C:/Users/Zak Johnson/Documents/Fall 2022/Public Finance"
   ```

   with the absolute path to the folder where you placed the repository files, e.g.:

   ```stata
   cd "/path/to/Vacancy-Taxes"
   ```

3. **Update the import path** for the Excel file on the following line:

   ```stata
   import excel "C:\Users\Zak Johnson\...\dc_vacancy.xlsx", sheet("Sheet1") firstrow
   ```

   Change it to use a relative path (recommended):

   ```stata
   import excel "dc_vacancy.xlsx", sheet("Sheet1") firstrow
   ```

4. **Install required packages** (see [Requirements](#requirements) above) if you have not done so already.

> **TODO:** Consider refactoring path references to use a global macro (e.g., `global root "/path/to/Vacancy-Taxes"`) so the file is portable without edits throughout.

---

## Usage / Quick Start

1. Open Stata and set your working directory to the repository root (or use the `cd` command inside the do-file as described in [Setup](#setup)).

2. Open `dc_vacancy_do.do` in the Stata do-file editor.

3. Run the entire file:

   ```stata
   do dc_vacancy_do.do
   ```

   Or run it from the Stata command line after setting `cd`:

   ```stata
   cd "/path/to/Vacancy-Taxes"
   do dc_vacancy_do.do
   ```

4. The script will:
   - Import and clean `dc_vacancy.xlsx`
   - Save an intermediate cleaned dataset (`cleaned.dta`) in the working directory
   - Produce descriptive plots
   - Run the synthetic control and leave-one-out analysis
   - Run placebo-in-space tests and generate effect graphs
   - Run the interrupted time series model
   - Run time-series diagnostics for D.C.

5. All output graphs will be saved as `.png` files in the working directory.

> **TODO:** If you wish to run specific sections in isolation, comment out earlier `drop if` statements that restrict the sample, and ensure `cleaned.dta` exists from a prior full run.

---

## Data

### Input

| File | Format | Description |
|---|---|---|
| `dc_vacancy.xlsx` | Excel (`.xlsx`), Sheet1 | Panel dataset of U.S. cities with annual observations |

### Variables (inferred from code)

| Variable | Description |
|---|---|
| `city` | City name (string) |
| `year` | Year of observation |
| `housing_index` | Housing price index |
| `property_tax` | Property tax rate (cleaned and rescaled in do-file) |
| `pop` | Population |
| `pop_change` | Population change |
| `pop_density` | Population density |
| `minwage` | Minimum wage |
| `unemploy` | Unemployment rate |
| `subprime` | Subprime mortgage share (%) |
| `percap_income` | Per-capita income |
| `new_units` | New housing units permitted/built |
| `econ_index` | Economic index |

### Coverage

- **Treated unit:** Washington, D.C. (`city_num == 31`)
- **Treatment year:** 2003
- **Panel period:** Approximately 1978–2013 (shorter window used in synthetic control)

### Data source & privacy

> **TODO:** Document the original source(s) for `dc_vacancy.xlsx` (e.g., FHFA House Price Index, Census Bureau, BLS). Confirm whether the data may be redistributed; if not, provide download instructions and remove the file from the repository.

---

## Outputs

The following files are produced when `dc_vacancy_do.do` is run to completion:

| File | Description |
|---|---|
| `cleaned.dta` | Intermediate cleaned Stata dataset saved to working directory |
| `Johnson_housing_index.png` | `xtline` overlay of housing index for all cities |
| `Johnson_housing_indexDCvsUS.png` | D.C. housing index vs. U.S. average |
| `Johnson_placebo_in_space.png` | Placebo-in-space effects graph (`synth_runner`) |
| `Johnson_autocorrelation.png` | Autocorrelation plot for D.C. housing index |

Pre-generated output images already committed to the repository:

| File | Description |
|---|---|
| `housing_index_effects.jpg` | Placebo/effects graph (pre-generated) |
| `itsa_graph.jpg` | Interrupted time series graph (pre-generated) |
| `main_result.jpg` | Main synthetic control result (pre-generated) |

---

## Reproducibility

- **Stata do-file:** All analysis is contained in a single self-contained do-file (`dc_vacancy_do.do`). Running it from top to bottom reproduces the full analysis.
- **Paths:** The do-file currently contains absolute hard-coded paths (see [Setup](#setup)). Update these before running on a different machine.
- **Random seeds:** The synthetic control optimisation (`synth2` with `nested allopt`) does not rely on random seeds; results are deterministic given the data and donor pool.
- **Logs:** Stata's default logging is not explicitly enabled in the do-file. To capture a full log, run:

  ```stata
  log using "dc_vacancy_analysis.log", replace text
  do dc_vacancy_do.do
  log close
  ```

- **Package versions:** See [Requirements](#requirements). Pin package versions where possible for long-term reproducibility.

> **TODO:** Consider adding a `master.do` that sets all globals, installs packages, opens a log, and calls `dc_vacancy_do.do`, to make one-click reproduction easier.

---

## Citation

If you use or build upon this code, please cite it using the metadata in [`CITATION.cff`](CITATION.cff).

A suggested citation (APA-style):

> Johnson, Z. (2022). *Vacancy-Taxes: Stata code for analyzing DC's vacancy tax effects on housing prices* [Computer software]. GitHub. https://github.com/zachessesjohnson/Vacancy-Taxes

---

## License

**No license has been specified for this repository.**

The absence of a license means that default copyright law applies — others may not reproduce, distribute, or create derivative works without explicit permission from the author.

> **Recommendation:** Add an open-source license (e.g., MIT, BSD-2-Clause, or CC BY 4.0 for data/documentation) to allow others to use, cite, and build on this work. See [choosealicense.com](https://choosealicense.com) for guidance.

---

## Contributing

Contributions, bug reports, and suggestions are welcome. To contribute:

1. Fork the repository.
2. Create a feature branch (`git checkout -b feature/my-improvement`).
3. Commit your changes with clear messages.
4. Open a pull request describing what you changed and why.

Please ensure any new Stata code follows the style of the existing do-file (comments, section headings, `preserve`/`restore` blocks).

---

## Contact

- **Author:** Zachary Johnson (`zachessesjohnson` on GitHub)
- **Repository:** https://github.com/zachessesjohnson/Vacancy-Taxes
- **Course context:** PPD 647 Term Project (Fall 2022)

> For questions about the analysis or data, please open a GitHub Issue in this repository.
