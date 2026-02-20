# Black Hole Study - Detailed Calculations and Results

Questo documento dettaglia i calcoli eseguiti in `Paper/Black_Hole_Study/scripts/` e i risultati registrati in `Paper/Black_Hole_Study/logs/`.

Convenzioni:
1. `M`: massa efficace del buco nero nel patch statico.
2. `H`: scala cosmologica (`H^2 = Lambda_eff/3` nel background di riferimento).
3. `z2`: soglia operativa di redshift (`0 < z2 < 1`) per definire accessibilita causale pratica.
4. `f(r;M,H) = 1 - 2M/r - H^2 r^2`.
5. `D_Theta`: dominio causale operativo sulla foglia `Theta = const`.

## 00 - DTheta Domain SdS Shape Derivative

Riferimenti:
1. Script: `scripts/00_dtheta_domain_sds_shape_derivative.wl`.
2. Log: `logs/00_dtheta_domain_sds_shape_derivative.log`.
3. Notebook generato: `00_DTheta_Domain_SdS_Shape_Derivative.nb`.

### 1) Definizione operativa unica di dominio

Nel notebook `00` si adotta:

`D_Theta(M,H,z2) = { r > 0 | f(r;M,H) >= z2 }`.

Equivalentemente, se `r_in` e `r_out` sono le due radici positive di:

`f(r;M,H) - z2 = 0`,

si ha:

`D_Theta = [r_in, r_out]`.

Questa definizione e:
1. operativa (controllata da `z2`);
2. dinamica (dipende da `M`, `H`);
3. adatta a shape derivative.

### 2) Shape derivative del bordo

Dalla derivata implicita di `f(r;M,H)-z2=0` rispetto a `M`:

`dr/dM = - (partial_M f)/(partial_r f) = r/(M - H^2 r^3)`.

La formula viene verificata su entrambe le frontiere:
1. `r_in(M,H,z2)`;
2. `r_out(M,H,z2)`.

Criterio di successo: accordo con differenze finite centrali.

### 3) Test su funzionale di dominio

Per un peso regolare `mu(r)`:

`I0(M) = integral_{D_Theta(M)} mu(r) dr`.

Con dipendenza da `M` solo nei bordi:

`dI0/dM = mu(r_out) dr_out/dM - mu(r_in) dr_in/dM`.

Il notebook confronta:
1. derivata numerica di `I0(M)`;
2. previsione da termini di bordo.

### 4) Output numerico 00

Dal log:
1. parametri: `m0=1`, `h0=1/100`, `z20=1/20`, `dm=10^-6`;
2. frontiere: `r_in=2.10624672529...`, `r_out=96.39775038176...`;
3. rapporto scale: `r_out/r_in=45.76754908354...`;
4. errori: `errIn ~ 9.96e-16`, `errOut ~ 5.68e-16`, `errI0 ~ 4.97e-13`;
5. check complessivo: `check=True`.

## 01 - Kottler Global Foliation Crossing Test

Riferimenti:
1. Script: `scripts/01_kottler_global_foliation_crossing_test.wl`.
2. Log: `logs/01_kottler_global_foliation_crossing_test.log`.
3. Notebook generato: `01_Kottler_Global_Foliation_Crossing_Test.nb`.

### 1) Setup della biforcazione "attraversano vs asintotizzano"

Nel patch Kottler si considera:

`f(r;M,H)=1-2M/r-H^2 r^2`.

Si testa la foliazione:

`Theta = T = t + g(r)`, con `g'(r)=Sqrt[1-f]/f`.

Questa e una scelta horizon-penetrating di tipo Painleve-Gullstrand.

### 2) Criteri implementati

1. Timelike globale:
   `X_Theta = 1/f - f (g')^2 = 1`.
2. Regolarita del blocco metrico `(T,r)`:
   `g_Tr=Sqrt[1-f]`, `g_RR=1`, `det2D=-1`.
3. Esistenza di due orizzonti positivi `r_bh < r_c`.
4. Test di confronto con foliazione statica:
   `X_t = 1/f`, che cambia segno attraversando gli orizzonti.
5. Classificazione automatica:
   `behavior = "A_crossing"` se i check geometrici sono tutti soddisfatti.

### 3) Output numerico 01

Dal log:
1. orizzonti:
   `r_bh = 2.00080096153...`, `r_c = 98.98458637542...`;
2. regolarita ai bordi:
   `gTrBH=1`, `gTrC=1`, `detBH=-1`, `detC=-1`;
3. pendenze nulle ai bordi finite:
   `vPlusBH=0`, `vMinusBH=-2`, `vPlusC=0`, `vMinusC=-2`;
4. foliazione statica non globale:
   `xStaticInside<0`, `xStaticMid>0`, `xStaticOutside<0`;
5. foliazione `T` globale:
   `xThetaInside~1`, `xThetaMid~1`, `xThetaOutside~1`;
6. classificazione:
   `behavior="A_crossing"`;
7. check complessivo:
   `check=True`.

### 4) Lettura fisica della domanda 2

Nel caso testato (Kottler):
1. esiste una foliazione globale regolare;
2. cade nel caso `A` (foglie che attraversano gli orizzonti);
3. lo "stall" e l'asintoto emergono nella coordinata statica `t`, non nella variabile regolare `T`.

## 02 - IR Robustness BH Weight on Q

Riferimenti:
1. Script: `scripts/02_ir_robustness_bh_weight_on_q.wl`.
2. Log: `logs/02_ir_robustness_bh_weight_on_q.log`.
3. Notebook generato: `02_IR_Robustness_BH_Weight_On_Q.nb`.

### 1) Setup toy: de Sitter + difetto locale BH

Il notebook implementa:
1. `Q = I1/I0`.
2. `I1 = I1bg + deltaI1BH`.
3. `I0 = I0cosmo`.

Per il fondo:
1. `K2bg = 3 H^2`.
2. scala locale `rs` dalla radice BH di Kottler.
3. scala cosmologica `rc` dalla radice cosmologica di Kottler.

Profilo locale testato:
`deltaI1BH(p) ~ integral_{r_eps}^{r_match} r^(2-p) dr`.

### 2) Criterio di integrabilita profonda

Per il termine radiale:
1. `p < 3`: integrabile al core.
2. `p = 3`: divergenza logaritmica.
3. `p > 3`: non integrabile (power-like), forte sensibilita al cutoff `r_eps`.

Questo e il test diretto della tua domanda:
se il core non diverge in modo non integrabile, il contributo resta controllato.

### 3) Test quantitativi implementati

1. Coerenza analitico/numerica del canale `p=2`:
   `deltaI1` da formula chiusa coincide con integrazione diretta (`err=0` numerico nel log).
2. Scaling IR cosmologico:
   valutazione di `deltaQ` con `Rc`, `2Rc`, `4Rc`.
3. Robustezza su cutoff per ramo integrabile (`p=2`):
   `r_eps = {10^-2,10^-4,10^-6} rs`.
4. Test ramo marginale (`p=3`).
5. Test ramo non integrabile (`p=4`) sulla stessa griglia di `r_eps`.

### 4) Output numerico 02

Dal log:
1. scale geometriche:
   `rs = 2.00080096153...`, `rc = 98.98458637542...`,
   `volRatio=(rs/rc)^3 = 8.25864777853...*10^-6`.
2. ramo integrabile `p=2`:
   `qShiftP2 = 4.45892652210...*10^-8`,
   `fracP2 = qShiftP2/K2bg = 1.48630884070...*10^-4`,
   `coeffP2 = fracP2/volRatio = 17.99700000000...`.
3. scaling IR:
   `scaleRatiosP2 = {8.00000000000..., 8.00000000000...}`.
4. ramo marginale `p=3`:
   `fracP3 = 2.15538684448...*10^-4` (ancora piccolo nel benchmark).
5. ramo non integrabile `p=4`:
   `qEpsRatiosP4 ~ {100.165..., 100.001...}`,
   `fracP4Small = 24.77593920628...` per `r_eps = 10^-6 rs`.
6. classificazione:
   `regime = "IR_robust_except_nonintegrable_core"`,
   `check=True`.

### 5) Lettura fisica della domanda 3

1. Nel toy testato, il contributo BH locale a `Q` non compete con il contributo cosmologico se il core e integrabile.
2. Il comportamento e precisamente IR-soppresso con legge di volume cosmologico (`~1/rc^3`, quindi `~(rs/rc)^3` a parita di scala locale).
3. Un contributo O(1) compare solo nel ramo non integrabile (`p>3`) e dipende fortemente dal cutoff interno `r_eps`, cioe da una divergenza di core non regolata.

## 03 - Singularity No-Go Cutoff Test

Riferimenti:
1. Script: `scripts/03_singularity_nogo_cutoff_test.wl`.
2. Log: `logs/03_singularity_nogo_cutoff_test.log`.
3. Notebook generato: `03_Singularity_NoGo_Cutoff_Test.nb`.

### 1) Obiettivo e setup

Scopo del test: verificare se un interno singolare classico resta compatibile col vincolo su `Q=I1/I0` quando la foliazione attraversa l'orizzonte.

Setup:
1. Foliation crossing (gia validata in `01`):
   `Theta = T = t + g(r)`, `g'(r)=Sqrt[1-f]/f`.
2. Dominio usato nel test:
   `r in [rmin, rout]`, con `rout` preso dal bordo esterno Kottler.
3. Cutoff interno:
   `rmin = rs*10^{-1..-6}`.
4. Misura spaziale sulla foglia `T=const`:
   `sqrt(gamma) = r^2 sin(theta)`.

### 2) Famiglia singolare testata

Per isolare il comportamento di core:
1. `K2toy(r,n) = K2bg + A (rs/r)^n`.
2. `I1 = 4 pi integral K2toy r^2 dr`.
3. `Q = I1/I0`, con `I0 = (4 pi/3)(rout^3-rmin^3)`.

Regola teorica verificata:
1. `n<3`: integrabile.
2. `n=3`: marginale logaritmico.
3. `n>3`: non integrabile.

### 3) Output numerico 03

Dal log:
1. `check=True`.
2. crossing confermato:
   `xThetaMid = 1.0000000000...`.
3. ramo integrabile `n=2.5`:
   `qN25Lim = 0.000300104559450...`,
   `errN25 = 4.95346222949...*10^-8`.
4. ramo marginale `n=3`:
   `ratioN3 ~ {1.000000022..., 1.00000000003..., ...}`.
5. ramo singolare `n=6`:
   `ratioN6 -> {9.1828..., 892.100..., 999.879..., 999.999..., 999.999999...}`,
   `growthN6 = 8.19100118479...*10^12`.
6. classificazione finale:
   `classification = "NO_GO_singular_crossing"`.

### 4) Lettura fisica del no-go

1. In scenario crossing, un core con `K2 ~ r^-n` e compatibile col vincolo solo se `n<3`.
2. Per `n>=3` il cutoff test non converge riducendo `rmin`; quindi il contributo interno non e controllato.
3. Il caso classico forte (`n=6`) e escluso dal vincolo in assenza di regolarizzazione del core (o esclusione dell'interno da `D_Theta`).

## 04 - BH Non-Switches-Off Selection IR Scaling Test

Riferimenti:
1. Script: `scripts/04_bh_non_switches_off_selection_ir_scaling_test.wl`.
2. Log: `logs/04_bh_non_switches_off_selection_ir_scaling_test.log`.
3. Notebook generato: `04_BH_Non_Switches_Off_Selection_IR_Scaling_Test.nb`.

### 1) Obiettivo del test

Verificare la tesi centrale:
1. il BH e una sotto-regione locale;
2. la selezione del vuoto resta dominata dal canale IR cosmologico;
3. quindi il contributo BH su `Q` deve sopprimersi quando il dominio cosmologico cresce.

Implementazione richiesta:
1. fissare `M` e il criterio di dominio (`z2` costante);
2. calcolare `Q(M,H)` e `Q(0,H)`;
3. definire `deltaQ(H)=Q(M,H)-Q(0,H)`;
4. ripetere con `H -> H/2` e confrontare.

### 2) Setup operativo usato

1. Parametri:
   `M=1`, `z2=1/20`, `H=1/100`, `H/2=1/200`.
2. Dominio:
   `D_Theta = {r>0 | f(r;M,H)>=z2}` con radici `r_in,r_out`.
3. Canale locale BH in `I1`:
   profilo regolare localizzato `~ (2M)^2/(r^2+a^2)^2`, per evitare divergenze UV artificiali.
4. `Q(0,H)` calcolato nello stesso schema e verificato uguale a `3H^2`.

### 3) Criteri di validazione implementati

1. `deltaQ(H) > 0`, `deltaQ(H/2) > 0`.
2. `deltaQ(H/2)/deltaQ(H)` vicino a `1/8`.
3. crescita volume:
   `I0(H/2)/I0(H)` vicino a `8`.
4. termine locale quasi costante:
   `localI1(H/2)/localI1(H)` vicino a `1`.
5. effetto BH subleading:
   `deltaQ/Q0 < 5%`.

### 4) Output numerico 04

Dal log:
1. `deltaQ(H) = 4.07709104588...*10^-6`.
2. `deltaQ(H/2) = 5.09829438270...*10^-7`.
3. `ratioDelta = deltaQ(H/2)/deltaQ(H) = 0.12504735178...`.
4. `ratioI0 = I0(H/2)/I0(H) = 8.13515907416...`.
5. `ratioLoc = localI1(H/2)/localI1(H) = 1.01728009856...`.
6. `epsH = deltaQ(H)/Q0(H) = 0.01359030348...`.
7. `epsHalf = deltaQ(H/2)/Q0(H/2) = 0.00679772584...`.
8. `predErr = 3.78814270985...*10^-4` rispetto a `deltaQ(H)/8`.
9. classificazione:
   `classification = "BH_selection_not_switched_off"`, `check=True`.

### 5) Lettura fisica della validazione

1. Il rapporto `0.125047...` e praticamente `1/8`: il test scala come atteso da soppressione `~1/Volume`.
2. Il termine locale resta quasi invariato mentre cresce il volume cosmologico: la riduzione di `deltaQ` e dominata da `I0`.
3. Quindi il BH non contamina il canale IR in modo O(1): resta un contributo locale su fondo cosmologico gia selezionato.

## 05 - Geometric K2 Cutoff Killer Test

Riferimenti:
1. Script: `scripts/05_geometric_k2_cutoff_killer_test.wl`.
2. Log: `logs/05_geometric_k2_cutoff_killer_test.log`.
3. Notebook generato: `05_Geometric_K2_Cutoff_Killer_Test.nb`.

### 1) Obiettivo del killer test

Ripetere il no-go di cutoff del `03` eliminando il profilo toy:
1. usare direttamente `K2` geometrico reale della foliazione crossing `T`;
2. mantenere identico criterio `rmin -> 0` su `Q=I1/I0`;
3. decidere se il no-go resta vero in modo geometrico.

### 2) K2 geometrico usato

Nel patch Kottler con tempo crossing:
1. `v(r) = Sqrt[2M/r + H^2 r^2]`.
2. `K2geom(r) = (v'(r))^2 + 2 (v(r)/r)^2`.

Forma chiusa implementata:
`K2geom = ((H^2 r^3 - M)^2)/(r^3 (2M + H^2 r^3)) + 4M/r^3 + 2H^2`.

Controllo di coefficiente asintotico:
`r^3 K2geom -> 9M/2` per `r -> 0`.

### 3) Setup cutoff (identico al test 03)

1. Dominio: `r in [rmin, rout]`.
2. Griglia:
   `rmin = rs*10^{-1..-6}`.
3. Integrale:
   `Q(rmin)=I1(rmin)/I0(rmin)`.
4. Decomposizione numerica stabile:
   separazione esplicita del termine asintotico `9M/(2r^3)` + parte regolare.

### 4) Output numerico 05

Dal log:
1. `check=True`.
2. classificazione:
   `classification = "GEOMETRIC_NO_GO_singular_crossing"`.
3. esponente effettivo nel core:
   `tailNEff = {2.999999999999942..., 2.99999999999999994..., 2.999999999999999999...}`.
4. coefficiente asintotico:
   `c3Num = 4.500000000000000000000600...`, `c3Theo = 4.5`.
5. trend non convergente di cutoff:
   `dqRatios tail ~ {1.000000000000091..., 1.000000000000000100...}`.
6. coerenza con predizione analitica di incremento logaritmico:
   `predRelErrTail ~ {9.1987e-14, 1.0023e-16, 1.0848e-19}`.

### 5) Lettura fisica del killer test

1. Il comportamento marginale `n_eff ~ 3` non e un artefatto toy: emerge dal `K2` geometrico reale del setup crossing.
2. Quindi il no-go sulle singolarita classiche in questo scenario e geometrico:
   il cutoff `rmin -> 0` non porta convergenza di `Q`.
3. La conclusione dipende dal fatto che il dominio includa l'interno (`crossing`) e che non ci sia regolarizzazione del core.

## 06 - Interior Regularization Consistency Test

Riferimenti:
1. Script: `scripts/06_interior_regularization_consistency_test.wl`.
2. Log: `logs/06_interior_regularization_consistency_test.log`.
3. Notebook generato: `06_Interior_Regularization_Consistency_Test.nb`.

### 1) Obiettivo del test

Dopo il no-go geometrico del `05`, testare la via forzata:
1. regolarizzare il core interno in modo esplicito;
2. verificare che `Q=I1/I0` converga al rimuovere il cutoff;
3. controllare che la narrativa IR resti valida (`BH` locale su sfondo cosmologico dominante).

### 2) Regolarizzazione implementata

Nel patch Kottler crossing si usa:
1. `vReg(r)=Sqrt[2M/Sqrt[r^2+aReg^2]+H^2 r^2]`;
2. `K2reg(r)=(vReg'(r))^2+2(vReg(r)/r)^2`;
3. scelta benchmark: `aReg=rs` (stessa scala del raggio BH del caso di riferimento).

Nel core (`r << aReg`) il test predice:
1. `K2reg ~ c2/r^2`,
2. quindi `n_eff ~ 2 < 3` (integrabile).

### 3) Setup cutoff + convergenza

1. Dominio: `r in [rmin, rout]`.
2. Griglia:
   `rmin = rs*10^{-1..-7}`.
3. Integrale:
   `Q(rmin)=I1reg(rmin)/I0(rmin)`.
4. Diagnostiche:
   `n_eff = -d log K2reg / d log r`,
   `c2Num = r^2 K2reg`,
   fit tail `Q(rmin) ~ Q0 + c rmin`.

### 4) Output numerico 06

Dal log:
1. `check=True`.
2. classificazione:
   `classification="INTERIOR_REGULARIZATION_CONSISTENT"`.
3. foliazione crossing ancora valida:
   `xThetaMid = 1.0000000000...`.
4. esponente effettivo nel core:
   `tailNEff = {2.0000002148..., 2.0000000021..., 2.00000000002..., 2.00000000000021...}`.
5. coefficiente core regolarizzato:
   `c2Num = 1.99919935910...`, `c2Theo = 1.99919935910...`.
6. andamento `Q` al diminuire di `rmin`:
   incrementi positivi ma in decade ratio `~0.1`:
   `dqRatios tail ~ {0.1000000183..., 0.10000000018..., 0.1000000000018...}`.
7. errore di extrapolazione al limite:
   `relTailErr = 3.5983...*10^-9`.
8. test IR (`H -> H/2`):
   `ratioDelta = 0.14115348786...`,
   `ratioI0 = 8.12468890948...`,
   `epsRef = 0.14619...`,
   `epsHalf = 0.08254...`.

### 5) Lettura fisica del test 06

1. La regolarizzazione interna cambia regime UV/profondo da marginale-log (`n~3`) a integrabile (`n~2`).
2. In scenario crossing, il vincolo su `Q` torna ben posto: il cutoff test converge.
3. Il canale BH resta subleading e non O(1), quindi la selezione globale resta IR-dominata dal dominio cosmologico.
4. Questo implementa concretamente la scelta `(1)` richiesta: `Interior regularization`.

## Conclusione tecnica attuale

1. La "domanda zero" su `D_Theta` e ora chiusa operativamente (`00`).
2. La biforcazione della "domanda 2" in Kottler e classificata come `A_crossing` (`01`).
3. La "domanda 3" su robustezza IR di `Q` e ora testata nel toy: BH subleading nel ramo integrabile, rischio O(1) solo con core non integrabile (`02`).
4. Il no-go a cutoff su interno singolare in scenario crossing e ora esplicitato e verificato (`03`).
5. La validazione diretta "BH non spegne selezione" e ora confermata con scaling `deltaQ(H/2) ~ deltaQ(H)/8` (`04`).
6. Il killer test geometrico (`05`) conferma che il no-go sulle singolarita classiche resta valido anche senza profili toy.
7. Il test `06` implementa `Interior regularization` e verifica che il core diventa integrabile (`n_eff ~ 2`), `Q` converge, e la soppressione IR resta compatibile con il quadro globale.
8. Nel branch crossing, la consistenza del framework richiede quindi un interno regolato (oppure una ridefinizione non banale del dominio che escluda il core profondo).

## Riproduzione rapida

```powershell
cd c:\lean\StaticSanityCheck\Paper\Black_Hole_Study
.\run_all.ps1
```
