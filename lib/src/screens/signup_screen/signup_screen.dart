import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../helpers/helpers.dart';
import '../../models/user_model.dart';
import '../../widgets/widgets.dart';

class SignupScreen extends StatefulWidget {
  static const String route = "signupPage";

  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  File? pickedImage;
  bool isLoading = false;
  bool showPassword = false;
  final email = TextEditingController();
  final username = TextEditingController(text: '');
  final password = TextEditingController();
  late AuthController authProvider;

  void choosePhoto() async {
    final result = await showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          contentPadding: const EdgeInsets.all(15),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: const Text('Select Image Source'),
          children: [
            SimpleDialogOption(
              child: const Row(
                children: [
                  Icon(
                    Icons.image,
                    color: AppColors.purpleColor,
                    size: 22,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Gallery',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              onPressed: () {
                Navigator.pop(context, "gallery");
              },
            ),
            const SizedBox(width: 6),
            SimpleDialogOption(
              child: Row(
                children: [
                  Icon(
                    Icons.camera_alt,
                    color: AppColors.purpleColor,
                    size: 22,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Camera',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              onPressed: () {
                Navigator.pop(context, "camera");
              },
            )
          ],
        );
      },
    );

    if (result == null) {
      return;
    }

    final ImagePicker picker = ImagePicker();
    // Pick an image
    final XFile? image = await picker.pickImage(
        source: result == "gallery" ? ImageSource.gallery : ImageSource.camera,
        maxHeight: 500,
        maxWidth: 500);
    if (image != null) {
      setState(() {
        pickedImage = File(image.path);
      });
    }
  }

  void signup() async {
    try {
      Dialogs.showLoadingDialog(title: 'Validating...', context: context);
      UserModel user = UserModel(
        email: email.text.trim(),
        username: username.text.trim(),
        photoUrl: '',
        password: password.text.trim(),
      );
      authProvider
          .emailPasswordSignUp(user, pickedImage, context)
          .then((isSuccess) {
        if (isSuccess) {
          //closing dialog
          Navigator.pop(context);

          Navigator.pushNamedAndRemoveUntil(
              context, Routes.homeScreen, (route) => false);
        }
      }).catchError((error, stackTrace) {
        // closing loading dialog
        Navigator.pop(context);

        // Showing error dialog
        Dialogs.showErrorDialog(
            title: 'Sign Up failed',
            description: error.toString(),
            context: context);
      });
    } catch (e) {}
  }

  @override
  void initState() {
    authProvider = Provider.of<AuthController>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.only(left: 20, top: 20, right: 20, bottom: 10),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: [
                  30.spaceY,
                  Semantics(
                    label: "Mood",
                    child: Image.asset(
                      BehaviourImage.excellent,
                      height: 120,
                    ),
                  ),
                  // 15.spaceY,
                  Semantics(
                    // label: "Enter the following details to proceed",
                    child: Column(
                      children: [
                        Text(
                          "Enter Basic Details",
                          style: MyTextStyle.boldBlack.copyWith(
                            fontSize: 34,
                          ),
                        ),
                        0.spaceY,
                        Text(
                          "Enter the following details to proceed",
                          style: MyTextStyle.mediumBlack.copyWith(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  15.spaceY,
                  Semantics(
                    label: "Chose profile photo",
                    child: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        choosePhoto();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        // height: 113,
                        child: Stack(
                          children: [
                            CircleProfile(
                              radius: 50,
                              image: pickedImage == null
                                  ? Image.asset(MyImage.placeholder)
                                  : Image.file(
                                      pickedImage!,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            Positioned(
                              right: 5,
                              bottom: 0,
                              // left: 0,
                              child: Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: AppColors.purpleColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.add,
                                  color: AppColors.white,
                                  size: 18,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  25.spaceY,
                  Semantics(
                    label: "Input field for",
                    child: PrimaryTextField(
                      controller: email,
                      textCapitalization: TextCapitalization.none,
                      'Email',
                      labelText: "Email",
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter email address';
                        }
                        return null;
                      },
                      // onChange: (value) {
                      //   email = value.trim();
                      // },
                    ),
                  ),
                  15.spaceY,
                  Semantics(
                    label: "Input field for",
                    child: PrimaryTextField(
                      controller: username,
                      textCapitalization: TextCapitalization.none,
                      'Username',
                      labelText: "Username",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter Username';
                        }
                        return null;
                      },
                      // onChange: (value) {
                      //   email = value.trim();
                      // },
                    ),
                  ),
                  15.spaceY,
                  Semantics(
                    label: "Input field for",
                    child: PrimaryTextField(
                      'Password', controller: password,
                      labelText: "Password",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter password';
                        } else if (value.length < 6) {
                          return 'Enter minimum 6 digits';
                        } else {
                          return null;
                        }
                      },
                      hideText: !showPassword,
                      suffixIcon: showPassword
                          ? CupertinoIcons.eye
                          : CupertinoIcons.eye_slash,
                      suffixIconOnPressed: () {
                        setState(() {
                          showPassword = !showPassword;
                          // print("showPassword: $showPassword");
                        });
                      },
                      // onChange: (value) {
                      //   password = value;
                      // },
                    ),
                  ),
                  15.spaceY,
                  Semantics(
                    label: "Input field for",
                    // readOnly: true,
                    child: PrimaryTextField(
                      labelText: "Confirm Password",
                      'Confirm Password',
                      hideText: true,
                      validator: (value) {
                        if (value != password.text) {
                          return 'Passwords do no not match';
                        }
                        return null;
                      },
                      // onChange: (value) {
                      //   confirmPassword = value;
                      // },
                    ),
                  ),
                  20.spaceY,
                  isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.orange),
                        )
                      : Semantics(
                          label: "Sign up button",
                          child: PrimaryButton(
                            text: "Sign up",
                            onPress: () {
                              if (_formKey.currentState!.validate()) {
                                closeKeyboard();
                                signup();
                              }
                            },
                          ),
                        ),
                  20.spaceY,
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     Text(
                  //       'By signing up I accept the ',
                  //       style: MyTextStyle.regularLightBlack,
                  //     ),
                  //     InkWell(
                  //       onTap: () {
                  //         // Navigator.pushNamedAndRemoveUntil(
                  //         //     context, LoginPage.route, (route) => false);
                  //       },
                  //       child: Text('terms of use',
                  //           style: MyTextStyle.mediumBlack.copyWith(
                  //             decoration: TextDecoration.underline,
                  //           )),
                  //     ),
                  //   ],
                  // ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     Text(
                  //       ' and the ',
                  //       style: MyTextStyle.regularLightBlack,
                  //     ),
                  //     InkWell(
                  //       onTap: () {
                  //         // Navigator.pushNamedAndRemoveUntil(
                  //         //     context, LoginPage.route, (route) => false);
                  //       },
                  //       child: Text('data privacy policy.',
                  //           style: MyTextStyle.mediumBlack.copyWith(
                  //             decoration: TextDecoration.underline,
                  //           )),
                  //     ),
                  //   ],
                  // ),
                  // 15.SpaceY,
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     Text(
                  //       'Already have an account? ',
                  //       style: MyTextStyle.regularLightBlack,
                  //     ),
                  //     InkWell(
                  //       onTap: () {
                  //         Navigator.pushNamedAndRemoveUntil(
                  //             context, LoginPage.route, (route) => false);
                  //       },
                  //       child: Text('Login',
                  //           style: MyTextStyle.mediumBlack.copyWith(
                  //             decoration: TextDecoration.underline,
                  //           )),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
