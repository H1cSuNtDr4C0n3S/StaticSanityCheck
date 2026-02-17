# Geometric Vacuum Selection Project

[![CI](https://github.com/H1cSuNtDr4C0n3S/GeometricVacuumSelection/actions/workflows/lean_action_ci.yml/badge.svg)](https://github.com/H1cSuNtDr4C0n3S/GeometricVacuumSelection/actions/workflows/lean_action_ci.yml)
[![Release](https://img.shields.io/github/v/release/H1cSuNtDr4C0n3S/GeometricVacuumSelection?display_name=tag)](https://github.com/H1cSuNtDr4C0n3S/GeometricVacuumSelection/releases)
[![Lean](https://img.shields.io/badge/Lean-v4.27.0-blue)](https://github.com/leanprover/lean4)
[![mathlib](https://img.shields.io/badge/mathlib-a3a10db0-informational)](https://github.com/leanprover-community/mathlib4/commit/a3a10db0e9d66acbebf76c5e6a135066525ac900)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.18361297.svg)](https://doi.org/10.5281/zenodo.18361297)

Lean 4 workspace for formal checks of the key analytical steps in the paper:
`Geometric_Vacuum_Selection_from_Constrained_Spacetime_Foliations_v2.0.pdf`
(available in `Paper/`).

Goal: encode the analytical chain used in the vacuum-selection argument as Lean theorems with explicit assumptions.

## Repository Structure

- `Paper/`: LaTeX paper (`main.tex`), PDF, figures, and computational material (Mathematica notebooks and Python scripts).
- `StaticSanityCheck/` plus Lean files in repo root (`Main.lean`, `StaticSanityCheck.lean`, `lakefile.toml`, `lean-toolchain`, `lake-manifest.json`): Lean 4 formalization artifact.
- `.github/workflows/lean_action_ci.yml`: CI workflow running `lake build`.

## Minimal Physics Context

The paper imposes a non-local leafwise constraint on the normalized average of `K^2` over a causal domain (`<K^2> = K0^2` in the IR limit). The Lean files certify:

- static limit: `X = 1/A` and `K^2 = 0` (sec. 5.2, eqs. (19)-(20));
- Minkowski with linear tilt: IR average decays to zero (sec. 6.1-6.2, eqs. (23)-(25));
- de Sitter with PG slicing: `K^2 = 3H^2`, average equals local value, and selection rule `H^2 = K0^2/3` (sec. 6.3, eqs. (27)-(30));
- independent cross-check by substitution into the general `K^2` formula (eq. (11), explicit in `StaticSanityCheck/K2General.lean`);
- IR dominance of local sources: compactly supported contributions are suppressed under normalized averages on `B_R` as `R -> atTop`;
- de Sitter well-posedness of the leafwise average: `I0 > 0`, finite causal domain radius `H^-1`, and saturation of the IR limit at the horizon scale.

## Build

```bash
lake build
lake exe staticsanitycheck
```

## Reproduce (Copy/Paste)

```bash
lake exe cache get   # optional but recommended (mathlib cache)
lake build
```

## Version Pinning (Reproducibility)

Versions currently pinned in this repository:

- Lean toolchain:
  `leanprover/lean4:v4.27.0`
  (file: `lean-toolchain`)
- Mathlib:
  `https://github.com/leanprover-community/mathlib4.git`
  with `inputRev = v4.27.0` and resolved commit
  `a3a10db0e9d66acbebf76c5e6a135066525ac900`
  (file: `lake-manifest.json`)

For referee-level reproducibility, treat `lean-toolchain` and `lake-manifest.json` as canonical.

## Artifact Release

- Recommended release tag for review:
  `v2.0`
- Archive DOI:
  `10.5281/zenodo.18361297`
- Citation metadata:
  `CITATION.cff` (repository root)

## Formalization Boundaries (Explicit)

- Formal starting point:
  Eq. (11) in the paper, Lean symbol `K2_general` in `StaticSanityCheck/K2General.lean`.

- Origin of `K2_general`:
  The Lean development certifies the full analytical chain that starts from the explicit coordinate expression of `K^2` (`NumK2/DenK2` in `StaticSanityCheck/K2General.lean`). It does not yet formalize, in the same artifact, the full differential-geometric derivation of that expression from base objects (`u^mu`, projectors, connection, and tensor construction of `K_{mu nu}K^{mu nu}`).

- Causal domain `D_Theta`:
  In Lean, `D_Theta` is modeled with nested proxy domains suitable for IR tests (balls `B_R`, and in de Sitter `ball(0, min(R, H^-1))`). Mean-value, IR-dominance, and horizon-saturation results are proved on these proxies. The full Lorentzian definition of mutual causal reachability and a general equivalence proof with the proxy domains are not yet formalized.

Claim scope statement (canonical wording):

> The Lean artifact verifies the analytic chain of results starting from the explicit coordinate expression `K2_general` and the proxy domains used in the manuscript; it does not yet certify the derivation of `K2_general` from the full geometric definition `K_{mu nu}K^{mu nu}`, nor the equivalence between the proxy domains and the general Lorentzian causal-domain definition.

## What Each Lean File Verifies (and Why)

- `Main.lean`
  Executable entry point. No physics content: only a final build smoke test (`StaticSanityCheck: build OK`).

- `StaticSanityCheck.lean`
  Aggregator module importing all verification files. Provides a single compilation/re-export target.

- `StaticSanityCheck/Basic.lean`
  Minimal placeholder (`hello`). Not used in the physics checks.

- `StaticSanityCheck/K2General.lean`
  Defines the closed general form of `K^2`: `NumK2`, `DenK2`, `K2_general`.
  Why: this is the algebraic base used to derive special cases (for example de Sitter PG) without assuming pre-simplified formulas.

- `StaticSanityCheck/StaticLimit.lean`
  Formalizes the static-limit sanity check (`psi' = 0`): `XInvariant_static` and `K2Invariant_static`, with denominator guards.
  Why: establishes the GR-consistent baseline used in sec. 5.2 of the paper (`X = 1/A`, `K^2 = 0`).

- `StaticSanityCheck/MinkowskiLinearTilt.lean`
  Defines the closed IR average in Minkowski with linear tilt:
  `minkowskiInfraredAverage v R = 6*v^2 / ((1 - v^2)*R^2)`.
  Proves `minkowskiInfraredAverage_tendsto_zero` for `|v| < 1`.
  Why: certifies the IR mechanism (decay `~ R^-2`) used to exclude generic Minkowski vacuum selection for `K0^2 > 0`.

- `StaticSanityCheck/DeSitterPG.lean`
  Implements the direct de Sitter branch:
  `dS_A`, `dS_B`, `dS_PG_psi'`, `X_of`, `deSitterPG_X_eq_one`,
  `deSitterPG_K2`, `deSitterPG_leafwiseAverage_eq`, `deSitter_selection_rule`.
  Why: formalizes the linear chain eq. (27)->(28)->(29)->(30):
  `X=1`, `K^2=3H^2`, leafwise average equals local value, then `H^2 = K0^2/3`.

- `StaticSanityCheck/DeSitterPG_FromGeneral.lean`
  Reaches the same de Sitter conclusion by explicit substitution into
  `K2_general` from `StaticSanityCheck/K2General.lean`:
  `deSitterPG_K2_eq_threeH2_from_general` and
  `deSitter_selection_rule_from_general`.
  Symbols are in namespace `StaticSanityCheck.FromGeneral` to avoid collisions with `StaticSanityCheck/DeSitterPG.lean`.
  Why: independent algebraic robustness check (cross-check between general formula and direct branch).

- `StaticSanityCheck/AbstractAverage.lean`
  Formalizes the abstract average lemma used by the leafwise constraint:
  if a quantity is constant on a domain, the normalized average equals that constant; uniform convergence on domains implies convergence of normalized averages.
  Main theorems:
  `leafAverage_eq_const_of_forall_eq`,
  `norm_leafAverage_sub_le_of_forall_norm_sub_le`,
  `tendsto_leafAverage_of_uniform_on_domains`,
  `tendsto_leafAverage_of_eventually_const`.
  Why: justifies the conceptual step "leafwise average -> constraint limit" independently of the specific metric.

- `StaticSanityCheck/IRDominance.lean`
  Formalizes the IR claim "local sources are suppressed":
  1) abstract lemma `tendsto_div_atTop_zero_of_eventuallyEq_const`;
  2) 3D volume growth `tendsto_volume_real_ball_fin_three_atTop`;
  3) physics corollary
  `tendsto_ballIntegral_div_volume_real_zero_of_tsupport_subset_closedBall`.
  Why: makes rigorous the step "compact/local contributions do not change the IR average" (numerator stabilizes, volume diverges).

- `StaticSanityCheck/DeSitterWellPosed.lean`
  Formalizes well-posedness of the de Sitter leafwise average using nested domains
  `D_Theta(R) = ball(0, min(R, H^-1))`:
  `I0`, `I1`, `leafAverage`, then
  `I0_pos_of_pos`,
  `dSDomain_measure_lt_top`,
  `leafAverage_eq_horizon_of_ge`,
  `leafAverage_eventuallyEq_horizon`,
  `leafAverage_tendsto_horizon`.
  Why: certifies that the IR limit in static de Sitter saturates at finite radius `H^-1`.

## Quick Traceability: Paper -> Lean

| Paper reference | Lean theorem/def | Main assumptions | File |
|---|---|---|---|
| Eq. (9): `X = 1/A - (psi')^2/B` | `X_of`, `deSitterPG_X_eq_one`; general-branch variants `StaticSanityCheck.FromGeneral.X_of`, `StaticSanityCheck.FromGeneral.deSitterPG_X_eq_one`; static-limit checks `XInvariant`, `XInvariant_static` | for `deSitterPG_X_eq_one`: `dS_A H r != 0`; for `XInvariant_static`: no extra assumptions | `StaticSanityCheck/DeSitterPG.lean`, `StaticSanityCheck/DeSitterPG_FromGeneral.lean`, `StaticSanityCheck/StaticLimit.lean` |
| Eq. (11): general `K^2` formula | `NumK2`, `DenK2`, `K2_general` | coordinate explicit definition (formal starting point) | `StaticSanityCheck/K2General.lean` |
| Eqs. (19)-(20): static limit | `XInvariant_static`, `K2Invariant_static`, `static_sanity_check` | for `K2Invariant_static`: `A != 0`, `B != 0`, `r != 0` | `StaticSanityCheck/StaticLimit.lean` |
| Eqs. (23)-(25): Minkowski + IR average | `minkowskiInfraredAverage`, `minkowskiInfraredAverage_eq_const_div`, `minkowskiInfraredAverage_tendsto_zero` | for limit: `|v| < 1` | `StaticSanityCheck/MinkowskiLinearTilt.lean` |
| Eqs. (27)-(30): de Sitter PG + selection rule | `dS_A`, `dS_B`, `dS_PG_psi'`, `deSitterPG_X_eq_one`, `deSitterPG_K2`, `deSitterPG_leafwiseAverage_eq`, `deSitter_selection_rule`; independent cross-check `deSitterPG_K2_eq_threeH2_from_general`, `deSitter_selection_rule_from_general` | direct branch: `dS_A H r != 0` where required; general cross-check: `dS_A H r != 0`, `r != 0` | `StaticSanityCheck/DeSitterPG.lean`, `StaticSanityCheck/DeSitterPG_FromGeneral.lean` |
| Abstract leafwise average/limit statement | `leafAverage_eq_const_of_forall_eq`, `norm_leafAverage_sub_le_of_forall_norm_sub_le`, `tendsto_leafAverage_of_uniform_on_domains`, `tendsto_leafAverage_of_eventually_const` | measurability, non-zero and finite restricted measure, integrability/uniformity assumptions depending on theorem | `StaticSanityCheck/AbstractAverage.lean` |
| IR claim: local sources suppressed | `tendsto_div_atTop_zero_of_eventuallyEq_const`, `tendsto_volume_real_ball_fin_three_atTop`, `tendsto_ballIntegral_div_volume_real_zero_of_tsupport_subset_closedBall` | topological support contained in a finite closed ball (local source) | `StaticSanityCheck/IRDominance.lean` |
| de Sitter well-posedness (`I0 > 0`, finite domain, saturation at `H^-1`) | `I0_pos_of_pos`, `dSDomain_measure_lt_top`, `leafAverage_eq_horizon_of_ge`, `leafAverage_eventuallyEq_horizon`, `leafAverage_tendsto_horizon` | `H > 0`, `R > 0` for `I0_pos_of_pos`; saturation threshold `H^-1 <= R` | `StaticSanityCheck/DeSitterWellPosed.lean` |
