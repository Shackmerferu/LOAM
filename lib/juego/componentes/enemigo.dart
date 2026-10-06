import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../estado/estado_juego.dart';
import '../juego_supervivencia.dart';
import 'diamante.dart';

enum EstadoEnemigo { caminando, muriendo }
enum TipoMonstruo { limo, lobo, slime, esqueleto, miniGolem }
typedef TipoEnemigo = TipoMonstruo;

class Enemigo extends SpriteAnimationGroupComponent<EstadoEnemigo>
    with HasGameReference<JuegoSupervivencia>, CollisionCallbacks {
  final TipoMonstruo tipo;
  final EstadoJuego estadoJuego;

  late double vidaMax;
  late double vidaActual;
  late double velocidad;
  late double danio;
  late double xpOtorgada;

  bool _spritesCargados = false;
  double _timerMuerteFallback = 0.0;
  static const double _duracionMuerteFallback = 0.35;

  double get radio => size.x * 0.4;

  Enemigo({
    required this.tipo,
    required this.estadoJuego,
    required Vector2 posicionInicial,
  }) : super(
    position: posicionInicial,
    size: Vector2(48, 48),
    anchor: Anchor.center,
  ) {
    _configurarEstadisticas();
  }

  void _configurarEstadisticas() {
    final mult = estadoJuego.multiplicadorEnemigo;
    switch (tipo) {
      case TipoMonstruo.limo:
      case TipoMonstruo.slime:
        vidaMax = 40.0 * mult;
        velocidad = 65.0 * (mult > 1.0 ? 1.3 : 1.0);
        danio = 8.0 * mult;
        xpOtorgada = 20.0;
        break;
      case TipoMonstruo.lobo:
        vidaMax = 30.0 * mult;
        velocidad = 120.0 * (mult > 1.0 ? 1.35 : 1.0);
        danio = 10.0 * mult;
        xpOtorgada = 25.0;
        break;
      case TipoMonstruo.esqueleto:
        vidaMax = 90.0 * mult;
        velocidad = 55.0 * (mult > 1.0 ? 1.2 : 1.0);
        danio = 16.0 * mult;
        xpOtorgada = 45.0;
        break;
      case TipoMonstruo.miniGolem:
        vidaMax = 120.0 * mult;
        velocidad = 45.0 * (mult > 1.0 ? 1.2 : 1.0);
        danio = 18.0 * mult;
        xpOtorgada = 50.0;
        break;
    }
    vidaActual = vidaMax;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    try {
      final animCaminar = await game.loadSpriteAnimation(
        'monstruos/${tipo.name}_caminar.png',
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: 0.15,
          textureSize: Vector2(32, 32),
        ),
      );

      final animMuerte = await game.loadSpriteAnimation(
        'monstruos/${tipo.name}_muerte.png',
        SpriteAnimationData.sequenced(
          amount: 6,
          stepTime: 0.08,
          textureSize: Vector2(32, 32),
          loop: false,
        ),
      );

      animations = {
        EstadoEnemigo.caminando: animCaminar,
        EstadoEnemigo.muriendo: animMuerte,
      };

      current = EstadoEnemigo.caminando;
      _spritesCargados = true;
    } catch (_) {
      _spritesCargados = false;
      current = EstadoEnemigo.caminando;
    }

    add(CircleHitbox(radius: radio, anchor: Anchor.center, position: size / 2));
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!estadoJuego.enJuego || estadoJuego.enPausa || estadoJuego.finPartida) return;

    if (current == EstadoEnemigo.muriendo) {
      if (_spritesCargados) {
        if (animationTicker?.done() ?? false) {
          removeFromParent();
        }
      } else {
        _timerMuerteFallback += dt;
        if (_timerMuerteFallback >= _duracionMuerteFallback) {
          removeFromParent();
        }
      }
      return;
    }

    final posicionJugador = game.jugador.position;
    final direccion = (posicionJugador - position).normalized();
    position.add(direccion * velocidad * dt);

    if (direccion.x < 0 && scale.x > 0) {
      flipHorizontally();
    } else if (direccion.x > 0 && scale.x < 0) {
      flipHorizontally();
    }

    if (position.distanceTo(posicionJugador) <= radio + 16.0) {
      game.jugador.recibirDanio(danio * dt);
    }
  }

  @override
  void render(Canvas canvas) {
    if (_spritesCargados) {
      super.render(canvas);
    } else {
      Color colorEntidad;
      switch (tipo) {
        case TipoMonstruo.limo:
        case TipoMonstruo.slime:
          colorEntidad = const Color(0xFF00E676);
          break;
        case TipoMonstruo.lobo:
          colorEntidad = const Color(0xFFFF9100);
          break;
        case TipoMonstruo.esqueleto:
          colorEntidad = const Color(0xFFECEFF1);
          break;
        case TipoMonstruo.miniGolem:
          colorEntidad = const Color(0xFF8D6E63);
          break;
      }

      if (current == EstadoEnemigo.muriendo) {
        final progreso = (_timerMuerteFallback / _duracionMuerteFallback).clamp(0.0, 1.0);
        canvas.drawCircle(
          Offset(size.x / 2, size.y / 2),
          radio * (1.0 - progreso),
          Paint()..color = Colors.white.withValues(alpha: 1.0 - progreso),
        );
        return;
      }

      canvas.drawCircle(
        Offset(size.x / 2, size.y / 2),
        radio,
        Paint()..color = colorEntidad,
      );

      if (vidaActual < vidaMax) {
        const anchoBarra = 24.0;
        const altoBarra = 3.0;
        final x = (size.x - anchoBarra) / 2;
        canvas.drawRect(
          Rect.fromLTWH(x, -6, anchoBarra, altoBarra),
          Paint()..color = Colors.black54,
        );
        canvas.drawRect(
          Rect.fromLTWH(x, -6, anchoBarra * (vidaActual / vidaMax).clamp(0.0, 1.0), altoBarra),
          Paint()..color = const Color(0xFF00E676),
        );
      }
    }
  }

  void recibirDanio(double cantidad) {
    if (current == EstadoEnemigo.muriendo) return;
    vidaActual -= cantidad;
    if (vidaActual <= 0) {
      _activarMuerte();
    }
  }

  void _activarMuerte() {
    current = EstadoEnemigo.muriendo;
    children.whereType<CircleHitbox>().forEach((hitbox) => hitbox.removeFromParent());

    final subioNivel = estadoJuego.sumarXp(xpOtorgada);
    if (subioNivel) {
      game.activarSubidaNivel();
    }

    game.mundo.add(
      Diamante(
        estadoJuego: estadoJuego,
        posicionInicial: position.clone(),
      ),
    );
  }
}