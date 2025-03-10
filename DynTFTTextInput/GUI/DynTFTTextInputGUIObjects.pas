//Generated by DynTFTCodeGen.


unit DynTFTTextInputGUIObjects;

{$IFNDEF IsMCU}
  {$DEFINE IsDesktop}
{$ENDIF}

{$IFDEF IsDesktop}
interface
{$ENDIF}

uses
  DynTFTTypes, DynTFTConsts,

//<DynTFTComponents>
  DynTFTButton,
  //DynTFTArrowButton,
  //DynTFTPanel,
  DynTFTCheckBox,
  //DynTFTScrollBar,
  //DynTFTItems,
  //DynTFTListBox,
  DynTFTLabel,
  //DynTFTRadioButton,
  //DynTFTRadioGroup,
  //DynTFTTabButton,
  //DynTFTPageControl,
  DynTFTEdit,
  DynTFTKeyButton,
  DynTFTVirtualKeyboard,
  //DynTFTComboBox,
  //DynTFTTrackBar,
  //DynTFTProgressBar,
  DynTFTMessageBox,
  //DynTFTVirtualTable,
  DynTFTVirtualKeyboardX2
//<EndOfDynTFTComponents> - Do not remove or modify this line!


  {$I DynTFTGUIAdditionalUnits.inc}
  ;


// Project name: DynTFTTextInput.dyntftcg //Do not delete or modify this line!

var
  btnLoad: PDynTFTButton;
  btnUnload: PDynTFTButton;
  btnCreateKeyboard: PDynTFTButton;
  chkPass: PDynTFTCheckBox;
  chkVKX2: PDynTFTCheckBox;
  edtInput: PDynTFTEdit;
  edtData1: PDynTFTEdit;
  edtData2: PDynTFTEdit;
  lblData1: PDynTFTLabel;
  lblData2: PDynTFTLabel;


const
  DummyConst = 0; //generated because there is no PerInstanceInitConstant.
  {$IFDEF RTTIREG}
      CAllCreatedBinComponents: array[0..0] of ^PDynTFTBaseComponent = (nil);  // No binary component with global variable.
  {$ENDIF} // RTTIREG

implementation

end.
