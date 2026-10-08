import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import '../../core/constantes.dart';
import '../../estado/estado_juego.dart';
import '../juego_supervivencia.dart';

enum EstadoJugador { quieto, caminando, danio, muerte }

class Jugador extends SpriteAnimationGroupComponent<EstadoJugador>
    with HasGameReference<JuegoSupervivencia>, CollisionCallbacks {
  final EstadoJuego estadoJuego;
  Vector2 direccionMovimiento = Vector2.zero();

  /// Última dirección con la que se movió (para el arco y la llamarada).
  Vector2 ultimaDireccion = Vector2(1, 0);
  bool _estaMuerto = false;

  double _inmunidadRestante = 0.0;
  static const double _tiempoInmunidad = 0.5;

  Jugador({required this.estadoJuego})
      : super(
    size: Vector2.all(96),
    anchor: Anchor.center,
  );

  /// Radio del hitbox circular del jugador (r = 16).
  double get radioHitbox => 16.0;

  /// Separación mínima desde la circunferencia del hitbox hasta la base de
  /// las armas (llamarada y arco), válida para cualquier dirección.
  static const double separacionBaseArmas = 16.0;

  /// Radio donde se anclan las armas: hitbox + 16 px = 32 px desde el centro.
  double get radioBaseArmas => radioHitbox + separacionBaseArmas;

  void mover(Vector2 delta) {
    if (_estaMuerto) return;
    direccionMovimiento = delta;
    if (!delta.isZero()) {
      ultimaDireccion = delta.normalized();
    }
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    position = game.size.isZero() ? Vector2(200, 400) : game.size / 2;
    debugPrint('[DEBUG_JUGADOR] onLoad() iniciado, posición inicial: $position');

    animations = {
      EstadoJugador.quieto: await _cargarAnimacion('personajes/Idle.png', 8, 0.2),
      EstadoJugador.caminando: await _cargarAnimacion('personajes/Walk.png', 7, 0.12),
      EstadoJugador.danio: await _cargarAnimacion('personajes/Hurt.png', 4, 0.08),
      EstadoJugador.muerte: await _cargarAnimacion('personajes/Dead.png', 4, 0.1),
    };

    current = EstadoJugador.quieto;
    add(CircleHitbox(radius: radioHitbox, anchor: Anchor.center, position: size / 2));
    debugPrint('[DEBUG_JUGADOR] Sprites del jugador cargados correctamente');
  }

  Future<SpriteAnimation> _cargarAnimacion(String path, int amount, double stepTime) async {
    final image = await game.images.load(path);
    final spriteSheet = SpriteSheet(image: image, srcSize: Vector2.all(image.height.toDouble()));
    return spriteSheet.createAnimation(row: 0, stepTime: stepTime, to: amount);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (position.isZero()) {
      position = size / 2;
    }
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

    // La animación de darío es en bucle (loop: true); se mantiene solo
    // 2 ciclos completos (2 x duración del sprite) y vuelve a quieto.
    if (current == EstadoJugador.danio) {
      final ticker = animationTicker;
      if (ticker != null && ticker.elapsed >= 2 * ticker.totalDuration()) {
        current = EstadoJugador.quieto;
      }
    }

    if (!direccionMovimiento.isZero()) {
      if (current != EstadoJugador.danio) {
        current = EstadoJugador.caminando;
      }
      position.add(direccionMovimiento.normalized() * estadoJuego.velocidadMovimiento * dt);

      if (direccionMovimiento.x < 0 && scale.x > 0) {
        flipHorizontally();
      } else if (direccionMovimiento.x > 0 && scale.x < 0) {
        flipHorizontally();
      }
    } else {
      if (current != EstadoJugador.danio) {
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

    super.render(canvas);

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
      final centro = game.centroArena;
      final mitad = GameConstants.tamanoAreaRestringida / 2;
      position.x = position.x.clamp(centro.x - mitad, centro.x + mitad);
      position.y = position.y.clamp(centro.y - mitad, centro.y + mitad);
    } else {
      const limite = 1400.0;
      position.x = position.x.clamp(-limite, limite);
      position.y = position.y.clamp(-limite, limite);
    }
  }

  void recibirDanio(double cantidad) {
    if (_estaMuerto || cantidad <= 0) return;

    // El daño por contacto se aplica siempre (modelo DPS: danio * dt por
    // frame); la inmunidad solo controla la animación de golpe y el parpadeo.
    estadoJuego.aplicarDanioJugador(cantidad);

    if (estadoJuego.vidaActual <= 0) {
      _morir();
      return;
    }

    if (_inmunidadRestante <= 0) {
      _inmunidadRestante = _tiempoInmunidad;
      current = EstadoJugador.danio;
      animationTicker?.reset();
    }
  }

  void _morir() {
    _estaMuerto = true;
    // Sin inmunidad pendiente: si quedara > 0 el parpadeo quedaría congelado
    // (update no corre con finPartida) y el cadáver no se vería.
    _inmunidadRestante = 0.0;
    current = EstadoJugador.muerte;
    animationTicker?.reset();
    children.whereType<CircleHitbox>().forEach((h) => h.removeFromParent());
  }

  /// Restaura al jugador tras un reinicio de partida: revuelve a vivo,
  /// repone el hitbox que se elimina al morir y resetea animación/estado.
  void reiniciar() {
    _estaMuerto = false;
    _inmunidadRestante = 0.0;
    direccionMovimiento = Vector2.zero();
    ultimaDireccion = Vector2(1, 0);
    scale.setValues(1, 1);
    position = game.size.isZero() ? Vector2(200, 400) : game.size / 2;

    if (children.whereType<CircleHitbox>().isEmpty) {
      add(CircleHitbox(radius: radioHitbox, anchor: Anchor.center, position: size / 2));
    }

    current = EstadoJugador.quieto;
    animationTicker?.reset();
  }
}
