{*********************************************}
{  TeeBI Software Library                     }
{  Base Array helper classes                  }
{  Copyright (c) 2015-2016 by Steema Software }
{  All Rights Reserved                        }
{*********************************************}
unit BI.Arrays;

// Supported from ide XE4 and up (needed: record helpers)

{$IF Declared(CompilerVersion)}
{$IF CompilerVersion>=25}
{$EXCESSPRECISION OFF} // x64 "to double" speedup (less precission)
{$ENDIF}
{$ENDIF}

interface

uses
  System.SysUtils, System.DateUtils;

{$IF Declared(CompilerVersion)}
{$IF COMPILERVERSION>28}
{.$DEFINE DELETEARRAY} // Very Slow !!!
{$ENDIF}
{$ENDIF}

type
  EBIException=class(Exception);

  TInteger=Int64;  // Alternative: Integer (32bit)
  TFloat=Double;   // Default float type: 8 bytes

  {$IF Declared(CompilerVersion)}
  TLoopInteger={$IF COMPILERVERSION>28}TInteger{$ELSE}Integer{$ENDIF};
  {$ELSE}
  TLoopInteger=Integer;
  {$ENDIF}

  TBooleanArray=Array of Boolean;
  TTextArray=Array of String;
  TDateTimeArray=Array of TDateTime;

  TInt32Array=Array of Integer;
  TInt64Array=Array of Int64;
  TSingleArray=Array of Single;
  TDoubleArray=Array of Double;

  TExtendedArray={$IFDEF CPUX86}Array of Extended{$ELSE}TDoubleArray{$ENDIF};

  TFloatGrid=Array of TDoubleArray;
  TSquareGrid=type TFloatGrid;

  TDataOrder=(None, Ascending, Descending);

  TDataOrderHelper=record helper for TDataOrder
  public
    function ToString:String;
  end;

  TDataMap=class
  public
    Map : TInt64Array;
    Sorted : TDataOrder;

    CachedCount : TInteger;

    function AsString(const Index:TInteger):String; virtual; abstract;
    procedure Clear; virtual;
    function Count:TInteger; inline;
  end;

  TInt32Map=class(TDataMap)
  private
    function GetItem(const Index:TInteger):Integer; inline;
  public
    Items : TInt32Array;

    procedure AddMap(const Value:Integer);
    function AsString(const Index:TInteger):String; override;
    procedure Clear; override;
    function Find(const Value:Integer; out Index: TInteger):Boolean;

    property Item[const Index:TInteger]:Integer read GetItem; default;
  end;

  TInt64Map=class(TDataMap)
  private
    function GetItem(const Index:TInteger):Int64; inline;
  public
    Items : TInt64Array;

    procedure AddMap(const Value:Int64);
    function AsString(const Index:TInteger):String; override;
    procedure Clear; override;
    function Find(const Value:Int64; out Index: TInteger):Boolean;

    property Item[const Index:TInteger]:Int64 read GetItem; default;
  end;

  TSingleMap=class(TDataMap)
  private
    function GetItem(const Index:TInteger):Single; inline;
  public
    Items : TSingleArray;

    procedure AddMap(const Value:Single);
    function AsString(const Index:TInteger):String; override;
    procedure Clear; override;
    function Find(const Value:Single; out Index: TInteger):Boolean;

    property Item[const Index:TInteger]:Single read GetItem; default;
  end;

  TDoubleMap=class(TDataMap)
  private
    function GetItem(const Index:TInteger):Double; inline;
  public
    Items : TDoubleArray;

    procedure AddMap(const Value:Double);
    function AsString(const Index:TInteger):String; override;
    procedure Clear; override;
    function Find(const Value:Double; out Index: TInteger):Boolean;

    property Item[const Index:TInteger]:Double read GetItem; default;
  end;

  {$IFDEF CPUX86}
  TExtendedMap=class(TDataMap)
  private
    function GetItem(const Index:TInteger):Extended; inline;
  public
    Items : TExtendedArray;

    procedure AddMap(const Value:Extended);
    function AsString(const Index:TInteger):String; override;
    procedure Clear; override;
    function Find(const Value:Extended; out Index: TInteger):Boolean;

    property Item[const Index:TInteger]:Extended read GetItem; default;
  end;
  {$ELSE}
  TExtendedMap=TDoubleMap;
  {$ENDIF}

  TDateTimeMap=class(TDataMap)
  private
    function GetItem(const Index:TInteger):TDateTime; inline;
  public
    Items : TDateTimeArray;

    procedure AddMap(const Value:TDateTime);
    function AsString(const Index:TInteger):String; override;
    procedure Clear; override;
    function Find(const Value:TDateTime; out Index: TInteger):Boolean;

    property Item[const Index:TInteger]:TDateTime read GetItem; default;
  end;

  TTextItem=record
    Text : String;
  end;

  TTextItemArray=Array of TTextItem;

  TTextMap=class(TDataMap)
  private
    type
      TCompareProc=function(const S1, S2: string): Integer;

    function GetItem(const Index:TInteger):String; inline;
  public
    Items : TTextItemArray;
    IgnoreCase : Boolean;

    procedure AddMap(const Value:String);
    function AsString(const Index:TInteger):String; override;
    procedure Clear; override;
    function Find(const Value:String; out Index: TInteger):Boolean;

    property Item[const Index:TInteger]:String read GetItem; default;
  end;

  TBooleanMap=class(TDataMap)
  public
    function AsString(const Index:TInteger):String; override;
  end;

  TDataStats=class
  public
    Mean,
    Peakedness, // Kurtosis, L-Moment
    Range,
    Skewness,
    StdDeviation,
    Sum,
    Variance : TFloat;
  end;

  TInt32Stats=class(TDataStats)
  public
    Min,
    Max,
    Median,
    Mode : Integer;
  end;

  TInt64Stats=class(TDataStats)
  public
    Min,
    Max,
    Median,
    Mode : Int64;
  end;

  TSingleStats=class(TDataStats)
  public
    Min,
    Max,
    Median,
    Mode : Single;
  end;

  TDoubleStats=class(TDataStats)
  public
    Min,
    Max,
    Median,
    Mode : Double;
  end;

  {$IFDEF CPUX86}
  TExtendedStats=class(TDataStats)
  public
    Min,
    Max,
    Median,
    Mode : Extended;
  end;
  {$ELSE}
  TExtendedStats=TDoubleStats;
  {$ENDIF}

  TDateTimeStats=class(TDataStats)
  public
    Min,
    Max,
    Median,
    Mode : TDateTime;
  end;

  TBooleanStats=class(TDataStats)
  public
    Min,
    Max,
    Median,
    Mode : Boolean;
  end;

  TTextStats=class(TDataStats)
  public
    Min,
    Max,
    Median,
    Mode : String;
  end;

  TSwapProc=procedure(const A,B:TInteger) of object;

  TBooleanArrayHelper=record helper for TBooleanArray
  public
    procedure Append(const Value:Boolean); overload;
    procedure Append(const Value:TBooleanArray); overload;
    function Compare(const A,B:TInteger):SmallInt; inline;
    function Copy:TBooleanArray;
    function Count:TInteger; inline;
    procedure Delete(const Index:TInteger; const ACount:TInteger=1); {$IFDEF DELETEARRAY}inline;{$ENDIF}
    procedure Empty; inline;
    function Map(const Missing:TBooleanArray):TBooleanMap;
    procedure Resize(const Count:TInteger); inline;
    procedure Sort(const Ascending:Boolean=True); overload;
    procedure Sort(const Ascending:Boolean; const Swap:TSwapProc); overload;
    function Stats:TBooleanStats;
    procedure Swap(const A,B:TInteger);
    procedure Zero(const Value:Boolean=False);
  end;

  TTextArrayHelper=record helper for TTextArray
  private
    function GuessOrder:TDataOrder;
  public
    procedure Append(const Value:String); overload;
    procedure Append(const Value:TTextArray); overload;
    function Copy:TTextArray;
    function Count:TInteger; inline;
    procedure Delete(const Index:TInteger; const ACount:TInteger=1); {$IFDEF DELETEARRAY}inline;{$ENDIF}
    procedure Empty; inline;
    function IndexOf(const Value:String):TInteger;
    function Map(const Missing:TBooleanArray; const IgnoreCase:Boolean=False):TTextMap;
    function MaxLength:Integer;
    procedure Resize(const Count:TInteger); inline;
    procedure Sort(const Ascending:Boolean=True; const IgnoreCase:Boolean=False); overload;
    procedure Sort(const Ascending,IgnoreCase:Boolean; const Swap:TSwapProc); overload;
    function Stats:TTextStats;
    procedure Swap(const A,B:TInteger);
    procedure Zero;
  end;

  TDateTimeArrayHelper=record helper for TDateTimeArray
  private
    function Distribution(const Mean:TDateTime; const StdDeviation:TFloat; const Exponent:Integer):TFloat;
    function GuessOrder:TDataOrder;
  public
    procedure Append(const Value:TDateTime); overload;
    procedure Append(const Value:TDateTimeArray); overload;
    function Copy:TDateTimeArray;
    function Count:TInteger; inline;
    procedure Delete(const Index:TInteger; const ACount:TInteger=1); {$IFDEF DELETEARRAY}inline;{$ENDIF}
    procedure Empty; inline;
    procedure Insert(const Index:TInteger; const Value:TDateTime);
    function Map(const Missing:TBooleanArray; out Median,Mode:TDateTime):TDateTimeMap; overload;
    function Maximum:TDateTime;
    function Mean:TDateTime;
    function Minimum:TDateTime;
    procedure Resize(const Count:TInteger); inline;
    procedure Sort(const Ascending:Boolean=True); overload;
    procedure Sort(const Ascending:Boolean; const Swap:TSwapProc); overload;
    function Stats:TDateTimeStats;
    function StdDeviation(const Mean:TDateTime):TFloat;
    procedure Swap(const A,B:TInteger);
    function Variance(const Mean:TDateTime):TFloat;
    procedure Zero;
  end;

  TInt32ArrayHelper=record helper for TInt32Array
  private
    function Distribution(const Mean,StdDeviation:TFloat; const Exponent:Integer):TFloat;
    function GuessOrder:TDataOrder;
  public
    procedure Append(const Value:Integer); overload;
    procedure Append(const Value:TInt32Array); overload;
    function Copy:TInt32Array;
    function Count:TInteger; inline;
    function Correlation(const Y: TInt32Array; const XMean,YMean: TFloat): TFloat;
    function CoVariance(const Y: TInt32Array; const XMean,YMean: TFloat):TFloat;
    procedure Delete(const Index:TInteger; const ACount:TInteger=1); {$IFDEF DELETEARRAY}inline;{$ENDIF}
    procedure Empty; inline;
    function IndexOf(const Value:Integer):TInteger;
    function IndexOfMax:TInteger;
    procedure Insert(const Index:TInteger; const Value:Integer);
    function Map(const Missing:TBooleanArray; out Median,Mode:Integer):TInt32Map;
    function Maximum:Integer;
    function Mean:TFloat;
    function Minimum:Integer;
    procedure RemoveValue(const Value:Integer);
    procedure Resize(const Count:TInteger); inline;
    procedure Sort(const Ascending:Boolean=True); overload;
    procedure Sort(const Ascending:Boolean; const Swap:TSwapProc); overload;
    function Stats:TInt32Stats;
    function StdDeviation(const Mean:TFloat):TFloat;
    function Sum:TFloat;
    function SumOfSquares: TFloat;
    procedure Swap(const A,B:TInteger);
    function Variance(const Mean:TFloat):TFloat;
    procedure Zero;
  end;

  TInt64ArrayHelper=record helper for TInt64Array
  private
    function Distribution(const Mean,StdDeviation:TFloat; const Exponent:Integer):TFloat;
    function GuessOrder:TDataOrder;
  public
    procedure Append(const Value:Int64); overload;
    procedure Append(const Value:TInt64Array); overload;
    function Copy:TInt64Array;
    function Count:TInteger; inline;
    function Correlation(const Y: TInt64Array; const XMean,YMean: TFloat): TFloat;
    function CoVariance(const Y: TInt64Array; const XMean,YMean: TFloat):TFloat;
    procedure Delete(const Index:TInteger; const ACount:TInteger=1); {$IFDEF DELETEARRAY}inline;{$ENDIF}
    procedure Empty; inline;
    function IndexOf(const Value:Int64):TInteger;
    function IndexOfMax:TInteger;
    procedure Insert(const Index:TInteger; const Value:Int64);
    function Map(const Missing:TBooleanArray; out Median,Mode:Int64):TInt64Map;
    function Maximum:Int64;
    function Mean:TFloat;
    function Minimum:Int64;
    procedure RemoveValue(const Value:Int64);
    procedure Resize(const Count:TInteger); inline;
    procedure Sort(const Ascending:Boolean=True); overload;
    procedure Sort(const Ascending:Boolean; const Swap:TSwapProc); overload;
    function Stats:TInt64Stats;
    function StdDeviation(const Mean:TFloat):TFloat;
    function Sum:TFloat;
    function SumOfSquares: TFloat;
    procedure Swap(const A,B:TInteger);
    function Variance(const Mean:TFloat):TFloat;
    procedure Zero;
  end;

  TSingleArrayHelper=record helper for TSingleArray
  private
    function Distribution(const Mean,StdDeviation:Single; const Exponent:Integer):Single;
    function GuessOrder:TDataOrder;
  public
    procedure Append(const Value:Single); overload;
    procedure Append(const Value:TSingleArray); overload;
    function Copy:TSingleArray;
    function Count:TInteger; inline;
    function Correlation(const Y: TSingleArray; const XMean,YMean: Single): Single;
    function CoVariance(const Y: TSingleArray; const XMean,YMean: Single):Single;
    procedure Delete(const Index:TInteger; const ACount:TInteger=1); {$IFDEF DELETEARRAY}inline;{$ENDIF}
    procedure Empty; inline;
    procedure Insert(const Index:TInteger; const Value:Single);
    function Map(const Missing:TBooleanArray; out Median,Mode:Single):TSingleMap; overload;
    function Maximum:Single;
    function Mean:Single;
    function Minimum:Single;
    procedure Normalize(const Mean:Single);
    procedure Resize(const Count:TInteger); inline;
    procedure Sort(const Ascending: Boolean=True); overload;
    procedure Sort(const Ascending:Boolean; const Swap:TSwapProc); overload;
    function Stats:TSingleStats;
    function StdDeviation(const Mean:Single):Single;
    function Sum:Single;
    function SumOfSquares: Single;
    procedure Swap(const A,B:TInteger);
    function Variance(const Mean:Single):Single;
    procedure Zero;
  end;

  TDoubleArrayHelper=record helper for TDoubleArray
  private
    function Distribution(const Mean,StdDeviation:Double; const Exponent:Integer):Double;
    function GuessOrder:TDataOrder;
  public
    procedure Append(const Value:Double); overload;
    procedure Append(const Value:TDoubleArray); overload;
    function Copy:TDoubleArray;
    function Count:TInteger; inline;
    function Correlation(const Y: TDoubleArray; const XMean,YMean: Double): Double;
    function CoVariance(const Y: TDoubleArray; const XMean,YMean: Double):Double;
    procedure Delete(const Index:TInteger; const ACount:TInteger=1); {$IFDEF DELETEARRAY}inline;{$ENDIF}
    procedure Empty; inline;
    procedure Insert(const Index:TInteger; const Value:Double);
    function Map(const Missing:TBooleanArray; out Median,Mode:Double):TDoubleMap; overload;
    function Maximum:Double;
    function Mean:Double;
    function Minimum:Double;
    procedure Normalize(const Mean:Double);
    procedure Resize(const Count:TInteger); inline;
    procedure Sort(const Ascending: Boolean=True); overload;
    procedure Sort(const Ascending:Boolean; const Swap:TSwapProc); overload;
    function Stats:TDoubleStats;
    function StdDeviation(const Mean:Double):Double;
    function Sum:Double;
    function SumOfSquares: Double;
    procedure Swap(const A,B:TInteger);
    function Variance(const Mean:Double):Double;
    procedure Zero;
  end;

  {$IFDEF CPUX86}
  TExtendedArrayHelper=record helper for TExtendedArray
  private
    function Distribution(const Mean,StdDeviation:Extended; const Exponent:Integer):Extended;
    function GuessOrder:TDataOrder;
  public
    procedure Append(const Value:Extended); overload;
    procedure Append(const Value:TExtendedArray); overload;
    function Copy:TExtendedArray;
    function Count:TInteger; inline;
    function Correlation(const Y: TExtendedArray; const XMean,YMean: Extended): Extended;
    function CoVariance(const Y: TExtendedArray; const XMean,YMean: Extended):Extended;
    procedure Delete(const Index:TInteger; const ACount:TInteger=1); {$IFDEF DELETEARRAY}inline;{$ENDIF}
    procedure Empty; inline;
    procedure Insert(const Index:TInteger; const Value:Extended);
    function Map(const Missing:TBooleanArray; out Median,Mode:Extended):TExtendedMap; overload;
    function Maximum:Extended;
    function Mean:Extended;
    function Minimum:Extended;
    procedure Normalize(const Mean:Extended);
    procedure Resize(const Count:TInteger); inline;
    procedure Sort(const Ascending: Boolean=True); overload;
    procedure Sort(const Ascending:Boolean; const Swap:TSwapProc); overload;
    function Stats:TExtendedStats;
    function StdDeviation(const Mean:Extended):Extended;
    function Sum:Extended;
    function SumOfSquares: Extended;
    procedure Swap(const A,B:TInteger);
    function Variance(const Mean:Extended):Extended;
    procedure Zero;
  end;
  {$ENDIF}

  TSquareGridHelper=record helper for TSquareGrid
  public
    function Count:TInteger; inline;
    procedure MakeIdentity;
    procedure Resize(const Count:TInteger); inline;
    procedure Zero;
  end;

  TFloatGridHelper=record helper for TFloatGrid
  public
    function Count:TInteger; inline;
    function CoVarianceMatrix(const Means:TDoubleArray):TSquareGrid;
    function Means:TDoubleArray;
    procedure Normalize(const Means:TDoubleArray);
    procedure Random;
    procedure Resize(const Cols,Rows:TInteger); inline;
    function ScatterMatrix(const CoVarianceMatrix:TSquareGrid):TSquareGrid;
    procedure Zero;
  end;

implementation