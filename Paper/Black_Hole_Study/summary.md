# Black Hole Study Summary

Mappa notebook `Paper/Black_Hole_Study` -> passaggi matematici, output verificati e lettura fisica.

## Notebook 00-06

1. `00_DTheta_Domain_SdS_Shape_Derivative.nb`
`Riferimento`: definizione operativa di `D_Theta` nel patch Schwarzschild-de Sitter con soglia di redshift `z2`.
`Output`:
1. frontiere positive `{r_in, r_out}` con `r_in < r_out`;
2. equivalenza tra indicatore diretto `UnitStep[f-z2]` e indicatore a frontiera mobile `UnitStep[r-r_in] UnitStep[r_out-r]`;
3. shape derivative del bordo:
   `dr/dM = r/(M - H^2 r^3)`;
4. confronto derivata implicita vs differenze finite su entrambi i bordi;
5. verifica di bordo del funzionale:
   `dI0/dM = mu(r_out) dr_out/dM - mu(r_in) dr_in/dM`.
`Perche questo passaggio`: chiude la "domanda zero" con una definizione univoca del dominio e una deformazione del bordo quantitativamente testabile.
`Interpretazione`: `D_Theta` viene trattato come regione geometrica con frontiera mobile ben definita, non come nozione qualitativa.
`Esito log`: `check=True`, `r_in=2.10624672529...`, `r_out=96.39775038176...`, `r_out/r_in=45.76754908354...`.

2. `01_Kottler_Global_Foliation_Crossing_Test.nb`
`Riferimento`: test pratico della biforcazione "attraversano vs asintotizzano" in metrica Kottler (Schwarzschild-de Sitter).
`Output`:
1. foliazione testata:
   `Theta = T = t + g(r)`, con `g'(r)=Sqrt[1-f]/f`;
2. norma del gradiente:
   `X_Theta = 1`;
3. blocco metrico `(T,r)` regolare:
   `g_rr=1`, `det2D=-1`, valori finiti ai due orizzonti;
4. due orizzonti positivi nel benchmark:
   `{r_bh, r_c} = {2.00080096153..., 98.98458637542...}`;
5. classificazione:
   `behavior="A_crossing"`.
`Perche questo passaggio`: risponde direttamente al test richiesto su esistenza e tipo di foliazione globale.
`Interpretazione`: nel patch Kottler esiste una foliazione globale regolare che attraversa gli orizzonti; la stasi/asintoto e legata alla coordinata statica `t`, non alla foliazione regolare `T`.
`Esito log`: `check=True`, con `checkH=True` (foliazione statica non globale) e `checkI=True` (foliazione `T` globale e timelike).

3. `02_IR_Robustness_BH_Weight_On_Q.nb`
`Riferimento`: test IR su `Q=I1/I0` con toy "de Sitter + difetto locale BH" e controllo di integrabilita del core.
`Output`:
1. decomposizione:
   `I1 = I1bg + deltaI1BH`, `deltaQ = deltaI1BH/I0`;
2. profilo locale:
   `deltaI1BH(p) ~ integral r^(2-p) dr` su `[r_eps, r_match]`;
3. ramo integrabile (`p=2`):
   `fracP2=deltaQ/K2bg=1.4863...*10^-4`;
4. scaling IR con volume cosmologico:
   `scaleRatiosP2(Rc -> 2Rc -> 4Rc) = {8..., 8...}`;
5. ramo marginale (`p=3`):
   `fracP3=2.1553...*10^-4` (log, ancora piccolo nel benchmark);
6. ramo non integrabile (`p=4`):
   `qEpsRatiosP4 ~ {100.165..., 100.001...}` al ridurre `r_eps`,
   `fracP4Small=24.7759...` (shift relativo O(1)+).
`Perche questo passaggio`: risponde direttamente alla domanda su quando il contributo BH puo competere con il fondo cosmologico in `Q`.
`Interpretazione`: senza divergenze di core (profilo integrabile) il peso BH resta volume-soppresso; contributi O(1) emergono solo in regime non integrabile e cutoff-sensitive.
`Esito log`: `check=True`, `regime="IR_robust_except_nonintegrable_core"`.

4. `03_Singularity_NoGo_Cutoff_Test.nb`
`Riferimento`: no-go test con cutoff interno su scenario crossing, per verificare la compatibilita di un core singolare con `Q=I1/I0`.
`Output`:
1. foliazione crossing (`Theta=T`) verificata (`XTheta=1`) con integrazione su `r in [rmin, rout]`;
2. scansione cutoff:
   `rmin = rs*10^{-1..-6}`;
3. ramo integrabile (`n=2.5`):
   `qN25` converge a limite finito,
   `qN25Lim=0.000300104559450...`,
   `errN25=4.95346...*10^-8`;
4. ramo marginale (`n=3`):
   incrementi quasi costanti per decade (`ratioN3 ~ 1`);
5. ramo singolare forte (`n=6`):
   `ratioN6 -> {999.879..., 999.999..., 999.999999...}`,
   `growthN6=8.19100...*10^12`;
6. classificazione automatica:
   `classification="NO_GO_singular_crossing"`.
`Perche questo passaggio`: implementa il criterio di esclusione richiesto quando le foglie attraversano l'orizzonte.
`Interpretazione`: in crossing, interni con `K2 ~ r^-n` sono compatibili solo per `n<3`; per `n>=3` il contributo a `Q` non converge al togliere cutoff.
`Esito log`: `check=True`.

5. `04_BH_Non_Switches_Off_Selection_IR_Scaling_Test.nb`
`Riferimento`: validazione diretta della tesi "BH non spegne selezione" tramite scaling di `deltaQ(H)=Q(M,H)-Q(0,H)`.
`Output`:
1. `deltaQ(H) = 4.07709104588...*10^-6`;
2. `deltaQ(H/2) = 5.09829438270...*10^-7`;
3. rapporto:
   `deltaQ(H/2)/deltaQ(H) = 0.12504735178...`;
4. controllo volume:
   `I0(H/2)/I0(H) = 8.13515907416...`;
5. controllo predittivo:
   `predErr = |deltaQ(H/2)-deltaQ(H)/8|/(deltaQ(H)/8) = 3.78814...*10^-4`;
6. classificazione:
   `classification="BH_selection_not_switched_off"`.
`Perche questo passaggio`: testa in modo operativo la dipendenza IR dal volume cosmologico mantenendo `M` e criterio di dominio fissati.
`Interpretazione`: l'effetto BH su `Q` resta locale e si sopprime come `~H^3` (`~1/Volume`), quindi la selezione resta dominata dal canale cosmologico.
`Esito log`: `check=True`.

6. `05_Geometric_K2_Cutoff_Killer_Test.nb`
`Riferimento`: killer test richiesto: sostituzione di `K2toy` con `K2` geometrico reale della foliazione crossing `T` in Kottler, con stesso cutoff test del `03`.
`Output`:
1. `K2geom = (v')^2 + 2(v/r)^2`, `v = Sqrt[2M/r + H^2 r^2]`;
2. scansione cutoff:
   `rmin = rs*10^{-1..-6}`;
3. profilo effettivo del core:
   `tailNEff ~ {2.999999999999942..., 2.99999999999999994..., 2.999999999999999999...}`;
4. coefficiente asintotico:
   `r^3 K2 -> c3`, con `c3Num=4.500000000000000000000600...`, `c3Theo=4.5`;
5. andamento di `Q`:
   incrementi per decade quasi costanti (`dqRatios tail ~ 1`);
6. classificazione:
   `classification="GEOMETRIC_NO_GO_singular_crossing"`.
`Perche questo passaggio`: e il test decisivo per togliere l'ambiguita toy e verificare il no-go direttamente sulla geometria reale del setup crossing.
`Interpretazione`: il core geometrico reale in Kottler crossing e marginale-log (`n_eff ~ 3`) e produce non-convergenza di cutoff; quindi il no-go sulle singolarita classiche e geometrico, non solo modellistico.
`Esito log`: `check=True`.

7. `06_Interior_Regularization_Consistency_Test.nb`
`Riferimento`: scelta forzata post-killer-test: implementare `Interior regularization` e verificare se rende il core integrabile senza rompere lo scaling IR cosmologico.
`Output`:
1. regolarizzazione interna:
   `vReg(r)=Sqrt[2M/Sqrt[r^2+aReg^2]+H^2 r^2]`,
   `K2reg=(vReg')^2 + 2(vReg/r)^2`;
2. scansione cutoff:
   `rmin = rs*10^{-1..-7}`;
3. profilo effettivo del core:
   `tailNEff ~ {2.0000002148..., 2.0000000021..., 2.00000000002..., 2.00000000000021...}`;
4. coefficiente asintotico regolare:
   `r^2 K2reg -> c2`, con `c2Num=1.99919935910...`, `c2Theo=1.99919935910...`;
5. andamento di `Q`:
   incrementi per decade in rapporto `~0.1` (`dqRatios tail ~ 0.1`), coerenti con convergenza lineare in `rmin`;
6. test IR:
   `ratioDelta=0.14115348786...`, `ratioI0=8.12468890948...`,
   `epsRef=0.14619...`, `epsHalf=0.08254...`;
7. classificazione:
   `classification="INTERIOR_REGULARIZATION_CONSISTENT"`.
`Perche questo passaggio`: dopo il no-go geometrico (`05`) era il test necessario per verificare la via di consistenza interna del framework.
`Interpretazione`: con core regolarizzato il ramo crossing resta coerente: il contributo profondo diventa integrabile (`n_eff<3`), `Q` converge, e il BH resta una correzione locale IR-soppressa.
`Esito log`: `check=True`.

## Quadro fisico attuale
1. `D_Theta` e ora definito in forma operativa con bordo mobile calcolabile (`00`).
2. La biforcazione della domanda 2, nel caso Kottler testato, cade nel caso `A` (foglie che attraversano) (`01`).
3. Il test IR su `Q` mostra che il contributo BH locale resta subleading nel ramo integrabile (`02`), con scaling `~(rs/rc)^3`.
4. Per ottenere un contributo O(1) serve una parte non integrabile del core (`p>3`), quindi un comportamento UV/profondo non regolato.
5. Il cutoff test no-go (`03`) rende esplicita l'esclusione in scenario crossing per interni singolari di tipo `n>=3` se non regolarizzati.
6. Il test `04` conferma direttamente la narrativa "BH = sotto-regione locale su sfondo gia selezionato", con `deltaQ(H/2) ~ deltaQ(H)/8`.
7. Il killer test `05` conferma che, nel setup geometrico reale crossing, il core e effettivamente `n_eff ~ 3` e il no-go resta valido senza ipotesi toy.
8. Il test `06` implementa la scelta `Interior regularization`: il core diventa integrabile (`n_eff ~ 2`), il cutoff converge e la soppressione IR resta compatibile con la tesi principale.

## Nota operativa

Generazione e verifica:

```powershell
cd c:\lean\StaticSanityCheck\Paper\Black_Hole_Study
.\run_all.ps1
```

Risultati:
1. notebook in `Paper/Black_Hole_Study/*.nb`
2. log in `Paper/Black_Hole_Study/logs/*.log`
