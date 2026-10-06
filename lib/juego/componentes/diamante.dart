import 'package:flame/components.dart';
import '../../estado/estado_juego.dart';
import '../juego_supervivencia.dart';

class Diamante extends SpriteAnimationComponent with HasGameReference<JuegoSupervivencia> {
  final EstadoJuego estadoJuego;

  static const double radioIman = 140.0;
  static const double radioRecoleccion = 24.0;
  static const double velocidadAtraccion = 320.0;

  Diamante({
    required this.estadoJuego,
    required Vector2 posicionInicial,
  }) : super(
    position: posicionInicial,
    size: Vector2(24, 24),
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    animation = await game.loadSpriteAnimation(
      'items/diamante_anim.png',
      SpriteAnimationData.sequenced(
        amount: 5,
        stepTime: 0.12,
        textureSize: Vector2(16, 16),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!estadoJuego.enJuego || estadoJuego.enPausa || estadoJuego.finPartida) return;

    final posJugador = game.jugador.position;
    final dist = position.distanceTo(posJugador);

    if (dist <= radioRecoleccion) {
      estadoJuego.dropDiamante();
      removeFromParent();
      return;
    }

    if (dist <= radioIman) {
      final dir = (posJugador - position).normalized();
      position.add(dir * velocidadAtraccion * dt);
    }
  }
}