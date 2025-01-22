import 'package:flutter/material.dart';

class CustomTabBar extends StatefulWidget {
  final List<String> tabs;
  final List<Widget> screens;
  final Function(int) onTabChanged;
 final int initialIndex;
  const CustomTabBar({
    super.key,
    required this.tabs,
    required this.screens,
    required this.onTabChanged,
    required this.initialIndex
  });

  @override
  _CustomTabBarState createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.tabs.length, vsync: this, initialIndex: widget.initialIndex);
    _pageController = PageController(initialPage: widget.initialIndex);
    _tabController.addListener(_handleTabSelection);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      _pageController.jumpToPage(_tabController.index); // Jump to the selected tab
      widget.onTabChanged(_tabController.index); // Notify parent about the change
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: Colors.blueGrey[900],
          unselectedLabelColor: Colors.black54,
          indicatorColor: Colors.blueGrey[900],
          isScrollable: true,
          tabs: widget.tabs.map((tab) => Tab(text: tab)).toList(),
        ),
        Expanded(
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              _tabController.index = index; // Sync tab selection
              widget.onTabChanged(index); // Notify parent about the change
            },
            children: widget.screens,
          ),
        ),
      ],
    );
  }
}
