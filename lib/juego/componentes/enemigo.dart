import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
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
    add(CircleHitbox(radius: radio, anchor: Anchor.center, position: size / 2));
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!estadoJuego.enJuego || estadoJuego.enPausa || estadoJuego.finPartida) return;

    if (current == EstadoEnemigo.muriendo) {
      if (animationTicker?.done() ?? false) {
        removeFromParent();
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