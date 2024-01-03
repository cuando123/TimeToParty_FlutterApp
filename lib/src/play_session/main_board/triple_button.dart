import 'package:flutter/material.dart';
import 'package:game_template/src/app_lifecycle/responsive_sizing.dart';
import 'package:provider/provider.dart';

import '../../audio/audio_controller.dart';
import '../../audio/sounds.dart';
import '../../instruction_dialog/instruction_dialog.dart';
import '../../style/palette.dart';

class TripleButton extends StatelessWidget {
  final AnimationController _controller;
  final VoidCallback showExitGameDialogCallback;

  const TripleButton(this._controller, this.showExitGameDialogCallback, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ResponsiveSizing.scaleWidth(context, 260),
      height: ResponsiveSizing.scaleHeight(context, 50),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Palette().pink,
            Color(0xFF5E0EAD),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Color(0xFF5E0EAD),
          width: 2.0,
        ), // Dodaj podwójną białą obwódkę
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.3),
            offset: Offset(4, 4),
            blurRadius: 10,
            spreadRadius: -3,
          ),
          BoxShadow(
            color: Colors.deepPurpleAccent.withOpacity(0.7),
            offset: Offset(-6, -4),
            blurRadius: 10,
            spreadRadius: -3,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildButtonIcon(context, Icons.home_rounded, showExitGameDialogCallback),
          _buildButtonIcon(context, Icons.info_outlined, () {
            Future.delayed(Duration(milliseconds: 150), () {
              showDialog<void>(
                context: context,
                builder: (context) {
                  return InstructionDialog(isGameOpened: true);
                },
              );
            });
          }),
          _buildButtonIcon(context, Icons.highlight, () {
            _controller.forward(from: 0); // Obsłuż tapnięcie w prawy przycisk
          }),
        ],
      ),
    );
  }

  Widget _buildButtonIcon(BuildContext context, IconData icon, VoidCallback originalOnTap) {
    return GestureDetector(
      onTap: () {
        final audioController = context.read<AudioController>();
        if (icon == Icons.info_outlined){
          audioController.playSfx(SfxType.button_infos);
        } else {
          audioController.playSfx(SfxType.button_back_exit);
        }
        originalOnTap();
      },
      child: Container(
        width: ResponsiveSizing.scaleWidth(context, 70),
        height: ResponsiveSizing.scaleHeight(context, 100),
        alignment: Alignment.center,
        child: Icon(icon, color: Colors.white, size: ResponsiveSizing.scaleWidth(context, 28)),
      ),
    );
  }
}