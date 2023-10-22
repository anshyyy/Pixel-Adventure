import 'dart:async';

import 'package:flame/components.dart';
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
    with HasGameRef<PixelAdventure> {
  final String playerName;
  Player({required this.playerName, position}) : super(position: position);
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation jumpingAnimation;
  late final SpriteAnimation doubleJumpingAnimation;
  late final SpriteAnimation fallingAnimation;
  late final SpriteAnimation wallJumpingAnimation;
  late final SpriteAnimation hittingingAnimation;
  final double stepTime = 0.05;

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimation();
    return super.onLoad();
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
    current = PlayerState.running;
  }

  SpriteAnimation makeCharacterAnimation(String stateName, int amount) {
    return SpriteAnimation.fromFrameData(
        game.images
            .fromCache('Main Characters/$playerName/$stateName (32x32).png'),
        SpriteAnimationData.sequenced(
            amount: amount, stepTime: stepTime, textureSize: Vector2.all(32)));
  }
}
