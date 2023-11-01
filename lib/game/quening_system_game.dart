import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flame/sprite.dart';
import 'package:quening_system/components/service_component.dart';
import 'package:quening_system/components/task_component.dart';
import 'package:quening_system/const/global.dart';
import 'package:quening_system/const/task_status.dart';
import 'package:quening_system/services/generator.dart';
import 'package:quening_system/services/task_component_generator.dart';

class QueningSystemGame extends FlameGame {
  List<TaskComponent> queueTasks = [];
  double taskDelay = 0;

  List<ServiceComponent> servicesList = [];

  ServiceComponent serviceComponent1 = ServiceComponent();
  ServiceComponent serviceComponent2 = ServiceComponent();

  late TextComponent textQueueSizeComponent;
  late final SpriteSheet characterSpriteSheet;

  late final Vector2 exitPosition;
  late final Vector2 startPosition;

  final Vector2 queuePosition = Vector2(30, 30);

  // final

  @override
  Future<void> onLoad() async {
    super.onLoad();

    exitPosition = Vector2(100, size.y - 10);
    startPosition = Vector2(100, size.y - 10);

    await images.load(Global.shopRegisterSpriteSheet);

    final spriteSheetImage = await images.load(Global.characterSpriteSheet);
    characterSpriteSheet =
        SpriteSheet(image: spriteSheetImage, srcSize: Vector2.all(64));

    serviceComponent1.position.x = size.x - 50;
    serviceComponent1.position.y = 100;
    // serviceComponent1.anchor = Anchor.topRight;

    serviceComponent2.position.x = size.x - 50;
    serviceComponent2.position.y = 300;
    // serviceComponent2.anchor = Anchor.topRight;

    add(serviceComponent1);
    add(serviceComponent2);

    servicesList.add(serviceComponent1);
    servicesList.add(serviceComponent2);

    textQueueSizeComponent = TextComponent();
    textQueueSizeComponent.text = queueTasks.length.toString();
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

  // List<TaskComponent> tasks = [];

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

  /// Попытка добаить сгенерировать задачу и добавить ее в очередь
  void tryAddTaskInQueue(TaskComponent taskComponent) {
    if (queueTasks.length < Global.maxSizeQueue) {
      // add(taskComponent);
      // tasks.add(taskComponent);

      if (queueTasks.isNotEmpty) {
        taskComponent.position = queueTasks.last.position;
        taskComponent.position.y += 50;
      } else {
        taskComponent.position = queuePosition;
      }

      queueTasks.add(taskComponent);
      // add(taskComponent);

      // print('Сгенерировано время выполнения ${queueTasks.last.executionTime}');
    } else {
      print('#### Задача отброшена ####');
    }
  }

  /// Попытка добавить задачу в сервис для ее выполнения
  void tryAddTaskInService(TaskComponent taskComponent) {
    int indexFreeService = indexOfFreeService();
    if (indexFreeService != -1) {
      // TaskComponent task = queueTasks.removeAt(0);

      goToService(taskComponent, servicesList[indexFreeService]);

      servicesList[indexFreeService].addTask(taskComponent: taskComponent);

      // updateQueue();
    } else {
      // Если все сервисы заняты, то пробуем добавить задачу в очередь
      tryAddTaskInQueue(taskComponent);
    }
  }

  void updateQueue() {
    for (var task in queueTasks) {
      task.position.y -= 50;
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

  // List<RectangleComponent> list = [];

  /*
  void addRectangle() {
    if (list.length < 20) {
      RectangleComponent rectangleComponent = RectangleComponent();
      rectangleComponent.size = Vector2.all(50);
      rectangleComponent.paint = BasicPalette.red.paint();

      if (list.isNotEmpty) {
        rectangleComponent.position = list.last.position;
        rectangleComponent.position.y += 50;

      } else {
        rectangleComponent.position = Vector2(100, 50);
      }
      list.add(rectangleComponent);
      add(rectangleComponent);
    }
  }
   */

  @override
  void update(double dt) {
    super.update(dt);

    // addRectangle();

    /// Сначала сделать заявка попала в систему
    /// Если очередь пустая и обслуживание то на обслуживание

    // Создаем заявку, если задержка на создание прошла
    TaskComponent? taskComponent;
    if (taskDelay <= 0) {
      taskComponent = createTask();
    }

    if (taskComponent != null) {
      // Смотрим есть ли свободный сервис, если да, то добавляем в него задачу
      tryAddTaskInService(taskComponent);

      // Добавляем задачу в очередь, если кончилось время задержки
      // tryAddTaskInQueue(taskComponent);
    }
    // Обновляем выполняемые задачи
    updateServices(dt);

    // Обновляем задержку
    updateDelay(dt);

    print('Размер очереди: ${queueTasks.length}');
    textQueueSizeComponent.text = queueTasks.length.toString();
  }
}
