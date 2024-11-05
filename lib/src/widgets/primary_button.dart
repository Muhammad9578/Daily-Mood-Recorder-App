import 'package:flutter/material.dart';
import '../helpers/helpers.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPress;
  final Color color;
  final TextStyle? textStyle;

  const PrimaryButton(
      {required this.text,
      this.textStyle,
      this.color = Colors.purple,
      this.onPress,
      super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: MaterialButton(
        elevation: 0,
        padding: EdgeInsets.all(5),
        color: color,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(25),
          ),
        ),
        onPressed: onPress ?? () {},
        child: Text(
          text,
          style: textStyle ??
              MyTextStyle.mediumBlack
                  .copyWith(color: AppColors.white, fontSize: 20),
        ),
      ),
    );
  }
}
