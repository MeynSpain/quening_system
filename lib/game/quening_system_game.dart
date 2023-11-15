import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/layers.dart';
import 'package:flame/palette.dart';
import 'package:flame/sprite.dart';
import 'package:quening_system/components/background_component.dart';
import 'package:quening_system/components/exit_component.dart';
import 'package:quening_system/components/service_component.dart';
import 'package:quening_system/components/task_component.dart';
import 'package:quening_system/const/global.dart';
import 'package:quening_system/const/task_status.dart';
import 'package:quening_system/layers/background_image_layer.dart';
import 'package:quening_system/services/generator.dart';
import 'package:quening_system/services/task_component_generator.dart';

class QueningSystemGame extends FlameGame with HasCollisionDetection {
  /* Состояния */

  // Очередь в которую попадают таски при создании (состояние С)
  List<TaskComponent> startQueue = [];

  // Очерель к первой кассе (состояник К1)
  List<TaskComponent> queueTasks1 = [];

  // Очерель ко второй кассе (состояние К2)
  List<TaskComponent> queueTasks2 = [];

  // Первая касса (состояние К1)
  ServiceComponent serviceComponent1 = ServiceComponent();

  // Вторая касса (состояние К2)
  ServiceComponent serviceComponent2 = ServiceComponent();

  // Выход из СМО, внутри него список тасков покидающих систему (состояние В)
  ExitComponent exitComponent = ExitComponent();

  /// Вектор маркировки состояний
  List<int> markVector = [
    1,
    0,
    0,
    0,
    0,
    0,
  ];

  /* ------------------------------------- */

  /* Матрицы переходов */

  /// Матрица D-
  List<List<int>> matrixDInput = [
    [1, 0, 0, 0, 0, 0],
    [1, 0, 0, 0, 0, 0],
    [1, 0, 0, 0, 0, 0],
    [1, 0, 0, 0, 0, 0],
    [0, 1, 0, 0, 0, 0],
    [0, 0, 0, 1, 0, 0],
    [0, 0, 1, 0, 0, 0],
    [0, 0, 0, 0, 1, 0],
    [1, 0, 0, 0, 0, 0],
  ];

  /// Матрица D+
  List<List<int>> matrixDOutput = [
    [0, 0, 1, 0, 0, 0],
    [0, 1, 0, 0, 0, 0],
    [0, 0, 0, 0, 1, 0],
    [0, 0, 0, 1, 0, 0],
    [0, 0, 1, 0, 0, 0],
    [0, 0, 0, 0, 1, 0],
    [0, 0, 0, 0, 0, 1],
    [0, 0, 0, 0, 0, 1],
    [0, 0, 0, 0, 0, 1],
  ];

  List<List<int>> matrixD() {
    List<List<int>> matrix = [];

    for (int i = 0; i < matrixDOutput.length; i++) {
      List<int> row = [];
      for (int j = 0; j < matrixDOutput[i].length; j++) {
        row.add(matrixDOutput[i][j] - matrixDInput[i][j]);
      }
      matrix.add(row);
      // row.clear();
    }

    return matrix;
  }

  /* ----------------------------------------- */

  // Список всех касс
  List<ServiceComponent> servicesList = [];

  // Задержка на создание таски
  double taskDelay = 0;

  late TextComponent textQueueSizeComponent;
  late final SpriteSheet characterSpriteSheet;

  late final Vector2 exitPosition;
  late final Vector2 startPosition;

  final Vector2 queuePosition = Vector2(30, 30);

  late final BackGroundImageLayer backGroundImageLayer;

  late final List<List<int>> dMatrix;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    dMatrix = matrixD();

    add(BackGroundComponent(
        sprite: await loadSprite(Global.shopFloorSprite), size: size));

    // backGroundImageLayer = BackGroundImageLayer(
    //   sprite: await loadSprite(Global.shopFloorSprite),
    //   size: size,
    // );

    exitPosition = Vector2(size.x - 100, size.y - 10);
    startPosition = Vector2(100, size.y - 10);

    exitComponent.position = exitPosition;

    add(exitComponent);

    await images.load(Global.shopRegisterSpriteSheet);

    final spriteSheetImage = await images.load(Global.characterSpriteSheet);
    characterSpriteSheet =
        SpriteSheet(image: spriteSheetImage, srcSize: Vector2.all(64));

    serviceComponent1.position.x = size.x - 50;
    serviceComponent1.position.y = 100;

    serviceComponent2.position.x = size.x - 50;
    serviceComponent2.position.y = 300;

    add(serviceComponent1);
    add(serviceComponent2);

    servicesList.add(serviceComponent1);
    servicesList.add(serviceComponent2);

    textQueueSizeComponent = TextComponent();
    textQueueSizeComponent.text = queueTasks1.length.toString();
    textQueueSizeComponent.position = Vector2(size.x / 2, 100);
    add(textQueueSizeComponent);
  }

  /// Возвращает индекс свободного сервиса.
  /// Если такого нет, то возвращает -1
  int indexOfFreeService() {
    for (int i = 0; i < servicesList.length; i++) {
      if (!servicesList[i].isBusy) {
        return i;
      }
    }

    return -1;
  }

  /// Создание заявки
  TaskComponent createTask() {
    TaskComponent taskComponent =
        TaskComponentGenerator.generateTaskComponent();
    taskComponent.position = startPosition;

    // Добавляем на экран
    add(taskComponent);

    return taskComponent;
  }

  /// Создается новая задержка на создание задачи
  void newTaskDelay() {
    taskDelay = Generator.generateDelayBetweenTasks(
            maxSeconds: Global.maxSecondsDelayBetweenTasks)
        .toDouble();
  }

  /// Попытка добавить задачу в очередь
  void tryAddTaskInQueue(
      List<TaskComponent> queueTasks, TaskComponent taskComponent) {
    if (queueTasks.length < Global.maxSizeQueue) {
      Vector2 newQueuePosition = Vector2.copy(queuePosition);
      if (queueTasks1.isNotEmpty) {
        newQueuePosition.y += (queueTasks1.length * 50);
      }

      goInQueue(taskComponent, newQueuePosition);

      queueTasks1.add(taskComponent);
    } else {
      print('#### Задача отброшена ####');
    }
  }

  void goInQueue(TaskComponent taskComponent, Vector2 newQueuePosition) {
    taskComponent.goInQueue(newQueuePosition);
  }

  /// Попытка добавить задачу в сервис для ее выполнения
  bool tryAddTaskInService(TaskComponent taskComponent) {
    int indexFreeService = indexOfFreeService();
    if (indexFreeService != -1) {
      goToService(taskComponent, servicesList[indexFreeService]);

      servicesList[indexFreeService].addTask(taskComponent: taskComponent);

      return true;
    } else {
      return false;
    }
  }

  void tryAddTaskInServiceFromQueue(List<TaskComponent> queueTasks) {
    if (queueTasks.isNotEmpty) {
      TaskComponent taskComponent = queueTasks.first;
      bool isAdded = tryAddTaskInService(taskComponent);

      if (isAdded) {
        queueTasks.removeAt(0);
        updateQueue(queueTasks);
      }
    }
  }

  void updateQueue(List<TaskComponent> queueTasks) {
    for (int i = 0; i < queueTasks.length; i++) {
      // if (queueTasks[i].status == TaskStatus.goInQueue) {
      Vector2 newQueuePosition = Vector2.copy(queuePosition);
      newQueuePosition.y += i * 50;
      queueTasks[i].goInQueue(newQueuePosition);
      // } else if (queueTasks[i].status == TaskStatus.inQueue) {

      // }
    }
  }

  void goToService(
      TaskComponent taskComponent, ServiceComponent serviceComponent) {
    taskComponent.goToService(serviceComponent);
    // taskComponent.position = serviceComponent.position;
  }

  /// Обновление данных в сервисах
  void updateServices(double dt) {
    for (var service in servicesList) {
      service.execute(dt);
    }
  }

  /// Обновление задержки
  void updateDelay(double dt) {
    taskDelay -= dt;
  }

  bool transitionAllow(List<int> transition, List<int> markVector) {
    for (int i = 0; i < transition.length; i++) {
      if (transition[i] > markVector[i]) {
        return false;
      }
    }
    return true;
  }

  List<int> plusVector(List<int> vector1, List<int> vector2) {
    List<int> resultVector = [];

    for (int i = 0; i < vector1.length; i++) {
      resultVector.add(vector1[i] + vector2[i]);
    }

    return resultVector;
  }

  void transition(
      {required List<int> vectorTransition, required int indexTransition}) {
    if (transitionAllow(vectorTransition, markVector)) {
      markVector = plusVector(markVector, dMatrix[indexTransition]);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Сначала создадим заявку, если задержка кончилась
    TaskComponent? taskComponent;
    if (taskDelay <= 0) {
      taskComponent = createTask();
    }

    // Проходим по всем переходам
    for (int i = 0; i < matrixDInput.length; i++) {
      switch (i) {
        // Рассматривем первый переход (сразу на 1й сервис)
        case 1:
          // Разрешен только в случае, если сервис свободен и очередь пустая
          if (!serviceComponent1.isBusy && queueTasks1.isEmpty) {
            transition(vectorTransition: matrixDInput[i], indexTransition: i);
          }
          break;

        // Переход в очередь 1
        case 2:
          if (queueTasks1.length < Global.maxSizeQueue) {
            transition(vectorTransition: matrixDInput[i], indexTransition: i);
          }
          break;

        // Сразу сервис 2
        case 3:
          if (!serviceComponent2.isBusy && queueTasks2.isEmpty) {
            transition(vectorTransition: matrixDInput[i], indexTransition: i);
          }
          break;

        // В очередь 2
        case 4:
          if (queueTasks2.length < Global.maxSizeQueue) {
            transition(vectorTransition: matrixDInput[i], indexTransition: i);
          }
          break;

        // С очереди 1 на сервис 1
        case 5:
          if (!serviceComponent1.isBusy) {
            transition(vectorTransition: matrixDInput[i], indexTransition: i);
          }
          break;

        // С очереди 2 на сервис 2
        case 6:
          if (!serviceComponent2.isBusy) {
            transition(vectorTransition: matrixDInput[i], indexTransition: i);
          }
          break;

        // С сервиса 1 на выход
        case 7:
          if (!serviceComponent1.isBusy) {
            transition(vectorTransition: matrixDInput[i], indexTransition: i);
          }
          break;

        // С сервиса 2 на выход
        case 8:
          if (!serviceComponent2.isBusy) {
            transition(vectorTransition: matrixDInput[i], indexTransition: i);
          }
          break;

        // С начала на выход
        case 9:
          if (queueTasks1.length >= Global.maxSizeQueue &&
              queueTasks2.length >= Global.maxSizeQueue) {
            transition(vectorTransition: matrixDInput[i], indexTransition: i);
          }
          break;
      }
    }

    // Обновляем выполняемые задачи
    updateServices(dt);

    // Обновляем задержку
    updateDelay(dt);

    /*

    // Сначала создадим заявку, если задержка кончилась
    TaskComponent? taskComponent;
    if (taskDelay <= 0) {
      taskComponent = createTask();
    }

    // Теперь просчитываем условия первого перехода
    if (queueTasks1.length < Global.maxSizeQueue ||
        queueTasks2.length < Global.maxSizeQueue) {

      if (queueTasks1.isEmpty && queueTasks2.isEmpty) {

        int indexFreeService = indexOfFreeService();
        if (indexFreeService != -1) {
          // Встаем на свободный сервис
        } else {
          // Нужно встать в очередь
        }
        // Выбираем какая очередь больше подходит
      } else if (queueTasks1.length < queueTasks2.length) {

        // Проверяем возможность сразу встать на сервис
        if (queueTasks1.isEmpty && !serviceComponent1.isBusy) {
          // Встаем на сервис
        } else {
          // Встаем в очередь
        }
      } else if (queueTasks2.length <= queueTasks1.length) {

        // Проверяем возможность сразу встать на сервис
        if (queueTasks2.isEmpty && !serviceComponent2.isBusy) {
          // Встаем на сервис
        } else {
          // Встаем в очередь
        }

      }


    } else {
      // На выход из системы
    }

     */
    /*
    /// Сначала сделать заявка попала в систему
    /// Если очередь пустая и обслуживание то на обслуживание

    // Создаем заявку, если задержка на создание прошла
    TaskComponent? taskComponent;
    if (taskDelay <= 0) {
      taskComponent = createTask();
      newTaskDelay();
    }

    if (taskComponent != null) {
      // Смотрим есть ли свободный сервис, если да, то добавляем в него задачу
      bool isAdded = tryAddTaskInService(taskComponent);

      // Если добавить не получилось, то пробуем добавить в очередь
      if (!isAdded) {
        tryAddTaskInQueue(taskComponent);
      }
    }

    tryAddTaskInServiceFromQueue();

    // Обновляем выполняемые задачи
    updateServices(dt);

    // Обновляем задержку
    updateDelay(dt);

    // print('Размер очереди: ${queueTasks.length}');
    textQueueSizeComponent.text = queueTasks.length.toString();

     */
  }
}
