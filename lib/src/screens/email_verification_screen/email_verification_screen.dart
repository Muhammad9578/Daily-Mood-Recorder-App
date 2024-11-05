import 'package:flutter/material.dart';
import 'package:mood_maker_kp/src/controllers/auth_controller.dart';
import 'package:provider/provider.dart';

import '../../helpers/helpers.dart';
import '../../widgets/widgets.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({Key? key}) : super(key: key);

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;
  final email = TextEditingController();

  void verifyEmail() async {
    try {
      AuthController authProvider = context.read<AuthController>();
      Dialogs.showLoadingDialog(title: 'Validating...', context: context);

      authProvider.checkUserExist(email.text).then((user) {
        if (user != null) {
          //closing dialog
          Navigator.pop(context);
          final snackBar = SnackBar(
            backgroundColor: Colors.lightGreen,
            margin: EdgeInsets.only(
                bottom: MediaQuery
                    .of(context)
                    .size
                    .height - 150,
                right: 20,
                left: 20),
            behavior: SnackBarBehavior.floating,
            content: Semantics(
              label:
              'Verification link has been send to your email. Click the link and reset your password',
              child: Text(
                'Verification link has been send to your email. Click the link and reset your password',
                style: MyTextStyle.mediumBlack.copyWith(fontSize: 16),
              ),
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);

          Navigator.pop(context);
        }
      }).catchError((error, stackTrace) {
        //closing loading dialog
        Navigator.pop(context);

        Dialogs.showErrorDialog(
            title: 'Error', description: error.toString(), context: context);
      });
    } catch (e) {
      Navigator.pop(context);

      debugLog("msg: $e");
      Toasty.error(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Semantics(
          label: "Forget Password Screen",
          child: Text(
            "Verify Email",
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
            icon: Icon(
              Icons.arrow_back,
              color: AppColors.purpleColor,
            ),
          ),
        ),
      ),
      body: Container(
        margin: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                50.spaceY,
                MergeSemantics(
                  child: Column(
                    children: [
                      Image.asset(
                        BehaviourImage.excellent,
                        semanticLabel: "Logo image",
                        height: 120,
                      ),
                      40.spaceY,
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          semanticsLabel: 'Enter your registered email',
                          'Enter your registered email',
                          style: MyTextStyle.regularBlack,
                        ),
                      ),
                    ],
                  ),
                ),
                15.spaceY,
                Semantics(
                  label: "Input field for email",
                  child: PrimaryTextField(
                    controller: email,
                    textCapitalization: TextCapitalization.none,
                    'Enter email',
                    // labelText: "Email",
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter email';
                      }
                      return null;
                    },

                  ),
                ),
                45.spaceY,
                isLoading
                    ? const Center(
                  child:
                  CircularProgressIndicator(color: AppColors.orange),
                )
                    : Semantics(
                  label: "Verify email button",
                  child: PrimaryButton(
                    text: "Verify",
                    onPress: () {
                      if (_formKey.currentState!.validate()) {
                        closeKeyboard();
                        verifyEmail();
                      }
                    },
                  ),
                ),
                25.spaceY,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
