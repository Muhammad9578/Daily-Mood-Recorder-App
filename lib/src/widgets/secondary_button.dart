import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import '../helpers/helpers.dart';

class SecondaryButton extends StatelessWidget {
  final String text;
  final String icon;
  final int index;
  final Function()? onTap;
  final double? fontSize;
  final String? emoji;
  final double? height;
  final TextAlign textAlign;
  final double? width;
  final String? expireTime;

  const SecondaryButton(
      {super.key,
      required this.text,
      required this.onTap,
      required this.icon,
      required this.index,
      this.expireTime,
      this.emoji,
      this.textAlign = TextAlign.left,
      this.fontSize = 22,
      this.width = 30,
      this.height = 30});

  @override
  Widget build(BuildContext context) {
    return FadeInRight(
      from: 40 * double.parse(index.toString()),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: Stack(
          children: [
            Semantics(
              button: true,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: onTap,
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    // margin: EdgeInsets.symmetric(horizontal: 30),
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.only(
                        left: 30, right: 10, top: 10, bottom: 10),
                    decoration: BoxDecoration(
                        border: Border.all(color: AppColors.white),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            offset: Offset.zero,
                            blurRadius: 10,
                          ),
                        ]),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        emoji != null
                            ? Text(
                                emoji!,
                                textAlign: textAlign,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontWeight: Fonts.medium,
                                    fontSize: fontSize! + 2,
                                    color: AppColors.white,
                                    fontFamily: FontFamily.courgette),
                              )
                            : Image.asset(
                                icon,
                                height: height,
                                width: width,
                              ),
                        textAlign == TextAlign.center ? 0.spaceX : 30.spaceX,
                        Expanded(
                          child: Text(
                            text,
                            textAlign: textAlign,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontWeight: Fonts.medium,
                                fontSize: fontSize,
                                color: AppColors.white,
                                fontFamily: FontFamily.courgette),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            expireTime != null
                ? Positioned(
                    top: 0,
                    right: 10,
                    child: Text(
                      "$expireTime",
                      style: TextStyle(
                          color: AppColors.white,
                          fontSize: 10,
                          fontWeight: Fonts.semiBold),
                    ))
                : const SizedBox.shrink()
          ],
        ),
      ),
    );
  }
}
