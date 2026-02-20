ClearAll["Global`*"];

nb = Notebook[{
  Cell["00 - DTheta Domain in Schwarzschild-de Sitter", "Title"],
  Cell["Question zero: define DTheta with an operational redshift cutoff and test unambiguous boundary shape derivative under BH-mass deformation.", "Text"],
  Cell[BoxData @ ToBoxes @ HoldForm[
    f[r_, M_, H_] := 1 - 2 M/r - H^2 r^2
  ], "Input"],
  Cell[BoxData @ ToBoxes @ HoldForm[
    DTheta[M_, H_, z2_] == {r > 0 | f[r, M, H] >= z2}
  ], "Input"],
  Cell[BoxData @ ToBoxes @ HoldForm[
    {rIn, rOut} /. (f[r, M, H] - z2 == 0) && rIn < rOut
  ], "Input"],
  Cell[BoxData @ ToBoxes @ HoldForm[
    drdM[r_] == -(D[f[r, M, H] - z2, M]/D[f[r, M, H] - z2, r]) == r/(M - H^2 r^3)
  ], "Input"],
  Cell[BoxData @ ToBoxes @ HoldForm[
    dI0dM == mu[rOut] drOutdM - mu[rIn] drIndM
  ], "Input"]
}];

f[r_, m_, h_] := 1 - 2 m/r - h^2 r^2;
poly[r_, m_, h_, z2_] := h^2 r^3 - (1 - z2) r + 2 m;

positiveRoots[m_?NumericQ, h_?NumericQ, z2_?NumericQ] := Module[{sol},
  sol = r /. NSolve[poly[r, m, h, z2] == 0, r, Reals, WorkingPrecision -> 80];
  sol = Chop[N[sol, 40], 10^-25];
  sol = Select[sol, NumericQ[#] && # > 0 &];
  Sort[DeleteDuplicates[sol, Abs[#1 - #2] < 10^-20 &]]
];

domainBounds[m_?NumericQ, h_?NumericQ, z2_?NumericQ] := Module[{roots = positiveRoots[m, h, z2]},
  If[Length[roots] < 2, $Failed, {First[roots], Last[roots]}]
];

checkA = False;
checkB = False;
checkC = False;
checkD = False;
checkE = False;
checkF = False;
checkG = False;
checkH = False;
checkRootsPerturbed = False;

rin0 = Indeterminate;
rout0 = Indeterminate;
rinPlus = Indeterminate;
routPlus = Indeterminate;
dRinPred = Indeterminate;
dRoutPred = Indeterminate;
dRinNum = Indeterminate;
dRoutNum = Indeterminate;
errIn = Indeterminate;
errOut = Indeterminate;
dI0Num = Indeterminate;
dI0Pred = Indeterminate;
errI0 = Indeterminate;
ratioScales = Indeterminate;
maxIndicatorDiff = Indeterminate;

m0 = 1;
h0 = 1/100;
z20 = 1/20;
dm = 10^-6;

bounds0 = domainBounds[m0, h0, z20];
checkA = bounds0 =!= $Failed && bounds0[[1]] < bounds0[[2]];

drdMImplicit = FullSimplify[
  -D[f[rr, mm, hh] - zz, mm]/D[f[rr, mm, hh] - zz, rr],
  Assumptions -> {rr > 0, mm > 0, hh > 0}
];
drdMClosed = rr/(mm - hh^2 rr^3);
checkB = TrueQ @ Simplify[drdMImplicit == drdMClosed, Assumptions -> {rr > 0, mm > 0, hh > 0}];

If[TrueQ[checkA],
  rin0 = bounds0[[1]];
  rout0 = bounds0[[2]];

  chiDirect[s_] := UnitStep[s] UnitStep[f[s, m0, h0] - z20];
  chiByBounds[s_] := UnitStep[s - rin0] UnitStep[rout0 - s];
  samplePts = N[Range[1/10, 120, 1/10], 20];
  maxIndicatorDiff = Max[Abs[Table[chiDirect[s] - chiByBounds[s], {s, samplePts}]]];
  checkC = TrueQ[maxIndicatorDiff == 0];

  boundsPlus = domainBounds[m0 + dm, h0, z20];
  boundsMinus = domainBounds[m0 - dm, h0, z20];
  checkRootsPerturbed = boundsPlus =!= $Failed && boundsMinus =!= $Failed;

  If[TrueQ[checkRootsPerturbed],
    rinPlus = boundsPlus[[1]];
    routPlus = boundsPlus[[2]];

    dRinPred = N[(drdMClosed /. {rr -> rin0, mm -> m0, hh -> h0}), 40];
    dRoutPred = N[(drdMClosed /. {rr -> rout0, mm -> m0, hh -> h0}), 40];

    dRinNum = N[(boundsPlus[[1]] - boundsMinus[[1]])/(2 dm), 40];
    dRoutNum = N[(boundsPlus[[2]] - boundsMinus[[2]])/(2 dm), 40];

    errIn = N[Abs[dRinNum - dRinPred], 40];
    errOut = N[Abs[dRoutNum - dRoutPred], 40];
    checkD = errIn < 10^-8;
    checkE = errOut < 10^-8;

    mu[s_] := 1 + s^2/10;
    antiMu[s_] := s + s^3/30;
    i0[m_?NumericQ] := Module[{bb = domainBounds[m, h0, z20]},
      If[bb === $Failed, Indeterminate, N[antiMu[bb[[2]]] - antiMu[bb[[1]]], 50]]
    ];

    dI0Num = N[(i0[m0 + dm] - i0[m0 - dm])/(2 dm), 40];
    dI0Pred = N[mu[rout0] dRoutPred - mu[rin0] dRinPred, 40];
    errI0 = N[Abs[dI0Num - dI0Pred], 40];
    checkF = errI0 < 10^-7;

    checkG = rinPlus > rin0 && routPlus < rout0;
    ratioScales = N[rout0/rin0, 30];
    checkH = ratioScales > 10;
  ];
];

check = TrueQ[checkA && checkB && checkC && checkD && checkE && checkF && checkG && checkH];

nbName = "00_DTheta_Domain_SdS_Shape_Derivative.nb";
logName = "00_dtheta_domain_sds_shape_derivative.log";
logLines = {
  "Notebook: " <> nbName,
  "m0 = " <> ToString[m0, InputForm],
  "h0 = " <> ToString[h0, InputForm],
  "z20 = " <> ToString[z20, InputForm],
  "dm = " <> ToString[dm, InputForm],
  "bounds0 = " <> ToString[bounds0, InputForm],
  "rin0 = " <> ToString[rin0, InputForm],
  "rout0 = " <> ToString[rout0, InputForm],
  "drdMImplicit = " <> ToString[drdMImplicit, InputForm],
  "drdMClosed = " <> ToString[drdMClosed, InputForm],
  "checkA(bounds) = " <> ToString[checkA, InputForm],
  "checkB(implicit derivative closed form) = " <> ToString[checkB, InputForm],
  "maxIndicatorDiff = " <> ToString[maxIndicatorDiff, InputForm],
  "checkC(domain indicator uniqueness) = " <> ToString[checkC, InputForm],
  "checkRootsPerturbed = " <> ToString[checkRootsPerturbed, InputForm],
  "dRinPred = " <> ToString[dRinPred, InputForm],
  "dRinNum = " <> ToString[dRinNum, InputForm],
  "errIn = " <> ToString[errIn, InputForm],
  "checkD(inner boundary derivative) = " <> ToString[checkD, InputForm],
  "dRoutPred = " <> ToString[dRoutPred, InputForm],
  "dRoutNum = " <> ToString[dRoutNum, InputForm],
  "errOut = " <> ToString[errOut, InputForm],
  "checkE(outer boundary derivative) = " <> ToString[checkE, InputForm],
  "dI0Num = " <> ToString[dI0Num, InputForm],
  "dI0Pred = " <> ToString[dI0Pred, InputForm],
  "errI0 = " <> ToString[errI0, InputForm],
  "checkF(shape derivative on I0) = " <> ToString[checkF, InputForm],
  "rinPlus - rin0 = " <> ToString[If[NumberQ[rinPlus] && NumberQ[rin0], N[rinPlus - rin0, 40], Indeterminate], InputForm],
  "routPlus - rout0 = " <> ToString[If[NumberQ[routPlus] && NumberQ[rout0], N[routPlus - rout0, 40], Indeterminate], InputForm],
  "checkG(mass increase deforms boundaries with expected signs) = " <> ToString[checkG, InputForm],
  "ratioScales = rout0/rin0 = " <> ToString[ratioScales, InputForm],
  "checkH(cosmological scale dominates local scale) = " <> ToString[checkH, InputForm],
  "check = " <> ToString[check, InputForm]
};
logText = StringRiffle[logLines, "\n"];

result = <|
  "script" -> "00_dtheta_domain_sds_shape_derivative",
  "nbName" -> nbName,
  "logName" -> logName,
  "nbBase64" -> BaseEncode[ExportByteArray[nb, "NB"]],
  "logText" -> logText,
  "check" -> check
|>;

Print["__RESULT__" <> ExportString[result, "RawJSON"]];
If[TrueQ[check], Exit[0], Exit[1]];
