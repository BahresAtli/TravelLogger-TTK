import 'package:flutter/widgets.dart';
import 'package:ttkapp/core/dataclass/record_data.dart';
import 'package:ttkapp/core/utility/location_utility.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ttkapp/core/constants.dart' as constants;
import 'package:ttkapp/pages/widgets/common_text.dart';

class DistanceSpeedText extends StatelessWidget {
  final bool isPageStable;
  final bool isButtonPressed;
  final bool isLocationEnabled;
  final LocationUtility utilLocation;
  final RecordData recordData;
  

  const DistanceSpeedText({
    super.key,
    required this.isPageStable,
    required this.isButtonPressed,
    required this.isLocationEnabled,
    required this.utilLocation,
    required this.recordData,
  });

  @override
  Widget build(BuildContext context) {
    String textField = AppLocalizations.of(context)!.seeDistanceSpeed;

    if (!isPageStable) {
      textField = AppLocalizations.of(context)!.appUpdated(constants.appVersion);
    }

    if (isButtonPressed) {
      double? kmh = utilLocation.currentPosition?.speed;
      if (kmh != null) {
        kmh = kmh * 3.6;
        textField = '${recordData.distance?.toStringAsFixed(2)} ${AppLocalizations.of(context)!.meter}, ${kmh.toStringAsFixed(2)} ${AppLocalizations.of(context)!.kmHour}';        
      } else if (isLocationEnabled) {
        textField = AppLocalizations.of(context)!.waitAvailableLocation;
      } else {
        textField = AppLocalizations.of(context)!.locationDisabled;
      }
    }
    
    return CommonText(text: textField, fontSize: 20);
  }
}