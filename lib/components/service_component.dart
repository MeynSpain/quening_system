import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:quening_system/components/task_component.dart';
import 'package:quening_system/const/global.dart';
import 'package:quening_system/game/quening_system_game.dart';

class ServiceComponent extends SpriteComponent
    with HasGameRef<QueningSystemGame> {
  bool isBusy = false;
  TaskComponent? taskComponent;

  @override
  Future<void> onLoad() async {
    // TODO: implement onLoad
    super.onLoad();

    final spriteImage = gameRef.images.fromCache(Global.shopRegisterSpriteSheet);
    SpriteSheet spriteSheet = SpriteSheet(image: spriteImage, srcSize: Vector2.all(64));

    sprite = spriteSheet.getSpriteById(0);
    size = Vector2(150, 120);
    anchor = Anchor.center;

  }

  void addTask({required TaskComponent taskComponent}) {
    this.taskComponent = taskComponent;
    isBusy = true;
  }

  void execute(double dt) {
    if (taskComponent != null) {
      if (!taskComponent!.isExecuted) {
        taskComponent!.updateExecutionTime(dt);
      } else {
        isBusy = false;
        taskComponent?.removeFromParent();
        // taskComponent?.leave();
        // taskComponent = null;
      }
    }

    print(
        'Service ${this}:\nisBusy: $isBusy\nTask:${taskComponent?.executionTime}');
  }
}
