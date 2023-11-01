import 'package:quening_system/components/task_component.dart';
import 'package:quening_system/const/global.dart';
import 'package:quening_system/services/generator.dart';

class TaskComponentGenerator {
  TaskComponentGenerator._();

  static TaskComponent generateTaskComponent() {
    TaskComponent taskComponent = TaskComponent(
        executionTime: Generator.generateTaskTime(
            maxSeconds: Global.maxSecondsExecutionTask).toDouble());

    return taskComponent;
  }
}