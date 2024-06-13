import 'package:flutter/material.dart';
import 'package:flutx/widgets/text/text.dart';

class FxAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String titleText;
  final VoidCallback onBack;
  final VoidCallback onSettings;

  FxAppBar({
    Key? key,
    required this.titleText,
    required this.onBack,
    required this.onSettings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color.fromARGB(255, 1, 67, 3),
      title: FxText.headlineMedium(
        titleText,
        fontWeight: 900,
        fontSize: MediaQuery.of(context).size.width * 0.05,
        color: Colors.white,
      ),
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.white),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: onBack,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: onSettings,
        )
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
