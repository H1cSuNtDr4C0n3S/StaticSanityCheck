# Paper Integration Checklist (main.tex)

Date: 2026-02-18

## Phase 0 - Sync
- [x] Push current repository state to GitHub before tex rewrite.

## Phase 1 - Scope Mapping
- [x] Identify all "future work" / "beyond scope" statements in `Paper/main.tex`.
- [x] Map each statement to existing evidence in:
  - [x] `Paper/Variational_Derivation/*`
  - [x] `Paper/Perturbative_Spectrum_Study/*`
  - [x] `Paper/Barotropic_Cosmology_Study/*` (brief mention)

## Phase 2 - Main Text Integration
- [x] Rewrite motivation/scope section to reflect completed perturbative/EFT analysis.
- [x] Replace variational "beyond scope" with explicit 4D variational structure and checks.
- [x] Integrate perturbative spectrum results (tensor/vector/scalar, projector algebra, dispersion, residues).
- [x] Integrate EFT validity discussion (operational cutoff, proxy strong-coupling, validity regime).
- [x] Keep wording technically accurate (proxy vs full derivation where needed).
- [x] Add explicit traceability references to files/scripts/logs.
- [x] Add brief barotropic consistency mention.

## Phase 3 - Computational Section Update
- [x] Update "Computational details" with actual current pipeline layout.
- [x] Reference new study folders and key scripts.
- [x] Remove obsolete notebook list that no longer reflects repository structure.

## Phase 4 - Conclusion Update
- [x] Update conclusion to include completed results.
- [x] Keep clear list of remaining open items only if truly still open.

## Phase 5 - Build and Verify
- [x] Compile LaTeX successfully (`main.tex`).
- [x] Resolve compilation warnings/errors introduced by edits.
- [x] Quick textual consistency pass on terminology across sections.

## Phase 6 - Final Sync
- [x] Commit checklist + tex/compile-related changes.
- [x] Push final paper update to GitHub.
