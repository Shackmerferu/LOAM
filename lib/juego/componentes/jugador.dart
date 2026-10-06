import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import '../../core/constantes.dart';
import '../../estado/estado_juego.dart';
import '../juego_supervivencia.dart';

enum EstadoJugador { quieto, caminando, danio, muerte, subirNivel }

class Jugador extends SpriteAnimationGroupComponent<EstadoJugador>
    with HasGameReference<JuegoSupervivencia>, CollisionCallbacks {
  final EstadoJuego estadoJuego;
  Vector2 direccionMovimiento = Vector2.zero();
  bool _estaMuerto = false;

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
      'personajes/Taking_Damage.png',
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.08,
        textureSize: Vector2(32, 32),
        loop: false,
      ),
    );

    final animMuerte = await game.loadSpriteAnimation(
      'personajes/muerto.png',
      SpriteAnimationData.sequenced(
        amount: 6,
        stepTime: 0.1,
        textureSize: Vector2(32, 32),
        loop: false,
      ),
    );

    final animSubirNivel = await game.loadSpriteAnimation(
      'personajes/Level_Up.png',
      SpriteAnimationData.sequenced(
        amount: 6,
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

    if (current == EstadoJugador.danio || current == EstadoJugador.subirNivel) {
      if (animationTicker?.done() ?? false) {
        current = EstadoJugador.quieto;
      } else {
        return;
      }
    }

    if (!direccionMovimiento.isZero()) {
      current = EstadoJugador.caminando;
      position.add(direccionMovimiento.normalized() * estadoJuego.velocidadMovimiento * dt);

      if (direccionMovimiento.x < 0 && scale.x > 0) {
        flipHorizontally();
      } else if (direccionMovimiento.x > 0 && scale.x < 0) {
        flipHorizontally();
      }
    } else {
      current = EstadoJugador.quieto;
    }

    _confinarLimites();
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
    if (_estaMuerto) return;

    estadoJuego.aplicarDanioJugador(cantidad);

    if (estadoJuego.vidaActual <= 0) {
      _morir();
    } else {
      if (current != EstadoJugador.danio && current != EstadoJugador.subirNivel) {
        current = EstadoJugador.danio;
        animationTicker?.reset();
      }
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
