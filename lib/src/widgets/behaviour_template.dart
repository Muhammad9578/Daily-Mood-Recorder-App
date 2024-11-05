import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/behaviour_controller.dart';
import '../helpers/helpers.dart';
import '../models/models.dart';
import 'behaviour_chip.dart';

class BehaviourTemplate extends StatelessWidget {
  final String title;
  final List<Behaviour> behaviourList;
  final BehaviourScreen behaviourScreen;

  const BehaviourTemplate({
    Key? key,
    required this.title,
    required this.behaviourList,
    required this.behaviourScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            left: 15,
            right: 15,
            bottom: 10,
            top: 80,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Semantics(
                    // label: title,
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                        fontFamily: 'courgette',
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: MoodBuild(
                      behaviourScreen: behaviourScreen,
                      behaviourList: behaviourList,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
              left: 7,
              top: 40,
              right: 0,
              child: Container(
                alignment: Alignment.topLeft,
                color: AppColors.appColor,
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    semanticLabel: "back",
                    color: AppColors.white,
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

class MoodBuild extends StatefulWidget {
  const MoodBuild(
      {super.key, required this.behaviourScreen, required this.behaviourList});

  final BehaviourScreen behaviourScreen;
  final List<Behaviour> behaviourList;

  @override
  State<MoodBuild> createState() => _MoodBuildState();
}

class _MoodBuildState extends State<MoodBuild> {
  bool isLoading = false;

  saveMoods(BehaviourController behaviourController, Behaviour behaviour) {
    setState(() {
      isLoading = true;
    });
    behaviourController.setEmotion(behaviour);
    behaviourController.saveBehaviour(context);

    setState(() {
      isLoading = false;
    });

    Dialogs.showSaveDialog(
        title: "Moods Saved",
        description:
            "All your operations are saved successfully, you can view moods history in trends section of settings tab.",
        context: context,
        onTap: () {
          Navigator.pushNamedAndRemoveUntil(
              context, Routes.homeScreen, (route) => false);
        });
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BehaviourController>(
      builder: (context, behaviourController, child) {
        return isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView.builder(
                shrinkWrap: true,
                itemCount: widget.behaviourList.length,
                itemBuilder: (context, index) {
                  final behaviour = widget.behaviourList[index];
                  bool selected = false;
                  switch (widget.behaviourScreen) {
                    case BehaviourScreen.mood:
                      selected =
                          behaviourController.mood?.text == behaviour.text;
                      break;
                    case BehaviourScreen.activity:
                      selected =
                          behaviourController.activity?.text == behaviour.text;
                      break;
                    case BehaviourScreen.emotion:
                      selected =
                          behaviourController.emotion?.text == behaviour.text;
                      break;
                  }
                  return FadeInRight(
                    from: 40 * double.parse(index.toString()),
                    child: BehaviourChip(
                      text: behaviour.text!,
                      emoji: behaviour.emoji!,
                      image: behaviour.image,
                      index: widget.behaviourList.indexOf(behaviour),
                      selected: selected,

                      // showImage:
                      //     behaviourScreen == BehaviourScreen.mood,
                      onTap: () {
                        switch (widget.behaviourScreen) {
                          case BehaviourScreen.mood:
                            behaviourController.setMood(behaviour);
                            behaviourController.setActivity(null);
                            Navigator.pushNamed(context, Routes.activityScreen);
                            break;
                          case BehaviourScreen.activity:
                            behaviourController.setActivity(behaviour);
                            behaviourController.setEmotion(null);

                            Navigator.pushNamed(context, Routes.emotionScreen);

                            break;
                          case BehaviourScreen.emotion:
                            saveMoods(behaviourController, behaviour);

                            break;
                        }
                      },
                    ),
                  );
                },
              );
      },
    );
  }
}
