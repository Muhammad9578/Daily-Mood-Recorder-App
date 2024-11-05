import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mood_maker_kp/src/controllers/auth_controller.dart';
import 'package:provider/provider.dart';

import '../../controllers/trends_controller.dart';
import '../../helpers/helpers.dart';
import '../../widgets/widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late AuthController authProvider;

  bool isLoading = false;
  bool showPassword = false;
  final email = TextEditingController();
  final password = TextEditingController();

  void signin() async {
    try {
      Dialogs.showLoadingDialog(title: 'Validating...', context: context);

      authProvider
          .emailPasswordSignIn(email.text.trim(), password.text.trim(), context)
          .then((isSuccess) async {
        if (isSuccess) {
          //closing dialog
          await authProvider.addLaunchCount();
          Provider.of<TrendController>(context, listen: false)
              .loadData(context);

          Navigator.pop(context);
          Navigator.of(context).pushNamedAndRemoveUntil(
              Routes.homeScreen,
              arguments: {PrefsKeys.fromStart: true},
              (Route<dynamic> route) => false);
        }
      }).catchError((error, stackTrace) {
        //closing loading dialog
        Navigator.pop(context);

        Dialogs.showErrorDialog(
            title: 'Login Failed',
            description: error.toString(),
            context: context);
      });
    } catch (e) {
      Navigator.pop(context);

      debugLog("inside catch 3: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    authProvider = Provider.of<AuthController>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  30.spaceY,
                  Semantics(
                    label: "Mood logo",
                    image: true,
                    child: Image.asset(
                      BehaviourImage.excellent,
                      height: 120,
                    ),
                  ),
                  15.spaceY,
                  MergeSemantics(
                    child: Column(
                      children: [
                        Text(
                          "Welcome Back",
                          semanticsLabel: "Welcome Back",
                          style: MyTextStyle.boldBlack.copyWith(
                            fontSize: 34,
                          ),
                        ),
                        0.spaceY,
                        Text(
                          "Enter the following details to proceed",
                          semanticsLabel:
                              "Enter the following details to proceed",
                          style: MyTextStyle.mediumBlack.copyWith(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  25.spaceY,
                  Semantics(
                    label: "Input email in this field",
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
                    label: "Input your password in this field",
                    child: PrimaryTextField(
                      'Password',
                      labelText: "Password",
                      controller: password,
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
                    ),
                  ),
                  20.spaceY,
                  Align(
                    alignment: Alignment.bottomRight,
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                            context, Routes.emailVerificationScreen);
                      },
                      child: Semantics(
                        button: true,
                        // readOnly: true,
                        // label: "labelRecover password button",
                        child: Text('Forgot Password? ',
                            textAlign: TextAlign.right,
                            style: MyTextStyle.mediumBlack.copyWith(
                                // decoration: TextDecoration.underline,
                                )),
                      ),
                    ),
                  ),
                  30.spaceY,
                  isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.orange),
                        )
                      : Semantics(
                          label: "Login button",
                          child: PrimaryButton(
                            text: "Login",
                            onPress: () {
                              if (_formKey.currentState!.validate()) {
                                closeKeyboard();
                                signin();
                              }
                            },
                          ),
                        ),
                  20.spaceY,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Semantics(
                        label:
                            "If you dont have an account, click next signup button",
                        child: Text(
                          'Don\'t have an account? ',
                          style: MyTextStyle.regularLightBlack,
                        ),
                      ),
                      Semantics(
                        button: true,
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, Routes.signupScreen);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('Sign up',
                                style: MyTextStyle.mediumBlack.copyWith(
                                    // decoration: TextDecoration.underline,
                                    )),
                          ),
                        ),
                      ),
                    ],
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
