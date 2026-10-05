import 'dart:ui';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../core/constantes.dart';
import '../../estado/estado_juego.dart';
import '../juego_supervivencia.dart';
import '../armas/espada.dart';
import '../armas/arco.dart';
import '../armas/magia_fuego.dart';

class Jugador extends PositionComponent
    with HasGameReference<JuegoSupervivencia>, CollisionCallbacks {
  final GameState estadoJuego;

  static const double radioJugador = 22.0;

  late Espada espada;
  late Arco arco;
  late MagiaFuego magiaFuego;

  Jugador({required this.estadoJuego})
      : super(
    size: Vector2.all(radioJugador * 2),
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    position = game.size / 2;
    add(CircleHitbox(radius: radioJugador));

    espada = Espada(estadoJuego: estadoJuego);
    arco = Arco(estadoJuego: estadoJuego);
    magiaFuego = MagiaFuego(estadoJuego: estadoJuego);

    add(espada);
    add(arco);
    add(magiaFuego);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _restringirLimites();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final centro = Offset(size.x / 2, size.y / 2);

    final cuerpoPaint = Paint()..color = const Color(0xFF29B6F6);
    canvas.drawCircle(centro, radioJugador, cuerpoPaint);

    final contornoPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawCircle(centro, radioJugador, contornoPaint);

    final ojosPaint = Paint()..color = Colors.white;
    canvas.drawCircle(centro + const Offset(-7, -4), 5, ojosPaint);
    canvas.drawCircle(centro + const Offset(7, -4), 5, ojosPaint);

    final pupilasPaint = Paint()..color = const Color(0xFF01579B);
    canvas.drawCircle(centro + const Offset(-7, -4), 2.5, pupilasPaint);
    canvas.drawCircle(centro + const Offset(7, -4), 2.5, pupilasPaint);

    _renderizarBarraVida(canvas);
  }

  void _renderizarBarraVida(Canvas canvas) {
    const anchoBarra = 36.0;
    const altoBarra = 6.0;
    final origenX = (size.x - anchoBarra) / 2;
    const origenY = -12.0;

    final fondoPaint = Paint()..color = Colors.black45;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(origenX, origenY, anchoBarra, altoBarra),
        const Radius.circular(3),
      ),
      fondoPaint,
    );

    final porcentajeVida = (estadoJuego.playerHp / estadoJuego.playerMaxHp).clamp(0.0, 1.0);
    final vidaPaint = Paint()..color = const Color(0xFF00E676);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(origenX, origenY, anchoBarra * porcentajeVida, altoBarra),
        const Radius.circular(3),
      ),
      vidaPaint,
    );
  }

  void mover(Vector2 delta) {
    position.add(delta);
    _restringirLimites();
  }

  void _restringirLimites() {
    if (estadoJuego.isHordeActive) {
      final centroMapa = game.size / 2;
      final medioLado = GameConstants.arenaSquareSize / 2;

      position.x = position.x.clamp(
        centroMapa.x - medioLado + radioJugador,
        centroMapa.x + medioLado - radioJugador,
      );
      position.y = position.y.clamp(
        centroMapa.y - medioLado + radioJugador,
        centroMapa.y + medioLado - radioJugador,
      );
    } else {
      position.x = position.x.clamp(radioJugador, game.size.x - radioJugador);
      position.y = position.y.clamp(radioJugador, game.size.y - radioJugador);
    }
  }

  void recibirDanio(double cantidad) {
    estadoJuego.playerHp -= cantidad;
    if (estadoJuego.playerHp <= 0) {
      estadoJuego.playerHp = 0;
      game.finalizarPartida();
    }
  }
}