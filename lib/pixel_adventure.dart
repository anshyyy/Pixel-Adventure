import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:pixel_adventure/components/actors/player.dart';
import 'package:pixel_adventure/components/levels/levels.dart';

class PixelAdventure extends FlameGame
    with HasKeyboardHandlerComponents, DragCallbacks, HasCollisionDetection {
  late final CameraComponent cam;

  @override
  Color backgroundColor() => const Color(0xFF211F30);

  Player player = Player(playerName: "Virtual Guy");
  late JoystickComponent joystick;
  bool showJoystick = false;

  @override
  FutureOr<void> onLoad() async {
    final world = Level(levelName: 'level-01', player: player);
    await images.loadAllImages(); // this can cause issue,image loaded in cache
    cam = CameraComponent.withFixedResolution(
        world: world, width: 640, height: 360);
    cam.viewfinder.anchor = Anchor.topLeft;
    addAll([cam, world]);
    if (showJoystick) _addJoyStick();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (showJoystick) updateJoystick(dt);
    super.update(dt);
  }

  void _addJoyStick() {
    joystick = JoystickComponent(
      knob: SpriteComponent(
        sprite: Sprite(
          images.fromCache('HUD/Knob.png'),
        ),
      ),
      background: SpriteComponent(
        sprite: Sprite(
          images.fromCache('HUD/Joystick.png'),
        ),
      ),
      margin: const EdgeInsets.only(left: 32, bottom: 32),
    );
    add(joystick);
  }

  void updateJoystick(double dt) {
    switch (joystick.direction) {
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
      case JoystickDirection.left:
        player.horizontalMovement = -1;
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        player.horizontalMovement = 1;
        break;
      default:
        player.horizontalMovement = 0;
        break;
      // player.playerDirection = PlayerDirection.none;
    }
  }
}
