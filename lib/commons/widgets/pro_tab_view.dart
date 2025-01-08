import 'package:flutter/material.dart';

class ProTabView extends StatefulWidget {
  final List<Widget> children;
  final List<String> childrenTabTitle;
  
  const ProTabView({super.key, required this.children, required this.childrenTabTitle});

  @override
  State<ProTabView> createState() => _ProTabViewState();
}

class _ProTabViewState extends State<ProTabView> with SingleTickerProviderStateMixin  {
  late List<Widget> myTabs;
  late TabController _tabController;
  int _tabIndex = 0;

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    myTabs = widget.childrenTabTitle.map((title) => Tab(text: title,)).toList();
    _tabController = TabController(length: widget.children.length, vsync: this);
    _tabController.addListener(_handleTabSelection);
    super.initState();
  }

  _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _tabIndex = _tabController.index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TabBar(
            controller: _tabController,
            tabs: myTabs,
          ),
          widget.children[_tabIndex],
        ],
      );
  }
}