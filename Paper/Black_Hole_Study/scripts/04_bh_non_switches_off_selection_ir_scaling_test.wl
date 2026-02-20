ClearAll["Global`*"];

nb = Notebook[{
  Cell["04 - BH Non-Switches-Off Selection (IR Scaling Test)", "Title"],
  Cell["Objective: validate that BH contribution to Q is IR-suppressed and decreases as cosmic domain grows (H -> H/2).", "Text"],
  Cell[BoxData @ ToBoxes @ HoldForm[
    DTheta[M_, H_, z2_] == {r > 0 | f[r, M, H] >= z2}
  ], "Input"],
  Cell[BoxData @ ToBoxes @ HoldForm[
    Q[M_, H_] == I1[M, H]/I0[M, H]
  ], "Input"],
  Cell[BoxData @ ToBoxes @ HoldForm[
    deltaQ[H_] == Q[M, H] - Q[0, H]
  ], "Input"],
  Cell[BoxData @ ToBoxes @ HoldForm[
    testIRRatio == deltaQ[H/2]/deltaQ[H]
  ], "Input"]
}];

f[r_, m_, h_] := 1 - 2 m/r - h^2 r^2;

positiveRoots[m_?NumericQ, h_?NumericQ, z2_?NumericQ] := Module[{sol},
  sol = r /. NSolve[h^2 r^3 - (1 - z2) r + 2 m == 0, r, Reals, WorkingPrecision -> 80];
  sol = Chop[N[sol, 40], 10^-25];
  sol = Select[sol, NumericQ[#] && # > 0 &];
  Sort[DeleteDuplicates[sol, Abs[#1 - #2] < 10^-20 &]]
];

domainBounds[m_?NumericQ, h_?NumericQ, z2_?NumericQ] := Module[{roots},
  If[m <= 10^-14,
    {0, N[Sqrt[(1 - z2)]/h, 50]},
    roots = positiveRoots[m, h, z2];
    If[Length[roots] < 2, $Failed, {First[roots], Last[roots]}]
  ]
];

i0Domain[m_?NumericQ, h_?NumericQ, z2_?NumericQ] := Module[{bb = domainBounds[m, h, z2]},
  If[bb === $Failed, $Failed, N[(4 Pi/3) (bb[[2]]^3 - bb[[1]]^3), 50]]
];

k2bg[h_?NumericQ] := N[3 h^2, 50];

localI1[m_?NumericQ, h_?NumericQ, z2_?NumericQ, alpha_?NumericQ, beta_?NumericQ, rFloor_?NumericQ] := Module[
  {bb, rs, a, ff},
  If[m <= 10^-14, Return[0]];
  bb = domainBounds[m, h, z2];
  If[bb === $Failed, Return[$Failed]];
  rs = 2 m;
  a = N[Sqrt[(beta rs)^2 + rFloor^2], 50];
  ff[x_] := N[(1/(2 a)) ArcTan[x/a] - x/(2 (x^2 + a^2)), 50];
  N[4 Pi alpha rs^2 (ff[bb[[2]]] - ff[bb[[1]]]), 50]
];

qValue[m_?NumericQ, h_?NumericQ, z2_?NumericQ, alpha_?NumericQ, beta_?NumericQ, rFloor_?NumericQ] := Module[
  {i0, loc},
  i0 = i0Domain[m, h, z2];
  If[i0 === $Failed, Return[$Failed]];
  loc = localI1[m, h, z2, alpha, beta, rFloor];
  If[loc === $Failed, Return[$Failed]];
  N[k2bg[h] + loc/i0, 50]
];

mBH = 1;
hRef = 1/100;
hHalf = hRef/2;
z20 = 1/20;
alpha = 1;
beta = 1;
rFloor = 10^-12;

bbMH = domainBounds[mBH, hRef, z20];
bbMHalf = domainBounds[mBH, hHalf, z20];
bb0H = domainBounds[0, hRef, z20];
bb0Half = domainBounds[0, hHalf, z20];

checkA = bbMH =!= $Failed && bbMHalf =!= $Failed && bb0H =!= $Failed && bb0Half =!= $Failed;

i0MH = Indeterminate;
i0MHalf = Indeterminate;
locMH = Indeterminate;
locMHalf = Indeterminate;
qMH = Indeterminate;
q0H = Indeterminate;
qMHalf = Indeterminate;
q0Half = Indeterminate;
deltaQH = Indeterminate;
deltaQHalf = Indeterminate;
ratioDelta = Indeterminate;
ratioI0 = Indeterminate;
ratioLoc = Indeterminate;
epsH = Indeterminate;
epsHalf = Indeterminate;
predHalf = Indeterminate;
predErr = Indeterminate;
classification = "undetermined";

checkB = False;
checkC = False;
checkD = False;
checkE = False;
checkF = False;
checkG = False;
checkH = False;
checkI = False;

If[TrueQ[checkA],
  i0MH = i0Domain[mBH, hRef, z20];
  i0MHalf = i0Domain[mBH, hHalf, z20];
  locMH = localI1[mBH, hRef, z20, alpha, beta, rFloor];
  locMHalf = localI1[mBH, hHalf, z20, alpha, beta, rFloor];

  qMH = qValue[mBH, hRef, z20, alpha, beta, rFloor];
  q0H = qValue[0, hRef, z20, alpha, beta, rFloor];
  qMHalf = qValue[mBH, hHalf, z20, alpha, beta, rFloor];
  q0Half = qValue[0, hHalf, z20, alpha, beta, rFloor];

  deltaQH = N[qMH - q0H, 50];
  deltaQHalf = N[qMHalf - q0Half, 50];

  ratioDelta = N[deltaQHalf/deltaQH, 40];
  ratioI0 = N[i0MHalf/i0MH, 40];
  ratioLoc = N[locMHalf/locMH, 40];
  epsH = N[deltaQH/q0H, 40];
  epsHalf = N[deltaQHalf/q0Half, 40];
  predHalf = N[deltaQH/8, 50];
  predErr = N[Abs[(deltaQHalf - predHalf)/predHalf], 40];

  checkB = Abs[q0H - k2bg[hRef]] < 10^-16 && Abs[q0Half - k2bg[hHalf]] < 10^-16;
  checkC = deltaQH > 0 && deltaQHalf > 0;
  checkD = Abs[ratioDelta/(1/8) - 1] < 0.15;
  checkE = Abs[ratioI0/8 - 1] < 0.05;
  checkF = Abs[ratioLoc - 1] < 0.05;
  checkG = epsH < 0.05 && epsHalf < 0.05;
  checkH = deltaQHalf < deltaQH/4;
  checkI = predErr < 0.15;

  classification = If[TrueQ[checkB && checkC && checkD && checkE && checkF && checkG && checkH && checkI],
    "BH_selection_not_switched_off",
    "undetermined"
  ];
];

check = TrueQ[checkA && checkB && checkC && checkD && checkE && checkF && checkG && checkH && checkI &&
   classification == "BH_selection_not_switched_off"];

nbName = "04_BH_Non_Switches_Off_Selection_IR_Scaling_Test.nb";
logName = "04_bh_non_switches_off_selection_ir_scaling_test.log";
logLines = {
  "Notebook: " <> nbName,
  "mBH = " <> ToString[mBH, InputForm],
  "hRef = " <> ToString[hRef, InputForm],
  "hHalf = " <> ToString[hHalf, InputForm],
  "z20 = " <> ToString[z20, InputForm],
  "alpha = " <> ToString[alpha, InputForm],
  "beta = " <> ToString[beta, InputForm],
  "rFloor = " <> ToString[rFloor, InputForm],
  "bbMH = " <> ToString[bbMH, InputForm],
  "bbMHalf = " <> ToString[bbMHalf, InputForm],
  "bb0H = " <> ToString[bb0H, InputForm],
  "bb0Half = " <> ToString[bb0Half, InputForm],
  "i0MH = " <> ToString[i0MH, InputForm],
  "i0MHalf = " <> ToString[i0MHalf, InputForm],
  "locMH = " <> ToString[locMH, InputForm],
  "locMHalf = " <> ToString[locMHalf, InputForm],
  "qMH = " <> ToString[qMH, InputForm],
  "q0H = " <> ToString[q0H, InputForm],
  "qMHalf = " <> ToString[qMHalf, InputForm],
  "q0Half = " <> ToString[q0Half, InputForm],
  "deltaQH = " <> ToString[deltaQH, InputForm],
  "deltaQHalf = " <> ToString[deltaQHalf, InputForm],
  "ratioDelta = deltaQ(H/2)/deltaQ(H) = " <> ToString[ratioDelta, InputForm],
  "ratioI0 = I0(H/2)/I0(H) = " <> ToString[ratioI0, InputForm],
  "ratioLoc = localI1(H/2)/localI1(H) = " <> ToString[ratioLoc, InputForm],
  "epsH = deltaQ(H)/Q0(H) = " <> ToString[epsH, InputForm],
  "epsHalf = deltaQ(H/2)/Q0(H/2) = " <> ToString[epsHalf, InputForm],
  "predHalf = deltaQ(H)/8 = " <> ToString[predHalf, InputForm],
  "predErr = " <> ToString[predErr, InputForm],
  "checkA(domains) = " <> ToString[checkA, InputForm],
  "checkB(Q0=3H^2) = " <> ToString[checkB, InputForm],
  "checkC(deltaQ positive) = " <> ToString[checkC, InputForm],
  "checkD(deltaQ scaling ~1/8) = " <> ToString[checkD, InputForm],
  "checkE(volume scaling ~8) = " <> ToString[checkE, InputForm],
  "checkF(local term ~constant) = " <> ToString[checkF, InputForm],
  "checkG(BH effect subleading) = " <> ToString[checkG, InputForm],
  "checkH(deltaQ decreases strongly) = " <> ToString[checkH, InputForm],
  "checkI(prediction match) = " <> ToString[checkI, InputForm],
  "classification = " <> ToString[classification, InputForm],
  "check = " <> ToString[check, InputForm]
};
logText = StringRiffle[logLines, "\n"];

result = <|
  "script" -> "04_bh_non_switches_off_selection_ir_scaling_test",
  "nbName" -> nbName,
  "logName" -> logName,
  "nbBase64" -> BaseEncode[ExportByteArray[nb, "NB"]],
  "logText" -> logText,
  "check" -> check
|>;

Print["__RESULT__" <> ExportString[result, "RawJSON"]];
If[TrueQ[check], Exit[0], Exit[1]];
