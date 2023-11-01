import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:quening_system/game/quening_system_game.dart';
import 'package:quening_system/services/generator.dart';

void main() {
  runApp(
    GameWidget(
      game: QueningSystemGame(),
    ),
  );
}

/// This example simply adds a rotating white square on the screen.
/// If you press on a square, it will be removed.
/// If you press anywhere else, another square will be added.
class MyGame extends FlameGame with TapCallbacks {
  late SpriteAnimationComponent slime;

  late Timer timer;

  @override
  Future<void> onLoad() async {

    timer = Timer(2);
    timer.limit = 4;



    final slimeImage = await images.load('slime-animation_sprite_sheet.png');

    final jsonData = await assets.readJson(
        'images/slime-animation_aseprite.json');

    var slimeAnimation = SpriteAnimation.fromAsepriteData(slimeImage, jsonData);
    // fromFrameData(
    //     slimeImage,
    //     SpriteAnimationData.sequenced(
    //         amount: 2, stepTime: 0.2, textureSize: Vector2(40, 32)));

    slime = SpriteAnimationComponent()
      ..animation = slimeAnimation;
    slime.position = size / 2;
    slime.size = Vector2.all(100);
    slime.anchor = Anchor.center;
    add(slime);

    final spriteSheet = SpriteSheet(
        image: slimeImage, srcSize: Vector2.all(32));


    final customSlimeAnimation = SpriteAnimation.fromFrameData(
        spriteSheet.image, SpriteAnimationData(
        [
          spriteSheet.createFrameDataFromId(0, stepTime: 0.1),
          spriteSheet.createFrameDataFromId(1, stepTime: 0.2),
        ]
    ));

    final customSlimeComponent = SpriteAnimationComponent(
      animation: customSlimeAnimation,
      position: Vector2(50, 50),
      size: Vector2.all(50),
    );

    customSlimeComponent.position = size / 2;
    customSlimeComponent.anchor = Anchor.center;
    add(customSlimeComponent);
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
  }
}
