import 'package:flutter/widgets.dart';
import 'package:ttkapp/core/utility/time_utility.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ttkapp/pages/widgets/common/common_text.dart';

class TimeText extends StatelessWidget {
  final bool isPressed;
  final TimeUtility utilTime;

  const TimeText({
      super.key,
      required this.isPressed,
      required this.utilTime
    });

  @override
  Widget build(BuildContext context) {
    String textField = AppLocalizations.of(context)!.defaultText;

    if (isPressed) {
      textField = utilTime.formatElapsedToText(null);
    }
    
    return Container(
      width: 250,
      //padding: widget.pageData.isPressed ? const EdgeInsets.only(left: 58) : null,
      alignment: /*widget.pageData.isPressed ? null :*/ Alignment.center,
      child: CommonText(
        text: textField,
        fontSize: 30
      ),
    );
  }
}