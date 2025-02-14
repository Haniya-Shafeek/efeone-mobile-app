import 'package:efeone_mobile/view/search_view.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize;

  const CustomAppBar({super.key})
      : preferredSize = const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Align(
        alignment: Alignment.centerLeft,
        child: Image.asset(
          'assets/images/efeone Logo.png',
          width: MediaQuery.of(context).size.width * 0.2,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SearchScreen()),
              // (route) =>
              //     route.isFirst,
            );
          },
          icon: const Icon(
            Icons.search,
            color: Color.fromARGB(255, 2, 51, 91),
            size: 28,
          ),
        ),
        const SizedBox(
          width: 20,
        ),
      ],
    );
  }
}
