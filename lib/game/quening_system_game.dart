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
  List<TaskComponent> queueTasks = [];
  double taskDelay = 0;

  List<ServiceComponent> servicesList = [];

  // Map<ServiceComponent, bool> servicesMap = {};

  ServiceComponent serviceComponent1 = ServiceComponent();
  ServiceComponent serviceComponent2 = ServiceComponent();

  ExitComponent exitComponent = ExitComponent();

  late TextComponent textQueueSizeComponent;
  late final SpriteSheet characterSpriteSheet;

  late final Vector2 exitPosition;
  late final Vector2 startPosition;

  final Vector2 queuePosition = Vector2(30, 30);

  late final BackGroundImageLayer backGroundImageLayer;

  @override
  Future<void> onLoad() async {
    super.onLoad();

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
    textQueueSizeComponent.text = queueTasks.length.toString();
    textQueueSizeComponent.position = Vector2(size.x / 2, 100);
    add(textQueueSizeComponent);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // backGroundImageLayer.render(canvas);
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
  void tryAddTaskInQueue(TaskComponent taskComponent) {
    if (queueTasks.length < Global.maxSizeQueue) {
      Vector2 newQueuePosition = Vector2.copy(queuePosition);
      if (queueTasks.isNotEmpty) {
        newQueuePosition.y += (queueTasks.length * 50);
      }

      goInQueue(taskComponent, newQueuePosition);

      queueTasks.add(taskComponent);
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

  void tryAddTaskInServiceFromQueue() {
    if (queueTasks.isNotEmpty) {
      TaskComponent taskComponent = queueTasks.first;
      bool isAdded = tryAddTaskInService(taskComponent);

      if (isAdded) {
        queueTasks.removeAt(0);
        updateQueue();
      }
    }
  }

  void updateQueue() {
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

  @override
  void update(double dt) {
    super.update(dt);

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
  }
}
