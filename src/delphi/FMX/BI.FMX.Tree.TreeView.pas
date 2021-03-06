unit BI.FMX.Tree.TreeView;

interface

uses
  System.Classes,
  FMX.Controls, FMX.TreeView,
  BI.Arrays, BI.FMX.Tree;

type
  TBITreeViewPlugin=class(TBITreePlugin)
  private
    FTree : TTreeView;
  protected
    procedure Clear; override;
    function GetControl:TControl; override;
    function GetCount:Integer; override;
    function GetOnChange: TNotifyEvent; override;
    function GetSelected:TBITreeNode; override;
    function GetSelectedData:TBITreePlugin.TNodeData; override;
    procedure SetOnChange(const Value: TNotifyEvent); override;
  public
    Constructor Create(const AOwner:TComponent); override;

    procedure Expand(const AIndex:Integer); override;
    function Find(const ATag:TObject; const AIndex:Integer):TBITreeNode; override;
    function NewNode(const AParent:TBITreeNode; const AText:String;
              const ATag:TObject=nil;
              const AIndex:TInteger=-1):TBITreeNode; override;
  end;

implementation
