import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:quening_system/components/task_component.dart';

class ExitComponent extends PositionComponent
    with HasGameRef, CollisionCallbacks {

  List<TaskComponent> leaveTasks = [];

  @override
  Future<void> onLoad() async {
    super.onLoad();

    add(RectangleHitbox());

    size = Vector2(50, 50);
    anchor = Anchor.center;
    // paint = BasicPalette.red.paint();
  }




}
