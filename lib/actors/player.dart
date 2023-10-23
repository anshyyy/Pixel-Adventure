import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

enum PlayerState {
  idle,
  running,
  jumping,
  doubleJumping,
  falling,
  wallJumping,
  hitting,
}

enum PlayerDirection { left, right, none }

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure>, KeyboardHandler {
  final String playerName;
  Player({this.playerName = "Ninja Frog", position})
      : super(position: position);
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation jumpingAnimation;
  late final SpriteAnimation doubleJumpingAnimation;
  late final SpriteAnimation fallingAnimation;
  late final SpriteAnimation wallJumpingAnimation;
  late final SpriteAnimation hittingingAnimation;
  final double stepTime = 0.05;
  bool isFacingRight = true;
  PlayerDirection playerDirection = PlayerDirection.none;
  double moveSpeed = 100;
  Vector2 velocity = Vector2.zero();

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimation();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _updatePlayerMovement(dt);
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    final isRightKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight);
    if (isLeftKeyPressed && isRightKeyPressed) {
      playerDirection = PlayerDirection.none;
    } else if (isLeftKeyPressed) {
      playerDirection = PlayerDirection.left;
    } else if (isRightKeyPressed) {
      playerDirection = PlayerDirection.right;
    } else {
      playerDirection = PlayerDirection.none;
    }
    return super.onKeyEvent(event, keysPressed);
  }

  void _loadAllAnimation() {
    idleAnimation = makeCharacterAnimation("Idle", 11);
    runningAnimation = makeCharacterAnimation("Run", 12);
    jumpingAnimation = makeCharacterAnimation("Jump", 1);
    doubleJumpingAnimation = makeCharacterAnimation('Double Jump', 6);
    fallingAnimation = makeCharacterAnimation('Fall', 1);
    wallJumpingAnimation = makeCharacterAnimation('Wall Jump', 5);
    hittingingAnimation = makeCharacterAnimation('Hit', 7);

    //List of all animations
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnimation,
      PlayerState.doubleJumping: doubleJumpingAnimation,
      PlayerState.falling: fallingAnimation,
      PlayerState.hitting: hittingingAnimation,
      PlayerState.jumping: jumpingAnimation,
      PlayerState.wallJumping: wallJumpingAnimation
    };
    //set current animation
    current = PlayerState.idle;
  }

  SpriteAnimation makeCharacterAnimation(String stateName, int amount) {
    return SpriteAnimation.fromFrameData(
        game.images
            .fromCache('Main Characters/$playerName/$stateName (32x32).png'),
        SpriteAnimationData.sequenced(
            amount: amount, stepTime: stepTime, textureSize: Vector2.all(32)));
  }

  void _updatePlayerMovement(double dt) {
    double dirX = 0.0;
    switch (playerDirection) {
      case PlayerDirection.left:
        if (isFacingRight) {
          flipHorizontallyAroundCenter();
          isFacingRight = false;
        }
        current = PlayerState.running;
        dirX -= moveSpeed;
        break;
      case PlayerDirection.right:
        if (!isFacingRight) {
          flipHorizontallyAroundCenter();
          isFacingRight = true;
        }
        current = PlayerState.running;
        dirX += moveSpeed;
        break;
      case PlayerDirection.none:
        current = PlayerState.idle;
        break;
      default:
    }
    velocity = Vector2(dirX, 0.0);
    position += velocity * dt;
  }
}
