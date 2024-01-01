import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../style/palette.dart';

class GlobalLoadingIndicator extends StatelessWidget {
  const GlobalLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LoadingStatus>(
      builder: (context, loadingStatus, child) {
        if (loadingStatus.isLoading) {
          return Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: CircularProgressIndicator(color: Palette().pink),
            ),
          );
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }
}