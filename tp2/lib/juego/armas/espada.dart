import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../componentes/enemigo.dart';
import 'arma_base.dart';

class Espada extends ArmaBase {
  Espada({required super.estadoJuego})
      : super(
    intervaloAtaque: 1.2,
    danioBase: 35.0,
  );

  @override
  int get nivel => estadoJuego.swordLevel;

  @override
  void ejecutarAtaque() {
    final jugador = game.jugador;

    if (!estaMejorada) {
      const radioCorte = 95.0;
      game.world.add(EfectoCorteCircular(posicion: jugador.position.clone(), radio: radioCorte));

      final enemigos = game.world.children.whereType<Enemigo>();
      for (final enemigo in enemigos) {
        if (enemigo.position.distanceTo(jugador.position) <= radioCorte) {
          enemigo.recibirDanio(danioFinal);
        }
      }
    } else {
      const cantidadCortes = 5;
      final random = Random();

      for (int i = 0; i < cantidadCortes; i++) {
        final angulo = random.nextDouble() * pi;
        final offset = Vector2(
          (random.nextDouble() - 0.5) * 260.0,
          (random.nextDouble() - 0.5) * 260.0,
        );
        final origen = jugador.position + offset;

        game.world.add(
          EfectoCorteDimensional(
            posicion: origen,
            angulo: angulo,
            longitud: 220.0,
          ),
        );
      }

      final danioEvolucionado = danioFinal * 1.8;
      final enemigos = game.world.children.whereType<Enemigo>();
      for (final enemigo in enemigos) {
        if (enemigo.position.distanceTo(jugador.position) <= 180.0) {
          enemigo.recibirDanio(danioEvolucionado);
        }
      }
    }
  }
}

class EfectoCorteCircular extends PositionComponent {
  final double radio;
  static const double _tiempoVida = 0.22;
  double _progreso = 0.0;

  EfectoCorteCircular({required Vector2 posicion, required this.radio})
      : super(
    position: posicion,
    size: Vector2.all(radio * 2),
    anchor: Anchor.center,
  );

  @override
  void update(double dt) {
    super.update(dt);
    _progreso += dt / _tiempoVida;
    if (_progreso >= 1.0) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final centro = Offset(size.x / 2, size.y / 2);
    final radioActual = radio * (0.6 + (_progreso * 0.4));
    final opacidad = (1.0 - _progreso).clamp(0.0, 1.0);

    final paint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: opacidad)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0 * (1.0 - _progreso);

    canvas.drawCircle(centro, radioActual, paint);
  }
}

class EfectoCorteDimensional extends PositionComponent {
  final double angulo;
  final double longitud;
  static const double _tiempoVida = 0.28;
  double _progreso = 0.0;

  EfectoCorteDimensional({
    required Vector2 posicion,
    required this.angulo,
    required this.longitud,
  }) : super(
    position: posicion,
    anchor: Anchor.center,
  );

  @override
  void update(double dt) {
    super.update(dt);
    _progreso += dt / _tiempoVida;
    if (_progreso >= 1.0) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final opacidad = (1.0 - _progreso).clamp(0.0, 1.0);

    final paintPrincipal = Paint()
      ..color = const Color(0xFFFF1744).withValues(alpha: opacidad)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;

    final paintBrillo = Paint()
      ..color = Colors.white.withValues(alpha: opacidad)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final dx = cos(angulo) * (longitud / 2);
    final dy = sin(angulo) * (longitud / 2);

    final p1 = Offset(-dx, -dy);
    final p2 = Offset(dx, dy);

    canvas.drawLine(p1, p2, paintPrincipal);
    canvas.drawLine(p1, p2, paintBrillo);
  }
}
