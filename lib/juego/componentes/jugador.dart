import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../core/constantes.dart';
import '../../estado/estado_juego.dart';
import '../juego_supervivencia.dart';

enum EstadoJugador { quieto, caminando, danio, muerte, subirNivel }

class Jugador extends SpriteAnimationGroupComponent<EstadoJugador>
    with HasGameReference<JuegoSupervivencia>, CollisionCallbacks {
  final EstadoJuego estadoJuego;
  Vector2 direccionMovimiento = Vector2.zero();
  bool _estaMuerto = false;
  bool _spritesCargados = false;

  double _inmunidadRestante = 0.0;
  static const double _tiempoInmunidad = 0.5;

  Jugador({required this.estadoJuego})
      : super(
    size: Vector2(48, 48),
    anchor: Anchor.center,
  );

  void mover(Vector2 delta) {
    if (_estaMuerto) return;
    direccionMovimiento = delta;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    position = Vector2.zero();

    try {
      final animQuieto = await game.loadSpriteAnimation(
        'personajes/jugador_quieto.png',
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: 0.2,
          textureSize: Vector2(32, 32),
        ),
      );

      final animCaminar = await game.loadSpriteAnimation(
        'personajes/jugador_caminar.png',
        SpriteAnimationData.sequenced(
          amount: 6,
          stepTime: 0.12,
          textureSize: Vector2(32, 32),
        ),
      );

      final animDanio = await game.loadSpriteAnimation(
        'personajes/jugador_quieto.png',
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: 0.08,
          textureSize: Vector2(32, 32),
          loop: false,
        ),
      );

      final animMuerte = await game.loadSpriteAnimation(
        'personajes/jugador_quieto.png',
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: 0.1,
          textureSize: Vector2(32, 32),
          loop: false,
        ),
      );

      final animSubirNivel = await game.loadSpriteAnimation(
        'personajes/jugador_quieto.png',
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: 0.1,
          textureSize: Vector2(32, 32),
          loop: false,
        ),
      );

      animations = {
        EstadoJugador.quieto: animQuieto,
        EstadoJugador.caminando: animCaminar,
        EstadoJugador.danio: animDanio,
        EstadoJugador.muerte: animMuerte,
        EstadoJugador.subirNivel: animSubirNivel,
      };

      current = EstadoJugador.quieto;
      _spritesCargados = true;
    } catch (_) {
      _spritesCargados = false;
      current = EstadoJugador.quieto;
    }

    add(CircleHitbox(radius: 16.0, anchor: Anchor.center, position: size / 2));
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!estadoJuego.enJuego || estadoJuego.enPausa || estadoJuego.finPartida) {
      if (_estaMuerto && current == EstadoJugador.muerte) {
        animationTicker?.update(dt);
      }
      return;
    }

    if (_estaMuerto) return;

    if (_inmunidadRestante > 0) {
      _inmunidadRestante -= dt;
    }

    if (_spritesCargados && (current == EstadoJugador.danio || current == EstadoJugador.subirNivel)) {
      if (animationTicker?.done() ?? false) {
        current = EstadoJugador.quieto;
      }
    }

    if (!direccionMovimiento.isZero()) {
      if (_spritesCargados && current != EstadoJugador.danio) {
        current = EstadoJugador.caminando;
      }
      position.add(direccionMovimiento.normalized() * estadoJuego.velocidadMovimiento * dt);

      if (direccionMovimiento.x < 0 && scale.x > 0) {
        flipHorizontally();
      } else if (direccionMovimiento.x > 0 && scale.x < 0) {
        flipHorizontally();
      }
    } else {
      if (_spritesCargados && current != EstadoJugador.danio) {
        current = EstadoJugador.quieto;
      }
    }

    _confinarLimites();
  }

  @override
  void render(Canvas canvas) {
    if (_inmunidadRestante > 0 && (_inmunidadRestante * 15).toInt() % 2 == 0) {
      return;
    }

    if (_spritesCargados) {
      super.render(canvas);
    } else {
      final centro = Offset(size.x / 2, size.y / 2);
      canvas.drawCircle(centro, 18.0, Paint()..color = const Color(0xFF6200EE));
      canvas.drawCircle(centro, 10.0, Paint()..color = const Color(0xFF00E5FF));
    }

    const anchoBarra = 36.0;
    const altoBarra = 4.0;
    final x = (size.x - anchoBarra) / 2;
    final pctVida = (estadoJuego.vidaActual / estadoJuego.vidaMax).clamp(0.0, 1.0);

    canvas.drawRect(Rect.fromLTWH(x, -10, anchoBarra, altoBarra), Paint()..color = Colors.black87);
    canvas.drawRect(
      Rect.fromLTWH(x, -10, anchoBarra * pctVida, altoBarra),
      Paint()..color = const Color(0xFF00E676),
    );
  }

  void _confinarLimites() {
    if (estadoJuego.esHordaActiva) {
      final mitad = GameConstants.tamanoAreaRestringida / 2;
      position.x = position.x.clamp(-mitad, mitad);
      position.y = position.y.clamp(-mitad, mitad);
    } else {
      const limite = 1400.0;
      position.x = position.x.clamp(-limite, limite);
      position.y = position.y.clamp(-limite, limite);
    }
  }

  void recibirDanio(double cantidad) {
    if (_estaMuerto || _inmunidadRestante > 0) return;

    _inmunidadRestante = _tiempoInmunidad;
    estadoJuego.aplicarDanioJugador(cantidad);

    if (estadoJuego.vidaActual <= 0) {
      _morir();
    } else if (_spritesCargados) {
      current = EstadoJugador.danio;
      animationTicker?.reset();
    }
  }

  void animarSubidaNivel() {
    if (_estaMuerto) return;
    if (_spritesCargados) {
      current = EstadoJugador.subirNivel;
      animationTicker?.reset();
    }
  }

  void _morir() {
    _estaMuerto = true;
    if (_spritesCargados) {
      current = EstadoJugador.muerte;
      animationTicker?.reset();
    }
    children.whereType<CircleHitbox>().forEach((h) => h.removeFromParent());
  }
}