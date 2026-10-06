import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../componentes/enemigo.dart';
import 'arma_base.dart';

class Arco extends ArmaBase {
  Arco({required super.estadoJuego})
      : super(
    intervaloAtaque: 1.0,
    danioBase: 25.0,
  );

  @override
  int get nivel => estadoJuego.bowLevel;

  @override
  void update(double dt) {
    intervaloAtaque = estaMejorada ? 0.45 : 1.0;
    super.update(dt);
  }

  @override
  void ejecutarAtaque() {
    final jugador = game.jugador;
    final enemigos = game.children.whereType<Enemigo>().toList();

    Vector2 direccionBase = Vector2(1, 0);
    if (enemigos.isNotEmpty) {
      enemigos.sort((a, b) => a.position
          .distanceTo(jugador.position)
          .compareTo(b.position.distanceTo(jugador.position)));
      direccionBase = (enemigos.first.position - jugador.position).normalized();
    }

    final anguloBase = atan2(direccionBase.y, direccionBase.x);

    if (!estaMejorada) {
      const abanico = [-0.22, 0.0, 0.22];
      for (final desfase in abanico) {
        final anguloFinal = anguloBase + desfase;
        final dir = Vector2(cos(anguloFinal), sin(anguloFinal));

        game.add(
          ProyectilFlecha(
            posicionInicial: jugador.position.clone(),
            direccion: dir,
            danio: danioFinal,
            esExplosiva: false,
          ),
        );
      }
    } else {
      const dispersion = [-0.15, 0.15];
      for (final desfase in dispersion) {
        final anguloFinal = anguloBase + desfase;
        final dir = Vector2(cos(anguloFinal), sin(anguloFinal));

        game.add(
          ProyectilFlecha(
            posicionInicial: jugador.position.clone(),
            direccion: dir,
            danio: danioFinal * 1.4,
            esExplosiva: true,
          ),
        );
      }
    }
  }
}

class ProyectilFlecha extends PositionComponent {
  final Vector2 direccion;
  final double danio;
  final bool esExplosiva;

  static const double velocidad = 380.0;
  static const double alcanceMaximo = 450.0;
  double _distanciaRecorrida = 0.0;

  ProyectilFlecha({
    required Vector2 posicionInicial,
    required this.direccion,
    required this.danio,
    required this.esExplosiva,
  }) : super(
    position: posicionInicial,
    size: Vector2(16.0, 4.0),
    anchor: Anchor.center,
  ) {
    angle = atan2(direccion.y, direccion.x);
  }

  @override
  void update(double dt) {
    super.update(dt);

    final avance = velocidad * dt;
    position.add(direccion * avance);
    _distanciaRecorrida += avance;

    final enemigos = parent?.children.whereType<Enemigo>() ?? [];
    for (final enemigo in enemigos) {
      if (enemigo.position.distanceTo(position) <= enemigo.radio + 6.0) {
        _impactar(enemigo);
        return;
      }
    }

    if (_distanciaRecorrida >= alcanceMaximo) {
      if (esExplosiva) {
        _detonarArea();
      }
      removeFromParent();
    }
  }

  void _impactar(Enemigo enemigo) {
    if (!esExplosiva) {
      enemigo.recibirDanio(danio);
    } else {
      _detonarArea();
    }
    removeFromParent();
  }

  void _detonarArea() {
    const radioExplosion = 85.0;
    parent?.add(EfectoExplosion(posicion: position.clone(), radio: radioExplosion));

    final enemigos = parent?.children.whereType<Enemigo>() ?? [];
    for (final enemigo in enemigos) {
      if (enemigo.position.distanceTo(position) <= radioExplosion) {
        enemigo.recibirDanio(danio);
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint()
      ..color = esExplosiva ? const Color(0xFFFF5722) : const Color(0xFFFFEB3B)
      ..strokeWidth = esExplosiva ? 4.0 : 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(-size.x / 2, 0),
      Offset(size.x / 2, 0),
      paint,
    );
  }
}

class EfectoExplosion extends PositionComponent {
  final double radio;
  static const double _tiempoVida = 0.25;
  double _progreso = 0.0;

  EfectoExplosion({required Vector2 posicion, required this.radio})
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
    final radioActual = radio * _progreso;
    final opacidad = (1.0 - _progreso).clamp(0.0, 1.0);

    final paintRelleno = Paint()
      ..color = const Color(0xFFFF9800).withValues(alpha: opacidad * 0.5)
      ..style = PaintingStyle.fill;

    final paintBorde = Paint()
      ..color = const Color(0xFFFF3D00).withValues(alpha: opacidad)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0 * (1.0 - _progreso);

    canvas.drawCircle(centro, radioActual, paintRelleno);
    canvas.drawCircle(centro, radioActual, paintBorde);
  }
}
