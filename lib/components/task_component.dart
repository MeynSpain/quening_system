import 'package:flame/components.dart';
import 'package:quening_system/components/service_component.dart';
import 'package:quening_system/const/global.dart';
import 'package:quening_system/const/task_status.dart';
import 'package:quening_system/game/quening_system_game.dart';

class TaskComponent extends SpriteComponent with HasGameRef<QueningSystemGame> {
  double executionTime;
  bool isExecuted = false;

  double speed = 200;
  Vector2 direction = Vector2(1, 1);

  late TaskStatus status;

  late ServiceComponent serviceComponent;

  TaskComponent({required this.executionTime});

  @override
  Future<void> onLoad() async {
    super.onLoad();

    if (gameRef.queueTasks.length < Global.maxSizeQueue) {
      status = TaskStatus.leave;
    } else {
      status = TaskStatus.created;
    }

    sprite = gameRef.characterSpriteSheet.getSpriteById(0);
    anchor = Anchor.center;
    // position = Vector2.all(30);
    size = Vector2.all(100);
  }

  void updateExecutionTime(double dt) {
    if (status == TaskStatus.onService) {
      if (executionTime > 0 && !isExecuted) {
        executionTime -= dt;
      } else {
        isExecuted = true;
      }
    }
  }

  void updateDirection(Vector2 target) {
    direction = target - position;
    direction = direction.normalized();
  }

  void move(double dt) {
    position += direction * dt * speed;
  }

  void goToService(ServiceComponent serviceComponent) {
    updateDirection(serviceComponent.position);
    this.serviceComponent = serviceComponent;
    status = TaskStatus.goToService;
  }

  void leave() {
    updateDirection(gameRef.exitPosition);
    status = TaskStatus.leave;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (status == TaskStatus.goToService) {
      move(dt);
      if (position.x >= serviceComponent.position.x &&
          position.y >= serviceComponent.position.y) {
        position = serviceComponent.position;
        status = TaskStatus.onService;
      }
    }

    // if (status == TaskStatus.leave) {
    //   move(dt);
    //   if (position.y >= serviceComponent.position.y) {
    //     position = gameRef.exitPosition;
    //     status = TaskStatus.leave;
    //     removeFromParent();
    //   }
    // }
  }

}