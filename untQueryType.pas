unit untQueryType;

interface

uses
  Classes, FireDAC.Comp.Client, System.Generics.Collections, SysUtils;

type
  TQueryType = class(TFDQuery)
  private
    FSizes: Integer;
    FSizesStr: string;
    FFieldsSize: LongInt;
    FCampos: TList<string>;
    //function GetName: TComponentName;
    //function GetObjectName: string; virtual;
    //procedure SetName(const Value: TComponentName);
  protected
    procedure Loaded; override;
    procedure LoadSizes(Stream: TStream); virtual;
    procedure SaveSizes(Stream: TStream); virtual;
    procedure LoadSizesStr(Stream: TStream); virtual;
    procedure SaveSizesStr(Stream: TStream); virtual;

    procedure LoadFieldsSize(Stream: TStream); virtual;
    procedure SaveFieldsSize(Stream: TStream); virtual;
    procedure LoadFields(Stream: TStream); virtual;
    procedure SaveFields(Stream: TStream); virtual;

    procedure DefineProperties(Filer: TFiler); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetPosition(ALeft, ATop: Integer);
    function Campos: TList<string>;
  end;

implementation

uses
  untFuncoes;

{ TQueryType }

function TQueryType.Campos: TList<string>;
begin
  if Self.FCampos = nil then
    Self.FCampos := TList<string>.Create;

  Result := Self.FCampos;
end;

constructor TQueryType.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

procedure TQueryType.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
  Filer.DefineBinaryProperty('Sizes', LoadSizes, SaveSizes, True);
  Filer.DefineBinaryProperty('SizesStr', LoadSizesStr, SaveSizesStr, True);
  Filer.DefineBinaryProperty('FieldsSize', LoadFieldsSize, SaveFieldsSize, True);
  Filer.DefineBinaryProperty('ListaCampos', LoadFields, SaveFields, True);
end;

destructor TQueryType.Destroy;
begin
  FreeAndNil(Self.FCampos);
  inherited Destroy;
end;

procedure TQueryType.SetPosition(ALeft, ATop: Integer);
var
  NewDesignInfo: LongRec;
begin
  NewDesignInfo.Hi := Word(ATop);
  NewDesignInfo.Lo := Word(ALeft);
  Self.DesignInfo := Longint(NewDesignInfo);
end;

procedure TQueryType.Loaded;
begin
  inherited Loaded;
end;

procedure TQueryType.LoadFields(Stream: TStream);
var
  i,
  iPosIni,
  iSizeCampo,
  iContCampos: Integer;
  sCampos: string;
begin
  Self.Campos.Clear;
  SetString(sCampos, PChar(nil), Self.FFieldsSize);
  Stream.Read(PChar(sCampos)^, Self.FFieldsSize * SizeOf('A'));

  iPosIni := 1;
  iContCampos := StrToInt(Copy(Self.FSizesStr, 1, 8));

  for i := 0 to Pred(iContCampos) do begin
    iSizeCampo := StrToInt(Copy(Self.FSizesStr, (i + 1) * 8 + 1, 8));
    Self.Campos.Add(Copy(sCampos, iPosIni, iSizeCampo));
    iPosIni := iPosIni + iSizeCampo;
  end;
end;

procedure TQueryType.LoadFieldsSize(Stream: TStream);
begin
  Stream.Read(Self.FFieldsSize, SizeOf(Self.FFieldsSize));
end;

procedure TQueryType.LoadSizes(Stream: TStream);
begin
  Stream.Read(Self.FSizes, SizeOf(Self.FSizes));
end;

procedure TQueryType.LoadSizesStr(Stream: TStream);
begin
  SetString(Self.FSizesStr, PChar(nil), Self.FSizes);
  Stream.Read(PChar(Self.FSizesStr)^, Self.FSizes * SizeOf('A'));
end;

procedure TQueryType.SaveFields(Stream: TStream);
var
  i: Integer;
  iSize: LongInt;
  sCampos: string;
begin
  sCampos := EmptyStr;

  for i := 0 to Self.Fields.Count - 1 do
    sCampos := sCampos + TFunc.ComponentToString(Self.Fields.Fields[i]);

  iSize := Length(sCampos);
  Stream.Write(PChar(sCampos)^, iSize * SizeOf(sCampos[1]));
end;

procedure TQueryType.SaveFieldsSize(Stream: TStream);
var
  i: Integer;
  sCampos: string;
begin
  sCampos := EmptyStr;

  for i := 0 to Self.Fields.Count - 1 do
    sCampos := sCampos + TFunc.ComponentToString(Self.Fields.Fields[i]);

  Self.FFieldsSize := Length(sCampos);
  Stream.Write(Self.FFieldsSize, Sizeof(Self.FFieldsSize));
end;

procedure TQueryType.SaveSizes(Stream: TStream);
var
  i: Integer;
begin
  Self.FSizesStr := Format('%.8d', [Self.Fields.Count]);

  for i := 0 to Self.Fields.Count - 1 do
    Self.FSizesStr := Self.FSizesStr + Format('%.8d', [Length(TFunc.ComponentToString(Self.Fields.Fields[i]))]);

  Self.FSizes := Length(Self.FSizesStr);
  Stream.Write(FSizes, Sizeof(Self.FSizes));
end;

procedure TQueryType.SaveSizesStr(Stream: TStream);
begin
  Stream.Write(PChar(Self.FSizesStr)^, Self.FSizes * SizeOf('A'));
end;

end.
