class ChartData<X, Y> {
  final X x;
  final Y y;
  final String xToString;
  final String? yToString;

  ChartData(this.x, this.y, this.xToString, {this.yToString});
}
