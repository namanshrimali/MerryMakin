import 'package:flutter/material.dart';

class ProListView extends StatelessWidget {
  final List<Widget> listItems;
  final double height;
  final ScrollController? scrollController;

  const ProListView(
      {super.key, required this.listItems, this.scrollController, required this.height});


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.builder(
        controller: scrollController,
        itemCount: listItems.length,
        itemBuilder: (BuildContext context, int index) {
          return listItems[index];
        },
      ),
    );
  }
}
