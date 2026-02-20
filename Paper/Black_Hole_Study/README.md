# Black_Hole_Study

Questa cartella e separata dalle altre pipeline e contiene test mirati sui buchi neri senza modificare il paper.

## Scope
1. Fissare una definizione operativa e univoca di `D_Theta` in presenza di buco nero.
2. Testare la shape derivative del bordo di `D_Theta` quando la geometria varia.
3. Decidere in modo operativo la biforcazione: foglie `Theta` che attraversano l'orizzonte oppure foglie che stallano/asintotizzano.
4. Misurare la robustezza IR di `Q=I1/I0` contro contributi locali BH (integrabili vs non integrabili).
5. Eseguire il no-go test a cutoff su interni singolari in scenario crossing.
6. Validare che il BH non spenga la selezione del vuoto (scaling IR con `H -> H/2`).
7. Eseguire il killer test con `K2` geometrico reale (non toy) sulla foliazione crossing.
8. Implementare e validare la via `Interior regularization` come scelta coerente dopo il killer test.

## Struttura
1. `scripts/00_dtheta_domain_sds_shape_derivative.wl`
2. `scripts/01_kottler_global_foliation_crossing_test.wl`
3. `scripts/02_ir_robustness_bh_weight_on_q.wl`
4. `scripts/03_singularity_nogo_cutoff_test.wl`
5. `scripts/04_bh_non_switches_off_selection_ir_scaling_test.wl`
6. `scripts/05_geometric_k2_cutoff_killer_test.wl`
7. `scripts/06_interior_regularization_consistency_test.wl`
8. `logs/`
9. `summary.md`
10. `detailed_calculations.md`
11. `run_all.ps1`

## Cosa verifica il notebook 00
1. Definizione operativa:
   `D_Theta(M,H,z2) = {r > 0 | f(r;M,H) >= z2}`, con `f=1-2M/r-H^2 r^2`.
2. Esistenza e ordinamento univoco delle due frontiere `{r_in, r_out}`.
3. Formula chiusa della shape derivative:
   `dr/dM = r/(M - H^2 r^3)`.
4. Confronto numerico tra derivata implicita e differenze finite su `r_in`, `r_out`.
5. Test di consistenza sul funzionale:
   `dI0/dM = mu(r_out) dr_out/dM - mu(r_in) dr_in/dM`.

## Cosa verifica il notebook 01
1. Esistenza di una foliazione globale regolare su Kottler:
   `Theta = T = t + g(r)`, `g'(r)=Sqrt[1-f]/f`.
2. Norma del gradiente:
   `X_Theta = 1` (timelike su tutte le regioni campionate).
3. Regolarita metrica nei nuovi tempi:
   blocco `(T,r)` con `g_rr=1`, `det2D=-1`, valori finiti ai due orizzonti.
4. Classificazione operativa della biforcazione:
   `behavior="A_crossing"` (foglie che attraversano).

## Cosa verifica il notebook 02
1. Toy model:
   `I1 = I1bg + deltaI1BH`, `Q=I1/I0`, con fondo de Sitter e difetto BH locale.
2. Profilo BH:
   `deltaI1BH ~ integral r^(2-p) dr` tra `r_eps` e `r_match`.
3. Test di integrabilita profonda:
   `p<3` integrabile, `p=3` log, `p>3` non integrabile.
4. Test di scaling IR:
   `deltaQ` sul ramo integrabile scala come `~1/Rc^3` (rapporti `~8` quando `Rc` raddoppia).
5. Test di rischio O(1):
   nel ramo non integrabile (`p=4`) `deltaQ` diventa cutoff-sensitive e puo arrivare a shift relativi O(1).

## Cosa verifica il notebook 03
1. Usa la foliazione crossing (`Theta=T`) e integra su `r in [rmin, rout]`.
2. Ripete il calcolo per `rmin = rs*10^{-1..-6}`.
3. Testa il profilo:
   `K2toy = K2bg + A (rs/r)^n`.
4. Verifica convergenza/non-convergenza di `Q=I1/I0` per:
   `n=2.5` (integrabile), `n=3` (log), `n=6` (singolare classico forte).
5. Applica criterio no-go:
   in crossing, `n>=3` rende `Q` cutoff-sensitive o divergente.

## Cosa verifica il notebook 04
1. Fissa `M` e `z2` e calcola:
   `Q(M,H)` e `Q(0,H)`.
2. Definisce:
   `deltaQ(H)=Q(M,H)-Q(0,H)`.
3. Ripete per `H/2`:
   `deltaQ(H/2)=Q(M,H/2)-Q(0,H/2)`.
4. Valida il criterio IR:
   `deltaQ(H/2)/deltaQ(H) ~ 1/8`.
5. Controlla che il contributo locale BH resti subleading rispetto al canale cosmologico.

## Cosa verifica il notebook 05
1. Sostituisce `K2toy` con `K2` geometrico reale su foliazione crossing `T` in Kottler.
2. Ricalcola `Q(rmin)=I1(rmin)/I0(rmin)` su `r in [rmin, rout]` con `rmin=rs*10^{-1..-6}`.
3. Misura il comportamento effettivo del core:
   `n_eff = - d log K2 / d log r`.
4. Verifica il coefficiente asintotico reale:
   `r^3 K2 -> 9M/2`.
5. Applica lo stesso criterio no-go del cutoff test:
   se `Q` non converge per `rmin -> 0`, allora no-go geometrico in scenario crossing.

## Cosa verifica il notebook 06
1. Implementa una regolarizzazione interna morbida:
   `vReg(r)=Sqrt[2M/Sqrt[r^2+aReg^2]+H^2 r^2]`,
   `K2reg=(vReg')^2+2(vReg/r)^2`.
2. Ripete il cutoff test su `r in [rmin,rout]` con `rmin=rs*10^{-1..-7}`.
3. Misura l'esponente effettivo:
   `n_eff = - d log K2reg / d log r` nel core.
4. Verifica convergenza di `Q(rmin)` e fit lineare nel tail (`Q -> Q0 + c rmin`).
5. Ricontrolla il test IR `H -> H/2` su `deltaQ=Q(M,H)-3H^2`.
6. Classifica la consistenza del ramo:
   `classification="INTERIOR_REGULARIZATION_CONSISTENT"` se convergenza core + soppressione IR restano vere.

## Esito attuale
Dal log `logs/00_dtheta_domain_sds_shape_derivative.log`:
1. `check=True`.
2. `r_in = 2.10624672529...`.
3. `r_out = 96.39775038176...`.
4. `r_out/r_in = 45.76754908354...`.

Dal log `logs/01_kottler_global_foliation_crossing_test.log`:
1. `check=True`.
2. `roots = {2.00080096153..., 98.98458637542...}`.
3. `behavior = "A_crossing"`.
4. `checkH=True` (foliazione statica `t` non globale), `checkI=True` (foliazione `T` globale e timelike).

Dal log `logs/02_ir_robustness_bh_weight_on_q.log`:
1. `check=True`.
2. `volRatio=(rs/rc)^3 = 8.25864777853...*10^-6`.
3. `fracP2 = deltaQ(p=2)/K2bg = 1.48630884070...*10^-4`.
4. `scaleRatiosP2 = {8.00000000000..., 8.00000000000...}`.
5. `fracP4Small = deltaQ(p=4,r_eps=10^-6 rs)/K2bg = 24.77593920628...`.
6. `regime = "IR_robust_except_nonintegrable_core"`.

Dal log `logs/03_singularity_nogo_cutoff_test.log`:
1. `check=True`.
2. `classification = "NO_GO_singular_crossing"`.
3. caso `n=2.5`: `errN25 = 4.95346222949...*10^-8` (convergente).
4. caso `n=3`: `ratioN3 ~ 1` (trend logaritmico non convergente).
5. caso `n=6`: `ratioN6 -> {999.879..., 999.999..., 999.999999...}`.
6. crescita complessiva `n=6`: `growthN6 = 8.19100118479...*10^12`.

Dal log `logs/04_bh_non_switches_off_selection_ir_scaling_test.log`:
1. `check=True`.
2. `classification = "BH_selection_not_switched_off"`.
3. `deltaQ(H) = 4.07709104588...*10^-6`.
4. `deltaQ(H/2) = 5.09829438270...*10^-7`.
5. `ratioDelta = deltaQ(H/2)/deltaQ(H) = 0.12504735178...` (compatibile con `1/8`).
6. `ratioI0 = I0(H/2)/I0(H) = 8.13515907416...`.
7. `predErr = 3.78814270985...*10^-4` rispetto alla stima `deltaQ(H)/8`.

Dal log `logs/05_geometric_k2_cutoff_killer_test.log`:
1. `check=True`.
2. `classification = "GEOMETRIC_NO_GO_singular_crossing"`.
3. `tailNEff = {2.999999999999942..., 2.99999999999999994..., 2.999999999999999999...}`.
4. coefficiente core reale:
   `c3Num = 4.500000000000000000000600...`, `c3Theo = 4.5`.
5. trend cutoff:
   `dqRatios -> {1.000000000000091..., 1.000000000000000100...}` (incrementi per decade quasi costanti, non convergenza logaritmica).
6. accordo con predizione asintotica:
   `predRelErrTail ~ {9.19e-14, 1.00e-16, 1.08e-19}`.

Dal log `logs/06_interior_regularization_consistency_test.log`:
1. `check=True`.
2. `classification = "INTERIOR_REGULARIZATION_CONSISTENT"`.
3. core regolarizzato:
   `tailNEff ~ {2.0000002148..., 2.0000000021..., 2.00000000002..., 2.00000000000021...}`.
4. coefficiente asintotico regolare:
   `c2Num = 1.99919935910...`, `c2Theo = 1.99919935910...`.
5. convergenza cutoff:
   `dqRatios tail ~ {0.1000000183..., 0.10000000018..., 0.1000000000018...}`.
6. fit di convergenza:
   `relTailErr = 3.5983...*10^-9`.
7. test IR:
   `ratioDelta = 0.14115348786...` (compatibile con `1/8` entro tolleranza),
   `ratioI0 = 8.12468890948...`,
   `epsRef = 0.14619...`, `epsHalf = 0.08254...` (subleading, non O(1)).

## Risposta operativa alla tua domanda 2
1. Nel patch Kottler il test `01` trova una foliazione globale regolare che attraversa gli orizzonti.
2. In coordinate statiche `t` le foglie possono apparire asintotiche (slope molto grande vicino all'orizzonte), ma e un effetto di coordinate.
3. Con la variabile di tempo regolare `T` la classificazione cade nel caso `A` (attraversano), non nel caso `B` (stall).

## Risposta operativa alla tua domanda 3
1. Nel toy "de Sitter + difetto BH", per profili integrabili (`p<3`) il contributo locale resta IR-soppresso:
   `deltaQ ~ O((rs/rc)^3)`.
2. Nel benchmark, il ramo integrabile da `deltaQ/K2bg ~ 1.49*10^-4`, quindi non compete con il termine cosmologico.
3. Un contributo BH che diventa O(1) emerge solo nel ramo non integrabile (`p>3`) e dipende in modo forte dal cutoff interno (`r_eps`), cioe da una divergenza di core non regolata.

## Risposta operativa al no-go sulle singolarita
1. Nel caso crossing, il cutoff test conferma la regola:
   `K2 ~ r^-n` e compatibile solo per `n<3`.
2. Per `n>=3` il valore di `Q` non converge al ridurre `rmin`.
3. Nel proxy singolare classico (`n=6`) il test e no-go (`classification="NO_GO_singular_crossing"`), salvo:
   regolarizzazione del core oppure esclusione dell'interno da `D_Theta`.

## Risposta operativa al killer test geometrico
1. Con `K2` geometrico reale sulla foliazione crossing, il core risulta effettivamente `n_eff ~ 3`.
2. Il cutoff test resta non convergente (`Q` cresce con incrementi logaritmici quasi costanti al ridurre `rmin`).
3. Quindi il no-go non e solo toy: nel setup Kottler crossing emerge come
   `classification="GEOMETRIC_NO_GO_singular_crossing"`.

## Risposta operativa: Interior regularization
1. La scelta forzata e stata implementata nella via `(1)`:
   regolarizzazione del core con `aReg` finito.
2. Nel nuovo test `06`, il core passa a regime integrabile (`n_eff ~ 2 < 3`) e `Q(rmin)` converge.
3. Il canale IR resta coerente con la narrativa globale:
   il BH resta locale e la soppressione con volume cosmologico e preservata.

## Risposta operativa alla validazione "BH non spegne selezione"
1. Il test `04` conferma la narrativa IR:
   `deltaQ(H/2) ~ (1/8) deltaQ(H)`.
2. Quindi, aumentando il dominio cosmologico (riducendo `H`), l'impronta del BH su `Q` si sopprime come `~1/Volume`.
3. Nel benchmark il BH resta una sotto-regione locale su sfondo cosmologico dominante (`classification="BH_selection_not_switched_off"`).

## Esecuzione (Wolfram Cloud trial)
Autenticati una volta:

```powershell
& "C:\Program Files\Wolfram Research\WolframScript\wolframscript.exe" -authenticate
```

Poi:

```powershell
cd c:\lean\StaticSanityCheck\Paper\Black_Hole_Study
.\run_all.ps1
```

`run_all.ps1` esegue gli script `.wl`, salva i notebook `.nb` nella cartella corrente e i log testuali in `logs/`.
