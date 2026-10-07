import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../estado/estado_juego.dart';
import '../juego_supervivencia.dart';

class Diamante extends SpriteComponent with HasGameReference<JuegoSupervivencia> {
  final EstadoJuego estadoJuego;
  final int valor;

  static const double radioIman = 140.0;
  static const double radioRecoleccion = 24.0;
  static const double velocidadAtraccion = 320.0;

  bool _spritesCargados = false;

  Diamante({
    required this.estadoJuego,
    required Vector2 posicionInicial,
    this.valor = 10,
  }) : super(
    position: posicionInicial,
    size: Vector2(24, 24),
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    try {
      sprite = await game.loadSprite('items/diamante.png');
      _spritesCargados = true;
    } catch (_) {
      _spritesCargados = false;
    }
  }

  @override
  void render(Canvas canvas) {
    if (_spritesCargados) {
      super.render(canvas);
    } else {
      final paint = Paint()..color = const Color(0xFF00E5FF);
      final path = Path()
        ..moveTo(size.x / 2, 0)
        ..lineTo(size.x, size.y / 2)
        ..lineTo(size.x / 2, size.y)
        ..lineTo(0, size.y / 2)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!estadoJuego.enJuego || estadoJuego.enPausa || estadoJuego.finPartida) return;

    final posJugador = game.jugador.position;
    final dist = position.distanceTo(posJugador);

    if (dist <= radioRecoleccion) {
      estadoJuego.dropDiamante(valor);
      removeFromParent();
      return;
    }

    if (dist <= radioIman) {
      final dir = (posJugador - position).normalized();
      position.add(dir * velocidadAtraccion * dt);
    }
  }
}
