import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import '../componentes/enemigo.dart';
import '../juego_supervivencia.dart';
import 'arma_base.dart';

class MagiaFuego extends ArmaBase {
  /// Segundos que no puede volver a lanzarse la llamarada tras terminar.
  static const double duracionCooldownLlamarada = 3.0;

  double _cooldownLlamarada = 0.0;
  bool _llamaradaEncendida = false;

  MagiaFuego({required super.estadoJuego})
      : super(
    intervaloAtaque: 1.6,
    danioBase: 45.0,
  );

  @override
  int get nivel => estadoJuego.fireMagicLevel;

  @override
  void update(double dt) {
    final jugando = estadoJuego.isPlaying &&
        !estadoJuego.isPaused &&
        !estadoJuego.isGameOver &&
        !estadoJuego.victoria;
    if (jugando) {
      final hayLlamarada = game.world.children
          .whereType<EfectoLlamaradaContinua>()
          .isNotEmpty;

      if (_llamaradaEncendida && !hayLlamarada) {
        // La llamarada cesó: inicia el cooldown de 3 s.
        _llamaradaEncendida = false;
        _cooldownLlamarada = duracionCooldownLlamarada;
      }

      if (_cooldownLlamarada > 0) {
        _cooldownLlamarada -= dt;
        if (_cooldownLlamarada <= 0) {
          _cooldownLlamarada = 0.0;
          // Dispara apenas termine el cooldown.
          temporizador = intervaloAtaque;
        }
      }
    }

    super.update(dt);
  }

  @override
  void ejecutarAtaque() {
    final jugador = game.jugador;
    final enemigos = game.world.children
        .whereType<Enemigo>()
        .where((e) => e.estaVivo)
        .toList();

    Vector2 direccion = Vector2(0, -1);
    if (enemigos.isNotEmpty) {
      enemigos.sort((a, b) => a.position
          .distanceTo(jugador.position)
          .compareTo(b.position.distanceTo(jugador.position)));
      direccion = (enemigos.first.position - jugador.position).normalized();
    }

    if (!estaMejorada) {
      game.world.add(
        ProyectilBolaFuego(
          posicionInicial: jugador.position.clone(),
          direccion: direccion,
          danio: danioFinal,
        ),
      );
    } else {
      final yaActiva =
          game.world.children.whereType<EfectoLlamaradaContinua>().isNotEmpty;
      if (yaActiva || _cooldownLlamarada > 0) return;

      _llamaradaEncendida = true;
      game.world.add(
        EfectoLlamaradaContinua(
          posicionOrigen: jugador.position.clone(),
          danioBaseSegundo: danioFinal * 1.5,
        ),
      );
    }
  }
}

class ProyectilBolaFuego extends SpriteAnimationComponent
    with HasGameReference<JuegoSupervivencia> {
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
    size: Vector2(50.0, 61.0),
    anchor: Anchor.center,
    priority: 4,
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final image = game.images.fromCache('armas/boladefuego.png');
    const cantidadFrames = 8;
    final anchoFrame = image.width / cantidadFrames;

    final hoja = SpriteSheet(
      image: image,
      srcSize: Vector2(anchoFrame, image.height.toDouble()),
    );

    animation = hoja.createAnimation(
      row: 0,
      stepTime: 0.07,
      to: cantidadFrames,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!game.estadoJuego.enJuego ||
        game.estadoJuego.enPausa ||
        game.estadoJuego.finPartida) {
      return;
    }

    final avance = velocidad * dt;
    position.add(direccion * avance);
    _distanciaRecorrida += avance;

    final enemigos = parent?.children.whereType<Enemigo>() ?? [];
    for (final enemigo in enemigos) {
      if (!enemigo.estaVivo) continue;
      if (enemigo.position.distanceTo(position) <= enemigo.radio + 20.0) {
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
      if (!enemigo.estaVivo) continue;
      if (enemigo.position.distanceTo(position) <= radioArea) {
        enemigo.recibirDanio(danio);
      }
    }
    removeFromParent();
  }
}

enum EstadoLlamarada { encendiendo, sostenido }

class EfectoLlamaradaContinua
    extends SpriteAnimationGroupComponent<EstadoLlamarada>
    with HasGameReference<JuegoSupervivencia> {
  final double danioBaseSegundo;

  static const double duracionTotal = 5.0;
  static const double alcanceLlama = 150.0;

  double _tiempoActivo = 0.0;
  Vector2 _direccion = Vector2(1, 0);

  EfectoLlamaradaContinua({
    required Vector2 posicionOrigen,
    required this.danioBaseSegundo,
  }) : super(
    position: posicionOrigen,
    size: Vector2(170.0, 191.0),
    anchor: const Anchor(0.5, 0.4),
    priority: 5,
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final hoja = SpriteSheet(
      image: game.images.fromCache('armas/llamarada.png'),
      srcSize: Vector2(80, 90),
    );

    animations = {
      EstadoLlamarada.encendiendo: hoja.createAnimation(
        row: 0,
        stepTime: 0.08,
        from: 0,
        to: 5,
        loop: false,
      ),
      EstadoLlamarada.sostenido: hoja.createAnimation(
        row: 0,
        stepTime: 0.15,
        from: 5,
        to: 8,
        loop: true,
      ),
    };

    current = EstadoLlamarada.encendiendo;
    _actualizarTransforme();
  }

  @override
  void update(double dt) {
    if (!game.estadoJuego.enJuego ||
        game.estadoJuego.enPausa ||
        game.estadoJuego.finPartida) {
      return;
    }

    super.update(dt);

    _tiempoActivo += dt;
    if (_tiempoActivo >= duracionTotal) {
      removeFromParent();
      return;
    }

    if (current == EstadoLlamarada.encendiendo &&
        (animationTicker?.done() ?? false)) {
      current = EstadoLlamarada.sostenido;
    }

    _actualizarTransforme();
    _aplicarDanio(dt);
  }

  void _actualizarTransforme() {
    final jugador = game.jugador;

    // Sigue el control del jugador (touchpad), sin priorizar enemigos.
    _direccion = jugador.ultimaDireccion;

    position = jugador.position + _direccion * (size.x * 0.3);
    angle = atan2(_direccion.y, _direccion.x);
  }

  void _aplicarDanio(double dt) {
    final jugador = game.jugador;
    final factorEscala = 1.0 + (_tiempoActivo / duracionTotal);
    final danioTick = danioBaseSegundo * factorEscala * dt;

    final centroFrente = jugador.position + _direccion * (alcanceLlama / 2);

    final enemigos = game.world.children
        .whereType<Enemigo>()
        .where((e) => e.estaVivo);

    for (final enemigo in enemigos) {
      if (enemigo.position.distanceTo(centroFrente) <= 90.0) {
        enemigo.recibirDanio(danioTick);
      }
    }
  }
}
