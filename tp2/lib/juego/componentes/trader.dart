import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/foundation.dart';
import '../../estado/estado_juego.dart';
import 'jugador.dart';
import '../juego_supervivencia.dart';

class Trader extends SpriteAnimationComponent
    with HasGameReference<JuegoSupervivencia>, CollisionCallbacks {
  final EstadoJuego estadoJuego;

  bool _tiendaAbierta = false;

  Trader({
    required this.estadoJuego,
    required Vector2 posicionInicial,
  }) : super(
    position: posicionInicial,
    size: Vector2.all(120),
    anchor: Anchor.center,
    priority: 2,
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final image = game.images.fromCache('personajes/trader_comerciar.png');
    final hoja = SpriteSheet(image: image, srcSize: Vector2.all(128));

    animation = hoja.createAnimation(
      row: 0,
      stepTime: 0.15,
      to: 16,
      loop: true,
    );

    add(
      CircleHitbox(
        radius: 55.0,
        anchor: Anchor.center,
        position: size / 2,
      ),
    );

    debugPrint('[DEBUG_TRADER] Comerciante spawneado en $position');
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    if (_tiendaAbierta) return;
    if (other is! Jugador) return;
    if (!estadoJuego.enJuego || estadoJuego.enPausa || estadoJuego.finPartida) {
      return;
    }

    _tiendaAbierta = true;
    game.pausarPorOverlay('ModalTienda');
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    if (other is Jugador) {
      _tiendaAbierta = false;
    }
  }
}
