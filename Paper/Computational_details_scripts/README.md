# Computational Details Scripts

This folder contains the computational material used in the paper
"Geometric Vacuum Selection from Constrained Spacetime Foliations".
It includes Mathematica notebooks for symbolic derivations and one Python script
for quantitative domain-sensitivity plots.

## Conventions

- Metric signature: `(+,-,-,-)`
- Riemann-sign convention: `R_{munurhosigma}`, with `R = g^{munu} R_{munu}`
- Default smoothing choice in tests: `W = 1` (optional smoothing is not varied)

## File Tree

```text
Computational_details_scripts/
|- 00_Setup_Assumptions.nb
|- 01_Invariants_X_K2_R.nb
|- 02_Action_Lagrangian.nb
|- 03_Leff_Radial_Reduction.nb
|- 04_SanityChecks.nb
|- 05_Test_Minkowski.nb
|- 06_Test_deSitter.nb
|- 07 Domain sensitivity calculations.py
|- GR_Spherical_Foliation_K2_R.nb
`- plot_3_hybrid_transition.png
```

## What Each File Does

### `00_Setup_Assumptions.nb`
Sets global assumptions and model parameters for the hard global-per-leaf constraint setup.
Defines coordinates, positivity assumptions (`A[r] > 0`, `B[r] > 0`, `r > 0`), timelike-foliation condition, and coupling constants.

### `01_Invariants_X_K2_R.nb`
Computes the basic geometric invariants for the spherically symmetric ansatz:
`X`, `K^2`, and `R`, keeping full dependence on `A[r]`, `B[r]`, `psi[r]`, and derivatives.

### `02_Action_Lagrangian.nb`
Builds the local 4D Lagrangian density and the integral kernel structure for the leafwise global constraint.
Defines the reference value `K0^2` and the global constraint functional at the symbolic level.

### `03_Leff_Radial_Reduction.nb`
Performs angular integration and obtains radial kernels (`f0`, `f1`) and the reduced global functional.
Shows explicitly that the constraint is integral/leafwise, not pointwise.

### `04_SanityChecks.nb`
Runs consistency checks:
- `sqrt(-g)` volume element,
- Schwarzschild test (`R = 0`),
- static foliation limit (`psi' = 0`) with expected simplifications.

### `05_Test_Minkowski.nb`
Evaluates the leafwise constraint in Minkowski.
Shows that the normalized average `<K^2>_{D_Theta}` vanishes in the IR limit, excluding Minkowski for `K0^2 > 0`.

### `06_Test_deSitter.nb`
Evaluates the leafwise constraint in static-patch de Sitter with PG-type slicing.
Checks `X = 1` and constant `K^2 = 3H^2`, yielding the selection rule `H^2 = K0^2/3`.

### `07 Domain sensitivity calculations.py`
Python quantitative analysis and plotting script.
It computes and visualizes domain-size sensitivity for:
- Minkowski with linear tilt,
- de Sitter,
- a hybrid transition model.

It writes the following plot files:
- `plot_1_minkowski_sensitivity.png`
- `plot_2_velocity_dependence.png`
- `plot_3_hybrid_transition.png`
- `plot_4_convergence_analysis.png`

Main dependencies:
- `numpy`
- `scipy`
- `matplotlib`

Run it from this folder:

```bash
python "07 Domain sensitivity calculations.py"
```

### `GR_Spherical_Foliation_K2_R.nb`
Independent first-principles derivation of `X`, `K^2`, and `R` for
`Theta = t + psi(r)` in the spherically symmetric metric ansatz.
Includes Schwarzschild consistency check.

## Summary of Computational Outcome

- The global-per-leaf normalized constraint is non-local by construction.
- Minkowski is excluded in the IR for `K0^2 > 0`.
- de Sitter satisfies the constraint with `H^2 = K0^2/3`.
- The Python sensitivity script quantifies how the normalized average depends
  on domain size and confirms the expected infrared scaling behavior.
