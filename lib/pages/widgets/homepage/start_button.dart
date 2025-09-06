import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ttkapp/pages/widgets/common/common_text.dart';

class StartButton extends StatelessWidget {
  final bool isPageStable;
  final bool isButtonPressed;
  final VoidCallback onPressed;

  const StartButton({
    super.key,
    required this.isPageStable,
    required this.isButtonPressed,
    required this.onPressed
  });

  @override
  Widget build(BuildContext context) {
    VoidCallback pressFunction = () {};
    String textField = AppLocalizations.of(context)!.defaultText;

    if (isButtonPressed) {
      textField = AppLocalizations.of(context)!.finish;
    } else {
      textField = AppLocalizations.of(context)!.start;
    }

    if (isPageStable) {
      pressFunction = onPressed;
    } else {
      pressFunction = () {};
      textField = AppLocalizations.of(context)!.pleaseWait;
    }

    return TextButton(
      onPressed: pressFunction,
      style: TextButton.styleFrom(
        backgroundColor: Colors.red,
        minimumSize: const Size(150, 50),
      ),
      child: CommonText(text: textField, fontSize: 20),
    );
  }
}