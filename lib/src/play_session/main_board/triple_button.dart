import 'package:flutter/material.dart';

import '../../instruction_dialog/instruction_dialog.dart';
import '../../style/palette.dart';

class TripleButton extends StatelessWidget {
  final AnimationController _controller;
  final VoidCallback showExitGameDialogCallback;

  TripleButton(this._controller, this.showExitGameDialogCallback);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: 60,
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
          _buildButtonIcon(Icons.home_rounded, showExitGameDialogCallback),
          _buildButtonIcon(Icons.info_outlined, () {
            Future.delayed(Duration(milliseconds: 150), () {
              showDialog<void>(
                context: context,
                builder: (context) {
                  return InstructionDialog();
                },
              );
            });
          }),
          _buildButtonIcon(Icons.highlight, () {
            _controller.forward(from: 0); // Obsłuż tapnięcie w prawy przycisk
          }),
        ],
      ),
    );
  }

  Widget _buildButtonIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        height: 100,
        alignment: Alignment.center,
        child: Icon(icon, color: Colors.white, size: 32),
      ),
    );
  }
}