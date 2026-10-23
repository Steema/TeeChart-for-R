unit Tee.Styles;

{$IFNDEF MSWINDOWS}
{$DEFINE FMX}
{$ENDIF}

interface

uses
  {$IFDEF FMX}
  FMXTee.Engine,
  FMXTee.Series,
  FMXTee.Series.Arrow,
  FMXTee.Series.BoxPlot,
  FMXTee.Series.Bubble,
  FMXTee.Series.Candle,
  FMXTee.Series.Donut,
  FMXTee.Series.Error,
  FMXTee.Series.ErrorPoint,
  FMXTee.Functions.Stats,
  FMXTee.Series.Funnel,
  FMXTee.Series.Gantt,
  FMXTee.Series.HighLowLine,
  FMXTee.Series.Kagi,
  FMXTee.Series.OHLC,
  FMXTee.Series.Point3D,
  FMXTee.Series.Polar,
  FMXTee.Series.PolarContour,
  FMXTee.Series.PolarGrid,
  FMXTee.Series.Renko,
  FMXTee.Series.Rose,
  FMXTee.Series.Smith,
  FMXTee.Series.SquarifiedMap,
  FMXTee.Series.Sankey,
  FMXTee.Series.Slope,
  FMXTee.Series.Surface,
  FMXTee.Series.Ternary,
  FMXTee.Series.Tornado,
  FMXTee.Series.TreeMap,
  FMXTee.Series.TriSurface
  {$ELSE}
  TeEngine,

  ArrowCha,
  CandleCh,
  GanttCh,
  Series,
  TeePolar,
  TeeSmith,
  TeeSquarifiedMap,
  TeeTreeMapSeries,
  BubbleCh,
  TeeSankeySeries,
  TeeSlopeSeries,
  TeeSurfa,
  TeeDonut,
  TeeTornadoSeries,
  OHLChart,
  TeeRenkoSeries,
  TeeKagiSeries,
  TeeEquiVolume,
  TeeHistogram,
  StatChar,
  ErrorBar,
  TeeBoxPlot,
  TeeFunnel,
  TeeHighLowLine,
  TeeTernary,
  TeeErrorPoint,
  TeeWorldSeries,
  TeePoin3,
  TeePolarContour,
  TeePolarGrid,
  TeeRose,
  TeeTriSurface
  {$ENDIF};

type
  TStyle=record Name:String; Series:TChartSeriesClass; end;

const
  Styles:Array[0..{$IFDEF FMX}49{$ELSE}50{$ENDIF}] of TStyle=(
     (Name:'Area';        Series:TAreaSeries),
     (Name:'Arrow';       Series:TArrowSeries),
     (Name:'Bar';         Series:TBarSeries),
     (Name:'BeeSwarm';    Series:TBeeSwarmSeries),
     (Name:'BoxPlot';     Series:TBoxSeries),
     (Name:'Bubble';      Series:TBubbleSeries),
     (Name:'Bubble3D';    Series:TBubble3DSeries),
     (Name:'BubbleCloud'; Series:TBubbleCloudSeries),
     (Name:'Candle';      Series:TCandleSeries),
     (Name:'ColorGrid';   Series:TColorGridSeries), // Heatmap
     (Name:'Contour';     Series:TContourSeries),
     (Name:'Darvas';      Series:TDarvasSeries),
     (Name:'Donut';       Series:TDonutSeries),
     {$IFNDEF FMX}
     (Name:'EquiVolume';  Series:TEquiVolumeSeries),
     {$ENDIF}
     (Name:'Error';       Series:TErrorSeries),
     (Name:'Error3D';     Series:TErrorPoint3DSeries),
     (Name:'ErrorBar';    Series:TErrorBarSeries),
     (Name:'ErrorPoint';  Series:TErrorPointSeries),
     (Name:'FastLine';    Series:TFastLineSeries),
     (Name:'Funnel';      Series:TFunnelSeries),
     (Name:'Gantt';       Series:TGanttSeries),
     (Name:'HighLow';     Series:THighLowSeries),
     (Name:'HighLowLine'; Series:THighLowLineSeries),
     (Name:'Histogram';   Series:THistogramSeries),
     (Name:'IsoSurface';  Series:TIsoSurfaceSeries),
     (Name:'Kagi';        Series:TKagiSeries),
     (Name:'Line';        Series:TLineSeries),
     (Name:'Pie';         Series:TPieSeries),
     (Name:'Point';       Series:TPointSeries),
     (Name:'Point3D';     Series:TPoint3dSeries),
     (Name:'PointFigure'; Series:TPointFigureSeries),
     (Name:'Polar';       Series:TPolarSeries),
     (Name:'PolarContour'; Series:TPolarContourSeries),
     (Name:'PolarGrid';   Series:TPolarGridSeries),
     (Name:'PolarBar';    Series:TPolarBarSeries),
     (Name:'Radar';       Series:TRadarSeries),
     (Name:'Renko';       Series:TRenkoSeries),
     (Name:'Rose';        Series:TRoseSeries),
     (Name:'Sankey';      Series:TSankeySeries),
     (Name:'Slope';       Series:TSlopeSeries),
     (Name:'Smith';       Series:TSmithSeries),
     (Name:'Squarified';  Series:TSquarifiedMapSeries),
     (Name:'Surface';     Series:TSurfaceSeries),
     (Name:'Ternary';     Series:TTernarySeries),
     (Name:'Tornado';     Series:TTornadoSeries),
     (Name:'Tower';       Series:TTowerSeries),
     (Name:'TreeMap';     Series:TTreeMapSeries),
     (Name:'TriSurface';  Series:TTriSurfaceSeries),
     (Name:'Vector';      Series:TVector3DSeries),
     (Name:'Violin';      Series:TViolinSeries),
     (Name:'Waterfall';   Series:TWaterFallSeries)
   );

   MapStyles:Array[0..24] of String=(
     'Africa',
     'Asia',
     'Australia',
     'Australia_Counties',
     'Australia_States',
     'CentralAmerica',
     'China',
     'China_Provinces',
     'EurAsia',
     'Europe',
     'Europe15',
     'Europe28',
     'France',
     'Germany',
     'Japan',
     'MiddleEast',
     'NorthAmerica',
     'SouthAmerica',
     'Spain',
     'UK',
     'USA',
     'USA_Alaska',
     'USA_Alaska_Counties',
     'USA_Counties',
     'World'
   );

function StyleFrom(const S:String):TChartSeriesClass;

implementation

uses
  SysUtils;

function StyleFrom(const S:String):TChartSeriesClass;
var t : Integer;
begin
  if S<>'' then
  for t:=Low(Styles) to High(Styles) do
      if SameText(Styles[t].Name,S) then
      begin
        result:=Styles[t].Series;
        Exit;
      end;

  result:=nil;
end;

end.
