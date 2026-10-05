import 'dart:ui';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../estado/estado_juego.dart';
import '../juego_supervivencia.dart';
import 'diamante.dart';

enum TipoEnemigo { slime, fantasma, miniGolen, basico, rapido, tanque }

class Enemigo extends PositionComponent
    with HasGameReference<JuegoSupervivencia>, CollisionCallbacks {
  final TipoEnemigo tipo;
  final GameState estadoJuego;

  late double vidaMax;
  late double vidaActual;
  late double velocidad;
  late double danio;
  late double radio;
  late Color colorCuerpo;

  Enemigo({
    required this.tipo,
    required this.estadoJuego,
    required Vector2 posicionInicial,
  }) : super(
    position: posicionInicial,
    anchor: Anchor.center,
  ) {
    _configurarEstadisticas();
    size = Vector2.all(radio * 2);
  }

  void _configurarEstadisticas() {
    switch (tipo) {
      case TipoEnemigo.slime:
      case TipoEnemigo.basico:
        vidaMax = 50.0;
        velocidad = 75.0;
        danio = 10.0;
        radio = 14.0;
        colorCuerpo = const Color(0xFFE53935);
        break;
      case TipoEnemigo.fantasma:
      case TipoEnemigo.rapido:
        vidaMax = 25.0;
        velocidad = 130.0;
        danio = 6.0;
        radio = 10.0;
        colorCuerpo = const Color(0xFFFFB300);
        break;
      case TipoEnemigo.miniGolen:
      case TipoEnemigo.tanque:
        vidaMax = 180.0;
        velocidad = 45.0;
        danio = 22.0;
        radio = 22.0;
        colorCuerpo = const Color(0xFF6A1B9A);
        break;
    }
    vidaActual = vidaMax;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox(radius: radio));
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!estadoJuego.isPlaying || estadoJuego.isPaused || estadoJuego.isGameOver) {
      return;
    }

    final jugador = game.jugador;
    final direccion = (jugador.position - position).normalized();
    position.add(direccion * velocidad * dt);

    if (position.distanceTo(jugador.position) <= radio + 22.0) {
      jugador.recibirDanio(danio * dt);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final centro = Offset(size.x / 2, size.y / 2);

    final paintCuerpo = Paint()..color = colorCuerpo;
    canvas.drawCircle(centro, radio, paintCuerpo);

    final paintBorde = Paint()
      ..color = Colors.black45
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(centro, radio, paintBorde);

    if (vidaActual < vidaMax) {
      const anchoBarra = 24.0;
      const altoBarra = 4.0;
      final origenX = (size.x - anchoBarra) / 2;
      const origenY = -8.0;

      final paintFondo = Paint()..color = Colors.black54;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(origenX, origenY, anchoBarra, altoBarra),
          const Radius.circular(2),
        ),
        paintFondo,
      );

      final porcentaje = (vidaActual / vidaMax).clamp(0.0, 1.0);
      final paintVida = Paint()..color = const Color(0xFF00E676);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(origenX, origenY, anchoBarra * porcentaje, altoBarra),
          const Radius.circular(2),
        ),
        paintVida,
      );
    }
  }

  void recibirDanio(double cantidad) {
    vidaActual -= cantidad;
    if (vidaActual <= 0) {
      _morir();
    }
  }

  void _morir() {
    final esTanque = tipo == TipoEnemigo.miniGolen || tipo == TipoEnemigo.tanque;
    estadoJuego.addScore(esTanque ? 30 : 10);
    game.add(
      Diamante(
        estadoJuego: estadoJuego,
        valor: esTanque ? 5 : 1,
        posicionInicial: position.clone(),
      ),
    );
    removeFromParent();
  }
}