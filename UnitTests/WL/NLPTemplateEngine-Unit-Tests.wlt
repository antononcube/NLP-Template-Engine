(* Mathematica Test File *)
(* Created by the Wolfram Language Plugin for IntelliJ, see http://wlplugin.halirutan.de/ *)

BeginTestSection["NLPTemplateEngine-Unit-Tests.wlt.mt"]

(***********************************************************)
(* Load packages                                           *)
(***********************************************************)

VerificationTest[
  Import["https://raw.githubusercontent.com/antononcube/NLP-Template-Engine/main/Packages/WL/NLPTemplateEngine.m"];
  Length[DownValues[NLPTemplateEngine`Concretize]] > 0
  ,
  True
  ,
  TestID -> "LoadPackage-1"
];


(***********************************************************)
(* RandomTabularDataset                                    *)
(***********************************************************)

VerificationTest[
  rtbCommand1 = StringTemplate["Make a random tabular dataset with `nrow` rows and `ncol` columns."];
  {nrow1, ncol1} = {20, 5};
  rtbRes1 = Concretize["RandomTabularDataset", rtbCommand1[<| "nrow" -> nrow1, "ncol" -> ncol1|>]];
  Head[rtbRes1] == Hold
  ,
  True

  ,
  TestID -> "RandomTabularDataset-1"
];


VerificationTest[
  dsRes = ReleaseHold[rtbRes1];
  Head[dsRes] == Dataset && Dimensions[dsRes] == {nrow1, ncol1}
  ,
  True
  ,
  {ResourceFunction::usermessage...}
  ,
  TestID -> "RandomTabularDataset-2"
];


(***********************************************************)
(* ClCon                                                   *)
(***********************************************************)

VerificationTest[
  clCommand1 = "Make a classifier with the data dfXXXTitanic.";
  clRes1 = Concretize["ClCon", clCommand1];
  Head[clRes1] == Hold &&
      Length[Cases[clRes1, dfXXXTitanic, Infinity]] > 0 &&
      Length[Cases[clRes1, _ClConMakeClassifier, Infinity, Heads -> True]] > 0
  ,
  True
  ,
  TestID -> "ClCon-1"
];


(***********************************************************)
(* QRMon                                                   *)
(***********************************************************)

VerificationTest[
  qrCommand1 = "Do quantile regression over dfXXXFinData.";
  qrRes1 = Concretize["QRMon", qrCommand1];
  Head[qrRes1] == Hold &&
      Length[Cases[qrRes1, dfXXXFinData, Infinity]] > 0 &&
      Length[Cases[qrRes1, _QRMonQuantileRegression, Infinity, Heads -> True]] > 0
  ,
  True
  ,
  TestID -> "QRMon-1"
];


EndTestSection[]
