import 'package:flame/components.dart';
import 'package:flutter/cupertino.dart';

class BackGroundComponent extends SpriteComponent {

  BackGroundComponent({required Sprite sprite, required Vector2 size}) {
    this.sprite = sprite;
    this.size = size;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
  }
}
