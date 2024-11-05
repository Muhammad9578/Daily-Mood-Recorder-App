import 'package:flutter/material.dart';
import 'package:mood_maker_kp/src/helpers/app_images.dart';

import '../helpers/app_colors.dart';

class CircleProfile extends StatelessWidget {
  final Image image;
  final double radius;

  const CircleProfile({required this.radius, required this.image, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: AppColors.lightOrange,
      radius: radius,
      child: ClipOval(
        child: AspectRatio(
          aspectRatio: 1,
          child: FadeInImage(
            fit: BoxFit.cover,
            placeholder: const AssetImage(MyImage.placeholder),
            image: image.image,
            imageErrorBuilder: (context, error, stackTrace) {
              return const Center(child: Text('Unable to load image'));
            },
          ),
        ),
      ),
    );
  }
}
