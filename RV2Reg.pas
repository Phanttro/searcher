unit RV2Reg;

interface

uses
  DesignIntf, DesignEditors, VCLEditors, Windows, Graphics, ImgList, TypInfo,
  SysUtils, Classes, FireDAC.VCLUI.QEdit, DSDesign, untFuncoes, ColnEdit, DB,
  Dialogs, uConsts, cxEdit, cxGridReg, FireDAC.VCLUI.Fields, untQueryType;

type
  TSearcherEditor = class(TDefaultEditor)
  private
    FOldEditor: TComponentEditor;
  public
    constructor Create(AComponent: TComponent; ADesigner: IDesigner); override;
    procedure Edit; override;
    function GetVerbCount: Integer; override;
    function GetVerb(Index: Integer): string; override;
    procedure ExecuteVerb(Index: Integer); override;
    procedure Copy; override;
    procedure ShowEditor;
  end;

  TButtonSearcherEditor = class(TComponentEditor)
    procedure Edit; override;
    function GetVerbCount: Integer; override;
    function GetVerb(Index: Integer): string; override;
    procedure ExecuteVerb(Index: Integer); override;
    procedure ShowEditor;
  end;

  { TCampoPesquisaFieldStrProperty }

  TCampoPesquisaFieldStrProperty = class(TStringProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure GetValueList(AList: TStrings); virtual;
    procedure GetValues(Proc: TGetStrProc); override;
    procedure SetValue(const Value: string); override;
  end;

  { TCampoPesquisaFieldCompProperty }

  TCampoPesquisaFieldCompProperty = class(TComponentProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure GetValueList(AList: TStrings); virtual;
    procedure GetValues(Proc: TGetStrProc); override;
    procedure SetValue(const Value: string); override;
  end;

  { TCampoPesquisaControleVisualProperty }

  TCampoPesquisaControleVisualProperty = class(TComponentProperty)
  public
    procedure SetValue(const Value: string); override;
  end;

  { TCustomCampoPesquisaPropertiesProperty }

type
  TCustomCampoPesquisaPropertiesProperty = class(TClassProperty)
  protected
    function HasSubProperties: Boolean;
  public
    function GetAttributes: TPropertyAttributes; override;
    function GetValue: string; override;
    procedure GetValues(Proc: TGetStrProc); override;
    procedure SetValue(const Value: string); override;
  end;

  { TSearcherOrderByProperty }

  TSearcherOrderByProperty = class(TStringProperty)
  private
    procedure ShowDesigner;
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure Edit; override;
  end;

  { TCampoPesquisaOrderByProperty }

  TCampoPesquisaOrderByProperty = class(TStringProperty)
  private
    procedure ShowDesigner;
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure Edit; override;
  end;

procedure Register;

implementation

{$R Icones.dcr}

uses
  untSearcher, Vcl.Controls;

var
  PrevEditorClass: TComponentEditorClass = nil;

procedure Register;
var
  tmpSearcher: TSearcher;
  searcherEditor: IComponentEditor;
begin
  tmpSearcher := TSearcher.Create(nil);

  try
    searcherEditor := GetComponentEditor(tmpSearcher, nil);

    if Assigned(searcherEditor) then
      PrevEditorClass := TComponentEditorClass((searcherEditor AS TObject).ClassType);
  finally
    searcherEditor := nil;
    tmpSearcher.Free;
  end;

  RegisterComponents('RV2', [TQueryType, TSearcher, TButtonSearcher]);
  RegisterComponentEditor(TSearcher, TSearcherEditor);
  RegisterComponentEditor(TButtonSearcher, TButtonSearcherEditor);
  RegisterPropertyEditor(TypeInfo(string), TCampoPesquisa, 'FieldName', nil);
  RegisterPropertyEditor(TypeInfo(TField), TCampoPesquisa, 'Field',
     TCampoPesquisaFieldCompProperty);
  RegisterPropertyEditor(TypeInfo(TcxCustomEditProperties), TCampoPesquisa,
    'Properties', TCustomCampoPesquisaPropertiesProperty);
  RegisterPropertyEditor(TypeInfo(string), TCampoPesquisa, 'ControleVisualClassName', nil);
  RegisterPropertyEditor(TypeInfo(string), TCampoPesquisa, 'PropertiesClassName', nil);
  RegisterPropertyEditor(TypeInfo(string), TCampoPesquisa, 'OrderBy', TCampoPesquisaOrderByProperty);
  RegisterPropertyEditor(TypeInfo(TControl), TCampoPesquisa, 'ControleVisual', TCampoPesquisaControleVisualProperty);
  RegisterPropertyEditor(TypeInfo(string), TSearcher, 'OrderBy', TSearcherOrderByProperty);
end;

{ TButtonSearcherEditor }

procedure TSearcherEditor.Copy;
begin
  (Component as TSearcher).CopyToClipboard;
end;

constructor TSearcherEditor.Create(AComponent: TComponent;
  ADesigner: IDesigner);
begin
  inherited Create(AComponent, ADesigner);

  if Assigned(PrevEditorClass) then
    FOldEditor := TComponentEditor(PrevEditorClass.Create(AComponent, ADesigner));
end;

procedure TSearcherEditor.Edit;
begin
  ShowEditor;
end;

procedure TSearcherEditor.ExecuteVerb(Index: Integer);
var
  tmpName: string;
begin
  inherited;

  tmpName := (Component as TSearcher).Name + '.' + (Component as TSearcher).Query.Name;

  case Index of
    0: begin
         if (Component as TSearcher).Query.Connection <> nil then begin
           if Trim((Component as TSearcher).Query.SQL.Text) <> EmptyStr then begin
             if (Component as TSearcher).Query.Active then
               (Component as TSearcher).Query.Close
             else
               (Component as TSearcher).Query.Open;
           end else
             TFunc.MsgDlg('Não foi definido SQL da query:' + #13 + tmpName + '!');
         end else
           TFunc.MsgDlg('Não foi definido a conexão da query:' + #13 + tmpName + '!');
       end;
    1: TfrmFDGUIxFormsQEdit.Execute((Component as TSearcher).Query, (Component as TSearcher).Query.Name);
    2: ShowFieldsEditor(Designer, (Component as TSearcher).Query, TDSDesigner);
  end;
end;

function TSearcherEditor.GetVerb(Index: Integer): string;
begin
  case Index of
    0: Result := '&Open/Close Query...';
    1: Result := '&Query Editor...';
    2: Result := '&Fields Editor...';
  end;
end;

function TSearcherEditor.GetVerbCount: Integer;
begin
  Result := 3;
end;

procedure TSearcherEditor.ShowEditor;
begin
  //ExecuteVerb(2);
  ShowCollectionEditor(Designer, Component,
    (Component as TSearcher).CamposPesquisa,
    'CamposPesquisa');
end;

{ TButtonSearcherEditor }

procedure TButtonSearcherEditor.Edit;
begin
  ShowEditor;
end;

procedure TButtonSearcherEditor.ExecuteVerb(Index: Integer);
var
  tmpName: string;
begin
  inherited;

  tmpName := (Component as TButtonSearcher).Name + '.' + (Component as TButtonSearcher).Query.Name;

  case Index of
    0: begin
         if (Component as TButtonSearcher).Query.Connection <> nil then begin
           if Trim((Component as TButtonSearcher).Query.SQL.Text) <> EmptyStr then begin
             if (Component as TButtonSearcher).Query.Active then
               (Component as TButtonSearcher).Query.Close
             else
               (Component as TButtonSearcher).Query.Open
           end else
             TFunc.MsgDlg('Não foi definido SQL da query:' + #13 + tmpName + '!');
         end else
           TFunc.MsgDlg('Não foi definido a conexão da query:' + #13 + tmpName + '!');
       end;
    1: TfrmFDGUIxFormsQEdit.Execute((Component as TButtonSearcher).Query, (Component as TButtonSearcher).Query.Name);
    2: ShowFieldsEditor(Designer, (Component as TButtonSearcher).Query, TDSDesigner);
  end;
end;

function TButtonSearcherEditor.GetVerb(Index: Integer): string;
begin
  case Index of
    0: Result := '&Open/Close Query...';
    1: Result := '&Query Editor...';
    2: Result := '&Fields Editor...';
  end;
end;

function TButtonSearcherEditor.GetVerbCount: Integer;
begin
  Result := 3;
end;

procedure TButtonSearcherEditor.ShowEditor;
begin
  //ExecuteVerb(2);
  ShowCollectionEditor(Designer, Component,
    (Component as TButtonSearcher).Searcher.CamposPesquisa,
    'CamposPesquisa');
end;

{ TCampoPesquisaFieldStrProperty }

function TCampoPesquisaFieldStrProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paValueList, paSortList, paMultiSelect];
end;

procedure TCampoPesquisaFieldStrProperty.GetValueList(AList: TStrings);
var
  i: Integer;
  Component: TComponent;
begin
   if (TObject(Component) is TComponent) and
    (Component.Owner = Self.Designer.GetRoot) and
    (Self.Designer.GetRoot.Name <> '') then

  if Assigned(TCampoPesquisa(GetComponent(0)).DataSet) then begin
    with TCampoPesquisa(GetComponent(0)).DataSet do
      for i := 0 to FieldCount - 1 do
        if(Fields[i].Owner = Owner)
        and (Fields[i].FieldName <> '')then
          AList.Add(Fields[i].FieldName);
  end;
end;

procedure TCampoPesquisaFieldStrProperty.GetValues(Proc: TGetStrProc);
var
  I: Integer;
  Values: TStringList;
begin
  Values := TStringList.Create;
  try
    GetValueList(Values);
    for I := 0 to Values.Count - 1 do Proc(Values[I]);
  finally
    Values.Free;
  end;
end;

procedure TCampoPesquisaFieldStrProperty.SetValue(const Value: string);
begin
  if Value <> EmptyStr then begin
    if Assigned(TCampoPesquisa(GetComponent(0)).DataSet) then begin
      if Assigned(TCampoPesquisa(GetComponent(0)).DataSet.FindField(Value)) then
        inherited SetValue(Value)
      else
        Showmessage('Campo não encontrado!');
    end;
  end;
end;

{ TCampoPesquisaFieldCompProperty }

function TCampoPesquisaFieldCompProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paValueList, paSubProperties, paSortList];
end;

procedure TCampoPesquisaFieldCompProperty.GetValueList(AList: TStrings);
var
  i : Integer;
begin
  if Assigned(TCampoPesquisa(GetComponent(0)).DataSet) then begin
    with TCampoPesquisa(GetComponent(0)).DataSet do
      for i := 0 to FieldCount - 1 do
        if(Fields[i].Owner = Owner)
        and (Fields[i].FieldName <> '')then
          AList.Add(Fields[i].FieldName);
  end;
end;

procedure TCampoPesquisaFieldCompProperty.GetValues(Proc: TGetStrProc);
var
  I: Integer;
begin
  if Assigned(TCampoPesquisa(GetComponent(0)).DataSet) then begin
    for I := 0 to Pred(TCampoPesquisa(GetComponent(0)).DataSet.Fields.Count) do
      Proc(TCampoPesquisa(GetComponent(0)).DataSet.Fields.Fields[I].FieldName);
  end;
end;

procedure TCampoPesquisaFieldCompProperty.SetValue(const Value: string);
var
  Component: TComponent;
begin
  if Value = '' then begin
    Component := nil;
    TCampoPesquisa(GetComponent(0)).FieldName := Value;
  end else begin
    Component := TField(TFunc.FindComponent(nil, TCampoPesquisa(GetComponent(0)), Value));

    if Component = nil then begin
      if Assigned(TCampoPesquisa(GetComponent(0)).DataSet) then begin
        if Assigned(TCampoPesquisa(GetComponent(0)).DataSet.FindField(Value)) then begin
          Component := TCampoPesquisa(GetComponent(0)).DataSet.FindField(Value);
          TCampoPesquisa(GetComponent(0)).FieldName := Component.Name;
        end else begin
          TCampoPesquisa(GetComponent(0)).FieldName := EmptyStr;
          raise EDesignPropertyError.CreateRes(@SInvalidPropertyValue);
        end;
      end else begin
        Component := nil;
        TCampoPesquisa(GetComponent(0)).FieldName := EmptyStr;
      end;
    end else
      TCampoPesquisa(GetComponent(0)).FieldName := Value;
  end;

  SetOrdValue(LongInt(Component));
end;

{ TCustomCampoPesquisaPropertiesProperty }

function TCustomCampoPesquisaPropertiesProperty.HasSubProperties: Boolean;
var
  I: Integer;
begin
  for I := 0 to PropCount - 1 do
  begin
    Result := TCampoPesquisa(GetComponent(I)).Properties <> nil;
    if not Result then Exit;
  end;
  Result := True;
end;

function TCustomCampoPesquisaPropertiesProperty.GetAttributes: TPropertyAttributes;
begin
  Result := inherited GetAttributes;
  if not HasSubProperties then
    Exclude(Result, paSubProperties);
  Result := Result - [paReadOnly] +
    [paValueList, paSortList, paRevertable, paVolatileSubProperties];
end;

function TCustomCampoPesquisaPropertiesProperty.GetValue: string;
begin
  if HasSubProperties then
    Result := GetRegisteredEditProperties.GetDescriptionByClass(
      TCampoPesquisa(GetComponent(0)).Properties.ClassType)
  else
    Result := '';
end;

procedure TCustomCampoPesquisaPropertiesProperty.GetValues(Proc: TGetStrProc);
var
  I: Integer;
  ADesc: string;
begin
  for I := 0 to GetRegisteredEditProperties.Count - 1 do begin
    ADesc := GetRegisteredEditProperties.Descriptions[I];

    if ADesc <> '' then
      Proc(ADesc);
  end;
end;

procedure TCustomCampoPesquisaPropertiesProperty.SetValue(const Value: string);
var
  APropertiesClass: TcxCustomEditPropertiesClass;
  I: Integer;
begin
  APropertiesClass := TcxCustomEditPropertiesClass(GetRegisteredEditProperties.FindByClassName(Value));

  if APropertiesClass = nil then
    APropertiesClass := TcxCustomEditPropertiesClass(GetRegisteredEditProperties.FindByDescription(Value));

  for I := 0 to PropCount - 1 do
    TCampoPesquisa(GetComponent(I)).PropertiesClass := APropertiesClass;

  Modified;
end;

{ TSearcherOrderByProperty }

procedure TSearcherOrderByProperty.Edit;
begin
  ShowDesigner;
end;

function TSearcherOrderByProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog];
end;

procedure TSearcherOrderByProperty.ShowDesigner;
var
  tmpValue: string;
begin
  tmpValue := Value;

  if TSearcher(GetComponent(0)).Query <> nil then begin
    if TfrmFDGUIxFormsFields.EditFields(tmpValue, TSearcher(GetComponent(0)).Query, 'Selecionar lista de campos da ordenação') then
      SetStrValue(tmpValue);
  end;

  Designer.Modified;
end;

{ TCampoPesquisaOrderByProperty }

procedure TCampoPesquisaOrderByProperty.Edit;
begin
  ShowDesigner;
end;

function TCampoPesquisaOrderByProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog];
end;

procedure TCampoPesquisaOrderByProperty.ShowDesigner;
var
  tmpValue: string;
begin
  tmpValue := Value;

  if TCampoPesquisa(GetComponent(0)).DataSet <> nil then begin
    if TfrmFDGUIxFormsFields.EditFields(tmpValue, TCampoPesquisa(GetComponent(0)).DataSet, 'Selecionar lista de campos da ordenação') then
      SetStrValue(tmpValue);
  end;

  Designer.Modified;
end;

{ TCampoPesquisaControleVisualProperty }

procedure TCampoPesquisaControleVisualProperty.SetValue(const Value: string);
begin
  TCampoPesquisa(GetComponent(0)).ControleVisualClassName := Value;
  Inherited SetValue(Value);
end;

end.
