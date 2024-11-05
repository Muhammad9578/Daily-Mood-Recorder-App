import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../helpers/helpers.dart';
import '../../widgets/widgets.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  Image profileImage = Image.asset(MyImage.placeholder);
  File? profileImageFile;
  bool isLoading = false;
  bool pageLoading = true;
  bool showPassword = false;
  late AuthController authProvider;

  final email = TextEditingController();
  final username = TextEditingController();

  final password = TextEditingController();

  void choosePhoto() async {
    final result = await showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          contentPadding: const EdgeInsets.all(15),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: Text('Select Image Source'),
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
        profileImageFile = File(image.path);
      });
    }
  }

  getProfileData() {
    email.text = authProvider.prefs.getString(FirestoreConstants.email)!;
    password.text = authProvider.prefs.getString(FirestoreConstants.password)!;
    username.text = authProvider.prefs.getString(FirestoreConstants.username)!;

    profileImage =
    authProvider.prefs.getString(FirestoreConstants.photoUrl) == ''
        ? Image.asset(MyImage.placeholder)
        : Image.network(
        authProvider.prefs.getString(FirestoreConstants.photoUrl)!);
    setState(() {
      pageLoading = false;
    });
  }

  void update() async {
    try {
      Dialogs.showLoadingDialog(title: 'Updating...', context: context);

      authProvider
          .updateUserProfile(
          email.text, profileImageFile, password.text, username.text)
          .then((isSuccess) {
        if (isSuccess) {
          // closing dialog
          Navigator.pop(context);
          Toasty.success("Successfully updated");
        }
      }).catchError((error, stackTrace) {
        // closing loading dialog
        Navigator.pop(context);

        // Showing error dialog
        Dialogs.showErrorDialog(
            title: 'Update failed',
            description: error.toString(),
            context: context);
      });
    } catch (e) {}
  }

  @override
  void initState() {
    authProvider = Provider.of<AuthController>(context, listen: false);
    getProfileData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Semantics(
          child: Text(
            "Update Profile",
            style: TextStyle(
                color: AppColors.purpleColor,
                fontSize: 20,
                fontWeight: Fonts.medium),
          ),
        ),
        backgroundColor: AppColors.white,
        leading: Semantics(
          label: "Back button",
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.purpleColor,
            ),
          ),
        ),
      ),
      body: Container(
        margin: EdgeInsets.only(left: 20, top: 20, right: 20, bottom: 20),
        child: Form(
          key: _formKey,
          child: pageLoading
              ? Center(
            child: CircularProgressIndicator(),
          )
              : SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                50.spaceY,
                InkWell(
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
                    child: Semantics(
                      label: "Profile image, click to replace",
                      child: Stack(
                        children: [
                          CircleProfile(
                            radius: 50,
                            image: profileImageFile == null
                                ? profileImage
                                : Image.file(
                              profileImageFile!,
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
                  label: "Input field for username",
                  child: PrimaryTextField(
                    controller: username,
                    textCapitalization: TextCapitalization.none,
                    'Change username',
                    labelText: "Change username",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter username';
                      }
                      return null;
                    },

                  ),
                ),
                // 15.spaceY,
                // Semantics(
                //   label: "Input field for email",
                //   child: PrimaryTextField(
                //     controller: email,
                //     textCapitalization: TextCapitalization.none,
                //     'Change email',
                //     labelText: "Change email",
                //     validator: (value) {
                //       if (value == null || value.isEmpty) {
                //         return 'Enter email';
                //       }
                //       return null;
                //     },
                //     // onChange: (value) {
                //     //   email = value.trim();
                //     // },
                //   ),
                // ),
                15.spaceY,
                Semantics(
                  label: "Input field for password",
                  child: PrimaryTextField(
                    controller: password,
                    'Password',
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
                      });
                    },

                    // onChange: (value) {
                    //   password = value;
                    // },
                  ),
                ),
                20.spaceY,
                isLoading
                    ? Center(
                  child: Semantics(
                      label: "Loading",
                      child: CircularProgressIndicator(
                          color: AppColors.purpleColor)),
                )
                    : Semantics(
                  label: "Update button",
                  child: PrimaryButton(
                    text: "Update",
                    onPress: () {
                      if (_formKey.currentState!.validate()) {
                        closeKeyboard();
                        update();
                      }
                    },
                  ),
                ),
                20.spaceY,
              ],
            ),
          ),
        ),
      ),
    );
  }

}
