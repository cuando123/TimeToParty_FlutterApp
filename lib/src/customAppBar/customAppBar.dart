import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackButtonPressed;
  final VoidCallback? onMenuButtonPressed;

  CustomAppBar({required this.title, this.onBackButtonPressed, this.onMenuButtonPressed});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: onBackButtonPressed ?? () => Navigator.pop(context),
      ),
      title: Text(title),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Icons.more_horiz),
          onPressed: onMenuButtonPressed,
        ),
      ],
    );
  }


}