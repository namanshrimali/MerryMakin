import 'package:flutter/material.dart';

class ProFutureWrapper<T> extends StatelessWidget {
  final Future<T?> future;
  final Future<bool> isTableEmptyFuture;
  final Function(BuildContext, T?) childOnDataLoad;
  final Function(BuildContext) childOnTableEmpty;
  final bool displayLoadingWidgetOnDataLoad;
  const ProFutureWrapper({super.key, required this.future, required this.childOnDataLoad, required this.isTableEmptyFuture, required this.childOnTableEmpty, this.displayLoadingWidgetOnDataLoad = true});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Future.wait([future, isTableEmptyFuture]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (displayLoadingWidgetOnDataLoad && (snapshot.connectionState == ConnectionState.waiting || snapshot.data == null)) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data![1]) {
            return childOnTableEmpty(context);
          }
          return childOnDataLoad(context, snapshot.data![0] as T?);
        });
  }
}
