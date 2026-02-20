ClearAll["Global`*"];

nb = Notebook[{
  Cell["05 - Geometric K2 Cutoff Killer Test", "Title"],
  Cell["Replace K2toy with geometric K2 from crossing foliation T in Kottler and rerun the same cutoff no-go logic.", "Text"],
  Cell[BoxData @ ToBoxes @ HoldForm[
    Theta == T == t + g[r] && g'[r] == Sqrt[1 - f[r, M, H]]/f[r, M, H]
  ], "Input"],
  Cell[BoxData @ ToBoxes @ HoldForm[
    K2geom[r_] == KijKij[gamma(T), beta(T)] == (v'[r])^2 + 2 (v[r]/r)^2
  ], "Input"],
  Cell[BoxData @ ToBoxes @ HoldForm[
    v[r_] == Sqrt[2 M/r + H^2 r^2]
  ], "Input"],
  Cell[BoxData @ ToBoxes @ HoldForm[
    Q[rmin] == I1[rmin]/I0[rmin] && r in [rmin, rout]
  ], "Input"],
  Cell[BoxData @ ToBoxes @ HoldForm[
    killerRule == "if Q does not converge as rmin -> 0 then geometric NO-GO in crossing scenario"
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

k2GeomExpr[m_, h_, r_] := ((h^2 r^3 - m)^2)/(r^3 (2 m + h^2 r^3)) + 4 m/r^3 + 2 h^2;
i0[rmin_?NumericQ, rout_?NumericQ] := N[(4 Pi/3) (rout^3 - rmin^3), 60];

i1Geom[m_?NumericQ, h_?NumericQ, rmin_?NumericQ, rout_?NumericQ] := Module[{core, regIntegrand, reg},
  core = N[(9 m/2) Log[rout/rmin], 60];
  regIntegrand[r_] := (k2GeomExpr[m, h, r] - 9 m/(2 r^3)) r^2;
  reg = N[
    NIntegrate[regIntegrand[r], {r, rmin, rout},
      WorkingPrecision -> 60,
      AccuracyGoal -> 22,
      PrecisionGoal -> 20,
      MaxRecursion -> 30,
      Method -> {"GlobalAdaptive", "SymbolicProcessing" -> 0}
    ],
    55
  ];
  N[4 Pi (core + reg), 55]
];

qGeom[m_?NumericQ, h_?NumericQ, rmin_?NumericQ, rout_?NumericQ] := N[i1Geom[m, h, rmin, rout]/i0[rmin, rout], 55];

m0 = 1;
h0 = 1/100;
roots = horizonRoots[m0, h0];

checkA = Length[roots] >= 2 && roots[[1]] < roots[[2]];

rs = Indeterminate;
rout = Indeterminate;
rminList = Indeterminate;
xThetaMid = Indeterminate;
kVals = Indeterminate;
qVals = Indeterminate;
dqVals = Indeterminate;
dqRatios = Indeterminate;
nEffVals = Indeterminate;
tailNEff = Indeterminate;
c3Theo = Indeterminate;
c3Num = Indeterminate;
deltaQPred = Indeterminate;
deltaQPredTail = Indeterminate;
predRelErrTail = Indeterminate;
classification = "undetermined";

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

If[TrueQ[checkA],
  rs = roots[[1]];
  rout = roots[[2]];
  rminList = N[rs*10^-Range[1, 6], 50];

  rmid = (rs + rout)/2;
  xThetaMid = N[(1/f[rmid, m0, h0] - f[rmid, m0, h0] gPrime[rmid, m0, h0]^2), 40];
  checkB = Abs[xThetaMid - 1] < 10^-12;

  kVals = Table[N[k2GeomExpr[m0, h0, rr], 50], {rr, rminList}];
  qVals = Table[qGeom[m0, h0, rr, rout], {rr, rminList}];
  dqVals = Differences[qVals];
  dqRatios = N[dqVals[[2 ;;]]/dqVals[[1 ;; -2]], 40];

  nEffVals = Table[
    N[-Log[kVals[[ii + 1]]/kVals[[ii]]]/Log[rminList[[ii + 1]]/rminList[[ii]]], 40],
    {ii, 1, Length[kVals] - 1}
  ];
  tailNEff = nEffVals[[-3 ;;]];

  c3Theo = N[9 m0/2, 40];
  c3Num = N[rminList[[-1]]^3 k2GeomExpr[m0, h0, rminList[[-1]]], 40];

  deltaQPred = Table[
    N[(18 Pi m0 Log[10])/i0[rminList[[ii + 1]], rout], 50],
    {ii, 1, Length[rminList] - 1}
  ];
  deltaQPredTail = deltaQPred[[-3 ;;]];
  dqTail = dqVals[[-3 ;;]];
  predRelErrTail = N[Abs[(dqTail - deltaQPredTail)/deltaQPredTail], 40];

  checkC = Min[dqVals] > 0;
  checkD = Max[Abs[dqRatios[[-3 ;;]] - 1]] < 5*10^-3;
  checkE = Min[tailNEff] > 2.98 && Max[tailNEff] < 3.02;
  checkF = Abs[c3Num/c3Theo - 1] < 5*10^-4;
  checkG = Max[predRelErrTail] < 5*10^-3;
  checkH = qVals[[-1]] > qVals[[1]] + 10^-4;
  checkI = rminList[[-1]] < rs < rout;
  checkJ = qVals[[-1]] > 3 h0^2;
  checkK = TrueQ[(Min[tailNEff] >= 3 - 0.02)];

  classification = If[TrueQ[checkB && checkC && checkD && checkE && checkF && checkG && checkH && checkI && checkJ && checkK],
    "GEOMETRIC_NO_GO_singular_crossing",
    "undetermined"
  ];
];

check = TrueQ[checkA && checkB && checkC && checkD && checkE && checkF && checkG && checkH && checkI && checkJ && checkK &&
   classification == "GEOMETRIC_NO_GO_singular_crossing"];

nbName = "05_Geometric_K2_Cutoff_Killer_Test.nb";
logName = "05_geometric_k2_cutoff_killer_test.log";
logLines = {
  "Notebook: " <> nbName,
  "m0 = " <> ToString[m0, InputForm],
  "h0 = " <> ToString[h0, InputForm],
  "roots = " <> ToString[roots, InputForm],
  "rs = " <> ToString[rs, InputForm],
  "rout = " <> ToString[rout, InputForm],
  "rminList = " <> ToString[rminList, InputForm],
  "xThetaMid = " <> ToString[xThetaMid, InputForm],
  "kVals = " <> ToString[kVals, InputForm],
  "qVals = " <> ToString[qVals, InputForm],
  "dqVals = " <> ToString[dqVals, InputForm],
  "dqRatios = " <> ToString[dqRatios, InputForm],
  "nEffVals = " <> ToString[nEffVals, InputForm],
  "tailNEff = " <> ToString[tailNEff, InputForm],
  "c3Theo = " <> ToString[c3Theo, InputForm],
  "c3Num = " <> ToString[c3Num, InputForm],
  "deltaQPred = " <> ToString[deltaQPred, InputForm],
  "deltaQPredTail = " <> ToString[deltaQPredTail, InputForm],
  "predRelErrTail = " <> ToString[predRelErrTail, InputForm],
  "classification = " <> ToString[classification, InputForm],
  "checkA(two horizons) = " <> ToString[checkA, InputForm],
  "checkB(crossing foliation) = " <> ToString[checkB, InputForm],
  "checkC(Q increases as rmin decreases) = " <> ToString[checkC, InputForm],
  "checkD(log-tail ratios ~1) = " <> ToString[checkD, InputForm],
  "checkE(n_eff tail ~3) = " <> ToString[checkE, InputForm],
  "checkF(c3 coefficient match) = " <> ToString[checkF, InputForm],
  "checkG(deltaQ increment prediction match) = " <> ToString[checkG, InputForm],
  "checkH(non-convergent growth visible) = " <> ToString[checkH, InputForm],
  "checkI(domain includes interior) = " <> ToString[checkI, InputForm],
  "checkJ(Q above deSitter baseline) = " <> ToString[checkJ, InputForm],
  "checkK(n>=3 effective core) = " <> ToString[checkK, InputForm],
  "check = " <> ToString[check, InputForm]
};
logText = StringRiffle[logLines, "\n"];

result = <|
  "script" -> "05_geometric_k2_cutoff_killer_test",
  "nbName" -> nbName,
  "logName" -> logName,
  "nbBase64" -> BaseEncode[ExportByteArray[nb, "NB"]],
  "logText" -> logText,
  "check" -> check
|>;

Print["__RESULT__" <> ExportString[result, "RawJSON"]];
If[TrueQ[check], Exit[0], Exit[1]];
