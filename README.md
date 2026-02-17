# Geometric Vacuum Selection Project

[![CI](https://github.com/H1cSuNtDr4C0n3S/GeometricVacuumSelection/actions/workflows/lean_action_ci.yml/badge.svg)](https://github.com/H1cSuNtDr4C0n3S/GeometricVacuumSelection/actions/workflows/lean_action_ci.yml)
[![Release](https://img.shields.io/github/v/release/H1cSuNtDr4C0n3S/GeometricVacuumSelection?display_name=tag)](https://github.com/H1cSuNtDr4C0n3S/GeometricVacuumSelection/releases)
[![Lean](https://img.shields.io/badge/Lean-v4.27.0-blue)](https://github.com/leanprover/lean4)
[![mathlib](https://img.shields.io/badge/mathlib-a3a10db0-informational)](https://github.com/leanprover-community/mathlib4/commit/a3a10db0e9d66acbebf76c5e6a135066525ac900)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.18361297.svg)](https://doi.org/10.5281/zenodo.18361297)

Workspace Lean 4 per verifiche formali dei passaggi chiave del paper:
`Geometric_Vacuum_Selection_from_Constrained_Spacetime_Foliations_v2.0.pdf`
(presente in `Paper/`).

Obiettivo: trasformare i passaggi analitici usati nell'argomento di vacuum
selection in enunciati Lean con ipotesi esplicite.

## Struttura Repository

- `Paper/`: paper LaTeX (`main.tex`), PDF, figure e materiale computazionale
  (notebook/script usati per i calcoli simbolici e numerici).
- `StaticSanityCheck/` + file Lean in root (`Main.lean`,
  `StaticSanityCheck.lean`, `lakefile.toml`, `lean-toolchain`,
  `lake-manifest.json`): artifact Lean 4 per la formalizzazione/sanity-check.
- `.github/workflows/lean_action_ci.yml`: CI che esegue `lake build`.

## Contesto fisico minimo

Il paper impone un vincolo non-locale leafwise sulla media normalizzata di
`K^2` nel dominio causale (`<K^2> = K0^2` in limite IR). La narrativa tecnica
controllata nei file Lean e':

- limite statico: `X = 1/A` e `K^2 = 0` (sez. 5.2, eq. (19)-(20));
- caso Minkowski con tilt lineare: media IR che decade a zero
  (sez. 6.1-6.2, eq. (23)-(25));
- caso de Sitter con slicing PG: `K^2 = 3H^2`, media coincidente, e regola
  `H^2 = K0^2/3` (sez. 6.3, eq. (27)-(30));
- verifica indipendente via sostituzione nella formula generale di `K^2`
  (eq. (11), forma esplicita in `K2General.lean`);
- dominance IR delle sorgenti locali: per supporto compatto, la media
  normalizzata su palle `B_R` tende a zero quando `R -> atTop`;
- ben-posedness de Sitter della media leafwise: `I0 > 0` (denominatore non
  degenere), dominio causale finito al raggio `H^-1`, e saturazione del limite
  IR a scala di orizzonte.

## Build

```bash
lake build
lake exe staticsanitycheck
```

## Reproduce (Copy/Paste)

```bash
lake exe cache get   # opzionale ma raccomandato (mathlib cache)
lake build
```

## Version Pinning (Riproducibilita')

Versioni usate nello sviluppo corrente (pinnate nel repository):

- Lean toolchain:
  `leanprover/lean4:v4.27.0`
  (file: `lean-toolchain`)
- Mathlib:
  `https://github.com/leanprover-community/mathlib4.git`
  con `inputRev = v4.27.0` e commit risolto
  `a3a10db0e9d66acbebf76c5e6a135066525ac900`
  (file: `lake-manifest.json`)

Per una riproduzione fedele da referee, i due file da considerare canonici
sono `lean-toolchain` e `lake-manifest.json`.

## Artifact Release

- GitHub release/tag consigliata per referaggio:
  `v2.0`
- DOI archivio:
  `10.5281/zenodo.18361297`
- Metadata citazione:
  `CITATION.cff` (in root repository)

## Confini Di Formalizzazione (Espliciti)

- Starting point formale (aggancio esplicito):
  Eq. (11) del paper, simbolo Lean `K2_general` in
  `StaticSanityCheck/K2General.lean`.

- Origine di `K2_general`:
  La libreria Lean certifica rigorosamente tutta la catena analitica che
  parte dalla forma coordinata esplicita di `K^2` (`NumK2/DenK2` in
  `StaticSanityCheck/K2General.lean`). Non e' ancora formalizzata, nello
  stesso sviluppo Lean, la derivazione completa di tale formula da
  definizioni geometriche di base (`u^mu`, proiettori, connessione,
  costruzione tensoriale completa di `K_{mu nu}K^{mu nu}`).

- Dominio causale `D_Theta`:
  In Lean `D_Theta` e' modellato tramite domini proxy annidati adatti ai test
  IR (palle `B_R`, e in de Sitter `ball(0, min(R, H^-1))`), su cui sono
  dimostrati i risultati di media, dominance IR e saturazione all'orizzonte.
  Non e' ancora formalizzata l'intera nozione lorentziana di "mutua
  raggiungibilita' causale" con prova di equivalenza generale ai proxy usati.

Claim scope statement (canonical wording):

> The Lean artifact verifies the analytic chain of results starting from the explicit coordinate expression `K2_general` and the proxy domains used in the manuscript; it does not yet certify the derivation of `K2_general` from the full geometric definition `K_{mu nu}K^{mu nu}`, nor the equivalence between the proxy domains and the general Lorentzian causal-domain definition.

## Cosa Verifica Ogni Script Lean (e Perche')

- `Main.lean`
  Entry point eseguibile. Non contiene fisica: serve solo come smoke test
  finale del build (`StaticSanityCheck: build OK`).

- `StaticSanityCheck.lean`
  Modulo aggregatore che importa i file di verifica. Serve per avere un unico
  target di compilazione/re-export.

- `StaticSanityCheck/Basic.lean`
  Placeholder minimale (`hello`). Non partecipa alle verifiche fisiche.

- `StaticSanityCheck/K2General.lean`
  Definisce la forma chiusa generale di `K^2`:
  `NumK2`, `DenK2`, `K2_general`.
  Perche': e' la base algebraica da cui derivare risultati specifici
  (es. de Sitter PG) senza assumere formule gia' semplificate.

- `StaticSanityCheck/StaticLimit.lean`
  Formalizza il sanity check del limite statico (`psi' = 0`):
  `XInvariant_static` e `K2Invariant_static`, con controllo dei denominatori.
  Perche': fissa il baseline coerente con GR locale e con la sezione 5.2 del
  paper (`X = 1/A`, `K^2 = 0`).

- `StaticSanityCheck/MinkowskiLinearTilt.lean`
  Definisce la forma chiusa della media IR nel caso Minkowski con tilt lineare:
  `minkowskiInfraredAverage v R = 6*v^2 / ((1 - v^2)*R^2)`.
  Prova poi `minkowskiInfraredAverage_tendsto_zero` per `|v| < 1`.
  Perche': certifica in Lean il meccanismo IR (decadimento `~ R^-2`) che nel
  paper esclude Minkowski come vacuum IR generico per `K0^2 > 0`.

- `StaticSanityCheck/DeSitterPG.lean`
  Implementa il ramo de Sitter in forma diretta:
  `dS_A`, `dS_B`, `dS_PG_psi'`, `X_of`, `deSitterPG_X_eq_one`,
  `deSitterPG_K2`, `deSitterPG_leafwiseAverage_eq`, `deSitter_selection_rule`.
  Perche': formalizza in modo lineare la catena eq. (27)->(28)->(29)->(30):
  `X=1`, `K^2=3H^2`, media leafwise uguale al valore locale, quindi
  `H^2 = K0^2/3`.

- `StaticSanityCheck/DeSitterPG_FromGeneral.lean`
  Stessa conclusione de Sitter, ma ottenuta sostituendo esplicitamente nel
  `K2_general` di `K2General.lean`:
  `deSitterPG_K2_eq_threeH2_from_general` e
  `deSitter_selection_rule_from_general`.
  Simboli nel namespace `StaticSanityCheck.FromGeneral` per evitare collisioni
  con `DeSitterPG.lean`.
  Perche': e' una verifica indipendente di robustezza algebraica (cross-check
  tra formula generale e versione diretta).

- `StaticSanityCheck/AbstractAverage.lean`
  Formalizza il lemma astratto usato per il vincolo leafwise:
  se su un dominio la quantita' e' costante, la media normalizzata coincide col
  valore costante; inoltre una convergenza uniforme sui domini implica la
  convergenza della media normalizzata.
  Teoremi principali:
  `leafAverage_eq_const_of_forall_eq`,
  `norm_leafAverage_sub_le_of_forall_norm_sub_le`,
  `tendsto_leafAverage_of_uniform_on_domains`,
  `tendsto_leafAverage_of_eventually_const`.
  Perche': giustifica in Lean il passaggio concettuale "media leafwise ->
  limite del vincolo" senza legarsi a una metrica specifica (Minkowski/de
  Sitter).

- `StaticSanityCheck/IRDominance.lean`
  Formalizza il claim IR "sorgenti locali sono soppresse":
  1) lemma astratto `tendsto_div_atTop_zero_of_eventuallyEq_const`;
  2) crescita del volume 3D `tendsto_volume_real_ball_fin_three_atTop`;
  3) corollario fisico
  `tendsto_ballIntegral_div_volume_real_zero_of_tsupport_subset_closedBall`.
  Perche': rende rigoroso il passaggio "contributi compatti/locali non alterano
  la media nel limite IR", cioe' il numeratore si stabilizza mentre il volume
  cresce senza bound.

- `StaticSanityCheck/DeSitterWellPosed.lean`
  Formalizza la ben-posedness della media nel caso de Sitter usando domini
  annidati `D_Theta(R) = ball(0, min(R, H^-1))`:
  `I0`, `I1`, `leafAverage`, poi
  `I0_pos_of_pos`,
  `dSDomain_measure_lt_top`,
  `leafAverage_eq_horizon_of_ge`,
  `leafAverage_eventuallyEq_horizon`,
  `leafAverage_tendsto_horizon`.
  Perche': certifica che il limite IR non richiede mandare davvero `R` a
  infinito nel patch statico de Sitter: oltre `H^-1` la media e' gia'
  costante.

## Tracciabilita' Rapida Paper -> Lean

| Riferimento paper | Nome Lean (theorem/def) | Ipotesi principali | File |
|---|---|---|---|
| Eq. (9): `X = 1/A - (psi')^2/B` | `X_of`, `deSitterPG_X_eq_one`; variante generale `X_of`, `deSitterPG_X_eq_one`; limite statico `XInvariant`, `XInvariant_static` | per `deSitterPG_X_eq_one`: `dS_A H r != 0`; per `XInvariant_static`: nessuna ipotesi extra | `StaticSanityCheck/DeSitterPG.lean`, `StaticSanityCheck/DeSitterPG_FromGeneral.lean`, `StaticSanityCheck/StaticLimit.lean` |
| Eq. (11): forma generale di `K^2` | `NumK2`, `DenK2`, `K2_general` | definizione coordinata (starting point) | `StaticSanityCheck/K2General.lean` |
| Eq. (19)-(20): limite statico | `XInvariant_static`, `K2Invariant_static`, `static_sanity_check` | per `K2Invariant_static`: `A != 0`, `B != 0`, `r != 0` | `StaticSanityCheck/StaticLimit.lean` |
| Eq. (23)-(25): Minkowski + media IR | `minkowskiInfraredAverage`, `minkowskiInfraredAverage_eq_const_div`, `minkowskiInfraredAverage_tendsto_zero` | per il limite: `|v| < 1` | `StaticSanityCheck/MinkowskiLinearTilt.lean` |
| Eq. (27)-(30): de Sitter PG + selection rule | `dS_A`, `dS_B`, `dS_PG_psi'`, `deSitterPG_X_eq_one`, `deSitterPG_K2`, `deSitterPG_leafwiseAverage_eq`, `deSitter_selection_rule`; cross-check indipendente `deSitterPG_K2_eq_threeH2_from_general`, `deSitter_selection_rule_from_general` | ramo diretto: `dS_A H r != 0` dove richiesto; cross-check generale: `dS_A H r != 0`, `r != 0` | `StaticSanityCheck/DeSitterPG.lean`, `StaticSanityCheck/DeSitterPG_FromGeneral.lean` |
| Vincolo leafwise astratto (media/limite) | `leafAverage_eq_const_of_forall_eq`, `norm_leafAverage_sub_le_of_forall_norm_sub_le`, `tendsto_leafAverage_of_uniform_on_domains`, `tendsto_leafAverage_of_eventually_const` | misurabilita', misura non nulla, finitezza misura ristretta, integrabilita'/uniformita' secondo il lemma | `StaticSanityCheck/AbstractAverage.lean` |
| Claim IR: sorgenti locali soppresse | `tendsto_div_atTop_zero_of_eventuallyEq_const`, `tendsto_volume_real_ball_fin_three_atTop`, `tendsto_ballIntegral_div_volume_real_zero_of_tsupport_subset_closedBall` | supporto topologico contenuto in una palla finita (sorgente locale) | `StaticSanityCheck/IRDominance.lean` |
| Ben-posedness de Sitter (`I0 > 0`, dominio finito, saturazione a `H^-1`) | `I0_pos_of_pos`, `dSDomain_measure_lt_top`, `leafAverage_eq_horizon_of_ge`, `leafAverage_eventuallyEq_horizon`, `leafAverage_tendsto_horizon` | `H > 0`, `R > 0` per `I0_pos_of_pos`; soglia di saturazione `H^-1 <= R` | `StaticSanityCheck/DeSitterWellPosed.lean` |
