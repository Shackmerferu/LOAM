import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../estado/estado_juego.dart';
import '../juego_supervivencia.dart';

class Diamante extends PositionComponent with HasGameReference<JuegoSupervivencia> {
  final GameState estadoJuego;
  final int valor;

  static const double tamanoVisual = 16.0;
  static const double radioAtraccion = 130.0;
  static const double radioRecoleccion = 26.0;
  static const double velocidadIman = 280.0;

  Diamante({
    required this.estadoJuego,
    required this.valor,
    required Vector2 posicionInicial,
  }) : super(
    position: posicionInicial,
    size: Vector2.all(tamanoVisual),
    anchor: Anchor.center,
  );

  @override
  void update(double dt) {
    super.update(dt);

    if (!estadoJuego.isPlaying || estadoJuego.isPaused || estadoJuego.isGameOver) {
      return;
    }

    final posicionJugador = game.jugador.position;
    final distancia = position.distanceTo(posicionJugador);

    if (distancia <= radioRecoleccion) {
      estadoJuego.addDiamonds(valor);
      removeFromParent();
      return;
    }

    if (distancia <= radioAtraccion) {
      final direccion = (posicionJugador - position).normalized();
      position.add(direccion * velocidadIman * dt);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final ancho = size.x;
    final alto = size.y;

    final path = Path()
      ..moveTo(ancho / 2, 0)
      ..lineTo(ancho, alto * 0.4)
      ..lineTo(ancho / 2, alto)
      ..lineTo(0, alto * 0.4)
      ..close();

    final paintCuerpo = Paint()..color = const Color(0xFF00E5FF);
    canvas.drawPath(path, paintCuerpo);

    final pathBrillo = Path()
      ..moveTo(ancho / 2, 0)
      ..lineTo(ancho * 0.75, alto * 0.4)
      ..lineTo(ancho / 2, alto * 0.6)
      ..lineTo(ancho * 0.25, alto * 0.4)
      ..close();

    final paintBrillo = Paint()..color = Colors.white.withValues(alpha: 0.65);
    canvas.drawPath(pathBrillo, paintBrillo);

    final paintBorde = Paint()
      ..color = const Color(0xFF0091EA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(path, paintBorde);
  }
}