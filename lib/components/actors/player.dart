import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:pixel_adventure/components/collision_block.dart';
import 'package:pixel_adventure/components/custom_hitbox.dart';
import 'package:pixel_adventure/components/fruit.dart';
import 'package:pixel_adventure/components/utils.dart';
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

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure>, KeyboardHandler, CollisionCallbacks {
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
  double horizontalMovement = 0;
  double moveSpeed = 100;
  final double _gravity = 9.8;
  final double _jumpForce = 300;
  bool isOnGround = false;
  bool hasJumped = false;
  final double _terminalVelocity = 300;
  Vector2 velocity = Vector2.zero();
  List<CollisionBlock> collisionBlocks = [];
  CustomHitbox hitbox =
      CustomHitbox(offsetX: 10, offsetY: 4, width: 14, height: 28);

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimation();

    add(RectangleHitbox(
        position: Vector2(hitbox.offsetX, hitbox.offsetY),
        size: Vector2(hitbox.width, hitbox.height)));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _updatePlayerState(dt);
    _updatePlayerMovement(dt);
    _checkHorizontalCollisions();
    _applygravity(dt);
    _checkVerticalCollisions();
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMovement = 0;
    final isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    final isRightKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight);
    hasJumped = keysPressed.contains(LogicalKeyboardKey.space);

    horizontalMovement += isLeftKeyPressed ? -1 : 0;
    horizontalMovement += isRightKeyPressed ? 1 : 0;

    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Fruit) other.collidedWithPlayer();
    super.onCollision(intersectionPoints, other);
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
    if (hasJumped && isOnGround) {
      _playerJump(dt);
    }

    if (velocity.y > _gravity) isOnGround = false;
    velocity.x = horizontalMovement * moveSpeed;
    position.x += velocity.x * dt;
  }

  void _updatePlayerState(double dt) {
    PlayerState playerState = PlayerState.idle;

    if (velocity.x < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
    } else if (velocity.x > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
    }

    //check moving
    if (velocity.x > 0 || velocity.x < 0) {
      playerState = PlayerState.running;
    }

    //check falling
    if (velocity.y > 0) playerState = PlayerState.falling;

    //check jumping
    if (velocity.y < 0) playerState = PlayerState.jumping;
    current = playerState;
  }

  void _checkHorizontalCollisions() {
    for (final block in collisionBlocks) {
      if (!block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.x > 0) {
            velocity.x = 0;
            position.x = block.x - hitbox.offsetX - hitbox.width;
            break;
          }
          if (velocity.x < 0) {
            velocity.x = 0;
            position.x = block.x + block.width + hitbox.width + hitbox.offsetX;
            break;
          }
        }
      }
    }
  }

  void _applygravity(double dt) {
    // check gravity
    velocity.y += _gravity;
    velocity.y = velocity.y.clamp(-_jumpForce, _terminalVelocity);
    position.y += velocity.y * dt;
  }

  void _checkVerticalCollisions() {
    for (final block in collisionBlocks) {
      if (block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }
        }
      } else {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }
          if (velocity.y < 0) {
            velocity.y = 0;
            position.y = block.y + block.height - hitbox.offsetY;
          }
        }
      }
    }
  }

  void _playerJump(double dt) {
    velocity.y = -_jumpForce;
    position.y += velocity.y * dt;
    current = PlayerState.jumping;
    hasJumped = false;
    isOnGround = false;
  }
}
