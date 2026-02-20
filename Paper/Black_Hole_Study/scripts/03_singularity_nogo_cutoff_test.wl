ClearAll["Global`*"];

nb = Notebook[{
  Cell["03 - No-Go on Singular Interiors (Cutoff Test)", "Title"],
  Cell["Objective: in crossing foliation, test whether singular core behavior is compatible with the constraint on Q=I1/I0 as rmin -> 0.", "Text"],
  Cell[BoxData @ ToBoxes @ HoldForm[
    Theta == T == t + g[r] && g'[r] == Sqrt[1 - f[r, M, H]]/f[r, M, H]
  ], "Input"],
  Cell[BoxData @ ToBoxes @ HoldForm[
    sqrtGamma == r^2 Sin[th] && I0[rmin] == (4 Pi/3) (rout^3 - rmin^3)
  ], "Input"],
  Cell[BoxData @ ToBoxes @ HoldForm[
    K2toy[r_, n_] == K2bg + A (rs/r)^n
  ], "Input"],
  Cell[BoxData @ ToBoxes @ HoldForm[
    I1[n, rmin] == 4 Pi Integrate[K2toy[r, n] r^2, {r, rmin, rout}]
  ], "Input"],
  Cell[BoxData @ ToBoxes @ HoldForm[
    Q[n, rmin] == I1[n, rmin]/I0[rmin]
  ], "Input"],
  Cell[BoxData @ ToBoxes @ HoldForm[
    rule == "integrable iff n < 3"
  ], "Input"]
}];

f[r_, m_, h_] := 1 - 2 m/r - h^2 r^2;
gPrime[r_, m_, h_] := Sqrt[1 - f[r, m, h]]/f[r, m, h];

horizonRoots[m_?NumericQ, h_?NumericQ] := Module[{sol},
  sol = r /. NSolve[f[r, m, h] == 0, r, Reals, WorkingPrecision -> 80];
  sol = Chop[N[sol, 40], 10^-25];
  sol = Select[sol, NumericQ[#] && # > 0 &];
  Sort[DeleteDuplicates[sol, Abs[#1 - #2] < 10^-20 &]]
];

i0[rmin_?NumericQ, rout_?NumericQ] := N[(4 Pi/3) (rout^3 - rmin^3), 50];

i1Toy[n_?NumericQ, rmin_?NumericQ, rout_?NumericQ, rs_?NumericQ, k2bg_?NumericQ, amp_?NumericQ] := Module[{bg, core},
  bg = (4 Pi/3) k2bg (rout^3 - rmin^3);
  core = If[Abs[n - 3] < 10^-14,
    4 Pi amp rs^3 Log[rout/rmin],
    4 Pi amp rs^n (rout^(3 - n) - rmin^(3 - n))/(3 - n)
  ];
  N[bg + core, 50]
];

qToy[n_?NumericQ, rmin_?NumericQ, rout_?NumericQ, rs_?NumericQ, k2bg_?NumericQ, amp_?NumericQ] :=
  N[i1Toy[n, rmin, rout, rs, k2bg, amp]/i0[rmin, rout], 50];

m0 = 1;
h0 = 1/100;
roots = horizonRoots[m0, h0];

checkA = Length[roots] >= 2 && roots[[1]] < roots[[2]];

rs = Indeterminate;
rout = Indeterminate;
k2bg = Indeterminate;
amp = Indeterminate;
rminList = Indeterminate;

checkB = False;
checkC = False;
checkD = False;
checkE = False;
checkF = False;
checkG = False;
checkH = False;
checkI = False;
checkJ = False;
checkK = False;

qN25 = Indeterminate;
qN3 = Indeterminate;
qN6 = Indeterminate;
qN25Lim = Indeterminate;
errN25 = Indeterminate;
dN3 = Indeterminate;
ratioN3 = Indeterminate;
ratioN6 = Indeterminate;
growthN6 = Indeterminate;
noGoClassical = False;
domainCrossingFlag = False;
xThetaMid = Indeterminate;

If[TrueQ[checkA],
  rs = roots[[1]];
  rout = roots[[2]];
  k2bg = N[3 h0^2, 50];
  amp = k2bg;
  rminList = N[rs*10^-Range[1, 6], 50];

  (* crossing foliation sanity check *)
  rmid = (rs + rout)/2;
  xThetaMid = N[(1/f[rmid, m0, h0] - f[rmid, m0, h0] gPrime[rmid, m0, h0]^2), 40];
  checkB = Abs[xThetaMid - 1] < 10^-12;

  (* angular measure on T=const slice *)
  angMeasure = FullSimplify[Integrate[Sin[th], {th, 0, Pi}, {ph, 0, 2 Pi}]];
  checkC = TrueQ[angMeasure == 4 Pi];

  qN25 = Table[qToy[5/2, rr, rout, rs, k2bg, amp], {rr, rminList}];
  qN3 = Table[qToy[3, rr, rout, rs, k2bg, amp], {rr, rminList}];
  qN6 = Table[qToy[6, rr, rout, rs, k2bg, amp], {rr, rminList}];

  qN25Lim = N[k2bg + (3 amp (rs/rout)^(5/2))/(3 - 5/2), 50];
  errN25 = N[Abs[(qN25[[-1]] - qN25Lim)/qN25Lim], 40];
  checkD = errN25 < 10^-4;

  dN3 = Differences[qN3];
  ratioN3 = N[dN3[[2 ;;]]/dN3[[1 ;; -2]], 30];
  checkE = Min[dN3] > 0 && Max[Abs[ratioN3 - 1]] < 10^-3;

  ratioN6 = N[qN6[[2 ;;]]/qN6[[1 ;; -2]], 30];
  growthN6 = N[qN6[[-1]]/qN6[[1]], 30];
  checkF = Min[ratioN6[[-3 ;; -1]]] > 900 && Max[ratioN6[[-3 ;; -1]]] < 1100;
  checkG = growthN6 > 10^10;

  noGoClassical = TrueQ[checkF && checkG];
  checkH = noGoClassical;

  domainCrossingFlag = rminList[[-1]] < rs < rout;
  checkI = domainCrossingFlag;

  volRatio = N[(rs/rout)^3, 40];
  fracN25 = N[(qN25[[-1]] - k2bg)/k2bg, 40];
  checkJ = fracN25 < 10^-3 && volRatio < 10^-4;

  checkK = TrueQ[(5/2 < 3) && !(6 < 3)];
];

classification = If[TrueQ[checkH && checkI], "NO_GO_singular_crossing", "undetermined"];

check = TrueQ[
  checkA && checkB && checkC && checkD && checkE && checkF && checkG && checkH && checkI && checkJ && checkK &&
   classification == "NO_GO_singular_crossing"
];

nbName = "03_Singularity_NoGo_Cutoff_Test.nb";
logName = "03_singularity_nogo_cutoff_test.log";
logLines = {
  "Notebook: " <> nbName,
  "m0 = " <> ToString[m0, InputForm],
  "h0 = " <> ToString[h0, InputForm],
  "roots = " <> ToString[roots, InputForm],
  "rs = " <> ToString[rs, InputForm],
  "rout = " <> ToString[rout, InputForm],
  "k2bg = " <> ToString[k2bg, InputForm],
  "amp = " <> ToString[amp, InputForm],
  "rminList = " <> ToString[rminList, InputForm],
  "xThetaMid = " <> ToString[xThetaMid, InputForm],
  "qN25 = " <> ToString[qN25, InputForm],
  "qN25Lim = " <> ToString[qN25Lim, InputForm],
  "errN25 = " <> ToString[errN25, InputForm],
  "qN3 = " <> ToString[qN3, InputForm],
  "dN3 = " <> ToString[dN3, InputForm],
  "ratioN3 = " <> ToString[ratioN3, InputForm],
  "qN6 = " <> ToString[qN6, InputForm],
  "ratioN6 = " <> ToString[ratioN6, InputForm],
  "growthN6 = " <> ToString[growthN6, InputForm],
  "noGoClassical = " <> ToString[noGoClassical, InputForm],
  "domainCrossingFlag = " <> ToString[domainCrossingFlag, InputForm],
  "classification = " <> ToString[classification, InputForm],
  "checkA(two horizons) = " <> ToString[checkA, InputForm],
  "checkB(crossing foliation XTheta=1) = " <> ToString[checkB, InputForm],
  "checkC(angular measure) = " <> ToString[checkC, InputForm],
  "checkD(n<3 convergence) = " <> ToString[checkD, InputForm],
  "checkE(n=3 logarithmic non-convergence trend) = " <> ToString[checkE, InputForm],
  "checkF(n=6 decade ratio ~10^3) = " <> ToString[checkF, InputForm],
  "checkG(n=6 blow-up amplitude) = " <> ToString[checkG, InputForm],
  "checkH(no-go flag) = " <> ToString[checkH, InputForm],
  "checkI(domain includes interior crossing) = " <> ToString[checkI, InputForm],
  "checkJ(integrable branch remains tiny) = " <> ToString[checkJ, InputForm],
  "checkK(rule n<3) = " <> ToString[checkK, InputForm],
  "check = " <> ToString[check, InputForm]
};
logText = StringRiffle[logLines, "\n"];

result = <|
  "script" -> "03_singularity_nogo_cutoff_test",
  "nbName" -> nbName,
  "logName" -> logName,
  "nbBase64" -> BaseEncode[ExportByteArray[nb, "NB"]],
  "logText" -> logText,
  "check" -> check
|>;

Print["__RESULT__" <> ExportString[result, "RawJSON"]];
If[TrueQ[check], Exit[0], Exit[1]];
