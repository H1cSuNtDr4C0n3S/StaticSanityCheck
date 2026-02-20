ClearAll["Global`*"];

nb = Notebook[{
  Cell["06 - Interior Regularization Consistency Test", "Title"],
  Cell["Implement interior regularization (soft core) and test: (i) Q(rmin) converges as rmin->0, (ii) BH IR scaling remains volume-suppressed.", "Text"],
  Cell[BoxData @ ToBoxes @ HoldForm[
    vReg[r_] == Sqrt[2 M/Sqrt[r^2 + aReg^2] + H^2 r^2]
  ], "Input"],
  Cell[BoxData @ ToBoxes @ HoldForm[
    K2reg[r_] == (vReg'[r])^2 + 2 (vReg[r]/r)^2
  ], "Input"],
  Cell[BoxData @ ToBoxes @ HoldForm[
    Qreg[rmin] == I1reg[rmin]/I0[rmin] && r in [rmin, rout]
  ], "Input"],
  Cell[BoxData @ ToBoxes @ HoldForm[
    validation == "convergent core (n_eff < 3) + preserved IR suppression"
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

vRegExpr[m_, h_, a_, r_] := Sqrt[2 m/Sqrt[r^2 + a^2] + h^2 r^2];
dvRegExpr[m_, h_, a_, r_] := r (h^2 - m/(r^2 + a^2)^(3/2))/Sqrt[2 m/Sqrt[r^2 + a^2] + h^2 r^2];
k2RegExpr[m_, h_, a_, r_] := dvRegExpr[m, h, a, r]^2 + 2 (vRegExpr[m, h, a, r]/r)^2;

i0[rmin_?NumericQ, rout_?NumericQ] := N[(4 Pi/3) (rout^3 - rmin^3), 40];
i1Reg[m_?NumericQ, h_?NumericQ, a_?NumericQ, rmin_?NumericQ, rout_?NumericQ] := Module[{int},
  int[r_?NumericQ] := N[4 Pi k2RegExpr[m, h, a, r] r^2, 40];
  N[
    Quiet[
      NIntegrate[int[r], {r, rmin, rout},
        WorkingPrecision -> 40,
        AccuracyGoal -> 14,
        PrecisionGoal -> 12,
        MaxRecursion -> 20,
        Method -> {"GlobalAdaptive", "SymbolicProcessing" -> 0}
      ],
      {NIntegrate::precw, NIntegrate::slwcon, NIntegrate::ncvb, General::stop}
    ],
    35
  ]
];
qReg[m_?NumericQ, h_?NumericQ, a_?NumericQ, rmin_?NumericQ, rout_?NumericQ] := N[i1Reg[m, h, a, rmin, rout]/i0[rmin, rout], 35];

m0 = 1;
hRef = 1/100;
hHalf = hRef/2;
rootsRef = horizonRoots[m0, hRef];
checkA = Length[rootsRef] >= 2 && rootsRef[[1]] < rootsRef[[2]];

rsRef = Indeterminate;
routRef = Indeterminate;
aReg = Indeterminate;
rminList = Indeterminate;

xThetaMid = Indeterminate;
kVals = Indeterminate;
nEffVals = Indeterminate;
tailNEff = Indeterminate;
qVals = Indeterminate;
dqVals = Indeterminate;
dqRatios = Indeterminate;
qFit0 = Indeterminate;
relTailErr = Indeterminate;
c2Theo = Indeterminate;
c2Num = Indeterminate;

rootsHalf = Indeterminate;
rsHalf = Indeterminate;
routHalf = Indeterminate;
rminRef = Indeterminate;
rminHalf = Indeterminate;
qMassRef = Indeterminate;
qMassHalf = Indeterminate;
deltaQRef = Indeterminate;
deltaQHalf = Indeterminate;
ratioDelta = Indeterminate;
ratioI0 = Indeterminate;
epsRef = Indeterminate;
epsHalf = Indeterminate;
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
checkL = False;

If[TrueQ[checkA],
  rsRef = rootsRef[[1]];
  routRef = rootsRef[[2]];
  aReg = N[rsRef, 50];
  rminList = N[rsRef*10^-Range[1, 7], 40];

  rmid = (rsRef + routRef)/2;
  xThetaMid = N[(1/f[rmid, m0, hRef] - f[rmid, m0, hRef] gPrime[rmid, m0, hRef]^2), 40];
  checkB = Abs[xThetaMid - 1] < 10^-12;

  kVals = Table[N[k2RegExpr[m0, hRef, aReg, rr], 50], {rr, rminList}];
  nEffVals = Table[
    N[-Log[kVals[[ii + 1]]/kVals[[ii]]]/Log[rminList[[ii + 1]]/rminList[[ii]]], 40],
    {ii, 1, Length[kVals] - 1}
  ];
  tailNEff = nEffVals[[-4 ;;]];

  c2Theo = N[4 m0/aReg, 40];
  c2Num = N[rminList[[-1]]^2 k2RegExpr[m0, hRef, aReg, rminList[[-1]]], 40];

  qVals = Table[qReg[m0, hRef, aReg, rr, routRef], {rr, rminList}];
  dqVals = Differences[qVals];
  dqRatios = N[dqVals[[2 ;;]]/dqVals[[1 ;; -2]], 40];

  tailData = Transpose[{rminList[[-4 ;;]], qVals[[-4 ;;]]}];
  fitModel = Fit[tailData, {1, r}, r];
  qFit0 = N[fitModel /. r -> 0, 50];
  relTailErr = N[Abs[(qVals[[-1]] - qFit0)/qFit0], 40];

  checkC = Min[tailNEff] > 1.95 && Max[tailNEff] < 2.05;
  checkD = Abs[c2Num/c2Theo - 1] < 10^-3;
  checkE = Min[dqVals] > 0;
  checkF = Min[dqRatios[[-3 ;;]]] > 0.08 && Max[dqRatios[[-3 ;;]]] < 0.12;
  checkG = relTailErr < 5*10^-6;

  rootsHalf = horizonRoots[m0, hHalf];
  checkH = Length[rootsHalf] >= 2 && rootsHalf[[1]] < rootsHalf[[2]];
  If[TrueQ[checkH],
    rsHalf = rootsHalf[[1]];
    routHalf = rootsHalf[[2]];
    rminRef = rminList[[-1]];
    rminHalf = rsHalf*10^-6;

    qMassRef = qReg[m0, hRef, aReg, rminRef, routRef];
    qMassHalf = qReg[m0, hHalf, aReg, rminHalf, routHalf];
    deltaQRef = N[qMassRef - 3 hRef^2, 50];
    deltaQHalf = N[qMassHalf - 3 hHalf^2, 50];
    ratioDelta = N[deltaQHalf/deltaQRef, 40];
    ratioI0 = N[i0[rminHalf, routHalf]/i0[rminRef, routRef], 40];
    epsRef = N[deltaQRef/(3 hRef^2), 40];
    epsHalf = N[deltaQHalf/(3 hHalf^2), 40];

    checkI = deltaQRef > 0 && deltaQHalf > 0;
    checkJ = Abs[ratioDelta/(1/8) - 1] < 0.2;
    checkK = Abs[ratioI0/8 - 1] < 0.2;
    checkL = epsRef < 0.3 && epsHalf < 0.3;
  ];

  classification = If[TrueQ[checkB && checkC && checkD && checkE && checkF && checkG && checkH && checkI && checkJ && checkK && checkL],
    "INTERIOR_REGULARIZATION_CONSISTENT",
    "undetermined"
  ];
];

check = TrueQ[checkA && checkB && checkC && checkD && checkE && checkF && checkG && checkH && checkI && checkJ && checkK && checkL &&
   classification == "INTERIOR_REGULARIZATION_CONSISTENT"];

nbName = "06_Interior_Regularization_Consistency_Test.nb";
logName = "06_interior_regularization_consistency_test.log";
logLines = {
  "Notebook: " <> nbName,
  "m0 = " <> ToString[m0, InputForm],
  "hRef = " <> ToString[hRef, InputForm],
  "hHalf = " <> ToString[hHalf, InputForm],
  "rootsRef = " <> ToString[rootsRef, InputForm],
  "rsRef = " <> ToString[rsRef, InputForm],
  "routRef = " <> ToString[routRef, InputForm],
  "aReg = " <> ToString[aReg, InputForm],
  "rminList = " <> ToString[rminList, InputForm],
  "xThetaMid = " <> ToString[xThetaMid, InputForm],
  "kVals = " <> ToString[kVals, InputForm],
  "nEffVals = " <> ToString[nEffVals, InputForm],
  "tailNEff = " <> ToString[tailNEff, InputForm],
  "c2Theo = " <> ToString[c2Theo, InputForm],
  "c2Num = " <> ToString[c2Num, InputForm],
  "qVals = " <> ToString[qVals, InputForm],
  "dqVals = " <> ToString[dqVals, InputForm],
  "dqRatios = " <> ToString[dqRatios, InputForm],
  "qFit0 = " <> ToString[qFit0, InputForm],
  "relTailErr = " <> ToString[relTailErr, InputForm],
  "rootsHalf = " <> ToString[rootsHalf, InputForm],
  "rsHalf = " <> ToString[rsHalf, InputForm],
  "routHalf = " <> ToString[routHalf, InputForm],
  "qMassRef = " <> ToString[qMassRef, InputForm],
  "qMassHalf = " <> ToString[qMassHalf, InputForm],
  "deltaQRef = " <> ToString[deltaQRef, InputForm],
  "deltaQHalf = " <> ToString[deltaQHalf, InputForm],
  "ratioDelta = " <> ToString[ratioDelta, InputForm],
  "ratioI0 = " <> ToString[ratioI0, InputForm],
  "epsRef = " <> ToString[epsRef, InputForm],
  "epsHalf = " <> ToString[epsHalf, InputForm],
  "classification = " <> ToString[classification, InputForm],
  "checkA(two horizons ref) = " <> ToString[checkA, InputForm],
  "checkB(crossing foliation) = " <> ToString[checkB, InputForm],
  "checkC(n_eff tail < 3) = " <> ToString[checkC, InputForm],
  "checkD(core coefficient r^-2) = " <> ToString[checkD, InputForm],
  "checkE(Q monotonic with cutoff) = " <> ToString[checkE, InputForm],
  "checkF(linear tail in rmin) = " <> ToString[checkF, InputForm],
  "checkG(convergent extrapolation) = " <> ToString[checkG, InputForm],
  "checkH(two horizons half) = " <> ToString[checkH, InputForm],
  "checkI(deltaQ positive) = " <> ToString[checkI, InputForm],
  "checkJ(IR ratio ~1/8) = " <> ToString[checkJ, InputForm],
  "checkK(volume ratio ~8) = " <> ToString[checkK, InputForm],
  "checkL(BH effect subleading, non-O(1)) = " <> ToString[checkL, InputForm],
  "check = " <> ToString[check, InputForm]
};
logText = StringRiffle[logLines, "\n"];

result = <|
  "script" -> "06_interior_regularization_consistency_test",
  "nbName" -> nbName,
  "logName" -> logName,
  "nbBase64" -> BaseEncode[ExportByteArray[nb, "NB"]],
  "logText" -> logText,
  "check" -> check
|>;

Print["__RESULT__" <> ExportString[result, "RawJSON"]];
If[TrueQ[check], Exit[0], Exit[1]];
