unit untPesquisa;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error,
  FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async,
  FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client, Vcl.Grids,
  Vcl.DBGrids, Data.FMTBcd, Data.SqlExpr, Vcl.ImgList, acAlphaImageList,
  Vcl.ComCtrls, Vcl.StdCtrls, Vcl.Buttons, sBitBtn, sToolBar, Vcl.ToolWin,
  acCoolBar, Vcl.Menus, cxButtons, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore, dxSkinBlack,
  dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom,
  dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy,
  dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian,
  dxSkinLiquidSky, dxSkinLondonLiquidSky, dxSkinMcSkin, dxSkinMetropolis,
  dxSkinMetropolisDark, dxSkinMoneyTwins, dxSkinOffice2007Black,
  dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink,
  dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue,
  dxSkinOffice2010Silver, dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray,
  dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic,
  dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust,
  dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinsDefaultPainters, untQueryType,
  dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue, cxStyles,
  dxSkinscxPCPainter, cxCustomData, cxFilter, cxData, cxDataStorage,
  cxNavigator, Data.DB, cxDBData, cxClasses, cxGridLevel, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid, cxTextEdit,
  cxMaskEdit, cxDropDownEdit, cxGroupBox, sSkinProvider, sSkinManager, sEdit,
  sComboBox, sSpeedButton, Vcl.ExtCtrls, sPanel, acPageScroller, sPageControl,
  untShowSQL, sCheckBox;

type
  TOnEnterEvent = procedure(Sender: TObject) of object;

  TfrmPesquisa = class(TForm)
    cxgbDados: TcxGroupBox;
    cxStyleRepository: TcxStyleRepository;
    HeaderNegrito: TcxStyle;
    sAlphaImageList1: TsAlphaImageList;
    ImgList_Multi16: TsAlphaImageList;
    ImgList_MultiState: TsAlphaImageList;
    ImageList32: TsAlphaImageList;
    ImageList16: TsAlphaImageList;
    cxgDados: TcxGrid;
    cxgdbtvDados: TcxGridDBTableView;
    cxglDados: TcxGridLevel;
    sSkinProvider1: TsSkinProvider;
    edtDescricao: TsEdit;
    cbCampos: TsComboBox;
    spToolButtons: TsPanel;
    btnFechar: TsSpeedButton;
    btnSelecionar: TsSpeedButton;
    ssbSeparador: TsSpeedButton;
    sSpeedButton3: TsSpeedButton;
    sPanel6: TsPanel;
    scbDesconsiderarAcentuacao: TsCheckBox;
    sSkinManager1: TsSkinManager;
    scbPesquisaAvancada: TsCheckBox;
    cbOperadorComparativo: TsComboBox;
    edtDescricao2: TsEdit;
    procedure FormShow(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
    procedure cxgDadosEnter(Sender: TObject);
    procedure btnSelecionarClick(Sender: TObject);
    procedure sPageScrollerResize(Sender: TObject);
    procedure cxgdbtvDadosKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure cxgdbtvDadosDblClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure scbPesquisaAvancadaClick(Sender: TObject);
    procedure cbOperadorComparativoChange(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    { Private declarations }
    FOnEnter: TOnEnterEvent;
    FResultado: TModalResult;
  public
    { Public declarations }
    property OnEnter: TOnEnterEvent read FOnEnter write FOnEnter;
    property Resultado: TModalResult read FResultado write FResultado;
  end;

var
  frmPesquisa: TfrmPesquisa;

implementation

{$R *.dfm}

uses
  Clipbrd, untSearcher;

procedure TfrmPesquisa.btnSelecionarClick(Sender: TObject);
begin
  Resultado := mrOk;
  Close;
end;

procedure TfrmPesquisa.cxgdbtvDadosDblClick(Sender: TObject);
begin
  Resultado := mrOk;
  Close;
end;

procedure TfrmPesquisa.cxgdbtvDadosKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then begin
    Resultado := mrOk;
    Close;
  end;

  if (Shift = [ssCtrl]) and (Key = Ord('C')) then begin
    Clipboard.AsText := cxgdbtvDados.DataController.DataSource.DataSet.FieldByName(
      TcxGridDbColumn(cxgdbtvDados.Controller.FocusedColumn).DataBinding.FieldName).AsString;
  end;
end;

procedure TfrmPesquisa.cbOperadorComparativoChange(Sender: TObject);
begin
  scbPesquisaAvancadaClick(Sender);
end;

procedure TfrmPesquisa.cxgDadosEnter(Sender: TObject);
begin
  if Assigned(FOnEnter) then
    FOnEnter(Self);
end;

procedure TfrmPesquisa.FormCreate(Sender: TObject);
begin
  edtDescricao.Height := 22;
end;

procedure TfrmPesquisa.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  tmpFrmShowSQL: TFrmShowSQL;
begin
  if (Shift = [ssCtrl]) and (Key = Ord('0')) then begin
    tmpFrmShowSQL := TFrmShowSQL.Create(Self);
    tmpFrmShowSQL.Query := TQueryType(cxgdbtvDados.DataController.DataSource.DataSet);
    tmpFrmShowSQL.ShowModal;
  end;

  if Key = VK_ESCAPE then
    btnFecharClick(Sender);
end;

procedure TfrmPesquisa.FormResize(Sender: TObject);
begin
  if scbPesquisaAvancada.Checked then begin
    if cbOperadorComparativo.Items[cbOperadorComparativo.ItemIndex] = OperadorComparativoNomes[Integer(ocEntre)] then begin
      edtDescricao.Width := Round((cxgbDados.Width - (cbOperadorComparativo.Left + cbOperadorComparativo.Width + 17)) / 2);
      edtDescricao2.Left := edtDescricao.Left + edtDescricao.Width + 6;
      edtDescricao2.Width := cxgbDados.Width - (cbOperadorComparativo.Left + cbOperadorComparativo.Width + 12) - edtDescricao.Width - 5;
    end;
  end
end;

procedure TfrmPesquisa.FormShow(Sender: TObject);
var
  i: Integer;
  Key: Word;
begin
  Key := 13;

  for i := 0 to cxgdbtvDados.ColumnCount - 1 do
    cxgdbtvDados.Columns[i].Styles.Header := HeaderNegrito;

  if cxgdbtvDados.DataController.DataSet.RecordCount > 0 then
    cxgDados.SetFocus
  else
    edtDescricao.SetFocus;
end;

procedure TfrmPesquisa.scbPesquisaAvancadaClick(Sender: TObject);
begin
  if scbPesquisaAvancada.Checked then begin
    cbOperadorComparativo.Visible := True;
    edtDescricao.Left := cbOperadorComparativo.Left + cbOperadorComparativo.Width + 6;

    if cbOperadorComparativo.Items[cbOperadorComparativo.ItemIndex] = OperadorComparativoNomes[Integer(ocEntre)] then begin
      edtDescricao2.Visible := True;
      edtDescricao.Width := Round((cxgbDados.Width - (cbOperadorComparativo.Left + cbOperadorComparativo.Width + 17)) / 2);
      edtDescricao2.Left := edtDescricao.Left + edtDescricao.Width + 6;
      edtDescricao2.Width := cxgbDados.Width - (cbOperadorComparativo.Left + cbOperadorComparativo.Width + 12) - edtDescricao.Width - 5;
    end else begin
      edtDescricao2.Visible := False;
      edtDescricao.Width := cxgbDados.Width - (cbOperadorComparativo.Left + cbOperadorComparativo.Width + 11);
    end;
  end else begin
    edtDescricao2.Visible := False;
    edtDescricao.Width := cxgbDados.Width - (cbCampos.Left + cbCampos.Width + 11);
    edtDescricao.Left := 178;
    cbOperadorComparativo.Visible := False;
  end;
end;

procedure TfrmPesquisa.sPageScrollerResize(Sender: TObject);
begin
  ssbSeparador.Width := Width - 187;
end;

procedure TfrmPesquisa.btnFecharClick(Sender: TObject);
begin
  Resultado := mrNone;
  Close;
end;

end.
