unit Tee.Styles;

interface

uses
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
  TeeTriSurface;

type
  TStyle=record Name:String; Series:TChartSeriesClass; end;

const
  Styles:Array[0..50] of TStyle=(
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
     (Name:'EquiVolume';  Series:TEquiVolumeSeries),
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
function FixHorizontal(const AClass:TChartSeriesClass; Horiz:Boolean):TChartSeriesClass;

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

function FixHorizontal(const AClass:TChartSeriesClass; Horiz:Boolean):TChartSeriesClass;
begin
  result:=AClass;

  if Horiz then
  begin
    if result=TLineSeries then result:=THorizLineSeries else
    if result=TBarSeries then result:=THorizBarSeries else
    if result=TAreaSeries then result:=THorizAreaSeries else
    if result=THistogramSeries then result:=THorizHistogramSeries else
    if result=TBoxSeries then result:=THorizBoxSeries else
    if result=TViolinSeries then result:=THorizViolinSeries else
    if result=TBeeSwarmSeries then result:=THorizBeeSwarmSeries;
  end
  else
  begin
    if result=THorizLineSeries then result:=TLineSeries else
    if result=THorizBarSeries then result:=TBarSeries else
    if result=THorizAreaSeries then result:=TAreaSeries else
    if result=THorizHistogramSeries then result:=THistogramSeries else
    if result=THorizBoxSeries then result:=TBoxSeries else
    if result=THorizViolinSeries then result:=TViolinSeries else
    if result=THorizBeeSwarmSeries then result:=TBeeSwarmSeries;
  end;
end;
end.
