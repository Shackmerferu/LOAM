import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../componentes/enemigo.dart';
import 'arma_base.dart';

class MagiaFuego extends ArmaBase {
  MagiaFuego({required super.estadoJuego})
      : super(
    intervaloAtaque: 1.6,
    danioBase: 45.0,
  );

  @override
  int get nivel => estadoJuego.fireMagicLevel;

  @override
  void ejecutarAtaque() {
    final jugador = game.jugador;
    final enemigos = game.children.whereType<Enemigo>().toList();

    Vector2 direccion = Vector2(0, -1);
    if (enemigos.isNotEmpty) {
      enemigos.sort((a, b) => a.position
          .distanceTo(jugador.position)
          .compareTo(b.position.distanceTo(jugador.position)));
      direccion = (enemigos.first.position - jugador.position).normalized();
    }

    if (!estaMejorada) {
      game.add(
        ProyectilBolaFuego(
          posicionInicial: jugador.position.clone(),
          direccion: direccion,
          danio: danioFinal,
        ),
      );
    } else {
      game.add(
        EfectoLlamaradaContinua(
          posicionOrigen: jugador.position.clone(),
          direccion: direccion,
          danioBaseSegundo: danioFinal * 1.5,
        ),
      );
    }
  }
}

class ProyectilBolaFuego extends PositionComponent {
  final Vector2 direccion;
  final double danio;

  static const double velocidad = 260.0;
  static const double alcanceMaximo = 380.0;
  double _distanciaRecorrida = 0.0;

  ProyectilBolaFuego({
    required Vector2 posicionInicial,
    required this.direccion,
    required this.danio,
  }) : super(
    position: posicionInicial,
    size: Vector2.all(22.0),
    anchor: Anchor.center,
  );

  @override
  void update(double dt) {
    super.update(dt);

    final avance = velocidad * dt;
    position.add(direccion * avance);
    _distanciaRecorrida += avance;

    final enemigos = parent?.children.whereType<Enemigo>() ?? [];
    for (final enemigo in enemigos) {
      if (enemigo.position.distanceTo(position) <= enemigo.radio + 11.0) {
        _impactarArea();
        return;
      }
    }

    if (_distanciaRecorrida >= alcanceMaximo) {
      removeFromParent();
    }
  }

  void _impactarArea() {
    const radioArea = 60.0;
    final enemigos = parent?.children.whereType<Enemigo>() ?? [];
    for (final enemigo in enemigos) {
      if (enemigo.position.distanceTo(position) <= radioArea) {
        enemigo.recibirDanio(danio);
      }
    }
    removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final centro = Offset(size.x / 2, size.y / 2);

    final paintNucleo = Paint()..color = const Color(0xFFFFEB3B);
    canvas.drawCircle(centro, 6.0, paintNucleo);

    final paintHalo = Paint()
      ..color = const Color(0xFFFF5722).withValues(alpha: 0.85)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
    canvas.drawCircle(centro, 11.0, paintHalo);
  }
}

class EfectoLlamaradaContinua extends PositionComponent {
  final Vector2 direccion;
  final double danioBaseSegundo;

  static const double duracionTotal = 2.4;
  double _tiempoActivo = 0.0;

  EfectoLlamaradaContinua({
    required Vector2 posicionOrigen,
    required this.direccion,
    required this.danioBaseSegundo,
  }) : super(
    position: posicionOrigen,
    size: Vector2.all(120.0),
    anchor: Anchor.center,
  ) {
    angle = atan2(direccion.y, direccion.x);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _tiempoActivo += dt;

    if (_tiempoActivo >= duracionTotal) {
      removeFromParent();
      return;
    }

    final factorEscala = 1.0 + (_tiempoActivo / duracionTotal) * 2.0;
    final danioTick = (danioBaseSegundo * factorEscala) * dt;
    final alcanceEfectivo = 110.0 * factorEscala;

    final centroFrente = position + (direccion * (alcanceEfectivo / 2));

    final enemigos = parent?.children.whereType<Enemigo>() ?? [];
    for (final enemigo in enemigos) {
      if (enemigo.position.distanceTo(centroFrente) <= alcanceEfectivo / 1.8) {
        enemigo.recibirDanio(danioTick);
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final progreso = (_tiempoActivo / duracionTotal).clamp(0.0, 1.0);
    final factorEscala = 1.0 + progreso * 2.0;
    final opacidad = (1.0 - (progreso * 0.3)).clamp(0.0, 1.0);

    final pathCono = Path()
      ..moveTo(0, 0)
      ..lineTo(70.0 * factorEscala, -25.0 * factorEscala)
      ..lineTo(100.0 * factorEscala, 0)
      ..lineTo(70.0 * factorEscala, 25.0 * factorEscala)
      ..close();

    final paintLlama = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white,
          const Color(0xFFFFEB3B).withValues(alpha: opacidad),
          const Color(0xFFFF3D00).withValues(alpha: opacidad * 0.8),
        ],
      ).createShader(Rect.fromLTWH(0, -30, 100 * factorEscala, 60 * factorEscala));

    canvas.drawPath(pathCono, paintLlama);
  }
}