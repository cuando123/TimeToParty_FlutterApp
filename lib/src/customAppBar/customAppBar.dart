import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Color(0xFFE5E5E5)),
        onPressed: onBackButtonPressed ?? () => GoRouter.of(context).go('/'),
      ),
      title: Text(title,
          style: TextStyle(
            color: Color(0xFFE5E5E5),
            fontFamily: 'HindMadurai',
            fontSize: 16,
          )
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Icons.more_horiz, color: Color(0xFFE5E5E5)),
          onPressed: onMenuButtonPressed,
        ),
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1.0),
        child: Container(
          color: Color(0xFFE5E5E5), // Kolor linii
          height: 1.0, // Grubość linii
          width: double.infinity, // Rozciągnięcie linii na całą szerokość
        ),
      ),
    );

  }


}