import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class InitializingPage extends StatelessWidget{
  const InitializingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _initializingMessage(context),
          ],
        ),
      ),
    );
  }

  Container _initializingMessage(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Text(
        AppLocalizations.of(context)!.appInitializing,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}