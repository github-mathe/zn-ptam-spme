# zn-ptam-spme

MATLAB implementation of a Single Particle Model with Electrolyte (SPMe) for Zn-PTAm dual-ion polymer batteries.

The repository contains:
- the SPMe model and solver,
- processed experimental data for selected C-rates,
- reproducible run scripts for single-case, sweep, and parameter-sensitivity studies,
- plotting scripts for experiment-versus-simulation comparison and internal-state visualization.

## Project Structure

```text
zn-ptam-spme/
  code/
    main.m
    model/
    plotting/
    utils/
  examples/
    run_base_case.m
    run_sweep.m
    run_parameter_sensitivity.m
  data/
    raw/
    processed/
  results/
  CHANGELOG.md
  LICENSE
  README.md
```

- `code/main.m`: workflow selector for single-case or sweep runs, with optional plotting of newly created results.
- `examples/run_base_case.m`: single-case entry point.
- `examples/run_sweep.m`: sweep entry point.
- `examples/run_parameter_sensitivity.m`: parameter-sensitivity example.
- `code/model/`: parameter loading, discretization, solver, and postprocessing.
- `code/plotting/`: plotting scripts and plot-data loaders.
- `code/utils/`: shared defaults, current-profile helpers, case lookup, and result-path helpers.
- `data/processed/`: processed experimental CSV files grouped by C-rate.
- `results/`: generated simulation outputs and exported figures.

## Running The Code

The code was developed and tested with MATLAB R2025b Update 4:

```text
MATLAB version 25.2.0.3150157 (R2025b) Update 4
```

Open MATLAB in the `zn-ptam-spme/` folder and add the code directory to the path:

```matlab
addpath(genpath('code'))
```

Run a single case:

```matlab
run('examples/run_base_case.m')
```

Run the selected workflow from `main.m`:

```matlab
run('code/main.m')
```

Run the explicit sweep example:

```matlab
run('examples/run_sweep.m')
```

Run the parameter-sensitivity example:

```matlab
run('examples/run_parameter_sensitivity.m')
```

Generate plots for one saved default case:

```matlab
run('code/plotting/plot_c_rate_sweep.m')
```

## Workflows

### Single-case run

`examples/run_base_case.m` runs one selected C-rate. The script resolves the matching default case from `code/utils/loadSimulationDefaults.m` and automatically inserts the corresponding default initial SOC.

Results are written to:

```text
results/default_cases/Crate_<C-rate>/
```

### Multi-case sweep

`code/main.m` can run either:
- `workflow = 'single_case'` for one selected `Crate`
- `workflow = 'sweep'` for the selected entries in `selectedIdx`

`examples/run_sweep.m` provides the explicit sweep-only entry point. Each selected case is resolved through `code/utils/getDefaultSimulationCase.m`.

Results are written to:

```text
results/default_cases/Crate_<C-rate>/
```

Single-case and sweep runs share the same output root because the same saved case layout is used for a given C-rate.

### Parameter sensitivity

`examples/run_parameter_sensitivity.m` writes sensitivity studies into a separate result tree.

Results are written under:

```text
results/parameter_sensitivity/
```

The current example varies `cathode.D_s` by a list of scale factors and stores each run under a separate subfolder.

### Plotting

`code/plotting/plot_c_rate_sweep.m` loads one saved simulation together with processed experimental data and exports comparison plots plus internal-state plots.

The main user inputs in that script are:
- `Crate`
- `runName`
- `saveFigures`
- `expMode`
- `numOfStates`

For default-case runs, exported figures are written under:

```text
results/default_cases/figures/Crate_<C-rate>/
```

## Shared Defaults

The main reproducibility settings are centralized in:

- `code/utils/loadSimulationDefaults.m`: standard C-rate list, default initial SOC values, time-step settings, and FEM options.
- `code/utils/getDefaultSimulationCase.m`: maps a selected C-rate to its default metadata.
- `code/utils/buildConstantCurrentProfile.m`: constructs the constant-current input profile used by the run scripts.
- `code/utils/getResultsRunRoot.m`: standardizes result-folder naming by run group.
- `code/utils/runDefaultSimulationCase.m`: runs and saves one default simulation case.
- `code/plotting/plotSavedCrateResults.m`: loads and plots one saved case programmatically.

## Data And Outputs

Processed experimental data are stored under:

```text
data/processed/<C-rate>/
  charge_<C-rate>C.csv
  discharge_<C-rate>C.csv
```

Each simulation case writes:
- `Geometry_cell.mat`
- `sim_<C-rate>.csv`

into its corresponding `Crate_<C-rate>/` result folder.

For default-case runs, figures are exported into:

```text
results/default_cases/figures/Crate_<C-rate>/
```
## License

The MATLAB source code in this repository is licensed under the MIT License. See `LICENSE` for details.

The processed experimental data were provided by collaborators and are included with permission for reproducibility of the simulations and figures. These data are not covered by the MIT License unless explicit permission from the data owners is obtained.

## Changelog

Notable changes are documented in `CHANGELOG.md`.

## Notes

- `plot_c_rate_sweep.m` expects `numOfStates >= 2`.
- If a selected `Crate` is not listed in the shared defaults, the run and plotting scripts stop with a clear error.
- The plotting workflow assumes that the corresponding processed experimental data exist for the selected C-rate.
- `main.m` can plot the results immediately after each simulation when `autoPlot = true`.