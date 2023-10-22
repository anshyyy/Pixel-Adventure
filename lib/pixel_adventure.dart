import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:pixel_adventure/levels/levels.dart';

class PixelAdventure extends FlameGame {
  late final CameraComponent cam;
  Color backgroundColor() => const Color(0xFF211F30);
  final world = Level();

  @override
  FutureOr<void> onLoad() async {
    await images.loadAllImages(); // this can cause issue,image loaded in cache
    cam = CameraComponent.withFixedResolution(
        world: world, width: 640, height: 360);
    cam.viewfinder.anchor = Anchor.topLeft;
    addAll([cam, world]);

    return super.onLoad();
  }
}
