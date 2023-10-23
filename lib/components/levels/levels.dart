import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixel_adventure/components/actors/player.dart';
import 'package:pixel_adventure/components/collision_block.dart';

class Level extends World {
  final String levelName;
  final Player player;
  Level({required this.levelName, required this.player});
  late TiledComponent level;
  List<CollisionBlock> collisionBlock = [];

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load('$levelName.tmx', Vector2.all(16));

    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>('Spawnpoints');
    if (spawnPointsLayer != null) {
      for (final spawnPoint in spawnPointsLayer.objects) {
        switch (spawnPoint.class_) {
          case 'Player':
            player.position = Vector2(spawnPoint.x, spawnPoint.y);
            add(player);
            break;
          default:
        }
      }
    }

    final collisionLayer = level.tileMap.getLayer<ObjectGroup>('Collisions');
    if (collisionLayer != null) {
      for (final collison in collisionLayer.objects) {
        switch (collison.class_) {
          case 'Platform':
            final platform = CollisionBlock(
                position: Vector2(collison.x, collison.y),
                size: Vector2(collison.width, collison.height),
                isPlatform: true);
            collisionBlock.add(platform);
            add(platform);
            break;
          default:
            final block = CollisionBlock(
              position: Vector2(collison.x, collison.y),
              size: Vector2(collison.width, collison.height),
            );
            collisionBlock.add(block);
            add(block);
        }
      }
      player.collisionBlocks = collisionBlock;
    }

    add(level);
    return super.onLoad();
  }
}
