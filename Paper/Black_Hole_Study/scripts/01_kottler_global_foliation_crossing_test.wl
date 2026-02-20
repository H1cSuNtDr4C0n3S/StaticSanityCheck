ClearAll["Global`*"];

nb = Notebook[{
  Cell["01 - Kottler Global Foliation: Crossing vs Asymptotic Stall", "Title"],
  Cell["Operational test for question 2: in Schwarzschild-de Sitter, does a regular global foliation Theta cross horizons or stall at them?", "Text"],
  Cell[BoxData @ ToBoxes @ HoldForm[
    f[r_, M_, H_] := 1 - 2 M/r - H^2 r^2
  ], "Input"],
  Cell[BoxData @ ToBoxes @ HoldForm[
    Theta == T == t + g[r] && g'[r] == Sqrt[1 - f[r, M, H]]/f[r, M, H]
  ], "Input"],
  Cell[BoxData @ ToBoxes @ HoldForm[
    XTheta == -(gInv[mu, nu] D[Theta, x[mu]] D[Theta, x[nu]]) == 1
  ], "Input"],
  Cell[BoxData @ ToBoxes @ HoldForm[
    ds2TR == -f dT^2 + 2 Sqrt[1 - f] dT dr + dr^2 + r^2 dOmega2
  ], "Input"],
  Cell[BoxData @ ToBoxes @ HoldForm[
    behavior == "A_crossing" (* global regular foliation exists and crosses both horizons *)
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

(* symbolic checks for the PG-like foliation Theta = T *)
xThetaRaw = FullSimplify[
  1/f[rr, mm, hh] - f[rr, mm, hh] gPrime[rr, mm, hh]^2,
  Assumptions -> {rr > 0, mm > 0, hh > 0}
];
checkA = TrueQ @ Simplify[xThetaRaw == 1, Assumptions -> {rr > 0, mm > 0, hh > 0}];

gTrRaw = FullSimplify[
  f[rr, mm, hh] gPrime[rr, mm, hh],
  Assumptions -> {rr > 0, mm > 0, hh > 0}
];
gRRRaw = FullSimplify[
  1/f[rr, mm, hh] - f[rr, mm, hh] gPrime[rr, mm, hh]^2,
  Assumptions -> {rr > 0, mm > 0, hh > 0}
];
det2DRaw = FullSimplify[
  -f[rr, mm, hh] gRRRaw - gTrRaw^2,
  Assumptions -> {rr > 0, mm > 0, hh > 0}
];

checkB = TrueQ @ Simplify[gTrRaw == Sqrt[1 - f[rr, mm, hh]], Assumptions -> {rr > 0, mm > 0, hh > 0}];
checkC = TrueQ @ Simplify[gRRRaw == 1, Assumptions -> {rr > 0, mm > 0, hh > 0}];
checkD = TrueQ @ Simplify[det2DRaw == -1, Assumptions -> {rr > 0, mm > 0, hh > 0}];

(* numerical benchmark *)
m0 = 1;
h0 = 1/100;

roots = horizonRoots[m0, h0];
checkE = Length[roots] >= 2 && roots[[1]] < roots[[2]];

rbh = Indeterminate;
rc = Indeterminate;

gTrBH = Indeterminate;
gTrC = Indeterminate;
detBH = Indeterminate;
detC = Indeterminate;
vPlusBH = Indeterminate;
vMinusBH = Indeterminate;
vPlusC = Indeterminate;
vMinusC = Indeterminate;
xStaticInside = Indeterminate;
xStaticMid = Indeterminate;
xStaticOutside = Indeterminate;
xThetaInside = Indeterminate;
xThetaMid = Indeterminate;
xThetaOutside = Indeterminate;
nearSlopeLeft = Indeterminate;
nearSlopeRight = Indeterminate;
behavior = "undetermined";

checkF = False;
checkG = False;
checkH = False;
checkI = False;
checkJ = False;

If[TrueQ[checkE],
  rbh = roots[[1]];
  rc = roots[[2]];

  gTrBH = N[Sqrt[1 - f[rbh, m0, h0]], 40];
  gTrC = N[Sqrt[1 - f[rc, m0, h0]], 40];
  detBH = N[(-f[rbh, m0, h0]) - (Sqrt[1 - f[rbh, m0, h0]])^2, 40];
  detC = N[(-f[rc, m0, h0]) - (Sqrt[1 - f[rc, m0, h0]])^2, 40];

  checkF = Abs[gTrBH - 1] < 10^-12 && Abs[gTrC - 1] < 10^-12 &&
    Abs[detBH + 1] < 10^-12 && Abs[detC + 1] < 10^-12;

  vPlus[r_] := -Sqrt[1 - f[r, m0, h0]] + 1;
  vMinus[r_] := -Sqrt[1 - f[r, m0, h0]] - 1;

  vPlusBH = N[vPlus[rbh], 40];
  vMinusBH = N[vMinus[rbh], 40];
  vPlusC = N[vPlus[rc], 40];
  vMinusC = N[vMinus[rc], 40];

  checkG = Abs[vPlusBH] < 10^-12 && Abs[vPlusC] < 10^-12 &&
    Abs[vMinusBH + 2] < 10^-12 && Abs[vMinusC + 2] < 10^-12;

  rInside = 0.8 rbh;
  rMid = (rbh + rc)/2;
  rOutside = 1.2 rc;

  xStaticInside = N[1/f[rInside, m0, h0], 40];
  xStaticMid = N[1/f[rMid, m0, h0], 40];
  xStaticOutside = N[1/f[rOutside, m0, h0], 40];

  xThetaInside = N[(1/f[rInside, m0, h0] - f[rInside, m0, h0] gPrime[rInside, m0, h0]^2), 40];
  xThetaMid = N[(1/f[rMid, m0, h0] - f[rMid, m0, h0] gPrime[rMid, m0, h0]^2), 40];
  xThetaOutside = N[(1/f[rOutside, m0, h0] - f[rOutside, m0, h0] gPrime[rOutside, m0, h0]^2), 40];

  checkH = xStaticInside < 0 && xStaticMid > 0 && xStaticOutside < 0;
  checkI = Abs[xThetaInside - 1] < 10^-12 && Abs[xThetaMid - 1] < 10^-12 && Abs[xThetaOutside - 1] < 10^-12;

  nearSlopeLeft = N[Abs[gPrime[rbh - 10^-4, m0, h0]], 30];
  nearSlopeRight = N[Abs[gPrime[rbh + 10^-4, m0, h0]], 30];
  checkJ = nearSlopeLeft > 10^3 && nearSlopeRight > 10^3;

  behavior = If[TrueQ[checkA && checkB && checkC && checkD && checkE && checkF && checkG && checkH && checkI],
    "A_crossing",
    "undetermined"
  ];
];

check = TrueQ[checkA && checkB && checkC && checkD && checkE && checkF && checkG && checkH && checkI && checkJ && behavior == "A_crossing"];

nbName = "01_Kottler_Global_Foliation_Crossing_Test.nb";
logName = "01_kottler_global_foliation_crossing_test.log";
logLines = {
  "Notebook: " <> nbName,
  "m0 = " <> ToString[m0, InputForm],
  "h0 = " <> ToString[h0, InputForm],
  "xThetaRaw = " <> ToString[xThetaRaw, InputForm],
  "gTrRaw = " <> ToString[gTrRaw, InputForm],
  "gRRRaw = " <> ToString[gRRRaw, InputForm],
  "det2DRaw = " <> ToString[det2DRaw, InputForm],
  "roots = " <> ToString[roots, InputForm],
  "rbh = " <> ToString[rbh, InputForm],
  "rc = " <> ToString[rc, InputForm],
  "gTrBH = " <> ToString[gTrBH, InputForm],
  "gTrC = " <> ToString[gTrC, InputForm],
  "detBH = " <> ToString[detBH, InputForm],
  "detC = " <> ToString[detC, InputForm],
  "vPlusBH = " <> ToString[vPlusBH, InputForm],
  "vMinusBH = " <> ToString[vMinusBH, InputForm],
  "vPlusC = " <> ToString[vPlusC, InputForm],
  "vMinusC = " <> ToString[vMinusC, InputForm],
  "xStaticInside = " <> ToString[xStaticInside, InputForm],
  "xStaticMid = " <> ToString[xStaticMid, InputForm],
  "xStaticOutside = " <> ToString[xStaticOutside, InputForm],
  "xThetaInside = " <> ToString[xThetaInside, InputForm],
  "xThetaMid = " <> ToString[xThetaMid, InputForm],
  "xThetaOutside = " <> ToString[xThetaOutside, InputForm],
  "nearSlopeLeft = " <> ToString[nearSlopeLeft, InputForm],
  "nearSlopeRight = " <> ToString[nearSlopeRight, InputForm],
  "checkA(XTheta=1) = " <> ToString[checkA, InputForm],
  "checkB(gTr form) = " <> ToString[checkB, InputForm],
  "checkC(gRR=1) = " <> ToString[checkC, InputForm],
  "checkD(det2D=-1) = " <> ToString[checkD, InputForm],
  "checkE(two horizons) = " <> ToString[checkE, InputForm],
  "checkF(metric regular at horizons) = " <> ToString[checkF, InputForm],
  "checkG(null slopes finite at horizons) = " <> ToString[checkG, InputForm],
  "checkH(static foliation not global) = " <> ToString[checkH, InputForm],
  "checkI(PG foliation timelike across regions) = " <> ToString[checkI, InputForm],
  "checkJ(static-time asymptotic behavior near horizon) = " <> ToString[checkJ, InputForm],
  "behavior = " <> ToString[behavior, InputForm],
  "check = " <> ToString[check, InputForm]
};
logText = StringRiffle[logLines, "\n"];

result = <|
  "script" -> "01_kottler_global_foliation_crossing_test",
  "nbName" -> nbName,
  "logName" -> logName,
  "nbBase64" -> BaseEncode[ExportByteArray[nb, "NB"]],
  "logText" -> logText,
  "check" -> check
|>;

Print["__RESULT__" <> ExportString[result, "RawJSON"]];
If[TrueQ[check], Exit[0], Exit[1]];
