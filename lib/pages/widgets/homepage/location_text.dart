import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ttkapp/core/utility/location_utility.dart';
import 'package:ttkapp/pages/widgets/common_text.dart';

class LocationText extends StatelessWidget{
  final bool isPageStable;
  final bool isButtonPressed;
  final bool isLocationEnabled;
  final bool isStartConfigDone;
  final LocationUtility utilLocation;

  const LocationText({
    super.key,
    required this.isPageStable,
    required this.isButtonPressed,
    required this.isLocationEnabled,
    required this.isStartConfigDone,
    required this.utilLocation
  });

  @override
  Widget build(BuildContext context) {
    String textField = AppLocalizations.of(context)!.seeLocation;

    if (!isPageStable) {
      textField = AppLocalizations.of(context)!.waitDbAdjust;
    }

    if (isButtonPressed) {
      if (isStartConfigDone) {
        textField = utilLocation.convertPositionToString(AppLocalizations.of(context), isLocationEnabled);
      } else if (isLocationEnabled) {
        textField = AppLocalizations.of(context)!.waitAvailableLocation;
      } else {
        textField = AppLocalizations.of(context)!.locationDisabled;
      }
    }

    return CommonText(text: textField, fontSize: 20);
  }
}