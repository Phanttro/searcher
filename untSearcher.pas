unit untSearcher;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxGrid, Vcl.DBGrids, Data.DB, Data.SQLExpr, Winapi.Windows, Vcl.StdCtrls,
  Vcl.Controls, Forms, untPesquisa, Dialogs, sPanel, sEdit, sBitBtn, cxEdit,
  cxCheckBox, sCheckBox, sCurrencyEdit, acAlphaImageList, Vcl.CheckLst,
  Vcl.ExtCtrls, sRadioButton, cxGroupBox, sCheckListBox, StrUtils, Vcl.Graphics,
  cxCurrencyEdit, System.Variants, cxDropDownEdit, untConstantes, untQueryType,
  System.Generics.Collections, cxCustomData, untFuncoes;

const
  OperadorLogicoNomes: array [0..2] of string =('', 'AND', 'OR');

  DatabaseNames: array [0..15] of string = ('Advantage Database Server',
    'Adaptive Server Anywhere', 'IBM Database 2', 'DataSnap', 'Firebird',
    'InterBase', 'InterBase Lite', 'Informix', 'MS Access', 'MS SQL', 'My SQL',
    'Open Database Connectivity', 'Oracle', 'PostgreSQL', 'SQLite', 'dbExpress 4');

  DatabaseDrivers: array [0..15] of string = ('ADS', 'ASA', 'DB2', 'DS', 'FB', 'IB',
    'IBLite', 'Infx', 'MSAcc', 'MSSQL', 'MySQL', 'ODBC', 'Ora', 'PG', 'SQLite', 'TDBX');

  OperadorComparativoNomes: array [0..11] of string = ('Igual', 'Diferente', 'Maior',
    'Maior ou igual', 'Menor', 'Menor ou igual', 'Come�a com', 'Termina com',
    'Entre', 'Nulo', 'N�o nulo', 'Em');

type
  TListaQuery = TObjectList<TQueryType>;

  TDetailExpanding = procedure(ADataController: TcxCustomDataController; ARecordIndex: Integer; var AAllow: Boolean) of object;

  TOperadorLogico = (olNenhum, olAnd, olOr);

  TFeatBase = (ftAdvantageDatabaseServer, ftAdaptiveServerAnywhere, ftIBMDatabase2,
    ftDataSnap, ftFireBird, ftInterBase, ftInterBaseLite, ftInformix, ftMSAccess,
    ftMSSQL, ftMySQL, ftOpenDatabaseConnectivity, ftOracle, ftPostgreSQL, ftSQLite,
    ftdbExpress4);

  TOperadorComparativo = (ocIgual, ocDiferente, ocMaior, ocMaiorOuIgual, ocMenor,
    ocMenorOuIgual, ocComecaCom, ocTerminaCom, ocEntre, ocNulo, ocNaoNulo, ocEm);
  TOperadoresComparativos = set of TOperadorComparativo;

  TWhere = class;

  TWhereCollection = class(TOwnedCollection)
  private
    FOnEvent: TNotifyEvent;
    FDataSet: TDataSet;
    FName: TComponentName;
    FCompOwner: TComponent;
    procedure DoEvent;
    function GetDataSet: TDataSet;
    function GetName: TComponentName;
    property OnEvent: TNotifyEvent read fOnEvent write fOnEvent;
    function GetItem(Index: Integer): TWhere;
    procedure SetItem(Index: Integer; const Value: TWhere);
  protected
    function GetOwner: TPersistent; override;
  public
    constructor Create(AOwner: TComponent);
    destructor Destroy;
    property Name: TComponentName read GetName write FName;
    procedure Update(Item: TCollectionItem); override;
    property DataSet: TDataSet read GetDataSet write FDataSet;
    property Items[Index: Integer]: TWhere read GetItem write SetItem;
    property Owner: TComponent read FCompOwner write FCompOwner;
  end;

  TWhere = class(TCollectionItem)
  private
    FName: String;
    FCaption: String;
    FIndice: Integer;
    FField: TField;
    FOwner: TPersistent;
    FFieldName: string;
    FValorAPesquisar: string;
    FValorAPesquisar2: string;
    FOperadorComparativo: TOperadorComparativo;
    FDesconsiderarAcentos: Boolean;
    FUtilizarUpperCase: Boolean;
    FUtilizarAspas: Boolean;
    FOperadorLogico: TOperadorLogico;
    FOperadorLogicoWC: TOperadorLogico;
    FWhere: TWhereCollection;
    FUtilizarNot: Boolean;
    FUtilizarNotWC: Boolean;
    function GetName: String;
    procedure SetName(const Value: String);
    function GetCaption: String;
    function GetDataSet: TDataSet;
    function GetField: TField;
    procedure SetUtilizarUpperCase(const Value: Boolean);
    function GetWhere: TWhereCollection;
  protected
    function GetDisplayName: String; override;
  public
    constructor Create(AOwner: TCollection); overload; override;
    constructor Create(AFieldName: String; AValorAPesquisar: Variant;
      AOperadorComparativo: TOperadorComparativo); overload;
    destructor Destroy;
    function GetCampos: TWhereCollection;
    property DataSet: TDataSet read GetDataSet;
    property Owner: TPersistent read FOwner write FOwner;
  published
    property Caption: String read GetCaption write FCaption;
    property Name: String read GetName write SetName;
    property FieldName: string read FFieldName write FFieldName;
    property Field: TField read GetField write FField;
    property Index;
    property ValorAPesquisar: string read FValorAPesquisar write FValorAPesquisar;
    property ValorAPesquisar2: string read FValorAPesquisar2 write FValorAPesquisar2;
    property OperadorComparativo: TOperadorComparativo read FOperadorComparativo write FOperadorComparativo default ocComecacom;
    property DesconsiderarAcentos: Boolean read FDesconsiderarAcentos write FDesconsiderarAcentos default True;
    property UtilizarUpperCase: Boolean read FUtilizarUpperCase write SetUtilizarUpperCase default True;
    property UtilizarAspas: Boolean read FUtilizarAspas write FUtilizarAspas default True;
    property OperadorLogico: TOperadorLogico read FOperadorLogico write FOperadorLogico default olAnd;
    property OperadorLogicoWC: TOperadorLogico read FOperadorLogicoWC write FOperadorLogicoWC default olAnd;
    property UtilizarNot: Boolean read FUtilizarNot write FUtilizarNot default False;
    property UtilizarNotWC: Boolean read FUtilizarNotWC write FUtilizarNotWC default False;
    property Where: TWhereCollection read GetWhere write FWhere;
  end;

  TCampoPesquisa = class;

  TCamposPesquisa = class(TOwnedCollection)
  private
    FOnEvent: TNotifyEvent;
    FDataSet: TDataSet;
    FName: TComponentName;
    FCompOwner: TComponent;
    procedure DoEvent;
    function GetTotalWidth: Integer;
    function GetDataSet: TDataSet;
    function GetName: TComponentName;
    property OnEvent: TNotifyEvent read fOnEvent write fOnEvent;
    function GetItem(Index: Integer): TCampoPesquisa;
    procedure SetItem(Index: Integer; const Value: TCampoPesquisa);
  protected
    function GetOwner: TPersistent; override;
  public
    constructor Create(AOwner: TComponent);
    destructor Destroy;
    property Name: TComponentName read GetName write FName;
    procedure Update(Item: TCollectionItem); override;
    function GetItemPeloNome(ANome: string): TCampoPesquisa;
    property DataSet: TDataSet read GetDataSet write FDataSet;
    property Items[Index: Integer]: TCampoPesquisa read GetItem write SetItem;
    property TotalWidth: Integer read GetTotalWidth;
    property Owner: TComponent read FCompOwner write FCompOwner;
  end;

  TCampoPesquisa = class(TCollectionItem)
  private
    FName: String;
    FSQL: TStrings;
    FCaption: String;
    FIndice: Integer;
    FDefault: Boolean;
    FWidth: Integer;
    FAlternateCaption: string;
    FKeyField: Boolean;
    FDescriptionField: Boolean;
    FControleVisual: TControl;
    FMostrarNaGride: Boolean;
    FMostrarNaPesquisa: Boolean;
    FField: TField;
    FProperties: TcxCustomEditProperties;
    FPropertiesClass: TcxCustomEditPropertiesClass;
    FPropertiesValue: TcxCustomEditProperties;
    FStringsProperties: TStrings;
    FOwner: TPersistent;
    FOrderBy: string;
    FControleVisualClassName: string;
    FWhereAdicional: TWhereCollection;
    FFieldName: string;
    FOnGetDisplayText: TcxGridGetDisplayTextEvent;
    FTipoCombo: TipoCombo;
    FOperadoresComparativos: TOperadoresComparativos;
    FValorAPesquisar: string;
    FOperadorComparativo: TOperadorComparativo;
    FValorAPesquisar2: string;
    FDesconsiderarAcentos: Boolean;
    FWhere: TWhereCollection;
    FWhereItem: TWhere;
    FTable: string;
    function GetSQL: TStrings;
    procedure SetSQL(const Value: TStrings);
    procedure SetDefault(const Value: Boolean);
    function GetName: String;
    procedure SetName(const Value: String);
    procedure SetDescriptionField(const Value: Boolean);
    function GetControleVisual: TControl;
    procedure SetControleVisual(const Value: TControl);
    function GetCaption: String;
    function GetDataSet: TDataSet;
    function GetField: TField;
    procedure SetProperties(const Value: TcxCustomEditProperties);
    procedure SetPropertiesClass(const Value: TcxCustomEditPropertiesClass);
    procedure CreateProperties;
    procedure DestroyProperties;
    procedure RecreateProperties;
    function GetProperties: TcxCustomEditProperties;
    function GetPropertiesClassName: string;
    procedure SetPropertiesClassName(const Value: string);
    function GetStringsProperties: TStrings;
    procedure SetStringsProperties(const Value: TStrings);
    procedure SetOrderBy(const Value: string);
    function GetControleVisualClassName: string;
    procedure SetControleVisualClassName(const Value: string);
    function GetWhereAdicional: TWhereCollection;
    function GetTipoCombo: TipoCombo;
    procedure SetTipoCombo(const Value: TipoCombo);
    procedure SetOperadoresComparativos(const Value: TOperadoresComparativos);
    function GetWhereItem: TWhere;
  protected
    function GetDisplayName: String; override;
    procedure PropertiesValueChanged;
    function GetPropertiesValue: TcxCustomEditProperties;
  public
    constructor Create(AOwner: TCollection); override;
    destructor Destroy;
    function GetCampos: TCamposPesquisa;
    property DataSet: TDataSet read GetDataSet;
    property PropertiesClass: TcxCustomEditPropertiesClass read FPropertiesClass write SetPropertiesClass;
    property Owner: TPersistent read FOwner write FOwner;
  published
    property Caption: String read GetCaption write FCaption;
    property AlternateCaption: string read FAlternateCaption write FAlternateCaption;
    property Name: String read GetName write SetName;
    property SQL: TStrings read GetSQL write SetSQL;
    property Default: Boolean read FDefault write SetDefault default False;
    property Table: string read FTable write FTable;
    property FieldName: string read FFieldName write FFieldName;
    property Field: TField read GetField write FField;
    property Width: Integer read FWidth write FWidth;
    property KeyField: Boolean read FKeyField write FKeyField default False;
    property DescriptionField: Boolean read FDescriptionField write SetDescriptionField default False;
    property ControleVisualClassName: string read GetControleVisualClassName write SetControleVisualClassName;
    property ControleVisual: TControl read GetControleVisual write SetControleVisual;
    property MostrarNaPesquisa: Boolean read FMostrarNaPesquisa write FMostrarNaPesquisa default True;
    property MostrarNaGride: Boolean read FMostrarNaGride write FMostrarNaGride default True;
    property OperadorComparativo: TOperadorComparativo read FOperadorComparativo write FOperadorComparativo default ocComecacom;
    property OrderBy: string read FOrderBy write SetOrderBy;
    property PropertiesClassName: string read GetPropertiesClassName write SetPropertiesClassName;
    property Properties: TcxCustomEditProperties read GetProperties write SetProperties;
    property StringsProperties: TStrings read GetStringsProperties write SetStringsProperties;
    property WhereAdicional: TWhereCollection read GetWhereAdicional write FWhereAdicional;
    property Index;
    property OnGetDisplayText: TcxGridGetDisplayTextEvent read FOnGetDisplayText write FOnGetDisplayText;
    property TipoCombo: TipoCombo read GetTipoCombo write SetTipoCombo default tpNenhum;
    property OperadoresComparativos: TOperadoresComparativos read FOperadoresComparativos write SetOperadoresComparativos
      default [ocIgual, ocDiferente, ocMaior, ocMaiorOuIgual, ocMenor, ocMenorOuIgual, ocComecaCom, ocTerminaCom, ocEntre, ocNulo, ocNaoNulo, ocEm];
    property Where: TWhereCollection read FWhere write FWhere;
    property WhereItem: TWhere read GetWhereItem write FWhereItem;
  end;

  TSearcherClass = class of TSearcher;

  TSearcher = class(TComponent)
  private
    { Private declarations }
    FSQL: TStrings;
    FQuerySize: LongInt;
    FNomePesquisa: String;
    FFrmPesquisa: TFrmPesquisa;
    FCamposPesquisa: TCamposPesquisa;
    FQuery: TQueryType;
    FKeyField: string;
    FDescriptionField: string;
    FDataSource: TDataSource;
    FMaxWidth: Integer;
    FMinWidth: Integer;
    FHeight: Integer;
    FMostrarPesquisa: Boolean;
    FDepoisPesquisar: TNotifyEvent;
    FMsgNaoEncontrado: string;
    FMsgEncontrado: string;
    FOrderBy: string;
    FWhereAdicional: TWhereCollection;
    FPressionouEnter: Boolean;
    procedure OnEnter(Sender: TObject);
    procedure OnKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure cbCamposChange(Sender: TObject);
    procedure PrepararForm;
    procedure MontarPesquisa;
    procedure SetDataSource(const Value: TDataSource);
    function GetFrmPesquisa: TFrmPesquisa;
    function GetDataSource: TDataSource;
    function GetCamposPesquisa: TCamposPesquisa;
    function GetSQL: TStrings;
    function GetQuery: TQueryType;
    procedure SetOrderBy(const Value: string);
    function GravarQueryData: Boolean;
    function GeTWhereAdicional: TWhereCollection;
    property FrmPesquisa: TFrmPesquisa read GetFrmPesquisa;
  protected
    procedure LoadQuery(Stream: TStream); virtual;
    procedure SaveQuery(Stream: TStream); virtual;
    procedure LoadQuerySize(Stream: TStream); virtual;
    procedure SaveQuerySize(Stream: TStream); virtual;
    procedure DefineProperties(Filer: TFiler); override;
    procedure OnColumnHeaderClick(Sender: TcxGridTableView; AColumn: TcxGridColumn);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property KeyField: string read FKeyField write FKeyField;
    property DescriptionField: string read FDescriptionField write FDescriptionField;
    procedure CopyToClipboard;
    property SQL: TStrings read GetSQL write FSQL;
    function ShowPesquisar(AIndice: Integer): Boolean; overload;
    function ShowPesquisar(ANomeCampoPesquisa: string): Boolean; overload;
    function Pesquisar(AIndice: Integer): Boolean; overload;
    function Pesquisar(ANomeCampoPesquisa: string): Boolean; overload;
  published
    property NomePesquisa: String read FNomePesquisa write FNomePesquisa;
    property Query: TQueryType read GetQuery write FQuery;
    property DataSource: TDataSource read GetDataSource write FDataSource;
    property CamposPesquisa: TCamposPesquisa read GetCamposPesquisa write FCamposPesquisa;
    property MinWidth: Integer read FMinWidth write FMinWidth default 765;
    property MaxWidth: Integer read FMaxWidth write FMaxWidth default 1428;
    property Height: Integer read FHeight write FHeight default 472;
    property MsgEncontrado: string read FMsgEncontrado write FMsgEncontrado;
    property MsgNaoEncontrado: string read FMsgNaoEncontrado write FMsgNaoEncontrado;
    property OrderBy: string read FOrderBy write SetOrderBy;
    property WhereAdicional: TWhereCollection read GeTWhereAdicional write FWhereAdicional;
    property OnDespoisPesquisar: TNotifyEvent read FDepoisPesquisar write FDepoisPesquisar;
  end;

  TmEdit = class(TsEdit)
  private
    FDisplayFormat: string;
    function GetHeight: Integer;
    procedure SetHeight(const Value: Integer);
    function GetLeft: Integer;
    procedure SetLeft(const Value: Integer);
    function GetTop: Integer;
    procedure SetTop(const Value: Integer);
    procedure SetWidth(const Value: Integer);
    function GetWidth: Integer;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function AsInteger: Integer;
    function Value: Double;
  published
    property DisplayFormat: string read FDisplayFormat write FDisplayFormat;
    property Height: Integer read GetHeight write SetHeight;
    property Left: Integer read GetLeft write SetLeft;
    property Top: Integer read GetTop write SetTop;
    property Width: Integer read GetWidth write SetWidth;
  end;

  TmBitBtn = class(TsBitBtn)
  private
    function GetLeft: Integer;
    procedure SetLeft(const Value: Integer);
    function GetHeight: Integer;
    procedure SetHeight(const Value: Integer);
    function GetWidth: Integer;
    procedure SetWidth(const Value: Integer);
    function GetTop: Integer;
    procedure SetTop(const Value: Integer);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Height: Integer read GetHeight write SetHeight;
    property Left: Integer read GetLeft write SetLeft;
    property Top: Integer read GetTop write SetTop;
    property Width: Integer read GetWidth write SetWidth;
  end;

  TButtonSearcher = class(TsPanel)
  private
    { Private declarations }
    FSearcher: TSearcher;
    FSearcherSize: LongInt;
    FEdtCodigo: TmEdit;
    FBtnPesquisa: TmBitBtn;
    FEdtDescricao: TmEdit;
    FImageList: TsAlphaImageList;
    FShowMsgAviso: Boolean;
    FImageListName: string;
    procedure SetSize(Sender: TObject);
    //procedure SetLeft(const Value: Integer);
    //procedure SetTop(const Value: Integer);
    procedure OnKeyPress(Sender: TObject; var Key: Char);
    procedure OnKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure OnChange(Sender: TObject);
    procedure OnExit(Sender: TObject);
    function GetImageList: TsAlphaImageList;
    function GetPngImageString: string;
    function GetEnabled: Boolean;
    procedure SetEnabled(const Value: Boolean);
    function GetSearcher: TSearcher;
    function GravarSearcherData: Boolean;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure LoadSearcher(Stream: TStream); virtual;
    procedure SaveSearcher(Stream: TStream); virtual;
    procedure LoadSearcherSize(Stream: TStream); virtual;
    procedure SaveSearcherSize(Stream: TStream); virtual;
    procedure DefineProperties(Filer: TFiler); override;
    property PngImageString: string read GetPngImageString;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure BtnPesquisaClick(Sender: TObject);
    function Query: TQueryType;
    procedure Clear;
  published
    property ImageList: TsAlphaImageList read GetImageList write FImageList;
    property EdtCodigo: TmEdit read FEdtCodigo;
    property BtnPesquisa: TmBitBtn read FBtnPesquisa;
    property EdtDescricao: TmEdit read FEdtDescricao;
    property Enabled: Boolean read GetEnabled write SetEnabled default True;
    property Searcher: TSearcher read GetSearcher write FSearcher;
    property ShowMsgAviso: Boolean read FShowMsgAviso write FShowMsgAviso default True;
  end;

  TGerarSQL = class
  private
    class var FDatabaseDrive: string;
    class function GetBatabaseName: string; static;
    class procedure SetDatabaseDrive(const Value: string); static;
    class function GetIndexDatabaseDrive(ADatabaseDrive: string): Integer;
    class function GerarWhereAdaptiveServerAnywhere(
      AWhere: TWhere): string;
    class function GerarWhereAdvantageDatabaseServer(
      AWhere: TWhere): string;
    class function GerarWhereDataSnap(AWhere: TWhere): string;
    class function GerarWheredbExpress4(AWhere: TWhere): string;
    class function GerarWhereFireBird(AWhere: TWhere; ACount: Integer = 1): string;
    class function GerarWhereIBMDatabase2(AWhere: TWhere): string;
    class function GerarWhereInformix(AWhere: TWhere): string;
    class function GerarWhereInterBase(AWhere: TWhere): string;
    class function GerarWhereInterBaseLite(AWhere: TWhere): string;
    class function GerarWhereMSAccess(AWhere: TWhere): string;
    class function GerarWhereMSSQL(AWhere: TWhere): string;
    class function GerarWhereMySQL(AWhere: TWhere): string;
    class function GerarWhereOpenDatabaseConnectivity(
      AWhere: TWhere): string;
    class function GerarWhereOracle(AWhere: TWhere; ACount: Integer = 1): string;
    class function GerarWherePostgreSQL(AWhere: TWhere): string;
    class function GerarWhereSQLite(AWhere: TWhere): string;
    class function GetDatabase: TFeatBase; static;
  public
    class property Database: TFeatBase read GetDatabase;
    class property DatabaseName: string read GetBatabaseName;
    class property DatabaseDrive: string read FDatabaseDrive write SetDatabaseDrive;
    class function GerarWhere(AWhere: TWhere): string;
  end;

procedure RegistrarClasses;

implementation

uses
  PngImage, Vcl.ImgList, Clipbrd, System.TypInfo;

procedure RegistrarClasses;
var
  i: Integer;
begin
  RegisterClasses([TQueryType, TSearcher, TAuxComponent, TFDAutoIncField]);

  for i := 0 to Length(DefaultFieldClasses) - 1 do begin
    if DefaultFieldClasses[TFieldType(i)] <> nil then
      RegisterClasses([DefaultFieldClasses[TFieldType(i)]]);
  end;

  TFunc.TraduzirCxComponentes;
end;

{ TSearcher }

function TSearcher.GravarQueryData: Boolean;
begin
  Result := (Self.FQuery.Owner = Self);
end;

procedure TSearcher.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);

  Filer.DefineBinaryProperty('QuerySize', LoadQuerySize, SaveQuerySize, True);
  Filer.DefineBinaryProperty('QueryData', LoadQuery, SaveQuery, True);
end;

destructor TSearcher.Destroy;
var
  i: Integer;
begin
  FreeAndNil(Self.FFrmPesquisa);

  if Self.FQuery.Owner = Self then
    FreeAndNil(Self.FQuery)
  else
    Self.FQuery := nil;

  if Self.FCamposPesquisa.Owner = Self then begin
    while Self.CamposPesquisa.Count > 0 do
      Self.CamposPesquisa.Delete(Self.CamposPesquisa.Count - 1);

    FreeAndNil(Self.FCamposPesquisa);
  end else
    Self.FCamposPesquisa := nil;

  Inherited Destroy;
end;

function TSearcher.GetCamposPesquisa: TCamposPesquisa;
begin
  if Self.FCamposPesquisa = nil then begin
    Self.FCamposPesquisa := TCamposPesquisa.Create(Self);
    Self.FCamposPesquisa.Name := 'cpDados';
  end;

  Self.FCamposPesquisa.DataSet := Self.Query;
  Result := Self.FCamposPesquisa;
end;

function TSearcher.GetDataSource: TDataSource;
var
  criar: Boolean;
  tmpForm: TForm;
  tmpDataSet: TDataSet;

  procedure PesquisaDataSource;
  var
    i, j: Integer;
  begin
    if Self.FDataSource = nil then
      Self.FDataSource := TDataSource(Self.FindComponent('dsDados'))
    else begin
      if Self.FDataSource.Owner is TSearcher then
        Self.FDataSource := TDataSource(Self.FindComponent('dsDados'));

      if Self.FDataSource = nil then begin
        for i := 0 to Pred(Self.ComponentCount) do begin
          if Self.Components[i] is TDataSource then begin

            if TDataSource(Self.Components[i]).Name = EmptyStr then begin
              j := 1;

              while tmpForm.FindComponent('DataSource' + IntToStr(j)) <> nil do
                Inc(j);

              TDataSource(Self.Components[i]).Name := 'DataSource' + IntToStr(j);
            end;

            Self.FDataSource := TDataSource(Self.Components[i]);
            Break;
          end;
        end;
      end;
    end;

    if Self.FDataSource = nil then
      criar := True;
  end;
begin
  criar := False;
  PesquisaDataSource;

  if criar then begin
    tmpForm := TFunc.GetFormPai(TControl(Self.Owner));

    if tmpForm.FindComponent('dsDados') <> nil then begin
      Self.FDataSource := TDataSource.Create(Self);
    end else begin
      Self.FDataSource := TDataSource.Create(Self);
      Self.FDataSource.Name := 'dsDados';
    end;
  end else if (Self.FDataSource.DataSet <> Self.Query) then begin
    tmpDataSet := Self.FDataSource.DataSet;
    FreeAndNil(tmpDataSet);
  end;

  Self.FDataSource.DataSet := Self.Query;
  Result := Self.FDataSource;
end;

function TSearcher.GetFrmPesquisa: TFrmPesquisa;
begin
  if not Assigned(Self.FFrmPesquisa) then begin
    Self.FFrmPesquisa := TFrmPesquisa.Create(Self);
    Self.FFrmPesquisa.Name := 'frmPesquisaDados';
  end;

  Result := Self.FFrmPesquisa;
end;

function TSearcher.GetQuery: TQueryType;
var
  i: Integer;
  tmpForm: TForm;
  criar: Boolean;

  procedure PesquisaQuery;
  var
    i: Integer;
  begin
    if Self.FQuery = nil then
      Self.FQuery := TQueryType(Self.FindComponent('qryDados'))
    else begin
      if Self.FQuery.Owner is TSearcher then begin
        Self.FQuery := TQueryType(Self.FindComponent('qryDados'));

        if Self.FQuery = nil then begin
          for i := 0 to Pred(Self.ComponentCount) do begin
            if Self.Components[i] is TQueryType then begin
              Self.FQuery := TQueryType(Self.Components[i]);
              Break;
            end;
          end;
        end;
      end;
    end;

    if Self.FQuery = nil then
      criar := True;
  end;
begin
  criar := False;
  PesquisaQuery;

  if criar then begin
    tmpForm := TFunc.GetFormPai(TControl(Self.Owner));

    if tmpForm.FindComponent('qryDados') <> nil then begin
      Self.FQuery := TQueryType.Create(Self);
    end else begin
      Self.FQuery := TQueryType.Create(Self);
      Self.FQuery.Name := 'qryDados';
    end;


    for i := 0 to Pred(tmpForm.ComponentCount) do begin
      if tmpForm.Components[i] is TFDCustomConnection then begin
        Self.FQuery.Connection := TFDCustomConnection(tmpForm.Components[i]);
        tmpForm := nil;
        Break;
      end;
    end;
  end;

  Result := Self.FQuery;
end;

function TSearcher.GetSQL: TStrings;
begin
  if Self.FSQL = nil then
    Self.FSQL := TStringList.Create;

  Result := Self.FSQL;
end;

function TSearcher.GeTWhereAdicional: TWhereCollection;
begin
  if Self.FWhereAdicional = nil then begin
    Self.FWhereAdicional := TWhereCollection.Create(Self);
    Self.FWhereAdicional.Name := 'waDados';
  end;

  Self.FWhereAdicional.DataSet := Self.Query;
  Result := Self.FWhereAdicional;
end;

procedure TSearcher.LoadQuery(Stream: TStream);
var
  i: Integer;
  sTemp: string;
  tmpFieldOri,
  tmpFieldDes: TField;
  tmpForm: TForm;
begin
  if Self.FQuerySize > 0 then begin
    while Self.FQuery.Fields.Count > 0 do begin
      tmpFieldOri := Self.FQuery.Fields.Fields[Self.FQuery.Fields.Count - 1];
      Self.FQuery.Owner.RemoveComponent(tmpFieldOri);
      Self.FQuery.Fields.Remove(tmpFieldOri);
      FreeAndNil(tmpFieldOri);
    end;

    FreeAndNil(Self.FQuery);

    SetString(sTemp, PChar(nil), Self.FQuerySize);
    Stream.Read(PChar(sTemp)^, Self.FQuerySize * SizeOf('A'));
    Self.FQuery := TQueryType(TFunc.StringToComponent(sTemp));

    tmpForm := TFunc.GetFormPai(TControl(Self.Owner));

    if tmpForm.FindComponent(Self.FQuery.Name) <> nil then begin
      i := 1;

      while tmpForm.FindComponent('QueryType' + IntToStr(i)) <> nil do
        Inc(i);

      Self.FQuery.Name := 'QueryType' + IntToStr(i);
    end;

    Self.InsertComponent(Self.FQuery);

    if Self.FQuery.Campos.Count > 0 then begin
      for i := 0 to Pred(Self.FQuery.Campos.Count) do begin
        tmpFieldOri := TField(TFunc.StringToComponent(Self.FQuery.Campos.Items[i]));
        tmpFieldDes := TField(TComponentClass(tmpFieldOri.ClassType).Create(Self));
        TFunc.CloneComponent(tmpFieldOri, tmpFieldDes, False);
        tmpFieldDes.DataSet := Self.FQuery;
        Self.InsertComponent(tmpFieldDes);
      end;

      Self.FQuery.Campos.Clear;
    end;

    Self.SQL.Text := Self.FQuery.SQL.Text;
  end;
end;

procedure TSearcher.LoadQuerySize(Stream: TStream);
begin
  Stream.Read(Self.FQuerySize, SizeOf(Self.FQuerySize));
end;

procedure TSearcher.MontarPesquisa;
var
  i: Integer;
  sWhere,
  sSQLTemp,
  tmpDescoAcentos: string;
  removeuAnd: Boolean;
  tmpCampoPesquisa: TCampoPesquisa;
begin
  Self.Query.Close;
  Self.Query.SQL.Clear;
  Self.Query.SQL.AddStrings(Self.SQL);

  tmpCampoPesquisa := TCampoPesquisa(Self.FrmPesquisa.cbCampos.Items.Objects[Self.FrmPesquisa.cbCampos.ItemIndex]);

  if (Self.FWhereAdicional.Count > 0) or
     (tmpCampoPesquisa.WhereAdicional.Count > 0) or
     (tmpCampoPesquisa.Where.Count > 0) then
    Self.Query.SQL.Add('WHERE')
  else if (tmpCampoPesquisa.WhereItem <> nil) then begin
    if (tmpCampoPesquisa.WhereItem.ValorAPesquisar <> EmptyStr) then
      Self.Query.SQL.Add('WHERE');
  end;

  removeuAnd := False;

  if (Self.FWhereAdicional.Count > 0) then begin
    for i := 0 to Pred(Self.FWhereAdicional.Count) do begin
      if (i = 0) then begin
        removeuAnd := True;
        Self.FWhereAdicional.Items[i].OperadorLogico := olNenhum;
      end;

      sWhere := TGerarSQL.GerarWhere(Self.FWhereAdicional.Items[i]);

      if (Trim(sWhere) <> EmptyStr) then
        Self.Query.SQL.Add(sWhere);
    end;
  end;

  if (tmpCampoPesquisa.WhereAdicional.Count > 0) then begin
    for i := 0 to Pred(tmpCampoPesquisa.WhereAdicional.Count) do begin
      if (i = 0) and (not removeuAnd) then begin
        removeuAnd := True;
        tmpCampoPesquisa.WhereAdicional.Items[i].OperadorLogico := olNenhum;
      end;

      sWhere := TGerarSQL.GerarWhere(tmpCampoPesquisa.WhereAdicional.Items[i]);

      if (Trim(sWhere) <> EmptyStr) then
        Self.Query.SQL.Add(sWhere);
    end;
  end;

  if (tmpCampoPesquisa.Where.Count > 0) then begin
    for i := 0 to Pred(tmpCampoPesquisa.Where.Count) do begin
      if (i = 0) and (not removeuAnd) then begin
        removeuAnd := True;
        tmpCampoPesquisa.Where.Items[i].OperadorLogico := olNenhum;
      end;

      sWhere := TGerarSQL.GerarWhere(tmpCampoPesquisa.Where.Items[i]);

      if (Trim(sWhere) <> EmptyStr) then
        Self.Query.SQL.Add(sWhere);
    end;
  end;

  if (tmpCampoPesquisa.WhereItem <> nil) then begin
    if (tmpCampoPesquisa.WhereItem.ValorAPesquisar <> EmptyStr) then begin
      if (not removeuAnd) then begin
        removeuAnd := True;
        tmpCampoPesquisa.WhereItem.OperadorLogico := olNenhum;
      end;

      sWhere := TGerarSQL.GerarWhere(tmpCampoPesquisa.WhereItem);

      if (Trim(sWhere) <> EmptyStr) then
        Self.Query.SQL.Add(sWhere);
    end;
  end;

  {if AValorAPesquisar = EmptyStr then
    AValorAPesquisar := tmpCampoPesquisa.ValorAPesquisar;}

  {if AValorAPesquisar <> EmptyStr then begin
    tmpDescoAcentos := TFunc.ifthen(Self.FrmPesquisa.scbDesconsiderarAcentuacao.Checked, '''S''', '''N''');
    Self.Query.SQL.Add('WHERE');

    if Trim(Self.FWhereAdicional.Text) <> EmptyStr then
      Self.Query.SQL.Add('  ' + Copy(Self.FWhereAdicional.Text, 1, Length(Self.FWhereAdicional.Text) - 2) + ' AND');

    if tmpCampoPesquisa.SQL.Text <> EmptyStr then begin
      if Pos(':NOME_CAMPO', tmpCampoPesquisa.SQL.Text) > 0 then begin
        sSQLTemp := StringReplace(tmpCampoPesquisa.SQL.Text, ':NOME_CAMPO', tmpCampoPesquisa.FieldName, [rfReplaceAll]);
        Self.Query.SQL.Add(Copy(sSQLTemp, 1, Length(sSQLTemp) - 2));
      end else
        Self.Query.SQL.Add('  ' + Copy(tmpCampoPesquisa.SQL.Text, 1, Length(tmpCampoPesquisa.SQL.Text) - 2));
    end else begin
      if (Self.FrmPesquisa.scbDesconsiderarAcentuacao.Checked) then begin
        if (TGerarSQL.Database = ftFireBird) then
          Self.Query.SQL.Add('  (SELECT RETORNO FROM RETIRAR_ACENTO('
                             + tmpCampoPesquisa.FieldName
                             + ')) LIKE  (SELECT RETORNO FROM RETIRAR_ACENTO(:PARAM1)) || '
                             + QuotedStr('%')
                             )
        else
          Self.Query.SQL.Add('  ANSIUPPERCASE(' + tmpCampoPesquisa.FieldName + ') LIKE   ANSIUPPERCASE(:PARAM1) || ' + QuotedStr('%'));
      end else
        Self.Query.SQL.Add(tmpCampoPesquisa.FieldName + ' LIKE :PARAM1 || ' + QuotedStr('%'));
    end;


    Self.Query.Params.ParamByName('PARAM1').Value := AValorAPesquisar;
  end else if Trim(Self.FWhereAdicional.Text) <> EmptyStr then begin
    Self.Query.SQL.Add('WHERE');
    Self.Query.SQL.Add('  ' + Copy(Self.FWhereAdicional.Text, 1, Length(Self.FWhereAdicional.Text) - 2));
  end;}

  {if Trim(tmpCampoPesquisa.WhereAdicional.Text) <> EmptyStr then
    Self.Query.SQL.Add('  AND ' + Copy(tmpCampoPesquisa.WhereAdicional.Text, 1, Length(tmpCampoPesquisa.WhereAdicional.Text) - 2));}

  {if (High(Self.FParametrosPesquisa) = High(Self.FTiposParamPesquisa)) and (High(Self.FTiposParamPesquisa) = High(Self.FValorParamPesquisa)) then begin
    for i := 0 to High(Self.FParametrosPesquisa) do begin
      if Assigned(Self.Query.Params.FindParam(Self.FParametrosPesquisa[i])) then
        Self.Query.Params.ParamByName(Self.FParametrosPesquisa[i]).Value := Self.FValorParamPesquisa[i];
    end;
  end;}

  if tmpCampoPesquisa.OrderBy <> EmptyStr then begin
    Self.Query.SQL.Add('ORDER BY');
    Self.Query.SQL.Add('  ' + StringReplace(tmpCampoPesquisa.OrderBy, ';', ',', [rfReplaceAll]));
  end else if Self.OrderBy <> EmptyStr then begin
    Self.Query.SQL.Add('ORDER BY');
    Self.Query.SQL.Add('  ' + StringReplace(Self.OrderBy, ';', ',', [rfReplaceAll]));
  end;
end;

procedure TSearcher.cbCamposChange(Sender: TObject);
var
  tmpOperadorComparativo: TOperadorComparativo;
  tmpCampoPesquisa: TCampoPesquisa;
begin
  Self.FrmPesquisa.cbOperadorComparativo.Clear;

  if (Self.FrmPesquisa.cbCampos.ItemIndex > -1) then begin
    tmpCampoPesquisa := TCampoPesquisa(Self.FrmPesquisa.cbCampos.Items.Objects[Self.FrmPesquisa.cbCampos.ItemIndex]);

    for tmpOperadorComparativo := Low(TOperadorComparativo) to High(TOperadorComparativo) do begin
      if tmpOperadorComparativo in tmpCampoPesquisa.OperadoresComparativos then
        Self.FrmPesquisa.cbOperadorComparativo.Items.Add(OperadorComparativoNomes[Integer(tmpOperadorComparativo)]);
    end;

    Self.FrmPesquisa.cbOperadorComparativo.ItemIndex := Self.FrmPesquisa.cbOperadorComparativo.Items.IndexOf(OperadorComparativoNomes[Integer(tmpCampoPesquisa.OperadorComparativo)]);
  end else begin
    Self.FrmPesquisa.cbOperadorComparativo.Items.Add(OperadorComparativoNomes[Integer(ocComecaCom)]);
    Self.FrmPesquisa.cbOperadorComparativo.ItemIndex := 0;
  end;
end;

procedure TSearcher.CopyToClipboard;
begin
  Clipboard.AsText := TFunc.ComponentToString(Self);
end;

constructor TSearcher.Create(AOwner: TComponent);
var
  tmpForm: TForm;
begin
  inherited Create(AOwner);

  tmpForm := TFunc.GetFormPai(TControl(AOwner));

  if tmpForm.FindComponent('qryDados') <> nil then begin
    Self.FQuery := TQueryType.Create(Self)
  end else begin
    Self.FQuery := TQueryType.Create(Self);
    Self.FQuery.Name := 'qryDados';
  end;

  if tmpForm.FindComponent('dsDados') <> nil then begin
    Self.FDataSource := TDataSource.Create(Self);
  end else begin
    Self.FDataSource := TDataSource.Create(Self);
    Self.FDataSource.Name := 'dsDados';
  end;

  Self.FDataSource.DataSet := Self.FQuery;

  Self.FCamposPesquisa := TCamposPesquisa.Create(Self);
  Self.FCamposPesquisa.Name := 'cpDados';
  Self.FCamposPesquisa.DataSet := Self.FQuery;

  Self.FWhereAdicional := TWhereCollection.Create(Self);
  Self.FWhereAdicional.Name := 'waDados';
  Self.FWhereAdicional.DataSet := Self.FQuery;

  Self.FHeight := 472;
  Self.FMinWidth := 765;
  Self.FMaxWidth := 1428;
  Self.FMostrarPesquisa := False;
  Self.FPressionouEnter := False;
end;

procedure TSearcher.OnColumnHeaderClick(Sender: TcxGridTableView;
  AColumn: TcxGridColumn);
var
  i: Integer;
begin
  for i := 0 to Pred(Self.FFrmPesquisa.cbCampos.Items.Count) do begin
    if TCxGridDBColumn(AColumn).DataBinding.FieldName = TCampoPesquisa(Self.FFrmPesquisa.cbCampos.Items.Objects[i]).FieldName then begin
      Self.FFrmPesquisa.cbCampos.ItemIndex := i;
      Break;
    end;
  end;
end;

procedure TSearcher.OnEnter(Sender: TObject);
begin
  if not FPressionouEnter then begin
    MontarPesquisa;
    Self.Query.Open;
  end;
end;

procedure TSearcher.OnKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  where: TWhere;
begin
  if (Key = VK_RETURN) then begin
    FPressionouEnter := True;

    if (Sender = Self.FrmPesquisa.edtDescricao2) or (not Self.FrmPesquisa.edtDescricao2.Visible) then begin
      if ((Trim(Self.FrmPesquisa.edtDescricao.Text) <> EmptyStr) or
          (Trim(Self.FrmPesquisa.edtDescricao2.Text) <> EmptyStr)) then begin
        TCampoPesquisa(Self.FrmPesquisa.cbCampos.Items.Objects[Self.FrmPesquisa.cbCampos.ItemIndex]).Where.Clear;
        where := TWhere.Create(TCampoPesquisa(Self.FrmPesquisa.cbCampos.Items.Objects[Self.FrmPesquisa.cbCampos.ItemIndex]).Where);
        where.FieldName := TCampoPesquisa(Self.FrmPesquisa.cbCampos.Items.Objects[Self.FrmPesquisa.cbCampos.ItemIndex]).Table +
          TCampoPesquisa(Self.FrmPesquisa.cbCampos.Items.Objects[Self.FrmPesquisa.cbCampos.ItemIndex]).FieldName;
        where.OperadorComparativo := TOperadorComparativo(Self.FrmPesquisa.cbOperadorComparativo.ItemIndex);
        where.ValorAPesquisar := Self.FrmPesquisa.edtDescricao.Text;
        where.ValorAPesquisar2 := Self.FrmPesquisa.edtDescricao2.Text;
        where.DesconsiderarAcentos := Self.FrmPesquisa.scbDesconsiderarAcentuacao.Checked;
      end;

      MontarPesquisa;
      TCampoPesquisa(Self.FrmPesquisa.cbCampos.Items.Objects[Self.FrmPesquisa.cbCampos.ItemIndex]).Where.Clear;
      Self.Query.Open;
      Self.FrmPesquisa.cxgDados.SetFocus;
    end;

    FPressionouEnter := False;
  end;
end;

function TSearcher.Pesquisar(AIndice: Integer): Boolean;
var
  i: Integer;
begin
  Result := False;
  PrepararForm;
  Self.FKeyField := EmptyStr;
  Self.FDescriptionField := EmptyStr;
  Self.FrmPesquisa.edtDescricao.Text := EmptyStr;
  Self.FrmPesquisa.cbCampos.ItemIndex := AIndice;
  MontarPesquisa;
  Self.Query.Open;

  if AIndice > -1 then
    Self.FrmPesquisa.cbCampos.ItemIndex := AIndice;

  if Self.FMostrarPesquisa then
    Self.FrmPesquisa.ShowModal
  else
    Self.FrmPesquisa.Resultado := mrOk;

  if Self.FrmPesquisa.Resultado = mrOk then begin
    if Self.Query.RecordCount > 0 then begin
      Self.FKeyField := EmptyStr;
      Self.FDescriptionField := EmptyStr;

      for i := 0 to Pred(Self.CamposPesquisa.Count) do begin
        if Self.CamposPesquisa.Items[i].KeyField then begin
          if Self.CamposPesquisa.Items[i].PropertiesClassName = 'TcxCurrencyEditProperties' then begin
            Self.FKeyField := Self.FKeyField + FormatFloat(TcxCurrencyEditProperties(Self.CamposPesquisa.Items[i].Properties).DisplayFormat,
                                                           Self.CamposPesquisa.Items[i].Field.AsFloat) + ' ';
          end else
            Self.FKeyField := Self.FKeyField + Self.CamposPesquisa.Items[i].Field.AsString + ' ';
        end;

        if Self.CamposPesquisa.Items[i].DescriptionField then
          Self.FDescriptionField := Self.FDescriptionField + Self.CamposPesquisa.Items[i].Field.AsString;
      end;

      Self.FKeyField := Trim(Self.FKeyField);

      for i := 0 to Pred(Self.CamposPesquisa.Count) do begin
        if Assigned(Self.CamposPesquisa.Items[i].ControleVisual) and Assigned(Self.CamposPesquisa.Items[i].Field) then begin
          if Self.CamposPesquisa.Items[i].ControleVisual is TsCheckListBox then begin
            TsCheckListBox(Self.CamposPesquisa.Items[i].ControleVisual).Items.Clear;
            TsCheckListBox(Self.CamposPesquisa.Items[i].ControleVisual).Items.AddStrings(Self.CamposPesquisa.Items[i].StringsProperties);
            TsCheckListBox(Self.CamposPesquisa.Items[i].ControleVisual).Checked[Self.CamposPesquisa.Items[i].Field.AsInteger] := True;
          end else if Self.CamposPesquisa.Items[i].ControleVisual is TCheckListBox then begin
            TCheckListBox(Self.CamposPesquisa.Items[i].ControleVisual).Items.Clear;
            TCheckListBox(Self.CamposPesquisa.Items[i].ControleVisual).Items.AddStrings(Self.CamposPesquisa.Items[i].StringsProperties);
            TCheckListBox(Self.CamposPesquisa.Items[i].ControleVisual).Checked[Self.CamposPesquisa.Items[i].Field.AsInteger] := True;
          end else if Self.CamposPesquisa.Items[i].ControleVisual is TsRadioButton then begin
            if Self.CamposPesquisa.Items[i].Properties <> nil then begin
              if Self.CamposPesquisa.Items[i].PropertiesClassName = 'TcxCheckBoxProperties' then begin
                TsRadioButton(Self.CamposPesquisa.Items[i].ControleVisual).Checked :=
                  TcxCheckBoxProperties(Self.CamposPesquisa.Items[i].Properties).ValueChecked = Self.CamposPesquisa.Items[i].Field.Value;
              end;
            end;
          end else if Self.CamposPesquisa.Items[i].ControleVisual is TRadioButton then begin
            if Self.CamposPesquisa.Items[i].Properties <> nil then begin
              if Self.CamposPesquisa.Items[i].PropertiesClassName = 'TcxCheckBoxProperties' then begin
                TRadioButton(Self.CamposPesquisa.Items[i].ControleVisual).Checked :=
                  TcxCheckBoxProperties(Self.CamposPesquisa.Items[i].Properties).ValueChecked = Self.CamposPesquisa.Items[i].Field.Value;
              end;
            end;
          end else if Self.CamposPesquisa.Items[i].ControleVisual is TsCurrencyEdit then
            TsCurrencyEdit(Self.CamposPesquisa.Items[i].ControleVisual).Value := Self.CamposPesquisa.Items[i].Field.AsFloat
          else if Self.CamposPesquisa.Items[i].ControleVisual is TGroupBox then
            TGroupBox(Self.CamposPesquisa.Items[i].ControleVisual).Caption := Self.CamposPesquisa.Items[i].Field.AsString
          else if Self.CamposPesquisa.Items[i].ControleVisual is TcxGroupBox then
            TcxGroupBox(Self.CamposPesquisa.Items[i].ControleVisual).Caption := Self.CamposPesquisa.Items[i].Field.AsString
          else if Self.CamposPesquisa.Items[i].ControleVisual is TCustomLabel then
            TCustomLabel(Self.CamposPesquisa.Items[i].ControleVisual).Caption := Self.CamposPesquisa.Items[i].Field.AsString
          else if Self.CamposPesquisa.Items[i].ControleVisual is TCustomRadioGroup then begin
            TRadioGroup(Self.CamposPesquisa.Items[i].ControleVisual).Items.Clear;
            TRadioGroup(Self.CamposPesquisa.Items[i].ControleVisual).Items.AddStrings(Self.CamposPesquisa.Items[i].StringsProperties);
            TRadioGroup(Self.CamposPesquisa.Items[i].ControleVisual).Buttons[Self.CamposPesquisa.Items[i].Field.AsInteger].Checked := True;
          end else if (Self.CamposPesquisa.Items[i].ControleVisual is TCustomComboBox) or
                      (Self.CamposPesquisa.Items[i].ControleVisual is TcxComboBox) then begin
            TComboBox(Self.CamposPesquisa.Items[i].ControleVisual).Items.Clear;
            TComboBox(Self.CamposPesquisa.Items[i].ControleVisual).Items.AddStrings(Self.CamposPesquisa.Items[i].StringsProperties);
            DictionaryTipo.TipoCombo := Self.CamposPesquisa.Items[i].TipoCombo;

            if DictionaryTipo.ContainsKey(Self.CamposPesquisa.Items[i].Field.AsString + IntToStr(Integer(DictionaryTipo.TipoCombo))) then
              TComboBox(Self.CamposPesquisa.Items[i].ControleVisual).ItemIndex :=
                TComboBox(Self.CamposPesquisa.Items[i].ControleVisual).Items.IndexOfObject(DictionaryTipo.Items[Self.CamposPesquisa.Items[i].Field.AsString + IntToStr(Integer(DictionaryTipo.TipoCombo))]);
          end else if Self.CamposPesquisa.Items[i].ControleVisual is TCustomCheckBox then begin
            if Self.CamposPesquisa.Items[i].Properties <> nil then begin
              if Self.CamposPesquisa.Items[i].PropertiesClassName = 'TcxCheckBoxProperties' then begin
                TsCheckBox(Self.CamposPesquisa.Items[i].ControleVisual).Checked :=
                  TcxCheckBoxProperties(Self.CamposPesquisa.Items[i].Properties).ValueChecked = Self.CamposPesquisa.Items[i].Field.Value;
              end;
            end;
          end else if Self.CamposPesquisa.Items[i].ControleVisual is TCustomEdit then begin
            if Self.CamposPesquisa.Items[i].PropertiesClassName = 'TcxCurrencyEditProperties' then
              TCustomEdit(Self.CamposPesquisa.Items[i].ControleVisual).Text := FormatFloat(TcxCurrencyEditProperties(Self.CamposPesquisa.Items[i].Properties).DisplayFormat,
                                                                                           Self.CamposPesquisa.Items[i].Field.AsFloat)
            else
              TCustomEdit(Self.CamposPesquisa.Items[i].ControleVisual).Text := Self.CamposPesquisa.Items[i].Field.AsString;
          end else if Self.CamposPesquisa.Items[i].ControleVisual is TCustomPanel then
            TPanel(Self.CamposPesquisa.Items[i].ControleVisual).Caption := Self.CamposPesquisa.Items[i].Field.AsString;
        end;
      end;

      if Assigned(FDepoisPesquisar) then
        FDepoisPesquisar(Self);

      Result := True;
    end;
  end;

  Self.FQuery.Close;

  if (TCampoPesquisa(Self.FrmPesquisa.cbCampos.Items.Objects[Self.FrmPesquisa.cbCampos.ItemIndex]).WhereItem <> nil) then
    TCampoPesquisa(Self.FrmPesquisa.cbCampos.Items.Objects[Self.FrmPesquisa.cbCampos.ItemIndex]).WhereItem := nil;

  FreeAndNil(FFrmPesquisa);
end;

function TSearcher.Pesquisar(ANomeCampoPesquisa: string): Boolean;
var
  i,
  tmpIndicePesquisa: Integer;
begin
  Result := False;
  tmpIndicePesquisa := -1;
  PrepararForm;

  for i := 0 to Pred(Self.GetCamposPesquisa.Count) do begin
    if Self.GetCamposPesquisa.Items[i].Name = ANomeCampoPesquisa then begin
      tmpIndicePesquisa := Self.FrmPesquisa.cbCampos.Items.IndexOfObject(Self.CamposPesquisa.Items[i]);
      Break;
    end;
  end;

  if tmpIndicePesquisa >= 0 then begin
    Result := Self.Pesquisar(tmpIndicePesquisa);
  end else
    TFunc.MsgDlg('Campo de pesquisa: ' + ANomeCampoPesquisa + ', n�o econtrado!', Self.FNomePesquisa);
end;

procedure TSearcher.PrepararForm;
var
  i, j,
  tmpHeigthBT,
  tmpTotalWidth: Integer;
  cxGridDBColumn: TCxGridDBColumn;
  tmpPosicaoBT: string;
  bDefault: Boolean;
begin
  tmpHeigthBT := TFunc.HeightBarraDeTarefas(tmpPosicaoBT);
  Self.FrmPesquisa.Height := Self.FHeight;
  Self.FrmPesquisa.Width := Self.FMinWidth;
  Self.FrmPesquisa.Top := TForm(Self.Owner).Top;

  if Self.FrmPesquisa.Top < TFunc.ifthen(tmpPosicaoBT = 'C', tmpHeigthBT, 0) then
    Self.FrmPesquisa.Top := TFunc.ifthen(tmpPosicaoBT = 'C', tmpHeigthBT, 0);

  if Self.FrmPesquisa.Top + FrmPesquisa.Height > Screen.Height - TFunc.ifthen(tmpPosicaoBT = 'B', tmpHeigthBT, 0) then
    Self.FrmPesquisa.Top := Screen.Height - Self.FrmPesquisa.Height - TFunc.ifthen(tmpPosicaoBT = 'B', tmpHeigthBT, 0);

  Self.FrmPesquisa.Caption := Self.NomePesquisa;
  Self.FrmPesquisa.edtDescricao.OnKeyDown := Self.OnKeyDown;
  Self.FrmPesquisa.edtDescricao2.OnKeyDown := Self.OnKeyDown;
  Self.FrmPesquisa.OnEnter := Self.OnEnter;
  Self.FrmPesquisa.cbCampos.Clear;
  Self.FrmPesquisa.cbCampos.OnChange := cbCamposChange;
  Self.FrmPesquisa.cxgdbtvDados.ClearItems;
  Self.FrmPesquisa.cxgdbtvDados.DataController.DataSource := Self.DataSource;
  Self.FrmPesquisa.cxgdbtvDados.OnColumnHeaderClick := Self.OnColumnHeaderClick;

  tmpTotalWidth := Self.CamposPesquisa.TotalWidth + 43;

  if tmpTotalWidth <= Self.FMinWidth then
    Self.FrmPesquisa.Width := Self.FMinWidth
  else if tmpTotalWidth <= Self.FMaxWidth then
    Self.FrmPesquisa.Width := tmpTotalWidth
  else
    Self.FrmPesquisa.Width := Self.FMaxWidth;

  if TForm(Self.Owner).Width > Self.FrmPesquisa.Width  then
    Self.FrmPesquisa.Left := TForm(Self.Owner).Left + Trunc(Abs(TForm(Self.Owner).Width - Self.FrmPesquisa.Width) / 2)
  else
    Self.FrmPesquisa.Left := TForm(Self.Owner).Left - Trunc(Abs(TForm(Self.Owner).Width - Self.FrmPesquisa.Width) / 2);

  if Self.FrmPesquisa.Left < TFunc.ifthen(tmpPosicaoBT = 'E', tmpHeigthBT, 0) then
    Self.FrmPesquisa.Left := TFunc.ifthen(tmpPosicaoBT = 'E', tmpHeigthBT, 0);

  if Self.FrmPesquisa.Left + Self.FrmPesquisa.Width > Screen.Width - TFunc.ifthen(tmpPosicaoBT = 'D', tmpHeigthBT, 0) then
    Self.FrmPesquisa.Left := Screen.Width - Self.FrmPesquisa.Width - TFunc.ifthen(tmpPosicaoBT = 'D', tmpHeigthBT, 0);

  bDefault := False;

  for i := 0 to Pred(Self.CamposPesquisa.Count) do begin
    if (Self.CamposPesquisa.Items[i].FieldName = EmptyStr) then begin
      TFunc.MsgDlg('N�o foi definido a propriedade "Field" para o campo' + #13 +
                   'de pesquisa: "' + Self.Name + '.' + Self.CamposPesquisa.Items[i].Name + '"', Self.Name);
      Abort;
    end;

    if Self.CamposPesquisa.Items[i].MostrarNaPesquisa then
      Self.FrmPesquisa.cbCampos.Items.AddObject(Self.CamposPesquisa.Items[i].Caption, Self.CamposPesquisa.Items[i]);

    Self.FrmPesquisa.scbPesquisaAvancada.Checked := False;

    if Self.CamposPesquisa.Items[i].Default then begin
      bDefault := True;
      Self.FrmPesquisa.cbCampos.ItemIndex := Self.FrmPesquisa.cbCampos.Items.IndexOfObject(Self.CamposPesquisa.Items[i]);
    end;

    if Self.CamposPesquisa.Items[i].MostrarNaGride then begin
      cxGridDBColumn := Self.FrmPesquisa.cxgdbtvDados.CreateColumn;
      cxGridDBColumn.DataBinding.FieldName := Self.CamposPesquisa.Items[i].FieldName;
      cxGridDBColumn.Caption := Self.CamposPesquisa.Items[i].Caption;
      cxGridDBColumn.Width := Self.CamposPesquisa.Items[i].Width;

      if Assigned(Self.CamposPesquisa.Items[i].OnGetDisplayText) then
        cxGridDBColumn.OnGetDisplayText := Self.CamposPesquisa.Items[i].OnGetDisplayText;

      if Self.CamposPesquisa.Items[i].Properties <> nil then begin
        cxGridDBColumn.PropertiesClassName := Self.CamposPesquisa.Items[i].PropertiesClassName;
        cxGridDBColumn.Properties.Assign(Self.CamposPesquisa.Items[i].Properties);
      end;
    end;
  end;

  if Self.FrmPesquisa.cbCampos.Items.Count = 0 then begin
    TFunc.MsgDlg('N�o foi informado campo(s) para pesquisa!');
    Abort;
  end;

  if (not bDefault) then
    Self.FrmPesquisa.cbCampos.ItemIndex := 0;

  cbCamposChange(Self.FrmPesquisa.cbOperadorComparativo);
end;

procedure TSearcher.SaveQuery(Stream: TStream);
var
  sTemp: string;
begin
  sTemp := TFunc.ComponentToString(Self.FQuery);
  Stream.Write(PChar(sTemp)^, Self.FQuerySize * SizeOf('A'));
end;

procedure TSearcher.SaveQuerySize(Stream: TStream);
var
  tmpSize: LongInt;
begin
  if GravarQueryData then
    tmpSize := Length(TFunc.ComponentToString(Self.FQuery))
  else
    tmpSize := 0;

  Self.FQuerySize :=  tmpSize;
  Stream.Write(Self.FQuerySize, Sizeof(Self.FQuerySize));
end;

procedure TSearcher.SetDataSource(const Value: TDataSource);
begin
  Self.FDataSource := Value;

  if Assigned(Self.FDataSource) then begin
    Self.FDataSource.DataSet := Self.Query;
  end;
end;

procedure TSearcher.SetOrderBy(const Value: string);
begin
  FOrderBy := Value;
end;

function TSearcher.ShowPesquisar(ANomeCampoPesquisa: string): Boolean;
begin
  Self.FMostrarPesquisa := True;
  Result := Pesquisar(ANomeCampoPesquisa);
  Self.FMostrarPesquisa := False;
end;

function TSearcher.ShowPesquisar(AIndice: Integer): Boolean;
begin
  Self.FMostrarPesquisa := True;
  Result := Pesquisar(AIndice);
  Self.FMostrarPesquisa := False;
end;

{ TCamposPesquisa }

constructor TCamposPesquisa.Create(AOwner: TComponent);
begin
  inherited Create(AOwner, TCampoPesquisa);
  Self.FCompOwner := AOwner;
end;

destructor TCamposPesquisa.Destroy;
begin
  while Self.Count > 0 do
    Self.Items[Self.Count - 1].Free;

  Self.FDataSet := nil;

  inherited;
end;

procedure TCamposPesquisa.DoEvent;
begin
  if Assigned(fOnEvent) then fOnEvent(Self);
end;

function TCamposPesquisa.GetDataSet: TDataSet;
begin
  Result:= Self.FDataSet;
end;

function TCamposPesquisa.GetItem(Index: Integer): TCampoPesquisa;
begin
  Result:= TCampoPesquisa(inherited Items[Index]);
end;

function TCamposPesquisa.GetItemPeloNome(ANome: string): TCampoPesquisa;
var
  i: Integer;
begin
  Result := nil;

  for i := 0 to Pred(Self.Count) do begin
    if Self.Items[i].Name = ANome then begin
      Result := Self.Items[i];
      Break;
    end;
  end;
end;

function TCamposPesquisa.GetName: TComponentName;
begin
  if (Self.FName = EmptyStr) then
    Result := TComponent(Self.Owner).Name + 'CamposPesquisa'
  else
    Result := Self.FName;
end;

function TCamposPesquisa.GetOwner: TPersistent;
begin
  Result := Self.FCompOwner;
end;

function TCamposPesquisa.GetTotalWidth: Integer;
var
  i: Integer;
begin
  Result := 0;

  for i := 0 to Pred(inherited Count) do
    Result := Result + Items[i].Width;
end;

procedure TCamposPesquisa.SetItem(Index: Integer; const Value: TCampoPesquisa);
begin
  inherited SetItem(Index, Value);
  DoEvent;
end;

procedure TCamposPesquisa.Update(Item: TCollectionItem);
begin
  inherited;

end;

{ TCampoPesquisa }

constructor TCampoPesquisa.Create(AOwner: TCollection);
begin
  inherited Create(AOwner);

  Self.FSQL := TStringList.Create;
  Self.FStringsProperties := TStringList.Create;
  Self.FWhereAdicional := TWhereCollection.Create(TCamposPesquisa(AOwner).FCompOwner);
  Self.FWhere := TWhereCollection.Create(TCamposPesquisa(AOwner).FCompOwner);

  if Self.GetCampos.Count = 1 then
    Self.FDefault := True;

  Self.FMostrarNaPesquisa := True;
  Self.FMostrarNaGride := True;
  Self.FOwner := AOwner;
  Self.FTable := EmptyStr;
  Self.FTipoCombo := tpNenhum;
  Self.FOperadorComparativo := ocComecacom;
  Self.FOperadoresComparativos := [ocIgual, ocDiferente, ocMaior, ocMaiorOuIgual,
    ocMenor, ocMenorOuIgual, ocComecaCom, ocTerminaCom, ocEntre, ocNulo, ocNaoNulo, ocEm];
  Self.FWhereItem := TWhere.Create('', '', ocIgual);
end;

procedure TCampoPesquisa.CreateProperties;
begin
  if Self.FPropertiesClass <> nil then
  begin
    Self.FProperties := Self.FPropertiesClass.Create(Self);
  end;
end;

destructor TCampoPesquisa.Destroy;
begin
  Self.PropertiesClassName := EmptyStr;
  Self.ControleVisualClassName := EmptyStr;
  Self.FField := nil;
end;

procedure TCampoPesquisa.DestroyProperties;
begin
  FreeAndNil(Self.FProperties);
end;

function TCampoPesquisa.GetCampos: TCamposPesquisa;
begin
  Result := Collection as TCamposPesquisa;
end;

function TCampoPesquisa.GetCaption: String;
begin
  if FCaption <> EmptyStr then
    Result := FCaption
  else
    Result := GetDisplayName;
end;

function TCampoPesquisa.GetDataSet: TDataSet;
begin
  if Collection <> nil then begin
    if TCamposPesquisa(Collection).DataSet <> nil then
      Result := TCamposPesquisa(Collection).DataSet
    else
      Result := nil;
  end else
    Result := nil;
end;

function TCampoPesquisa.GetDisplayName: String;
begin
  if (Self.FName = EmptyStr) then
    Result := 'CampoPesquisa' + IntToStr(Self.ID)
  else
    Result := Self.FName;
end;

function TCampoPesquisa.GetControleVisual: TControl;
begin
  Result := FControleVisual;
end;

function TCampoPesquisa.GetControleVisualClassName: string;
begin
  Result := Self.FControleVisualClassName;
end;

function TCampoPesquisa.GetField: TField;
begin
  if (Self.GetDataSet <> nil) then begin
    if Self.GetDataSet.Fields.Count > 0 then begin
      if Self.FieldName <> EmptyStr then
        Self.FField := Self.GetDataSet.FindField(Self.FieldName)
      else if Self.FField <> nil then begin
        Self.FField := Self.GetDataSet.FindField(FField.FieldName);
        Self.FFieldName := FField.FieldName;
      end;
    end;
  end;

  Result := Self.FField;
end;

function TCampoPesquisa.GetName: String;
begin
  Result := GetDisplayName;
end;

function TCampoPesquisa.GetProperties: TcxCustomEditProperties;
begin
  Result := Self.FProperties;
end;

function TCampoPesquisa.GetPropertiesClassName: string;
begin
  if Self.FProperties = nil then
    Result := ''
  else
    Result := Self.FProperties.ClassName;
end;

function TCampoPesquisa.GetPropertiesValue: TcxCustomEditProperties;
begin
  Result := Self.FProperties
end;

function TCampoPesquisa.GetSQL: TStrings;
begin
  Result := Self.FSQL;
end;

function TCampoPesquisa.GetStringsProperties: TStrings;
begin
  Result := Self.FStringsProperties;
end;

function TCampoPesquisa.GetTipoCombo: TipoCombo;
begin
  Result := Self.FTipoCombo;
end;

function TCampoPesquisa.GeTWhereAdicional: TWhereCollection;
begin
  Result := Self.FWhereAdicional;
end;

function TCampoPesquisa.GetWhereItem: TWhere;
begin
  if (FWhereItem = nil) then
    FWhereItem := TWhere.Create('', '', ocIgual);

  Result := FWhereItem;
end;

procedure TCampoPesquisa.PropertiesValueChanged;
var
  APrevPropertiesValue: TcxCustomEditProperties;
begin
  APrevPropertiesValue := FPropertiesValue;
  FPropertiesValue := GetPropertiesValue;
end;

procedure TCampoPesquisa.RecreateProperties;
begin
  DestroyProperties;
  CreateProperties;
end;

procedure TCampoPesquisa.SetDefault(const Value: Boolean);
var
  i: Integer;
  bPossuiDefault: Boolean;
begin
  if Value then begin
    for i := 0 to Pred(Self.GetCampos.Count) do
      Self.GetCampos.Items[i].FDefault := False;
  end;

  Self.FDefault := Value and Self.FMostrarNaPesquisa;
  bPossuiDefault := False;

  for i := 0 to Pred(Self.GetCampos.Count) do begin
    if Self.GetCampos.Items[i].FDefault then begin
      bPossuiDefault:= True;
      Break;
    end;
  end;

  if not bPossuiDefault then begin
    if Self.ID <> 0 then begin
      Self.GetCampos.Items[0].FMostrarNaPesquisa := True;
      Self.GetCampos.Items[0].FDefault := True;
    end else if GetCampos.Count > 1 then begin
      Self.GetCampos.Items[1].FMostrarNaPesquisa := True;
      Self.GetCampos.Items[1].FDefault := True;
    end;
  end;
end;

procedure TCampoPesquisa.SetDescriptionField(const Value: Boolean);
var
  i: Integer;
begin
  if Value then begin
    for i := 0 to Pred(Self.GetCampos.Count) do
      Self.GetCampos.Items[i].FDescriptionField := False;
  end;

  Self.FDescriptionField := Value;
end;

procedure TCampoPesquisa.SetControleVisual(const Value: TControl);
begin
  Self.FControleVisual := Value;
end;

procedure TCampoPesquisa.SetControleVisualClassName(const Value: string);
begin
  Self.FControleVisual := TControl(TFunc.FindComponent(nil, Self, Value));
  Self.FControleVisualClassName := Value;
end;

procedure TCampoPesquisa.SetName(const Value: String);
var
  i: Integer;
  AchouNome: Boolean;
begin
  AchouNome := False;

  for i := 0 to Pred(Self.GetCampos.Count) do begin
    if (AnsiUpperCase(GetCampos.Items[i].Name) = AnsiUpperCase(Value)) and (i <> Self.Index) then begin
      AchouNome := True;
      TFunc.MsgDlg('J� existe campo de pesquisa com esse nome!', GetCampos.Name);
      Break;
    end;
  end;

  if (Value = EmptyStr) or AchouNome then
    Self.FName := Self.GetDisplayName
  else
    Self.FName := Value;
end;

procedure TCampoPesquisa.SetOperadoresComparativos(
  const Value: TOperadoresComparativos);
var
  tmpOc: TOperadorComparativo;
begin
  Self.FOperadoresComparativos := Value;

  if (Self.FOperadoresComparativos = []) then
    Self.FOperadoresComparativos := [ocComecaCom];

  if not (Self.FOperadorComparativo in Self.FOperadoresComparativos) then begin
    for tmpOc in Self.FOperadoresComparativos do begin
      Self.FOperadorComparativo := tmpOc;
      Break;
    end;
  end;
end;

procedure TCampoPesquisa.SetOrderBy(const Value: string);
begin
  FOrderBy := Value;
end;

procedure TCampoPesquisa.SetProperties(const Value: TcxCustomEditProperties);
begin
  if (Self.FProperties <> nil) and (Value <> nil) then Self.FProperties.Assign(Value);
end;

procedure TCampoPesquisa.SetPropertiesClass(
  const Value: TcxCustomEditPropertiesClass);
begin
  if Self.FPropertiesClass <> Value then
  begin
    Self.FPropertiesClass := Value;
    Self.RecreateProperties;
    Self.PropertiesValueChanged;
  end;
end;

procedure TCampoPesquisa.SetPropertiesClassName(const Value: string);
begin
  Self.PropertiesClass := TcxCustomEditPropertiesClass(GetRegisteredEditProperties.FindByClassName(Value));
end;

procedure TCampoPesquisa.SetSQL(const Value: TStrings);
begin
  Self.FSQL.Assign(Value);
end;

procedure TCampoPesquisa.SetStringsProperties(const Value: TStrings);
begin
  Self.FStringsProperties.Assign(Value);
end;

procedure TCampoPesquisa.SetTipoCombo(const Value: TipoCombo);
begin
  if (Self.FProperties is TcxComboBoxProperties) then
    FTipoCombo := Value
  else
    FTipoCombo := tpNenhum;
end;

{ TButtonSearcher }

procedure TButtonSearcher.BtnPesquisaClick(Sender: TObject);
var
  sTemp: string;
begin
  if Self.EdtCodigo.Text = Self.EdtCodigo.DisplayFormat then
    sTemp := EmptyStr
  else
    sTemp := Self.EdtCodigo.Text;

  if Self.FSearcher.ShowPesquisar(0) then begin
    Self.FEdtCodigo.Text := Self.FSearcher.KeyField;
    Self.FEdtDescricao.Text := Self.FSearcher.DescriptionField;
  end;
end;

procedure TButtonSearcher.Clear;
begin
  if Self.EdtCodigo.FDisplayFormat <> EmptyStr then
    Self.EdtCodigo.Text := FormatFloat(Self.EdtCodigo.FDisplayFormat, 0)
  else
    Self.EdtCodigo.Clear;

  Self.EdtDescricao.Clear;
end;

constructor TButtonSearcher.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  Self.FEdtCodigo := TmEdit.Create(Self);
  Self.FEdtCodigo.SetSubComponent(True);
  Self.FEdtCodigo.Parent := Self;
  Self.FEdtCodigo.Name := 'sedtCodigo';
  Self.FEdtCodigo.Height := 21;
  Self.FEdtCodigo.Left := 0;
  Self.FEdtCodigo.Top := 0;
  Self.FEdtCodigo.Width := 70;
  Self.FEdtCodigo.Alignment := taRightJustify;
  Self.FEdtCodigo.Text := EmptyStr;
  Self.FEdtCodigo.Hint := 'C�digo';
  Self.FEdtCodigo.ShowHint := True;
  Self.FEdtCodigo.OnResize := SetSize;
  Self.FEdtCodigo.OnChange := OnChange;
  Self.FEdtCodigo.OnKeyDown := OnKeyDown;
  Self.FEdtCodigo.OnKeyPress := OnKeyPress;
  Self.FEdtCodigo.OnExit := OnExit;

  Self.FBtnPesquisa := TmBitBtn.Create(Self);
  Self.FBtnPesquisa.SetSubComponent(True);
  Self.FBtnPesquisa.Parent := Self;
  Self.FBtnPesquisa.Name := 'sbtnPesquisa';
  Self.FBtnPesquisa.Height := Self.FEdtCodigo.Height;
  Self.FBtnPesquisa.Left := Self.FEdtCodigo.Left + Self.FEdtCodigo.Width + 1;
  Self.FBtnPesquisa.Top := Self.FEdtCodigo.Top;
  Self.FBtnPesquisa.Width := 25;
  Self.FBtnPesquisa.Caption := EmptyStr;
  Self.FBtnPesquisa.Hint := 'Pesquisar';
  Self.FBtnPesquisa.ShowHint := True;
  Self.FBtnPesquisa.OnResize := SetSize;
  Self.FBtnPesquisa.OnClick := Self.BtnPesquisaClick;
  Self.FBtnPesquisa.Images := Self.ImageList;
  Self.FBtnPesquisa.ImageIndex := 0;

  Self.FEdtDescricao := TmEdit.Create(Self);
  Self.FEdtDescricao.SetSubComponent(True);
  Self.FEdtDescricao.Parent := Self;
  Self.FEdtDescricao.Name := 'sedtDescricao';
  Self.FEdtDescricao.Top := Self.FBtnPesquisa.Top;
  Self.FEdtDescricao.Left := Self.FBtnPesquisa.Left + Self.FBtnPesquisa.Width + 1;
  Self.FEdtDescricao.Height := Self.FBtnPesquisa.Height;
  Self.FEdtDescricao.Width := 260;
  Self.FEdtDescricao.Text := EmptyStr;
  Self.FEdtDescricao.Hint := 'Descri��o';
  Self.FEdtDescricao.ShowHint := True;
  Self.FEdtDescricao.OnResize := SetSize;
  Self.FEdtDescricao.ReadOnly := True;

  Self.Caption := EmptyStr;
  Self.ShowCaption := False;
  Self.Height := Self.FEdtDescricao.Height;
  Self.Width := Self.FEdtCodigo.Width + Self.FBtnPesquisa.Width + Self.FEdtDescricao.Width + 2;
  Self.FShowMsgAviso := True;
end;

function TButtonSearcher.GravarSearcherData: Boolean;
begin
  Result := (Self.FSearcher.Owner = Self);
end;

procedure TButtonSearcher.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);

  Filer.DefineBinaryProperty('SearcherDataSize', LoadSearcherSize, SaveSearcherSize, True);
  Filer.DefineBinaryProperty('SearcherData', LoadSearcher, SaveSearcher, True);
end;

destructor TButtonSearcher.Destroy;
begin
  if Self.FImageList.Owner = Self then
    FreeAndNil(Self.FImageList)
  else
    Self.FImageList := nil;

  if Self.FSearcher.Owner = Self then
    FreeAndNil(Self.FSearcher)
  else
    Self.FSearcher := nil;

  inherited Destroy;
end;

procedure TButtonSearcher.LoadSearcher(Stream: TStream);
var
  sTemp: string;
begin
  if Self.FSearcherSize > 0 then begin
    FreeAndNil(Self.FSearcher);
    SetString(sTemp, PChar(nil), Self.FSearcherSize);
    Stream.Read(PChar(sTemp)^, Self.FSearcherSize * SizeOf('A'));
    FSearcher := TSearcher(TFunc.StringToComponent(sTemp));
    Self.InsertComponent(Self.FSearcher);
  end;
end;

procedure TButtonSearcher.LoadSearcherSize(Stream: TStream);
begin
  Stream.Read(Self.FSearcherSize, SizeOf(Self.FSearcherSize));
end;

procedure TButtonSearcher.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);

  {if (Operation = opRemove) and (AComponent = FQuery) then begin
    FQuery := nil;
  end;}
end;

procedure TButtonSearcher.OnChange(Sender: TObject);
begin
  Self.FEdtDescricao.Clear;
end;

procedure TButtonSearcher.OnExit(Sender: TObject);
var
  Key: Word;
begin
  Key := 13;

  if (Self.EdtCodigo.Text <> EmptyStr) and (Self.EdtDescricao.Text = EmptyStr) then
    OnKeyDown(Sender, Key, [])
  else if Self.EdtCodigo.Text = EmptyStr then
    Self.Clear;
end;

procedure TButtonSearcher.OnKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  i,
  tmpIndice: Integer;
  sTemp: string;
begin
  if Key = VK_RETURN then begin
    for i := 0 to Pred(Self.FSearcher.CamposPesquisa.Count) do begin
      if Self.FSearcher.CamposPesquisa.Items[i].KeyField then begin
        tmpIndice := Self.FSearcher.CamposPesquisa.Items[i].Index;
        Break;
      end;
    end;

    if Self.FEdtCodigo.Text = Self.FEdtCodigo.FDisplayFormat then
      sTemp := EmptyStr
    else
      sTemp := Self.FEdtCodigo.Text;

    if sTemp = EmptyStr then begin
      if Self.FSearcher.ShowPesquisar(tmpIndice) then begin
        Self.EdtCodigo.Text := Self.FSearcher.KeyField;
        Self.EdtDescricao.Text := Self.FSearcher.DescriptionField;
      end;
    end else begin
      if Self.FSearcher.Pesquisar(tmpIndice) then begin
        Self.EdtDescricao.Text := Self.FSearcher.DescriptionField;

        if (Self.FSearcher.MsgEncontrado <> EmptyStr) and Self.FShowMsgAviso  then
          TFunc.MsgDlg(Self.FSearcher.MsgEncontrado, Self.FSearcher.NomePesquisa);
      end else begin
        Self.EdtCodigo.Text := Self.FEdtCodigo.FDisplayFormat;
        Self.EdtDescricao.Text := EmptyStr;

        if (Self.FSearcher.MsgNaoEncontrado <> EmptyStr) and Self.FShowMsgAviso  then
          TFunc.MsgDlg(Self.FSearcher.MsgNaoEncontrado, Self.FSearcher.NomePesquisa);
      end;
    end;
  end;
end;

procedure TButtonSearcher.OnKeyPress(Sender: TObject; var Key: Char);
begin

end;

function TButtonSearcher.Query: TQueryType;
begin
  Result := Searcher.Query;
end;

function TButtonSearcher.GetEnabled: Boolean;
begin
  Result := inherited GetEnabled;
end;

function TButtonSearcher.GetImageList: TsAlphaImageList;
var
  criar: Boolean;

  procedure PesquisaImageList;
  begin
    Self.FImageList := TsAlphaImageList(Self.FindComponent('ImageList'));

    if Self.FImageList = nil then
      criar := True;
  end;
begin
  criar := False;

  if Self.FImageList = nil then
    PesquisaImageList
  else if Self.FImageList.Owner is TButtonSearcher then
    PesquisaImageList;

  if criar then begin
    Self.FImageList := TsAlphaImageList.Create(Self);
    Self.FImageList.Name := 'ImageList';
    Self.FImageList.Masked := False;
    Self.FImageList.ColorDepth := cd32bit;
    Self.FImageList.LoadFromPngStream(TFunc.StringToMSHex(PngImageString));
  end;

  Result := Self.FImageList;
  Self.FBtnPesquisa.Images := Result;
end;

function TButtonSearcher.GetPngImageString: string;
begin
  Result := '89504E470D0A1A0A0000000D494844520000001400000010080300000021C6AF29'
          + '0000000467414D410000B18F0BFC610500000222504C5445000000909297A6A6A7'
          + 'FFFFFFA0A0A2797A7E9B9CA0787C7F52504D898888999C9EFEFEFE565454F5F5F6'
          + '313030E1E2E3FEFCFE3535379D9D9FF7F8F98C8C8E3C3C3E080808E5E5E7272727'
          + 'D4D5D7010101919393494A4A9C9DA0A0A0A397979AFFFFFFC4CBDC9D9D9F848485'
          + '72727364646563636573737585858694959775768397999E9696977D7D7EA4A4A5'
          + 'D5D5D5E3E4E4D8D9DA6B6B6D4F4F4F7B7A7B909193767B8089888A7F7F83D3D5D6'
          + 'FFFFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFFFF545E66797A7C8A8B8D4D4D4A818185'
          + 'B9BEC7FCFFFFFEFFFFFFFFFFFBFFFFF7FFFFF4FFFFE8FFFFD3F6FF8692A88E8E92'
          + '5253543837339699A2E0E6F3FDFFFFFCFFFFF9FFFFF7FFFFEEFFFFD5F5FFB2CAF2'
          + '9D9FA866666522201C979AA2DCE6F9FDFFFFFEFFFFF8FFFFF8FFFFF4FFFFE9FFFF'
          + 'CBECFFBFD4FAADAFB4403E3F000000747477C9D3E6DDEFFFE6FAFFE9FFFFEEFFFF'
          + 'E7FFFFD4F4FFBAD8FFC8D2E79898992B2A2994969AC7D4EBC3DEFFC6E6FFCFEEFF'
          + 'CEEEFFC5E5FFBED9FFCAD6EEB2B3B6ACACAE1817167F8081B0B6C3BECCE4BFCCE3'
          + 'B3B9C68E8F90AEAFB1B5B7B8E1E2E3FFFFFF0000002C2A276261607C7C7D7D7D7E'
          + '6564623634317B7C7D8F9193A1A3A5D3D4D5FAFBFB0000007C7E7E979A9CD4D6D7'
          + 'F2F2F20000007071729EA0A1E0E1E2EEEEEFDEDFE15355559A9B9CCECFD1ECEDEE'
          + 'EFEFF0D2D3D42E2E2E8D8E90C5C6C8D5D6D7B1B2B50000005B5B5D595A5BBDCFEE'
          + 'ABADAFC0C2C3FFFFFFA9FD5196000000B274524E53000000000000000000000000'
          + '0000000000000000000000000000000000152B1601012C6A83878484702D010350'
          + '8B86856A3F20408654033D8581C2985A1E0B081F8B3E0683868B927D3E2D2E2E2B'
          + '588606179CAC866E5C5C5C5C679B0F11A4BDC8B297929292919E9B0A0273DEDED8'
          + 'D0CFCFCFCFD36019AAFAFEFCFBFBFCFEFEC9271C86DAF8F7D493D5CC5B09042756'
          + '706E501F5DE6F59C230353DDCA430144CCE361062DADFCF27A091684E3960C0A39'
          + '12759D045400000001624B474403110C4CF2000000A64944415478DA6364606064'
          + '64946204924F187F33400023039B34230CDCFD0913D46644805350410E7D24C1E3'
          + 'DF2182CE8CC8600344309091F1B91423C822105802118C85F0A082D3218259C882'
          + 'DD30DBCB908CEC64FC0A11E40189EA325C8108377EFB0B1264E0AB87F07FB183C8'
          + '72C60F2041060641C68F02407E3323A3C44BC63491978C0C0820D1C6C828F29691'
          + 'B10C599041EAE542A85B5080743F16410699C98C8C4100432D1E84F567F6040000'
          + '002574455874646174653A63726561746500323031372D30322D30335431363A34'
          + '363A31392B30313A3030237FCCCA0000002574455874646174653A6D6F64696679'
          + '00323031372D30322D30335431363A34363A31392B30313A303052227476000000'
          + '0049454E44AE426082';
end;

function TButtonSearcher.GetSearcher: TSearcher;
var
  criar: Boolean;

  procedure PesquisaSearcher;
  begin
    Self.FSearcher := TSearcher(Self.FindComponent('shrDados'));

    if Self.FSearcher = nil then
      criar := True;
  end;
begin
  criar := False;

  if Self.FSearcher = nil then
    PesquisaSearcher
  else if Self.FSearcher.Owner is TButtonSearcher then
    PesquisaSearcher;

  if criar then begin
    Self.FSearcher := TSearcher.Create(Self);
    Self.FSearcher.Name := 'shrDados';
  end;

  Result := Self.FSearcher;
end;

procedure TButtonSearcher.SaveSearcher(Stream: TStream);
var
  sTemp: string;
begin
  sTemp := TFunc.ComponentToString(Self.FSearcher);
  Stream.Write(PChar(sTemp)^, Self.FSearcherSize * SizeOf('A'));
end;

procedure TButtonSearcher.SaveSearcherSize(Stream: TStream);
var
  tmpSize: LongInt;
begin
  if GravarSearcherData then
    tmpSize := Length(TFunc.ComponentToString(Self.FSearcher))
  else
    tmpSize := 0;

  Self.FSearcherSize := tmpSize;
  Stream.Write(Self.FSearcherSize, Sizeof(Self.FSearcherSize));
end;

{$Region 'SetLeft'}
{procedure TButtonSearcher.SetLeft(const Value: Integer);
var
  P: TPoint;
begin
  inherited Left := Value;

  if FQuery <> nil then begin
    P := TFunc.GetPositionInForm(Self);
    FQuery.SetPosition(P.X + FEdtCodigo.Left + FEdtCodigo.Width + 1 + FBtnPesquisa.Width + 1, P.Y);
  end;
end;}
{$EndRegion}

procedure TButtonSearcher.SetEnabled(const Value: Boolean);
begin
  Self.FEdtCodigo.Enabled    := Value;
  Self.FBtnPesquisa.Enabled  := Value;
  Self.FEdtDescricao.Enabled := Value;
  inherited SetEnabled(Value);
end;

procedure TButtonSearcher.SetSize(Sender: TObject);
var
  tmpTop,
  tmpHeight,
  tmpEdtCodigoLeft,
  tmpEdtCodigoWidth,
  tmpBtnPesquisaLeft,
  tmpBtnPesquisaWidth,
  tmpEdtDescricaoWidth: Integer;
  tmpOnResize: TNotifyEvent;
begin
  tmpTop := 0;
  tmpHeight := 0;
  tmpEdtCodigoLeft := 0;
  tmpEdtCodigoWidth := 0;
  tmpBtnPesquisaLeft := 0;
  tmpBtnPesquisaWidth := 0;
  tmpEdtDescricaoWidth := 0;

  if Assigned(Self.FEdtCodigo) then begin
    if Self.FEdtCodigo.Height > tmpHeight then
      tmpHeight := Self.FEdtCodigo.Height;

    if Self.FEdtCodigo.Top > tmpTop then
      tmpTop := Self.FEdtCodigo.Top;

    tmpEdtCodigoLeft := Self.FEdtCodigo.Left;
    tmpEdtCodigoWidth := Self.FEdtCodigo.Width;
  end;

  if Assigned(Self.FBtnPesquisa) then begin
    if Self.FBtnPesquisa.Height > tmpHeight then
      tmpHeight := Self.FBtnPesquisa.Height;

    if Self.FBtnPesquisa.Top > tmpTop then
      tmpTop := FBtnPesquisa.Top;

    tmpBtnPesquisaLeft := Self.FBtnPesquisa.Left;
    tmpBtnPesquisaWidth := Self.FBtnPesquisa.Width;
  end;

  if Assigned(Self.FEdtDescricao) then begin
    if Self.FEdtDescricao.Height > tmpHeight then
      tmpHeight := Self.FEdtDescricao.Height;

    if Self.FEdtDescricao.Top > tmpTop then
      tmpTop := Self.FEdtDescricao.Top;

    tmpEdtDescricaoWidth := Self.FEdtDescricao.Width;
  end;

  if tmpHeight = 0 then
    tmpHeight := 21;

  if tmpEdtCodigoWidth = 0 then
    tmpEdtCodigoWidth := 70;

  Height := tmpTop + tmpHeight;
  Width := tmpEdtCodigoLeft + tmpEdtCodigoWidth + tmpBtnPesquisaWidth + tmpEdtDescricaoWidth + 2;

  if Assigned(Self.FBtnPesquisa) then begin
    tmpOnResize := Self.FBtnPesquisa.OnResize;
    Self.FBtnPesquisa.OnResize := nil;
    Self.FBtnPesquisa.Left := tmpEdtCodigoLeft + tmpEdtCodigoWidth + 1;
    Self.FBtnPesquisa.OnResize := tmpOnResize;
  end;

  if Assigned(Self.FEdtDescricao) then begin
    tmpOnResize := Self.FEdtDescricao.OnResize;
    Self.FEdtDescricao.OnResize := nil;
    Self.FEdtDescricao.Left := tmpBtnPesquisaLeft + tmpBtnPesquisaWidth + 1;
    Self.FEdtDescricao.OnResize := tmpOnResize;
  end;
end;

{$Region 'SetTop'}
{procedure TButtonSearcher.SetTop(const Value: Integer);
var
  P: TPoint;
begin
  inherited Top := Value;

  if FQuery <> nil then begin
    P := TFunc.GetPositionInForm(Self);
    FQuery.SetPosition(P.X + FEdtCodigo.Left + FEdtCodigo.Width + 1 + FBtnPesquisa.Width + 1, P.Y);
  end;
end;}
{$EndRegion}

{ TmEdit }

function TmEdit.AsInteger: Integer;
begin
  Result := StrToInt(FloatToStr(Self.Value));
end;

constructor TmEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

destructor TmEdit.Destroy;
begin

  inherited;
end;

function TmEdit.GetHeight: Integer;
begin
  Result := inherited Height;
end;

procedure TmEdit.SetHeight(const Value: Integer);
begin
  inherited Height := Value;

  if Assigned(OnResize) then
    OnResize(Self);
end;

function TmEdit.GetLeft: Integer;
begin
  Result := inherited Left;
end;

procedure TmEdit.SetLeft(const Value: Integer);
begin
  inherited Left := Value;

  if Assigned(OnResize) then
    OnResize(Self);
end;

function TmEdit.GetTop: Integer;
begin
  Result := inherited Top;
end;

procedure TmEdit.SetTop(const Value: Integer);
begin
  inherited Top := Value;

  if Assigned(OnResize) then
    OnResize(Self);
end;

function TmEdit.GetWidth: Integer;
begin
  Result := inherited Width;
end;

procedure TmEdit.SetWidth(const Value: Integer);
begin
  inherited Width := Value;

  if Assigned(OnResize) then
    OnResize(Self);
end;

function TmEdit.Value: Double;
var
  tmpText: string;
begin
  tmpText := inherited Text;

  if TFunc.ENumerico(tmpText) then
    Result := StrToFloat(tmpText)
  else
    Result := 0;
end;

{ TmBitBtn }

constructor TmBitBtn.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

destructor TmBitBtn.Destroy;
begin

  inherited;
end;

function TmBitBtn.GetHeight: Integer;
begin
  Result := inherited Height;
end;

procedure TmBitBtn.SetHeight(const Value: Integer);
begin
  inherited Height := Value;

  if Assigned(OnResize) then
    OnResize(Self);
end;

function TmBitBtn.GetLeft: Integer;
begin
  Result := inherited Left;
end;

procedure TmBitBtn.SetLeft(const Value: Integer);
begin
  inherited Left := Value;

  if Assigned(OnResize) then
    OnResize(Self);
end;

function TmBitBtn.GetTop: Integer;
begin
  Result := inherited Top;
end;

procedure TmBitBtn.SetTop(const Value: Integer);
begin
  inherited Top := Value;

  if Assigned(OnResize) then
    OnResize(Self);
end;

function TmBitBtn.GetWidth: Integer;
begin
  Result := inherited Width;
end;

procedure TmBitBtn.SetWidth(const Value: Integer);
begin
  inherited Width := Value;

  if Assigned(OnResize) then
    OnResize(Self);
end;

{ TGerarSQL }

class function TGerarSQL.GerarWhere(AWhere: TWhere): string;
begin
  case DataBase of
    ftAdvantageDatabaseServer: Result := GerarWhereAdvantageDatabaseServer(AWhere);
    ftAdaptiveServerAnywhere: Result := GerarWhereAdaptiveServerAnywhere(AWhere);
    ftIBMDatabase2: Result := GerarWhereIBMDatabase2(AWhere);
    ftDataSnap: Result := GerarWhereDataSnap(AWhere);
    ftFireBird: Result := GerarWhereFireBird(AWhere);
    ftInterBase: Result := GerarWhereInterBase(AWhere);
    ftInterBaseLite: Result := GerarWhereInterBaseLite(AWhere);
    ftInformix: Result := GerarWhereInformix(AWhere);
    ftMSAccess: Result := GerarWhereMSAccess(AWhere);
    ftMSSQL: Result := GerarWhereMSSQL(AWhere);
    ftMySQL: Result := GerarWhereMySQL(AWhere);
    ftOpenDatabaseConnectivity: Result := GerarWhereOpenDatabaseConnectivity(AWhere);
    ftOracle: Result := GerarWhereOracle(AWhere);
    ftPostgreSQL: Result := GerarWherePostgreSQL(AWhere);
    ftSQLite: Result := GerarWhereSQLite(AWhere);
    ftdbExpress4: Result := GerarWheredbExpress4(AWhere);
    else
      TFunc.MsgDlg('Drive do banco de dados n�o foi definido!');
  end;
end;

class function TGerarSQL.GerarWhereAdvantageDatabaseServer(AWhere: TWhere): string;
begin
  Result := EmptyStr;
end;

class function TGerarSQL.GerarWhereAdaptiveServerAnywhere(AWhere: TWhere): string;
begin
  Result := EmptyStr;
end;

class function TGerarSQL.GerarWhereIBMDatabase2(AWhere: TWhere): string;
begin
  Result := EmptyStr;
end;

class function TGerarSQL.GerarWhereDataSnap(AWhere: TWhere): string;
begin
  Result := EmptyStr;
end;

class function TGerarSQL.GerarWhereFireBird(AWhere: TWhere; ACount: Integer): string;
var
  i: Integer;
  tmpOperador,
  tmpConsulta,
  tmpConsulta2: string;

  function AddRetirarAcento(AValor: string; AUpperCase, ADesconsiderarAcentos: Boolean): string;
  begin
    Result := '(SELECT RETORNO FROM RETIRAR_ACENTO(' + AValor + '))';
  end;

  function AddAspas(AValor: string; AUtilizarAspas: Boolean): string;
  begin
    if AUtilizarAspas then
      Result := QuotedStr(AValor)
    else
      Result := AValor;
  end;
begin
  Result := EmptyStr;
  tmpConsulta := EmptyStr;

  if (AWhere.ValorAPesquisar <> EmptyStr) then begin

    case AWhere.OperadorComparativo of
      ocIgual: tmpOperador := '=';
      ocDiferente: tmpOperador := '<>';
      ocMaior: tmpOperador := '>';
      ocMaiorOuIgual: tmpOperador := '>=';
      ocMenor: tmpOperador := '<';
      ocMenorOuIgual: tmpOperador := '<=';
      ocComecacom: tmpOperador := 'LIKE';
      ocTerminaCom: tmpOperador := 'LIKE';
      ocEntre: tmpOperador := 'BETWEEN';
      ocNulo: tmpOperador := 'IS NULL';
      ocNaoNulo: tmpOperador := 'IS NOT NULL';
      ocEm: tmpOperador := 'IN';
    end;

    if (AWhere.OperadorComparativo <> ocEm) then
      tmpConsulta := TFunc.ifthen(AWhere.OperadorLogico <> olNenhum, ' ' +
                   OperadorLogicoNomes[Integer(AWhere.OperadorLogico)] + ' ', '') +
                   TFunc.ifthen(AWhere.UtilizarNot, '(NOT (', '(')
    else
      tmpConsulta := TFunc.ifthen(AWhere.UtilizarNot, '(NOT (', '') + ' ' +
                   OperadorLogicoNomes[Integer(AWhere.OperadorLogico)] + ' (';

    tmpConsulta := tmpConsulta + AddRetirarAcento(AWhere.FieldName, AWhere.UtilizarUpperCase,
                 AWhere.DesconsiderarAcentos) + ' ' + tmpOperador + ' ';

    case AWhere.OperadorComparativo of
      ocIgual,
      ocDiferente,
      ocMaior,
      ocMaiorOuIgual,
      ocMenor,
      ocMenorOuIgual,
      ocEm: tmpConsulta := tmpConsulta + AddRetirarAcento(AddAspas(AWhere.ValorAPesquisar,
        AWhere.UtilizarAspas), AWhere.UtilizarUpperCase, AWhere.DesconsiderarAcentos);
      ocComecacom: tmpConsulta := tmpConsulta + AddRetirarAcento(AddAspas(AWhere.ValorAPesquisar + '%',
        AWhere.UtilizarAspas), AWhere.UtilizarUpperCase, AWhere.DesconsiderarAcentos);
      ocTerminaCom: tmpConsulta := tmpConsulta + AddRetirarAcento(AddAspas('%' + AWhere.ValorAPesquisar,
        AWhere.UtilizarAspas), AWhere.UtilizarUpperCase, AWhere.DesconsiderarAcentos);
      ocEntre: tmpConsulta := tmpConsulta + AddRetirarAcento(AddAspas(AWhere.ValorAPesquisar,
        AWhere.UtilizarAspas), AWhere.UtilizarUpperCase, AWhere.DesconsiderarAcentos)
        + ' AND ' + AddRetirarAcento(AddAspas(AWhere.ValorAPesquisar2, AWhere.UtilizarAspas),
        AWhere.UtilizarUpperCase, AWhere.DesconsiderarAcentos);
      ocNulo,
      ocNaoNulo: tmpConsulta := Copy(tmpConsulta, 1, Length(tmpConsulta) - 1);
    end;

    tmpConsulta := tmpConsulta + TFunc.ifthen(AWhere.UtilizarNot, '))', ')');
  end;

  tmpConsulta2 := EmptyStr;

  if (AWhere.Where <> nil) then begin
    if AWhere.Where.Count > 0 then begin
      if (AWhere.Where.Count > 1) then
        tmpConsulta2 := TFunc.ifthen(AWhere.OperadorLogicoWC <> olNenhum, ' ' +
          OperadorLogicoNomes[Integer(AWhere.OperadorLogicoWC)] + ' ', TFunc.ifthen((tmpConsulta <> EmptyStr), ' ', '')) +
          TFunc.ifthen(AWhere.UtilizarNotWC, '(NOT (', '(');

      for i := 0 to Pred(AWhere.Where.Count) do begin
        if (i = 0) and (AWhere.Where.Count > 1) then
          AWhere.Where.Items[i].OperadorLogico := olNenhum;

        tmpConsulta2 := tmpConsulta2 + GerarWhereOracle(AWhere.Where.Items[i], ACount + 1);
      end;

      if (AWhere.Where.Count > 1) then
        tmpConsulta2 := tmpConsulta2 + TFunc.ifthen(AWhere.UtilizarNotWC, '))', ')');
    end;
  end;

  if Trim(tmpConsulta + tmpConsulta2) <> EmptyStr then
    Result := TFunc.ifthen(ACount = 1, '  ', '')
            + tmpConsulta + tmpConsulta2;
end;

class function TGerarSQL.GerarWhereInterBase(AWhere: TWhere): string;
begin
  Result := EmptyStr;
end;

class function TGerarSQL.GerarWhereInterBaseLite(AWhere: TWhere): string;
begin
  Result := EmptyStr;
end;

class function TGerarSQL.GerarWhereInformix(AWhere: TWhere): string;
begin
  Result := EmptyStr;
end;

class function TGerarSQL.GerarWhereMSAccess(AWhere: TWhere): string;
begin
  Result := EmptyStr;
end;

class function TGerarSQL.GerarWhereMSSQL(AWhere: TWhere): string;
begin
  Result := EmptyStr;
end;

class function TGerarSQL.GerarWhereMySQL(AWhere: TWhere): string;
begin
  Result := EmptyStr;
end;

class function TGerarSQL.GerarWhereOpenDatabaseConnectivity(AWhere: TWhere): string;
begin
  Result := EmptyStr;
end;

class function TGerarSQL.GerarWhereOracle(AWhere: TWhere; ACount: Integer): string;
var
  i: Integer;
  tmpOperador,
  tmpConsulta,
  tmpConsulta2: string;

  function AddUpperCase(AValor: string; AUpperCase, ADesconsiderarAcentos: Boolean): string;
  begin
    if AUpperCase then
      Result := 'ANSIUPPERCASE(' + AValor + TFunc.ifthen(ADesconsiderarAcentos, ', ''S'')', ', ''N'')')
    else
      Result := AValor;
  end;

  function AddAspas(AValor: string; AUtilizarAspas: Boolean): string;
  begin
    if AUtilizarAspas then
      Result := QuotedStr(AValor)
    else
      Result := AValor;
  end;
begin
  Result := EmptyStr;
  tmpConsulta := EmptyStr;

  if (AWhere.ValorAPesquisar <> EmptyStr) then begin
    {ACampoPesquisa.Field.DataType
    TFieldType = (ftUnknown, ftString, ftSmallint, ftInteger, ftWord, // 0..4
      ftBoolean, ftFloat, ftCurrency, ftBCD, ftDate, ftTime, ftDateTime, // 5..11
      ftBytes, ftVarBytes, ftAutoInc, ftBlob, ftMemo, ftGraphic, ftFmtMemo, // 12..18
      ftParadoxOle, ftDBaseOle, ftTypedBinary, ftCursor, ftFixedChar, ftWideString, // 19..24
      ftLargeint, ftADT, ftArray, ftReference, ftDataSet, ftOraBlob, ftOraClob, // 25..31
      ftVariant, ftInterface, ftIDispatch, ftGuid, ftTimeStamp, ftFMTBcd, // 32..37
      ftFixedWideChar, ftWideMemo, ftOraTimeStamp, ftOraInterval, // 38..41
      ftLongWord, ftShortint, ftByte, ftExtended, ftConnection, ftParams, ftStream, //42..48
      ftTimeStampOffset, ftObject, ftSingle);}

    case AWhere.OperadorComparativo of
      ocIgual: tmpOperador := '=';
      ocDiferente: tmpOperador := '<>';
      ocMaior: tmpOperador := '>';
      ocMaiorOuIgual: tmpOperador := '>=';
      ocMenor: tmpOperador := '<';
      ocMenorOuIgual: tmpOperador := '<=';
      ocComecacom: tmpOperador := 'LIKE';
      ocTerminaCom: tmpOperador := 'LIKE';
      ocEntre: tmpOperador := 'BETWEEN';
      ocNulo: tmpOperador := 'IS NULL';
      ocNaoNulo: tmpOperador := 'IS NOT NULL';
      ocEm: tmpOperador := 'IN';
    end;

    if (AWhere.OperadorComparativo <> ocEm) then
      tmpConsulta := TFunc.ifthen(AWhere.OperadorLogico <> olNenhum, ' ' +
                   OperadorLogicoNomes[Integer(AWhere.OperadorLogico)] + ' ', '') +
                   TFunc.ifthen(AWhere.UtilizarNot, '(NOT (', '(')
    else
      tmpConsulta := TFunc.ifthen(AWhere.UtilizarNot, '(NOT (', '') + ' ' +
                   OperadorLogicoNomes[Integer(AWhere.OperadorLogico)] + ' (';

    tmpConsulta := tmpConsulta + AddUpperCase(AWhere.FieldName, AWhere.UtilizarUpperCase,
                 AWhere.DesconsiderarAcentos) + ' ' + tmpOperador + ' ';

    case AWhere.OperadorComparativo of
      ocIgual,
      ocDiferente,
      ocMaior,
      ocMaiorOuIgual,
      ocMenor,
      ocMenorOuIgual,
      ocEm: tmpConsulta := tmpConsulta + AddUpperCase(AddAspas(AWhere.ValorAPesquisar,
        AWhere.UtilizarAspas), AWhere.UtilizarUpperCase, AWhere.DesconsiderarAcentos);
      ocComecacom: tmpConsulta := tmpConsulta + AddUpperCase(AddAspas(AWhere.ValorAPesquisar + '%',
        AWhere.UtilizarAspas), AWhere.UtilizarUpperCase, AWhere.DesconsiderarAcentos);
      ocTerminaCom: tmpConsulta := tmpConsulta + AddUpperCase(AddAspas('%' + AWhere.ValorAPesquisar,
        AWhere.UtilizarAspas), AWhere.UtilizarUpperCase, AWhere.DesconsiderarAcentos);
      ocEntre: tmpConsulta := tmpConsulta + AddUpperCase(AddAspas(AWhere.ValorAPesquisar,
        AWhere.UtilizarAspas), AWhere.UtilizarUpperCase, AWhere.DesconsiderarAcentos)
        + ' AND ' + AddUpperCase(AddAspas(AWhere.ValorAPesquisar2, AWhere.UtilizarAspas),
        AWhere.UtilizarUpperCase, AWhere.DesconsiderarAcentos);
      ocNulo,
      ocNaoNulo: tmpConsulta := Copy(tmpConsulta, 1, Length(tmpConsulta) - 1);
    end;

    tmpConsulta := tmpConsulta + TFunc.ifthen(AWhere.UtilizarNot, '))', ')');
  end;

  tmpConsulta2 := EmptyStr;

  if (AWhere.Where <> nil) then begin
    if AWhere.Where.Count > 0 then begin
      if (AWhere.Where.Count > 1) then
        tmpConsulta2 := TFunc.ifthen(AWhere.OperadorLogicoWC <> olNenhum, ' ' +
          OperadorLogicoNomes[Integer(AWhere.OperadorLogicoWC)] + ' ', TFunc.ifthen((tmpConsulta <> EmptyStr), ' ', '')) +
          TFunc.ifthen(AWhere.UtilizarNotWC, '(NOT (', '(');

      for i := 0 to Pred(AWhere.Where.Count) do begin
        if (i = 0) and (AWhere.Where.Count > 1) then
          AWhere.Where.Items[i].OperadorLogico := olNenhum;

        tmpConsulta2 := tmpConsulta2 + GerarWhereOracle(AWhere.Where.Items[i], ACount + 1);
      end;

      if (AWhere.Where.Count > 1) then
        tmpConsulta2 := tmpConsulta2 + TFunc.ifthen(AWhere.UtilizarNotWC, '))', ')');
    end;
  end;

  if Trim(tmpConsulta + tmpConsulta2) <> EmptyStr then
    Result := TFunc.ifthen(ACount = 1, '  ', '')
            + tmpConsulta + tmpConsulta2;
end;

class function TGerarSQL.GerarWherePostgreSQL(AWhere: TWhere): string;
begin
  Result := EmptyStr;
end;

class function TGerarSQL.GerarWhereSQLite(AWhere: TWhere): string;
begin
  Result := EmptyStr;
end;

class function TGerarSQL.GerarWheredbExpress4(AWhere: TWhere): string;
begin
  Result := EmptyStr;
end;

class function TGerarSQL.GetBatabaseName: string;
begin
  Result := DatabaseNames[GetIndexDatabaseDrive(DatabaseDrive)];
end;

class function TGerarSQL.GetDatabase: TFeatBase;
begin
  Result := TFeatBase(GetIndexDatabaseDrive(DatabaseDrive));
end;

class function TGerarSQL.GetIndexDatabaseDrive(ADatabaseDrive: string): Integer;
var
  i: Integer;
begin
  Result := -1;

  for i := Low(DatabaseDrivers) to High(DatabaseDrivers) do begin
    if AnsiUpperCase(DatabaseDrivers[i]) = AnsiUpperCase(ADatabaseDrive) then
      Break;
  end;

  Result := i;
end;

class procedure TGerarSQL.SetDatabaseDrive(const Value: string);
begin
  FDatabaseDrive := DataBaseDrivers[GetIndexDatabaseDrive(Value)];
end;

{ TWhereCollection }

constructor TWhereCollection.Create(AOwner: TComponent);
begin
  inherited Create(AOwner, TWhere);
  Self.FCompOwner := AOwner;
end;

destructor TWhereCollection.Destroy;
begin
  while Self.Count > 0 do
    Self.Items[Self.Count - 1].Free;

  Self.FDataSet := nil;
  inherited;
end;

procedure TWhereCollection.DoEvent;
begin
  if Assigned(fOnEvent) then fOnEvent(Self);
end;

function TWhereCollection.GetDataSet: TDataSet;
begin
  Result:= Self.FDataSet;
end;

function TWhereCollection.GetItem(Index: Integer): TWhere;
begin
  Result:= TWhere(inherited Items[Index]);
end;

function TWhereCollection.GetName: TComponentName;
begin
  if (Self.FName = EmptyStr) then
    Result := TComponent(Self.Owner).Name + 'Where'
  else
    Result := Self.FName;
end;

function TWhereCollection.GetOwner: TPersistent;
begin
  Result := Self.FCompOwner;
end;

procedure TWhereCollection.SetItem(Index: Integer; const Value: TWhere);
begin
  inherited SetItem(Index, Value);
  DoEvent;
end;

procedure TWhereCollection.Update(Item: TCollectionItem);
begin
  inherited;

end;

{ TWhere }

constructor TWhere.Create(AOwner: TCollection);
begin
  inherited Create(AOwner);

  Self.FWhere := TWhereCollection.Create(TCamposPesquisa(AOwner).FCompOwner);
  Self.FOwner := AOwner;
  Self.FOperadorComparativo := ocComecacom;
  Self.FDesconsiderarAcentos := True;
  Self.FUtilizarUpperCase := True;
  Self.FUtilizarAspas := True;
  Self.FOperadorLogico := olAnd;
  Self.FOperadorLogicoWC := olAnd;
  Self.FUtilizarNot := False;
  Self.FUtilizarNotWC := False;
end;

constructor TWhere.Create(AFieldName: String; AValorAPesquisar: Variant;
  AOperadorComparativo: TOperadorComparativo);
var
  tmpOwner: TWhereCollection;
begin
  tmpOwner := TWhereCollection.Create(nil);

  inherited Create(tmpOwner);

  Self.FOwner := tmpOwner;
  Self.FOperadorComparativo := ocComecacom;
  Self.FDesconsiderarAcentos := True;
  Self.FUtilizarUpperCase := True;
  Self.FUtilizarAspas := True;
  Self.FOperadorLogico := olAnd;
  Self.FOperadorLogicoWC := olAnd;
  Self.FUtilizarNot := False;
  Self.FUtilizarNotWC := False;
  Self.FieldName := AFieldName;
  Self.ValorAPesquisar := VarToStrDef(AValorAPesquisar, EmptyStr);
  Self.OperadorComparativo := AOperadorComparativo;
end;

destructor TWhere.Destroy;
begin
  Self.FField := nil;
end;

function TWhere.GetCampos: TWhereCollection;
begin
  Result := Collection as TWhereCollection;
end;

function TWhere.GetCaption: String;
begin
  if FCaption <> EmptyStr then
    Result := FCaption
  else
    Result := GetDisplayName;
end;

function TWhere.GetDataSet: TDataSet;
begin
  if Collection <> nil then begin
    if TCamposPesquisa(Collection).DataSet <> nil then
      Result := TCamposPesquisa(Collection).DataSet
    else
      Result := nil;
  end else
    Result := nil;
end;

function TWhere.GetDisplayName: String;
begin
  if (Self.FName = EmptyStr) then
    Result := 'Where' + IntToStr(Self.ID)
  else
    Result := Self.FName;
end;

function TWhere.GetField: TField;
begin
  if Self.GetDataSet <> nil then begin
    if Self.GetDataSet.Fields.Count > 0 then begin
      if Self.FieldName <> EmptyStr then
        Self.FField := Self.GetDataSet.FindField(Self.FieldName)
      else if Self.FField <> nil then begin
        Self.FField := Self.GetDataSet.FindField(FField.FieldName);
        Self.FFieldName := FField.FieldName;
      end;
    end;
  end;

  Result := Self.FField;
end;

function TWhere.GetName: String;
begin
  Result := GetDisplayName;
end;

function TWhere.GetWhere: TWhereCollection;
begin
  Result := Self.FWhere;
end;

procedure TWhere.SetName(const Value: String);
var
  i: Integer;
  AchouNome: Boolean;
begin
  AchouNome := False;

  for i := 0 to Pred(Self.GetCampos.Count) do begin
    if (AnsiUpperCase(GetCampos.Items[i].Name) = AnsiUpperCase(Value)) and (i <> Self.Index) then begin
      AchouNome := True;
      TFunc.MsgDlg('J� existe campo de pesquisa com esse nome!', GetCampos.Name);
      Break;
    end;
  end;

  if (Value = EmptyStr) or AchouNome then
    Self.FName := Self.GetDisplayName
  else
    Self.FName := Value;
end;

procedure TWhere.SetUtilizarUpperCase(const Value: Boolean);
begin
  Self.FUtilizarUpperCase := Value;

  if not Value then
    Self.FDesconsiderarAcentos := False;
end;

initialization
  RegistrarClasses;

end.
