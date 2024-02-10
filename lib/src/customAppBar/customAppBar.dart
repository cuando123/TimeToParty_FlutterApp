import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../audio/audio_controller.dart';
import '../audio/sounds.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
  final VoidCallback? onBackButtonPressed;
  final VoidCallback? onMenuButtonPressed;

  const CustomAppBar({super.key, required this.title, this.onBackButtonPressed, this.onMenuButtonPressed});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final audioController = context.watch<AudioController>();
    return AppBar(
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Color(0xFFE5E5E5)),
        onPressed: onBackButtonPressed ?? () {
    GoRouter.of(context).go('/');
    audioController.playSfx(SfxType.buttonBackExit);
    },
    ),
      title: title,
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
          color: Color(0xFFE5E5E5),
          height: 1.0,
          width: double.infinity, // Rozciągnięcie linii na całą szerokość
        ),
      ),
    );
  }
}