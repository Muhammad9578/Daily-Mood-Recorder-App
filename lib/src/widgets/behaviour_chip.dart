import 'package:flutter/material.dart';

import '../helpers/helpers.dart';

class BehaviourChip extends StatelessWidget {
  final String text;
  final String? image;
  final int index;
  final Function()? onTap;
  final bool selected;
  final String emoji;
  final bool? showImage;

  const BehaviourChip({
    super.key,
    required this.text,
    required this.emoji,
    this.image,
    this.onTap,
    required this.index,
    this.showImage = false,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 5, left: 25, right: 25),
      child: Semantics(
        button: true,
        child: InkWell(
          borderRadius: BorderRadius.circular(5),
          onTap: onTap,
          child: Align(
            alignment: Alignment.center,
            child: Container(
              // margin: EdgeInsets.symmetric(horizontal: 30),
              width: MediaQuery.of(context).size.width,
              padding:
                  const EdgeInsets.only(left: 30, right: 10, top: 5, bottom: 5),
              decoration: BoxDecoration(
                border: Border.all(
                    color: selected ? AppColors.orange : AppColors.white),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // showImage!
                  //     ?
                  // Image.asset(
                  //         "$image",
                  //         height: 40,
                  //         width: 40,
                  //       )
                  //     : const SizedBox.shrink(),
                  Text(
                    emoji,
                    textAlign: TextAlign.left,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontWeight: Fonts.medium,
                        fontSize: 25,
                        color: selected ? AppColors.orange : AppColors.white,
                        fontFamily: FontFamily.courgette),
                  ),
                  30.spaceX,
                  // showImage! ? 30.spaceX : const SizedBox.shrink(),
                  Expanded(
                    child: Text(
                      text,
                      textAlign: TextAlign.left,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontWeight: Fonts.medium,
                          fontSize: 22,
                          color: selected ? AppColors.orange : AppColors.white,
                          fontFamily: FontFamily.courgette),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
