import 'package:flutter/widgets.dart';
import 'package:ttkapp/core/data/main_table.dart';
import 'package:ttkapp/core/functionality/location/location_ttk.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ttkapp/core/data/constants.dart' as constants;
import 'package:ttkapp/pages/widgets/common_text.dart';

class DistanceSpeedText extends StatelessWidget {
  final bool isPageStable;
  final bool isButtonPressed;
  final bool isLocationEnabled;
  final LocationTTK locationTTK;
  final MainTable mainData;
  

  const DistanceSpeedText({
    super.key,
    required this.isPageStable,
    required this.isButtonPressed,
    required this.isLocationEnabled,
    required this.locationTTK,
    required this.mainData,
  });

  @override
  Widget build(BuildContext context) {
    String textField = AppLocalizations.of(context)!.seeDistanceSpeed;

    if (!isPageStable) {
      textField = AppLocalizations.of(context)!.appUpdated(constants.appVersion);
    }

    if (isButtonPressed) {
      double? kmh = locationTTK.currentPosition?.speed;
      if (kmh != null) {
        kmh = kmh * 3.6;
        textField = '${mainData.distance?.toStringAsFixed(2)} ${AppLocalizations.of(context)!.meter}, ${kmh.toStringAsFixed(2)} ${AppLocalizations.of(context)!.kmHour}';        
      } else if (isLocationEnabled) {
        textField = AppLocalizations.of(context)!.waitAvailableLocation;
      } else {
        textField = AppLocalizations.of(context)!.locationDisabled;
      }
    }
    
    return CommonText(text: textField, fontSize: 20);
  }
}