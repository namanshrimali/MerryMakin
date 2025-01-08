import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScaffoldNavigationNotifier extends StateNotifier<int> {
  ScaffoldNavigationNotifier() : super(0);

  void gotoNewPage(int newPageIndex) {
    state = newPageIndex;
  }
}

final pageIndexProvider = StateNotifierProvider<ScaffoldNavigationNotifier, int>((ref) {
  return ScaffoldNavigationNotifier();
});
