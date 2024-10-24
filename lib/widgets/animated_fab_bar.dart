import 'package:efeone_mobile/view/ECP/Ecp_list_view.dart';
import 'package:efeone_mobile/view/Time%20Sheet/timesheet_list_view.dart';
import 'package:efeone_mobile/view/leave%20application/leavelist_view.dart';
import 'package:flutter/material.dart';

class CustomFABMenu extends StatefulWidget {
  const CustomFABMenu({super.key});

  @override
  _CustomFABMenuState createState() => _CustomFABMenuState();
}

class _CustomFABMenuState extends State<CustomFABMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _toggleMenu() {
    if (_isMenuOpen) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        _buildFABOption(
          icon: Icons.work_history,
          color: Colors.grey[100]!,
          label: 'Timesheet',
          index: 3,
          onTap: () {
            // Navigate to Timesheet
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TimesheetListviewScreen(),
                ));
          },
        ),
        _buildFABOption(
          icon: Icons.beach_access,
          color: Colors.grey[100]!,
          label: 'Leave',
          index: 2,
          onTap: () {
            // Navigate to Leave Application
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LeaveListview(),
                ));
          },
        ),
        _buildFABOption(
          icon: Icons.how_to_reg,
          color: Colors.grey[100]!,
          label: 'ECP',
          index: 1,
          onTap: () {
            // Navigate to Check-in Permission
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CheckinPermissionListScreen(),
                ));
          },
        ),
        _buildFAB(),
      ],
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: _toggleMenu,
      backgroundColor: Colors.grey[100],
      child: AnimatedIcon(
        icon: AnimatedIcons.menu_close,
        progress: _animation,
      ),
    );
  }

  Widget _buildFABOption({
    required IconData icon,
    required Color color,
    required String label,
    required int index,
    required VoidCallback onTap,
  }) {
    final double translation = 80.0 * index;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value * -translation),
          child: Opacity(
            opacity: _animation.value,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton(
                    onPressed: onTap,
                    heroTag: null,
                    backgroundColor: color,
                    child: Icon(icon),
                  ),
                  const SizedBox(width: 8), // Space between icon and text
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
