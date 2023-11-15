import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:quening_system/components/exit_component.dart';
import 'package:quening_system/components/service_component.dart';
import 'package:quening_system/const/global.dart';
import 'package:quening_system/const/task_status.dart';
import 'package:quening_system/game/quening_system_game.dart';

class TaskComponent extends SpriteComponent
    with HasGameRef<QueningSystemGame>, CollisionCallbacks {
  double executionTime;
  bool isExecuted = false;

  double speed = 200;
  Vector2 direction = Vector2(1, 1);

  late TaskStatus status;

  late ServiceComponent serviceComponent;

  late Vector2 queuePosition;

  late ExitComponent exitComponent;

  TaskComponent({required this.executionTime});

  @override
  Future<void> onLoad() async {
    super.onLoad();

    if (gameRef.queueTasks1.length < Global.maxSizeQueue) {
      status = TaskStatus.created;
    } else {
      goToExit(gameRef.exitComponent);
    }

    sprite = gameRef.characterSpriteSheet.getSpriteById(0);
    anchor = Anchor.center;
    // position = Vector2.all(30);
    size = Vector2.all(100);
    
    add(RectangleHitbox());
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

  void goInQueue(Vector2 queuePosition) {
    updateDirection(queuePosition);
    this.queuePosition = queuePosition;
    status = TaskStatus.goInQueue;
  }

  void leave() {
    updateDirection(gameRef.exitPosition);
    status = TaskStatus.leave;
  }

  void goToExit(ExitComponent exitComponent) {
    updateDirection(exitComponent.position);
    status = TaskStatus.goToExit;
    this.exitComponent = exitComponent;
    exitComponent.leaveTasks.add(this);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (status == TaskStatus.goToService) {
      move(dt);
      if (position.x >= serviceComponent.position.x + serviceComponent.size.x &&
          position.y >= serviceComponent.position.y) {
        position = serviceComponent.position;
        status = TaskStatus.onService;
      }
    } else if (status == TaskStatus.goInQueue) {
      move(dt);
      if (position.y <= queuePosition.y) {
        position = queuePosition;
        status = TaskStatus.inQueue;
      }
    } else if (status == TaskStatus.goToExit) {
      move(dt);

    }
    // print('POSITION: $position');
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (status == TaskStatus.goToService) {
      if (other == serviceComponent) {
        position = serviceComponent.position;
        status = TaskStatus.onService;
      }
    }

    if (status == TaskStatus.goToExit) {
      if (other == exitComponent) {
        status = TaskStatus.leave;
        removeFromParent();
      }
    }
  }
}
