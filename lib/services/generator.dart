import 'dart:math';

class Generator {

  Generator._();

  /// Генерирует время выполнения задачи в секундах [1..maxSeconds]
  static int generateTaskTime({required int maxSeconds}) {
    return Random().nextInt(maxSeconds) + 1;
  }

  /// Генерирует время выполнения задачи в секундах [0..maxSeconds]
  static int generateDelayBetweenTasks({required int maxSeconds}) {
    return Random().nextInt(maxSeconds);
  }
}