import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../helpers/helpers.dart';
import '../../../models/behaviour_history.dart';

class DisplayMoodChartBuild extends StatefulWidget {
  Map<String, List<BehaviourHistory>> behaviourList;

  DisplayMoodChartBuild({super.key, required this.behaviourList});

  @override
  State<StatefulWidget> createState() => DisplayMoodChartBuildState();
}

class DisplayMoodChartBuildState extends State<DisplayMoodChartBuild> {
  final double width = 2;

  late List<BarChartGroupData> rawBarGroups;
  late List<BarChartGroupData> showingBarGroups;

  late final titles;

  int maxCount = 5;
  int touchedGroupIndex = -1;

  @override
  void initState() {
    super.initState();
    List<BarChartGroupData> items = [];
    List<int> topMoodCount = [0, 0, 0, 0, 0];

    // String dates = widget.behaviourList.keys.
    List<String> keyss = [];
    int i = 0;
    for (MapEntry<String, List<BehaviourHistory>> item
        in widget.behaviourList.entries) {
      keyss.add(item.key);
      items.add(makeGroupData(i, item.value));
      List<int> subMoodCount = [0, 0, 0, 0, 0];
      for (BehaviourHistory md in item.value) {
        if (md.mood.text == "Excellent") {
          subMoodCount[0] = subMoodCount[0] + 1;
        } else if (md.mood.text == "Good") {
          subMoodCount[1] = subMoodCount[1] + 1;
        } else if (md.mood.text == "Ok") {
          subMoodCount[2] = subMoodCount[2] + 1;
        } else if (md.mood.text == "Bad") {
          subMoodCount[3] = subMoodCount[3] + 1;
        } else if (md.mood.text == "Terrible") {
          subMoodCount[4] = subMoodCount[4] + 1;
        }
      }

      for (int j = 0; j < topMoodCount.length; j++) {
        if (subMoodCount[j] >= topMoodCount[j]) {
          topMoodCount[j] = subMoodCount[j];
        }
      }

      i++;
    }
    maxCount = topMoodCount.reduce((curr, next) => curr > next ? curr : next);

    if (maxCount > 5) {
      int rem = maxCount % 3;
      maxCount += 3 - rem;
    }

    titles = keyss;
    rawBarGroups = items;
    showingBarGroups = rawBarGroups;
  }

  @override
  Widget build(BuildContext context) {
    return BarChart(
      swapAnimationCurve: Curves.linear,
      BarChartData(
        maxY: maxCount < 5 ? 5 : maxCount.toDouble(),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: bottomTitles,
              reservedSize: 50,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 20,
              interval: 1,
              getTitlesWidget: leftTitles,
            ),
          ),
        ),
        borderData: FlBorderData(
          border: const Border(
            left: BorderSide(color: Colors.white, width: 1.0), // Left border
            right: BorderSide.none, // No border on the right
            top: BorderSide.none, // No border on the top
            bottom:
                BorderSide(color: Colors.white, width: 1.0), // Bottom border
          ),
          show: true,
        ),
        barGroups: showingBarGroups,
        gridData: const FlGridData(
          show: false,
        ),
      ),
    );
  }

  Widget leftTitles(double value, TitleMeta meta) {
    if (maxCount > 5) {
      if (value % 3 != 0) {
        return const SizedBox.shrink();
      }
    }
    const style = TextStyle(
      color: AppColors.white,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    String text = "${value}  ";

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 0,
      child: RotatedBox(
        quarterTurns: 3, // Rotate the text vertically
        child: Text(text, style: style),
      ),
    );
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      letterSpacing: 0.04,
      wordSpacing: 0,
      color: AppColors.white,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    String text = "   ${titles[value.toInt()]}";

    return SideTitleWidget(
      axisSide: meta.axisSide,
      // space: 16, //margin top
      space: 0,
      child: RotatedBox(
        quarterTurns: 1, // Rotate the text vertically
        child: Text(
          text,
          style: style,
          maxLines: 2,
          semanticsLabel: "${titles[value.toInt()]}",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  BarChartGroupData makeGroupData(int x, List<BehaviourHistory> behaviour) {
    // Behaviour mood = behaviour.
    List<BarChartRodData>? barRod = [];
    int excellent = 0;
    int good = 0;
    int ok = 0;
    int bad = 0;
    int terrible = 0;

    for (var md in behaviour) {
      if (md.mood.text == "Excellent") {
        excellent++;
      } else if (md.mood.text == "Good") {
        good++;
      } else if (md.mood.text == "Ok") {
        ok++;
      } else if (md.mood.text == "Bad") {
        bad++;
      } else if (md.mood.text == "Terrible") {
        terrible++;
      }
    }

    if (excellent != 0) {
      barRod.add(
        BarChartRodData(
          toY: double.parse(excellent.toString()),
          color: AppColors.excellentMoodColor,
          width: width,
        ),
      );
    }
    if (good != 0) {
      barRod.add(
        BarChartRodData(
          toY: double.parse(good.toString()),
          color: AppColors.goodMoodColor,
          width: width,
        ),
      );
    }
    if (ok != 0) {
      barRod.add(
        BarChartRodData(
          toY: double.parse(ok.toString()),
          color: AppColors.okMoodColor,
          width: width,
        ),
      );
    }
    if (bad != 0) {
      barRod.add(
        BarChartRodData(
          toY: double.parse(bad.toString()),
          color: AppColors.badMoodColor,
          width: width,
        ),
      );
    }
    if (terrible != 0) {
      barRod.add(
        BarChartRodData(
          toY: double.parse(terrible.toString()),
          color: AppColors.terribleMoodColor,
          width: width,
        ),
      );
    }

    return BarChartGroupData(
      barsSpace: 4,
      x: x,
      barRods: barRod,
    );
  }
}
