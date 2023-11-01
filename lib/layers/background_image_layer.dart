import 'package:flame/components.dart';
import 'package:flame/layers.dart';

class BackGroundImageLayer extends PreRenderedLayer {
  final Sprite sprite;
  final Vector2 size;

  BackGroundImageLayer({required this.sprite, required this.size});

  @override
  void drawLayer() {
    sprite.render(canvas, size: size);
  }
}
