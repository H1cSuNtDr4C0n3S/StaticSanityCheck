ClearAll["Global`*"];

nb = Notebook[{
  Cell["02 - IR Robustness: BH Weight on Q=I1/I0", "Title"],
  Cell["Toy test: de Sitter background plus local BH defect. Goal: quantify when deltaQ stays volume-suppressed and when non-integrable core behavior can make it O(1).", "Text"],
  Cell[BoxData @ ToBoxes @ HoldForm[
    Q == I1/I0 && I1 == I1bg + deltaI1BH && I0 == I0cosmo
  ], "Input"],
  Cell[BoxData @ ToBoxes @ HoldForm[
    deltaI1BH[p] == 4 Pi a K2bg rs^p Integrate[r^(2 - p), {r, reps, rMatch}]
  ], "Input"],
  Cell[BoxData @ ToBoxes @ HoldForm[
    deltaQ == deltaI1BH/I0 && I0 == (4 Pi/3) (Rc^3 - reps^3)
  ], "Input"],
  Cell[BoxData @ ToBoxes @ HoldForm[
    p < 3 -> integrable (finite core contribution), p > 3 -> non-integrable core sensitivity
  ], "Input"]
}];

f[r_, m_, h_] := 1 - 2 m/r - h^2 r^2;

horizonRoots[m_?NumericQ, h_?NumericQ] := Module[{sol},
  sol = r /. NSolve[f[r, m, h] == 0, r, Reals, WorkingPrecision -> 80];
  sol = Chop[N[sol, 40], 10^-25];
  sol = Select[sol, NumericQ[#] && # > 0 &];
  Sort[DeleteDuplicates[sol, Abs[#1 - #2] < 10^-20 &]]
];

deltaI1Analytic[p_?NumericQ, a_?NumericQ, k2bg_?NumericQ, rs_?NumericQ, rMatch_?NumericQ, reps_?NumericQ] := Module[{pref},
  pref = 4 Pi a k2bg rs^p;
  If[Abs[p - 3] < 10^-14,
    N[pref Log[rMatch/reps], 50],
    N[pref (rMatch^(3 - p) - reps^(3 - p))/(3 - p), 50]
  ]
];

i0Cosmo[reps_?NumericQ, rc_?NumericQ] := N[(4 Pi/3) (rc^3 - reps^3), 50];

deltaQ[p_?NumericQ, a_?NumericQ, k2bg_?NumericQ, rs_?NumericQ, rMatch_?NumericQ, reps_?NumericQ, rc_?NumericQ] :=
  N[deltaI1Analytic[p, a, k2bg, rs, rMatch, reps]/i0Cosmo[reps, rc], 50];

m0 = 1;
h0 = 1/100;
roots = horizonRoots[m0, h0];

checkA = Length[roots] >= 2 && roots[[1]] < roots[[2]];

rs = Indeterminate;
rc = Indeterminate;
k2bg = Indeterminate;
rMatch = Indeterminate;
a0 = 1;
reps0 = Indeterminate;

checkB = False;
checkC = False;
checkD = False;
checkE = False;
checkF = False;
checkG = False;
checkH = False;
checkI = False;
checkJ = False;

qShiftP2 = Indeterminate;
qShiftP3 = Indeterminate;
fracP2 = Indeterminate;
fracP3 = Indeterminate;
volRatio = Indeterminate;
coeffP2 = Indeterminate;
qScaleValsP2 = Indeterminate;
scaleRatiosP2 = Indeterminate;
epsList = Indeterminate;
qEpsP2 = Indeterminate;
qEpsP4 = Indeterminate;
qEpsRatiosP4 = Indeterminate;
fracP4Small = Indeterminate;
numVsAnaErrP2 = Indeterminate;
regime = "undetermined";

If[TrueQ[checkA],
  rs = roots[[1]];
  rc = roots[[2]];
  k2bg = N[3 h0^2, 50];
  rMatch = N[6 rs, 50];
  reps0 = N[10^-3 rs, 50];

  (* p=2 integrable benchmark *)
  qShiftP2 = deltaQ[2, a0, k2bg, rs, rMatch, reps0, rc];
  fracP2 = N[qShiftP2/k2bg, 50];
  volRatio = N[(rs/rc)^3, 50];
  coeffP2 = N[fracP2/volRatio, 50];

  (* numeric-vs-analytic consistency for p=2 *)
  deltaI1NumP2 = N[Integrate[4 Pi a0 k2bg rs^2 r^(2 - 2), {r, reps0, rMatch}], 50];
  deltaI1AnaP2 = deltaI1Analytic[2, a0, k2bg, rs, rMatch, reps0];
  numVsAnaErrP2 = N[Abs[deltaI1NumP2 - deltaI1AnaP2], 40];
  checkB = numVsAnaErrP2 < 10^-20;

  (* IR robustness scaling with cosmological size *)
  qScaleValsP2 = Table[
    deltaQ[2, a0, k2bg, rs, rMatch, reps0, sc rc],
    {sc, {1, 2, 4}}
  ];
  scaleRatiosP2 = N[{qScaleValsP2[[1]]/qScaleValsP2[[2]], qScaleValsP2[[2]]/qScaleValsP2[[3]]}, 40];
  checkC = Max[Abs[scaleRatiosP2 - {8, 8}]] < 10^-9;

  (* finite-core robustness for integrable profile *)
  epsList = N[rs {10^-2, 10^-4, 10^-6}, 50];
  qEpsP2 = Table[deltaQ[2, a0, k2bg, rs, rMatch, ee, rc], {ee, epsList}];
  checkD = qEpsP2[[1]] < qEpsP2[[2]] < qEpsP2[[3]];
  checkE = Abs[(qEpsP2[[3]] - qEpsP2[[2]])/qEpsP2[[2]]] < 10^-2;

  (* marginal p=3 (log) still controlled in this benchmark *)
  qShiftP3 = deltaQ[3, a0, k2bg, rs, rMatch, reps0, rc];
  fracP3 = N[qShiftP3/k2bg, 50];
  checkF = fracP3 < 10^-2;

  (* non-integrable p=4: sensitivity to deep cutoff *)
  qEpsP4 = Table[deltaQ[4, a0, k2bg, rs, rMatch, ee, rc], {ee, epsList}];
  qEpsRatiosP4 = N[{qEpsP4[[2]]/qEpsP4[[1]], qEpsP4[[3]]/qEpsP4[[2]]}, 40];
  fracP4Small = N[qEpsP4[[3]]/k2bg, 50];
  checkG = qEpsP4[[1]] < qEpsP4[[2]] < qEpsP4[[3]];
  checkH = Min[qEpsRatiosP4] > 50;
  checkI = fracP4Small > 1;

  (* integrable branch remains strongly volume-suppressed *)
  checkJ = fracP2 < 10^-2 && coeffP2 > 1 && coeffP2 < 100;

  regime = If[TrueQ[checkB && checkC && checkD && checkE && checkF && checkG && checkH && checkI && checkJ],
    "IR_robust_except_nonintegrable_core",
    "undetermined"
  ];
];

check = TrueQ[checkA && checkB && checkC && checkD && checkE && checkF && checkG && checkH && checkI && checkJ &&
   regime == "IR_robust_except_nonintegrable_core"];

nbName = "02_IR_Robustness_BH_Weight_On_Q.nb";
logName = "02_ir_robustness_bh_weight_on_q.log";
logLines = {
  "Notebook: " <> nbName,
  "m0 = " <> ToString[m0, InputForm],
  "h0 = " <> ToString[h0, InputForm],
  "roots = " <> ToString[roots, InputForm],
  "rs = " <> ToString[rs, InputForm],
  "rc = " <> ToString[rc, InputForm],
  "k2bg = " <> ToString[k2bg, InputForm],
  "rMatch = " <> ToString[rMatch, InputForm],
  "reps0 = " <> ToString[reps0, InputForm],
  "volRatio=(rs/rc)^3 = " <> ToString[volRatio, InputForm],
  "deltaI1 num-vs-ana err p=2 = " <> ToString[numVsAnaErrP2, InputForm],
  "qShiftP2 = " <> ToString[qShiftP2, InputForm],
  "fracP2=qShiftP2/k2bg = " <> ToString[fracP2, InputForm],
  "coeffP2=fracP2/volRatio = " <> ToString[coeffP2, InputForm],
  "qScaleValsP2(Rc*{1,2,4}) = " <> ToString[qScaleValsP2, InputForm],
  "scaleRatiosP2 = " <> ToString[scaleRatiosP2, InputForm],
  "epsList = " <> ToString[epsList, InputForm],
  "qEpsP2 = " <> ToString[qEpsP2, InputForm],
  "qShiftP3 = " <> ToString[qShiftP3, InputForm],
  "fracP3 = " <> ToString[fracP3, InputForm],
  "qEpsP4 = " <> ToString[qEpsP4, InputForm],
  "qEpsRatiosP4 = " <> ToString[qEpsRatiosP4, InputForm],
  "fracP4Small = " <> ToString[fracP4Small, InputForm],
  "checkA(two horizons) = " <> ToString[checkA, InputForm],
  "checkB(analytic vs numeric p=2) = " <> ToString[checkB, InputForm],
  "checkC(IR scaling in Rc) = " <> ToString[checkC, InputForm],
  "checkD(integrable p=2 finite-core monotonicity) = " <> ToString[checkD, InputForm],
  "checkE(integrable p=2 near-cutoff stability) = " <> ToString[checkE, InputForm],
  "checkF(marginal p=3 still small here) = " <> ToString[checkF, InputForm],
  "checkG(non-integrable p=4 growth) = " <> ToString[checkG, InputForm],
  "checkH(non-integrable p=4 strong cutoff sensitivity) = " <> ToString[checkH, InputForm],
  "checkI(non-integrable p=4 can reach O(1) relative shift) = " <> ToString[checkI, InputForm],
  "checkJ(integrable branch remains volume-suppressed) = " <> ToString[checkJ, InputForm],
  "regime = " <> ToString[regime, InputForm],
  "check = " <> ToString[check, InputForm]
};
logText = StringRiffle[logLines, "\n"];

result = <|
  "script" -> "02_ir_robustness_bh_weight_on_q",
  "nbName" -> nbName,
  "logName" -> logName,
  "nbBase64" -> BaseEncode[ExportByteArray[nb, "NB"]],
  "logText" -> logText,
  "check" -> check
|>;

Print["__RESULT__" <> ExportString[result, "RawJSON"]];
If[TrueQ[check], Exit[0], Exit[1]];
