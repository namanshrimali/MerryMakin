import 'package:flutter/material.dart';
import 'package:merrymakin/commons/widgets/pro_text.dart';

class ProTabView extends StatefulWidget {
  final List<Widget> children;
  final List<String> childrenTabTitle;
  final bool showDivider;
  final EdgeInsets? tabPadding;
  final double? height;
  const ProTabView({
    super.key, 
    required this.children, 
    required this.childrenTabTitle,
    this.showDivider = true,
    this.tabPadding,
    this.height,
  });

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
    super.initState();
    _tabController = TabController(length: widget.children.length, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _buildTabs();
  }

  void _buildTabs() {
    myTabs = widget.childrenTabTitle.map((title) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Tab(
          child: ProText(
            title,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }).toList();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging || _tabController.index != _tabIndex) {
      setState(() {
        _tabIndex = _tabController.index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    
    return Column(
      children: <Widget>[
        Container(
          child: TabBar(
            controller: _tabController,
            tabs: myTabs,
            tabAlignment: TabAlignment.start,
            // physics: const BouncingScrollPhysics(),
            isScrollable: true,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              color: colorScheme.primaryContainer.withOpacity(isDark ? 0.4 : 0.3),
              border: Border.all(
                color: colorScheme.primary.withOpacity(0.6),
                width: 1.5,
              ),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorPadding: EdgeInsets.zero,
            indicatorWeight: 0,
            dividerColor: Colors.transparent,
            labelPadding: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            overlayColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.pressed)) {
                  return colorScheme.primary.withOpacity(0.1);
                }
                return null;
              },
            ),
            labelColor: colorScheme.primary,
            unselectedLabelColor: colorScheme.onSurface.withOpacity(0.7),
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              letterSpacing: 0.2,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              letterSpacing: 0.2,
            ),
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 60),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.05, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              ),
            );
          },
          child: SizedBox(height: widget.height ?? 400, child: TabBarView(controller: _tabController,  children: widget.children))

        ),
      ],
    );
  }
}