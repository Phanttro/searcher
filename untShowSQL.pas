unit untShowSQL;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, sLabel, sScrollBox, sFrameBar, Vcl.ExtCtrls, sSplitter,
  Vcl.StdActns, System.Actions, Vcl.ActnList, Vcl.Menus, sSkinProvider,
  sSkinManager, acTitleBar, acAlphaHints, Vcl.ImgList, acAlphaImageList,
  acImage, Vcl.Buttons, sSpeedButton, sPanel, acPageScroller, Vcl.ComCtrls,
  sPageControl, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, Vcl.Grids, Vcl.DBGrids, FireDAC.UI.Intf, untQueryType,
  FireDAC.VCLUI.Wait, FireDAC.Comp.UI, sEdit, sGroupBox, sCheckBox,
  cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxStyles,
  dxSkinsCore, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel,
  dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle,
  dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast,
  dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinLondonLiquidSky,
  dxSkinMcSkin, dxSkinMetropolis, dxSkinMetropolisDark, dxSkinMoneyTwins,
  dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green,
  dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black,
  dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven,
  dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver,
  dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld,
  dxSkinsDefaultPainters, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint,
  dxSkinXmas2008Blue, dxSkinscxPCPainter, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, cxNavigator, cxDBData, cxGridLevel, cxClasses,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxGrid, cxTextEdit;

type
  TfrmShowSQL = class(TForm)
    pcCadastro: TsPageControl;
    tsPrincipal: TsTabSheet;
    sPageScroller: TsPageScroller;
    PanelToolButtons: TsPanel;
    btnFechar: TsSpeedButton;
    btnAjuda: TsSpeedButton;
    btnSalvar: TsSpeedButton;
    sSpeedButton3: TsSpeedButton;
    sPanel6: TsPanel;
    PanelContainer: TsPanel;
    gbGeral: TsGroupBox;
    pnlCabecalho: TsPanel;
    lblDescricaoCabecalho: TsLabelFX;
    btnImprimir: TsSpeedButton;
    sSpeedButton12: TsSpeedButton;
    sdDados: TSaveDialog;
    spcDados: TsPageControl;
    stsText: TsTabSheet;
    Memo: TRichEdit;
    stsExecute: TsTabSheet;
    cxgdbtvExecute: TcxGridDBTableView;
    cxglExecute: TcxGridLevel;
    cxgExecute: TcxGrid;
    dsExecute: TDataSource;
    ImageList32: TsAlphaImageList;
    sSkinManager1: TsSkinManager;
    stsView: TsTabSheet;
    cxView: TcxGrid;
    cxgdbtvView: TcxGridDBTableView;
    cxglView: TcxGridLevel;
    dsView: TDataSource;
    procedure btnFecharClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure stsExecuteShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure stsViewShow(Sender: TObject);
  protected
    procedure LimparControles;
  private
    FQuery: TQueryType;
    FqryExecute: TQueryType;
    { Private declarations }
  public
    property Query: TQueryType read FQuery write FQuery;
    { Public declarations }
  end;

var
  frmShowSQL: TfrmShowSQL;

procedure ShowSQL(AQuery: TQueryType);

implementation

{$R *.dfm}

uses
  System.IOUtils, untFuncoes;

procedure ShowSQL(AQuery: TQueryType);
begin
  frmShowSQL := TfrmShowSQL.Create(nil);
  frmShowSQL.Query := AQuery;
  frmShowSQL.ShowModal;
end;

procedure TfrmShowSQL.btnFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmShowSQL.LimparControles();
var
  i: Integer;
begin
  for i := 0 to ComponentCount - 1 do begin
    if (Components[i] is TCustomEdit) then
      TCustomEdit(Components[i]).Clear;

    if (Components[i] is TsCheckBox) then
      TsCheckBox(Components[i]).Checked := False;
  end;
end;

procedure TfrmShowSQL.stsExecuteShow(Sender: TObject);
var
  i: Integer;
  cxGridDBColumn: TCxGridDBColumn;
begin
  if (Self.FQuery.Text <> EmptyStr) then begin
    FqryExecute.Close;
    FqryExecute.Connection := Self.FQuery.Connection;
    FqryExecute.SQL.Clear;
    FqryExecute.SQL.AddStrings(Memo.Lines);

    {for i := 0 to Pred(Self.FQuery.ParamCount) do
      qryExecute.ParamByName(Self.FQuery.Params.ParamByPosition(i).Name).Value := Self.FQuery.Params.ParamByPosition(i).Value;}

    FqryExecute.Open;
    cxgdbtvExecute.ClearItems;

    for i := 0 to Pred(FqryExecute.FieldCount) do begin
      cxGridDBColumn := cxgdbtvExecute.CreateColumn;
      cxGridDBColumn.DataBinding.FieldName := FqryExecute.Fields.Fields[i].FieldName;
      cxGridDBColumn.Caption := FqryExecute.Fields.Fields[i].FieldName;
      cxGridDBColumn.PropertiesClassName := 'TcxTextEditProperties';
      TcxTextEditProperties(cxGridDBColumn.Properties).ReadOnly := True;
    end;
  end;
end;

procedure TfrmShowSQL.stsViewShow(Sender: TObject);
var
  i: Integer;
  cxGridDBColumn: TCxGridDBColumn;
begin
  cxgdbtvView.ClearItems;

  if Self.FQuery.Active then begin
    for i := 0 to Pred(FQuery.FieldCount) do begin
      cxGridDBColumn := cxgdbtvView.CreateColumn;
      cxGridDBColumn.DataBinding.FieldName := FQuery.Fields.Fields[i].FieldName;
      cxGridDBColumn.Caption := FQuery.Fields.Fields[i].FieldName;
      cxGridDBColumn.PropertiesClassName := 'TcxTextEditProperties';
      TcxTextEditProperties(cxGridDBColumn.Properties).ReadOnly := True;
    end;
  end;
end;

procedure TfrmShowSQL.btnSalvarClick(Sender: TObject);
var
  i, j: Integer;
  sLinha: string;
  slTemp: TStrings;
begin
  if spcDados.ActivePage = stsText then begin
    sdDados.InitialDir := TPath.GetDocumentsPath;
    sdDados.Filter := 'SQL file|*.sql|Text file|*.txt';
    sdDados.DefaultExt := 'sql';
    sdDados.FilterIndex := 1;

    if sdDados.Execute then begin
      Memo.Lines.SaveToFile(sdDados.FileName);
    end;
  end else begin
    slTemp := TStringList.Create;

    for i := 0 to Pred(cxgdbtvExecute.Controller.SelectedRowCount) do begin
      sLinha := EmptyStr;

      for j := 0 to Pred(cxgdbtvExecute.Controller.SelectedColumnCount) do
        sLinha := sLinha + VarToStr(cxgdbtvExecute.Controller.SelectedRows[i].Values[cxgdbtvExecute.Controller.SelectedColumns[j].Index]) + '  ';

      sLinha := Trim(sLinha);
      slTemp.Add(sLinha);
    end;

    sdDados.Filter := 'Text file|*.txt';
    sdDados.DefaultExt := 'txt';
    sdDados.FilterIndex := 0;

    if sdDados.Execute then begin
      slTemp.SaveToFile(sdDados.FileName);
    end;
  end;
end;

procedure TfrmShowSQL.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FqryExecute.Close;
end;

procedure TfrmShowSQL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_RETURN)  then
    SelectNext(ActiveControl, True, True);
end;

procedure TfrmShowSQL.FormShow(Sender: TObject);
var
  i: Integer;
  tmpStrings: TStrings;
  tmpValor: string;
begin
  dsView.DataSet := Query;
  lblDescricaoCabecalho.Caption := TFunc.ifthen(FQuery.Name <> EmptyStr,  FQuery.Name, FQuery.ClassName);
  gbGeral.Caption := TFunc.ifthen(FQuery.Name <> EmptyStr,  FQuery.Name + '.', EmptyStr) + 'SQL';

  tmpStrings := TStringList.Create;
  tmpStrings.AddStrings(FQuery.SQL);
  spcDados.ActivePageIndex := 0;

  if FQuery.ParamCount > 0 then begin
    for i := 0 to Pred(FQuery.ParamCount) do begin
      tmpValor := VarToStr(FQuery.Params.ParamValues[FQuery.Params.ParamByPosition(i).Name]);

      if FQuery.Params.ParamByPosition(i).DataType in [ftString, ftMemo, ftFmtMemo,
                                                       ftFixedChar, ftWideString,
                                                       ftFixedWideChar, ftWideMemo] then
        tmpValor := QuotedStr(tmpValor);

      tmpStrings.Text := StringReplace(tmpStrings.Text, ':' + FQuery.Params.ParamByPosition(i).Name,
                                       tmpValor, [rfReplaceAll, rfIgnoreCase]);
    end;
  end;

  Memo.Lines.Clear;
  Memo.Lines.AddStrings(tmpStrings);

  if not Assigned(FqryExecute) then
    FqryExecute := TQueryType.Create(Self);

  FqryExecute.Connection := Query.Connection;
  dsExecute.DataSet := FqryExecute;
end;

end.
