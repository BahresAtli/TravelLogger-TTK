import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ttkapp/pages/widgets/common/common_snackbar.dart';

class LabelTextBox extends StatelessWidget{

  final bool isButtonPressed;
  final TextEditingController textEditingController;
  final Function buttonsPressed;

  const LabelTextBox({
    super.key,
    required this.isButtonPressed,
    required this.textEditingController,
    required this.buttonsPressed
  });

  @override
  Widget build(BuildContext context) {
    Color boxColor = Colors.white70;

    if (!isButtonPressed) {
      boxColor = const Color.fromARGB(97, 30, 30, 30);
    }
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
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: 0,
            children: [
              IconButton(
                onPressed: () {
                  buttonsPressed(1);
                  ScaffoldMessenger.of(context).removeCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    CommonSnackbar.create(AppLocalizations.of(context)!.copiedClipboard),
                  );
                },
                icon: Icon(
                  Icons.copy,
                  color: boxColor,
                ),
                iconSize: 15,
              ),
              IconButton(
                onPressed: () {
                  buttonsPressed(2);
                  ScaffoldMessenger.of(context).removeCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    CommonSnackbar.create(AppLocalizations.of(context)!.pastedClipboard),
                  );
                },
                icon: Icon(
                  Icons.paste,
                  color: boxColor,
                ),
                iconSize: 15,
              ),
              IconButton(
                onPressed: () {
                  buttonsPressed(3);
                  ScaffoldMessenger.of(context).removeCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    CommonSnackbar.create(AppLocalizations.of(context)!.cleared),
                  );
                },
                icon: Icon(
                  Icons.clear, 
                  color: boxColor,
                ),
                iconSize: 15,
              )
            ],
          ),
        ),
      ),
    );
  }
}