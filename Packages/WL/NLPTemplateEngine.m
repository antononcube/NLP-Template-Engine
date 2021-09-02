(*
    NLP Template Engine Mathematica package
    Copyright (C) 2021  Anton Antonov

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

    Written by Anton Antonov,
    antononcube @ posteo . net,
    Windermere, Florida, USA.
*)

(*
    Mathematica is (C) Copyright 1988-2021 Wolfram Research, Inc.

    Protected by copyright law and international treaties.

    Unauthorized reproduction or distribution subject to severe civil
    and criminal penalties.

    Mathematica is a registered trademark of Wolfram Research, Inc.
*)

(* Created by the Wolfram Language Plugin for IntelliJ, see http://wlplugin.halirutan.de/ *)

(* :Title: NLPTemplateEngine *)
(* :Context: NLPTemplateEngine` *)
(* :Author: Anton Antonov *)
(* :Date: 2021-07-19 *)

(* :Package Version: 0.5 *)
(* :Mathematica Version: 12.3 *)
(* :Copyright: (c) 2021 Anton Antonov *)
(* :Keywords: *)
(* :Discussion:

## Problem formulation

We want to have a system that:

- Generates relevant, correct, executable programming code based natural language specifications of computational workflows

- Can automatically recognize the workflow types

- Can generate code for different programming languages and related software packages

The points above are given in order of importance; the most important are placed first.

## Examples

Consider the following -- intentionally short and non-specific -- computational workflow specifications:

```mathematica
lsCommands = {
   "Create a random dataset.",
   "Do quantile regression over findData.",
   "Make a classifier over dsTitanic."};
```

Here we generate the code -- note the only the list of commands is given to the function Concretize, [AAp1]:

```mathematica
aRes = Concretize[lsCommands];
```

Here we tabulate the code generation (templates fill-in) results:

```mathematica
ResourceFunction["GridTableForm"][List @@@ Normal[aRes], TableHeadings -> {"Spec", "Code"}]
```

## References

[AAp1] Anton Antonov,
Computational workflow type classifier Mathematica package,
(2021),
[NLP-Template-Engine at GitHub/antononcube](https://github.com/antononcube/NLP-Template-Engine).

*)


(***********************************************************)
(* Load packages                                           *)
(***********************************************************)

If[ Length[DownValues[MonadicContextualClassification`ClConUnit]] == 0,
  Echo["MonadicContextualClassification.m", "Importing from GitHub:"];
  Import["https://raw.githubusercontent.com/antononcube/MathematicaForPrediction/master/MonadicProgramming/MonadicContextualClassification.m"];
];

If[ Length[DownValues[MonadicQuantileRegression`QRMonUnit]] == 0,
  Echo["MonadicQuantileRegression.m", "Importing from GitHub:"];
  Import["https://raw.githubusercontent.com/antononcube/MathematicaForPrediction/master/MonadicProgramming/MonadicQuantileRegression.m"];
];

If[ Length[DownValues[MonadicStructuralBreaksFinder`QRMonFindChowTestLocalMaxima]] == 0,
  Echo["MonadicStructuralBreaksFinder.m", "Importing from GitHub:"];
  Import["https://raw.githubusercontent.com/antononcube/MathematicaForPrediction/master/MonadicProgramming/MonadicStructuralBreaksFinder.m"];
];

If[ Length[DownValues[MonadicLatentSemanticAnalysis`LSAMonUnit]] == 0,
  Echo["MonadicLatentSemanticAnalysis.m", "Importing from GitHub:"];
  Import["https://raw.githubusercontent.com/antononcube/MathematicaForPrediction/master/MonadicProgramming/MonadicLatentSemanticAnalysis.m"];
];

If[ Length[DownValues[MonadicSparseMatrixRecommender`SMRMonUnit]] == 0,
  Echo["MonadicSparseMatrixRecommender.m", "Importing from GitHub:"];
  Import["https://raw.githubusercontent.com/antononcube/MathematicaForPrediction/master/MonadicProgramming/MonadicSparseMatrixRecommender.m"];
];

(*If[ Length[DownValues[MonadicEpidemiologyCompartmentalModeling`ECMMonUnit]] == 0,*)
(*  Echo["MonadicEpidemiologyCompartmentalModeling.m", "Importing from GitHub:"];*)
(*  Import["https://raw.githubusercontent.com/antononcube/SystemModeling/master/Projects/Coronavirus-propagation-dynamics/WL/MonadicEpidemiologyCompartmentalModeling.m"];*)
(*];*)

If[Length[DownValues[NLPTemplateEngineData`NLPTemplateEngineData]] == 0,
  Echo["NLPTemplateEngineData.m", "Importing from GitHub:"];
  Import["https://raw.githubusercontent.com/antononcube/NLP-Template-Engine/main/Packages/WL/NLPTemplateEngineData.m"];
];


(***********************************************************)
(* Package definition                                      *)
(***********************************************************)

BeginPackage["NLPTemplateEngine`"];
(* Exported symbols added here with SymbolName::usage *)

GetRawAnswers::usage = "GetRawAnswers[wfSpec, spec, opts] \
finds probability-scored answers of parameters questions for the computational workflow template wfSpec \
over the computational specification spec.";

GetAnswers::usage = "GetAnswers[wfSpec, spec, opts] \
finds precise answers of parameters questions for the computational workflow template wfSpec \
over the computational specification spec.";

Concretize::usage = "Concretize[ttype : (_String | Automatic), spec_String, opts] \
finds parameter values to fill-in the slots for the ttype template based on the natural language specification spec \
and creates corresponding executable expression. \
If ttype is Automatic then a dedicated classifier function used to guess the template type.";

ConvertCSVData::usage = "ConvertCSVData";

ConvertCSVDataForType::usage = "ConvertCSVDataForType";

Begin["`Private`"];

Needs["NLPTemplateEngineData`"];

(***********************************************************)
(* GetRawAnswers                                           *)
(***********************************************************)

Clear[GetRawAnswers];

GetRawAnswers::nwft =
    "The first argument is an unknown workflow type. The first argument is expected to be one of `1`.";

Options[GetRawAnswers] = Options[FindTextualAnswer];

GetRawAnswers[workflowTypeArg_String, command_String, nAnswers_Integer : 4, opts : OptionsPattern[]] :=
    Block[{workflowType = workflowTypeArg, aRes},

      workflowType = workflowType /. aShortcuts;

      If[! MemberQ[Values[aShortcuts], workflowType],
        Message[GetRawAnswers::nwft, Union[Keys[aShortcuts], Values[aShortcuts]]];
        Return[$Failed]
      ];

      aRes =
          Association@
              Map[# ->
                  FindTextualAnswer[command, #, nAnswers, {"String", "Probability"},
                    opts] &, Keys@aQuestions[workflowType]];

      Map[Association[Rule @@@ #] &, aRes]
    ];


(***********************************************************)
(* GetAnswers                                              *)
(***********************************************************)

ClearAll[TakeLargestKey];
TakeLargestKey[args__] := StringTrim@First@Keys@TakeLargest[args];

ClearAll[RemoveContextWords];
RemoveContextWords[s : (_String | {_String ..}), {} ] := s;
RemoveContextWords[s : (_String | {_String ..}), words : {_String..} ] :=
    StringTrim[StringReplace[ s, Thread[Thread[StringExpression[WordBoundary, words, WordBoundary]] -> ""] ]];

Clear[GetAnswers];
Options[GetAnswers] = Join[ Options[GetRawAnswers], {"RemoveByThreshold" -> True}];
GetAnswers[workflowTypeArg_String, command_String, nAnswers_Integer : 4, opts : OptionsPattern[]] :=
    Block[{workflowType = workflowTypeArg, aRes, aParameterQuestions, parVal},

      (*
       We have multiple questions for each parameter in order to capture relevant answers
       from different types of phrasings.
       We hope that the (1) multiplicity of questions and (2) passing threshold and redundant words per question
       would suffice to get correct answers (most of the time.)
      *)

      (*"Normalize" the specified workflow type with replacement rules.*)
      workflowType = workflowType /. aShortcuts;

      (*Get raw answers.*)
      (*For each question we get an association of scored answers. The answers are keys. *)
      aRes = GetRawAnswers[workflowType, command, nAnswers, FilterRules[{opts}, Options[GetRawAnswers]]];
      If[TrueQ[aRes === $Failed],
        Return[$Failed]
      ];

      (*Filter out candidates with too low probabilities.*)
      (*For each question apply the threshold filtering.*)
      If[ TrueQ[OptionValue[GetAnswers, "RemoveByThreshold"]],
        aRes =
            Association@
                KeyValueMap[
                  Function[{k, v},
                    k -> Select[v, # >= aQuestions[workflowType, k, "Threshold"] &]], aRes];
        aRes = Select[aRes, Length[#] > 0 &];
      ];

      (*Remove specified "redundant" words.*)
      (*For each question and each key/answer replace redundant words with empty string.*)
      aRes =
          Association@
              KeyValueMap[
                Function[{k, v},
                  k ->
                      KeySelect[
                        KeyMap[RemoveContextWords[#, Lookup[aQuestions[workflowType, k], "ContextWordsToRemove", {}]]&, v],
                        StringLength[#] > 0&
                      ]
                ], aRes];
      aRes = Select[aRes, Length[#] > 0 &];

      (*Group the questions per parameter.*)
      aParameterQuestions = GroupBy[aQuestions[workflowType], #["Parameter"] &, Keys];
      (*aParameterCandidateValues=Map[Merge[Values@KeyTake[aRes,#],Max]&, aParameterQuestions];*)

      (*For each parameter and each question of that parameter extract the top candidate parameter value and associated probability.*)
      aRes =
          Map[
            KeyValueMap[
              Function[{k, v},
                parVal =
                    Switch[
                      ToString[aQuestions[workflowType, k, "TypePattern"]],

                      "{_String..}",

                      Map["\"" <> # <> "\"" &,
                        Select[StringTrim[StringSplit[TakeLargestKey[v, 1], {",", "and"}]], StringLength[#] > 0 &]],

                      "{_?NumericQ..}" | "{_Integer..}",

                      ToExpression /@ Select[StringTrim[StringSplit[TakeLargestKey[v, 1], {",", "and"}]], StringLength[#] > 0&],

                      "_?NumericQ" | "_Integer",
                      ToExpression[TakeLargestKey[v, 1]],

                      "_?BooleanQ" | "(True|False)" | "(False|True)",
                      MemberQ[
                        If[KeyExistsQ[aQuestions[workflowType, k], "TrueValues"], aQuestions[workflowType, k, "TrueValues"], {"true", "false"}],
                        ToLowerCase[TakeLargestKey[v, 1]]
                      ],

                      _,
                      TakeLargestKey[v, 1]
                    ];
                parVal -> TakeLargest[v, 1][[1]]
              ],
              KeyTake[aRes, Flatten[{#}]]
            ] &,
            aParameterQuestions
          ];

      (*For each parameter take the parameter value candidate with the largest probability *)

      aRes = TakeLargestBy[#, #[[2]] &, 1][[1]] & /@ Select[aRes, Length[#] > 0 &];

      (*Drop the associated probabilities*)
      Keys /@ aRes
    ];


(***********************************************************)
(* Concretize                                              *)
(***********************************************************)

Clear[Concretize];

SyntaxInformation[Concretize] = {"ArgumentsPattern" -> {_, _., OptionsPattern[]}};

Options[Concretize] =
    Join[
      Options[GetAnswers],
      {"TargetLanguage" -> "WL", "AvoidMonads" -> False, "AssociationResult" -> False, "UserID" -> None}
    ];

Concretize::tlang = "The value of the option \"TargetLanguage\" is expected to be one of `1`.";
Concretize::aulang = "The automatic programming language detection failed. Continuing by using \"WL\".";
Concretize::nargs = "If one argument is given then the first argument is expected to be a string or a list of strings. \
If two arguments are given then the first argument is expected to be a classifier function or Automatic, \
and the second argument is expected to be a string or a list of strings.";

Concretize["Data"] := NLPTemplateEngineData`NLPTemplateEngineData["Standard"];

Concretize["Templates"] := Concretize["Data"]["Templates"];

Concretize["Questions"] := Concretize["Data"]["Questions"];

Concretize["Defaults"] := Concretize["Data"]["Defaults"];

Concretize["Shortcuts"] := Concretize["Data"]["Shortcuts"];

Concretize[ commands : ( _String | {_String..} ), opts : OptionsPattern[]] :=
    Concretize[Automatic, commands, opts];

Concretize[ sf : (Automatic | _ClassifierFunction | _String), commands : {_String..}, opts : OptionsPattern[]] :=
    Association @ Map[ # -> Concretize[sf, #, opts]&, commands];

Concretize[Automatic, command_String, opts : OptionsPattern[]] :=
    Block[{cf},

      If[Length[DownValues[ComputationalWorkflowTypeClassifier`GetComputationalWorkflowTypeClassifier]] == 0,
        Echo["ComputationalWorkflowTypeClassifier.m", "Importing from GitHub:"];
        Import["https://raw.githubusercontent.com/antononcube/NLP-Template-Engine/main/Packages/WL/ComputationalWorkflowTypeClassifier.m"];
      ];

      cf = ComputationalWorkflowTypeClassifier`GetComputationalWorkflowTypeClassifier[];

      If[ TrueQ[OptionValue[Concretize, "AvoidMonads"]],
        Concretize[ cf[command], command, opts],
        (*ELSE*)
        Concretize[ cf[command] /. {"Classification" -> "ClCon", "QuantileRegression" -> "QRMon"}, command, opts]
      ]
    ];

Concretize[cf_ClassifierFunction, command_String, opts : OptionsPattern[]] :=
    Concretize[ cf[command], command, opts];

Concretize[workflowTypeArg_String, command_String, opts : OptionsPattern[]] :=
    Block[{workflowType = workflowTypeArg, lsKnownLanguages, userID, lang, aRes, code, codeExpr},

      {aQuestions, aTemplates, aDefaults, aShortcuts} = Values @ KeyTake[ Concretize["Data"], {"Questions", "Templates", "Defaults", "Shortcuts"}];

      lsKnownLanguages = Union @ Flatten @ Values[ Keys /@ aTemplates ];

      (* User ID *)
      userID = OptionValue[Concretize, "UserID"];
      If[ MemberQ[{None, Automatic}, userID], userID = ""];
      userID = ToString[userID];

      (* Programming language *)
      lang = OptionValue[Concretize, "TargetLanguage"];
      If[ TrueQ[lang === Automatic],
        aRes = Join[aDefaults["ProgrammingEnvironment"], GetAnswers["ProgrammingEnvironment", command]];
        lang =
            Which[
              Length[StringCases[ aRes["Language"], WordBoundary ~~ ("WL" | "Mathematica") ~~ WordBoundary]] > 0, "WL",
              Length[StringCases[ aRes["Language"], WordBoundary ~~ ("R") ~~ WordBoundary]] > 0, "R",
              True,
              Message[Concretize::aulang];
              "WL"
            ]
      ];

      If[ TrueQ[StringQ[lang] && ToLowerCase[lang] == "mathematica"], lang = "WL"];

      If[ !StringQ[lang] || !MemberQ[ ToUpperCase[lsKnownLanguages], ToUpperCase[lang] ],
        Message[Concretize::tlang, Append[lsKnownLanguages, Automatic]];
        lang = "WL"
      ];

      workflowType = workflowType /. aShortcuts;

      aRes = GetAnswers[workflowType, command, FilterRules[{opts}, Options[GetAnswers]]];

      If[TrueQ[aRes === $Failed],
        Return[$Failed]
      ];

      code = Concretize["Templates"][workflowType][lang][Join[aDefaults[workflowType], aRes]];

      Which[
        lang == "WL",
        codeExpr = ToExpression["Hold[" <> code <> "]"],

        lang == "R",
        code =
            StringReplace[
              code,
              {
                WordBoundary ~~ "Automatic" ~~ WordBoundary -> "NULL",
                WordBoundary ~~ "True" ~~ WordBoundary -> "TRUE",
                WordBoundary ~~ "False" ~~ WordBoundary -> "FALSE",
                "{" ~~ x : (Except[Characters["{}"]]..) ~~ "}" :> "c(" <> x <> ")"
              }];
        codeExpr = "parse( text = '" <> code <> "')",

        True,
        codeExpr = code
      ];

      If[ TrueQ[OptionValue[Concretize, "AssociationResult"]],
        <|
          "CODE" -> code,
          "USERID" -> userID,
          "DSLTARGET" -> lang <> "::" <> workflowType,
          "DSL" -> workflowType,
          "DSLFUNCTION" -> With[{wf = workflowType, l = lang, am = TrueQ[OptionValue[Concretize, "AvoidMonads"]]},
            ToString[Concretize[wf, #,
              "TargetLanguage" -> l,
              "AvoidMonads" -> am,
              "AssociationResult" -> True]&]
          ]
        |>,
        (*ELSE*)
        codeExpr
      ]
    ];

Concretize[___] :=
    Block[{},
      Message[Concretize::nargs];
      $Failed
    ];


(***********************************************************)
(* Introspection data preparation functions                *)
(***********************************************************)

Clear[ToWorkflowTemplate];
ToWorkflowTemplate[spec_String] := Concretize["Templates"][spec]["WL"][Concretize["Defaults"][spec]];
ToWorkflowTemplate[x_] := x;

Clear[SplitWorkflowType];
SplitWorkflowType[name_String] := StringRiffle[StringCases[name, CharacterRange["A", "Z"] ~~ (CharacterRange["a", "z"] ..)]];
SplitWorkflowType[name_String] := StringRiffle[{StringReplace[name, "Mon" -> ""], "monad"}] /; StringMatchQ[name, __ ~~ "Mon"];
SplitWorkflowType["ClCon"] := "Classification monad";


(***********************************************************)
(* Introspection data                                      *)
(***********************************************************)

lsWorkflowTypes = Keys[Concretize["Templates"]];
txtWorkflowTypes = StringRiffle[lsWorkflowTypes, ", "];
txtSQASDescription1 = "The current specialized Question Answering System (QAS) has the workflow types " <> txtWorkflowTypes <> ".";
txtSQASDescription1 =
    txtSQASDescription1 <> "\nThe known workflow types are " <> txtWorkflowTypes <> ".";
txtSQASDescription1 =
    txtSQASDescription1 <> "\nThe implemented workflow template types are " <> txtWorkflowTypes <> ".";
txtSQASDescription1 =
    txtSQASDescription1 <> "\nThe number of implemented workflow templates is " <> ToString[Length@lsWorkflowTypes] <> ".";
txtSQASDescription1 =
    txtSQASDescription1 <> "\nThere are " <> ToString[Length@lsWorkflowTypes] <> " workflows.";
txtSQASDescription1 =
    txtSQASDescription1 <> "\nThere are " <> ToString[Length@lsWorkflowTypes] <> " templates per programming language.";

txtSQASDescription2 =
    Map["The template for " <> # <> " is: WorkflowTemplate-" <> # <> "." &, Keys[Concretize["Templates"]]];

txtSQASDescription2 =
    Join[
      txtSQASDescription2,
      Map["The template for " <> SplitWorkflowType[#] <> " is: WorkflowTemplate-" <> # <> "." &, Keys[Concretize["Templates"]]]
    ];

txtSQASDescription2 =
    Join[
      txtSQASDescription2,
      Map["The " <> SplitWorkflowType[#] <> " workflow template is: WorkflowTemplate-" <> # <> "." &, Keys[Concretize["Templates"]]]
    ];

txtSQASDescription2 =
    Join[
      txtSQASDescription2,
      StringReplace[Select[txtSQASDescription2, Length[StringCases[#, "LatentSemanticAnalysis"]] > 0 &], WhitespaceCharacter ~~ "LatentSemanticAnalysis" ~~ WhitespaceCharacter -> " LSAMon "],
      StringReplace[Select[txtSQASDescription2, Length[StringCases[#, "Recommendations"]] > 0 &], WhitespaceCharacter ~~ "Recommendations" ~~ WhitespaceCharacter -> " SMRMon "]
    ];

txtSQASDescription2 = StringRiffle[Union[txtSQASDescription2], "\n"];

txtSQASDescription = StringJoin[txtSQASDescription1, "\n", txtSQASDescription2];


(***********************************************************)
(* Concretize continued                                    *)
(***********************************************************)

Concretize["Introspection", query_String, opts : OptionsPattern[]] :=
    Block[{res},
      res = FindTextualAnswer[txtSQASDescription, query, FilterRules[{opts}, Options[FindTextualAnswer]]];
      res =
          StringReplace[
            res,
            "WorkflowTemplate-" ~~ (x : (LetterCharacter..)) ~~ WordBoundary :> Concretize["Templates"][x]["WL"][Concretize["Defaults"][x]]
          ];
      res
    ];


(***********************************************************)
(* Convert CSV data into associations                      *)
(***********************************************************)

Clear[ConvertCSVData];

ConvertCSVData::cnames = "The first argument is expected to be a dataset with column names `1`.";

ConvertCSVData[ dsTESpecs_Dataset ] :=
    Block[{lsExpectedColumnNames},

      (* Check correctness of the dataset. *)
      lsExpectedColumnNames = {"DataType", "WorkflowType", "Group", "Key", "Value"};
      If[ Length[Intersection[Normal@Keys@First@dsTESpecs, lsExpectedColumnNames]] <= Length[lsExpectedColumnNames],
        Message[ConvertCSVData::cnames, ToString[lsExpectedColumnNames]];
        Return[$Failed]
      ];

      Association @ Map[ # -> ConvertCSVDataForType[ dsTESpecs, #]&, {"Questions", "Templates", "Defaults", "Shortcuts"}]
    ];


Clear[ConvertCSVDataForType];

ConvertCSVDataForType[ dsTESpecs_Dataset, type : ("Questions" | "Templates") ] :=
    Block[{dsQuery, aRes},

      dsQuery = dsTESpecs[Select[#DataType == type&]];
      dsQuery = Normal[dsQuery[Values]];
      aRes = ResourceFunction["AssociationKeyDeflatten"][  Map[ Most[#] -> Last[#]&, dsQuery] ];

      aRes[type]
    ];

End[];

EndPackage[];