import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScaffoldNavigationNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void gotoNewPage(int newPageIndex) {
    state = newPageIndex;
  }
}

final pageIndexProvider = NotifierProvider<ScaffoldNavigationNotifier, int>(ScaffoldNavigationNotifier.new);
