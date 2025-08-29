import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LabelTextBox extends StatelessWidget{

  final bool isButtonPressed;
  final TextEditingController textEditingController;

  const LabelTextBox({
    super.key,
    required this.isButtonPressed,
    required this.textEditingController
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: TextFormField(
        cursorColor: Colors.white,
        controller: textEditingController,
        style: const TextStyle(
          color: Colors.white,
        ),
        enabled: isButtonPressed,
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.enterLabel,
        ),
      ),
    );
  }
}