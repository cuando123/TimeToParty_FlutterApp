import 'package:flutter/material.dart';

class CustomAppBar_notitle extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackButtonPressed;
  final VoidCallback? onMenuButtonPressed;

  CustomAppBar_notitle(
      {required this.title,
      this.onBackButtonPressed,
      this.onMenuButtonPressed});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          icon: Icon(Icons.more_horiz),
          onPressed: onMenuButtonPressed,
          color: Colors.white,
        ),
      ],
    );
  }
}
