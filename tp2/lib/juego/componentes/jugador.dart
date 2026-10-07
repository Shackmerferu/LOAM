import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/constantes.dart';
import '../../estado/estado_juego.dart';
import '../juego_supervivencia.dart';

enum EstadoJugador { quieto, caminando, danio, muerte, subirNivel }

class Jugador extends SpriteAnimationGroupComponent<EstadoJugador>
    with HasGameReference<JuegoSupervivencia>, CollisionCallbacks {
  final EstadoJuego estadoJuego;
  Vector2 direccionMovimiento = Vector2.zero();
  bool _estaMuerto = false;

  double _inmunidadRestante = 0.0;
  static const double _tiempoInmunidad = 0.5;

  Jugador({required this.estadoJuego})
    : super(size: Vector2(48, 48), anchor: Anchor.center);

  void mover(Vector2 delta) {
    if (_estaMuerto) return;
    direccionMovimiento = delta;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    position = game.size.isZero() ? Vector2(200, 400) : game.size / 2;
    debugPrint(
      '[DEBUG_JUGADOR] onLoad() iniciado, posición inicial: $position',
    );

    animations = {
      EstadoJugador.quieto: await _cargarAnimacion(
        'personajes/jugador_quieto.png',
        4,
        0.2,
      ),
      EstadoJugador.caminando: await _cargarAnimacion(
        'personajes/jugador_caminar.png',
        6,
        0.12,
      ),
      EstadoJugador.danio: await _cargarAnimacion(
        'personajes/jugador_herido.png',
        4,
        0.08,
      ),
      EstadoJugador.muerte: await _cargarAnimacion(
        'personajes/jugador_muerte.png',
        4,
        0.1,
      ),
      EstadoJugador.subirNivel: await _cargarAnimacion(
        'personajes/jugador_levelup.png',
        4,
        0.1,
      ),
    };

    current = EstadoJugador.quieto;
    add(CircleHitbox(radius: 16.0, anchor: Anchor.center, position: size / 2));
    debugPrint('[DEBUG_JUGADOR] Sprites del jugador cargados correctamente');
  }

  Future<SpriteAnimation> _cargarAnimacion(
    String path,
    int amount,
    double stepTime,
  ) async {
    final image = await game.images.load(path);
    final spriteSheet = SpriteSheet(image: image, srcSize: Vector2(32, 32));
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

    if (current == EstadoJugador.danio || current == EstadoJugador.subirNivel) {
      if (animationTicker?.done() ?? false) {
        current = EstadoJugador.quieto;
      }
    }

    if (!direccionMovimiento.isZero()) {
      if (current != EstadoJugador.danio) {
        current = EstadoJugador.caminando;
      }
      position.add(
        direccionMovimiento.normalized() * estadoJuego.velocidadMovimiento * dt,
      );

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
    final pctVida = (estadoJuego.vidaActual / estadoJuego.vidaMax).clamp(
      0.0,
      1.0,
    );

    canvas.drawRect(
      Rect.fromLTWH(x, -10, anchoBarra, altoBarra),
      Paint()..color = Colors.black87,
    );
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
    } else {
      current = EstadoJugador.danio;
      animationTicker?.reset();
    }
  }

  void animarSubidaNivel() {
    if (_estaMuerto) return;
    current = EstadoJugador.subirNivel;
    animationTicker?.reset();
  }

  void _morir() {
    _estaMuerto = true;
    current = EstadoJugador.muerte;
    animationTicker?.reset();
    children.whereType<CircleHitbox>().forEach((h) => h.removeFromParent());
  }
}
