import 'dart:ui';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../core/constantes.dart';
import '../estado/estado_juego.dart';
import 'componentes/jugador.dart';
import 'componentes/generador_enemigos.dart';
import 'componentes/enemigo.dart';
import 'componentes/diamante.dart';

class JuegoSupervivencia extends FlameGame with PanDetector, HasCollisionDetection {
  final GameState estadoJuego;

  late Jugador jugador;
  late GeneradorEnemigos generador;

  bool _tiendaMostradaMinutoCinco = false;

  JuegoSupervivencia({required this.estadoJuego});

  @override
  Color backgroundColor() => const Color(0xFF12121A);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    jugador = Jugador(estadoJuego: estadoJuego);
    generador = GeneradorEnemigos(estadoJuego: estadoJuego);

    add(jugador);
    add(generador);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!estadoJuego.isPlaying || estadoJuego.isPaused || estadoJuego.isGameOver) {
      return;
    }

    estadoJuego.updateGameTime(dt);

    if (estadoJuego.gameTime >= 300.0 && !_tiendaMostradaMinutoCinco) {
      _tiendaMostradaMinutoCinco = true;
      estadoJuego.pauseGame();
      overlays.add('ModalTienda');
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (estadoJuego.isHordeActive) {
      final paintCuadrado = Paint()
        ..color = const Color(0xFFFF1744).withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;

      final centro = Offset(size.x / 2, size.y / 2);

      canvas.drawRect(
        Rect.fromCenter(
          center: centro,
          width: GameConstants.arenaSquareSize,
          height: GameConstants.arenaSquareSize,
        ),
        paintCuadrado,
      );
    }
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    if (!estadoJuego.isPlaying || estadoJuego.isPaused || estadoJuego.isGameOver) {
      return;
    }
    jugador.mover(info.delta.global);
  }

  void pausarPorSubidaNivel() {
    estadoJuego.pauseGame();
    overlays.add('ModalSubirNivel');
  }

  void reanudarDesdeOverlay(String nombreOverlay) {
    overlays.remove(nombreOverlay);
    estadoJuego.resumeGame();
  }

  void finalizarPartida() {
    estadoJuego.endGame();
  }

  void reiniciar() {
    _tiendaMostradaMinutoCinco = false;

    children.whereType<Enemigo>().forEach((e) => e.removeFromParent());
    children.whereType<Diamante>().forEach((d) => d.removeFromParent());

    jugador.removeFromParent();
    generador.removeFromParent();

    jugador = Jugador(estadoJuego: estadoJuego);
    generador = GeneradorEnemigos(estadoJuego: estadoJuego);

    add(jugador);
    add(generador);
  }
}