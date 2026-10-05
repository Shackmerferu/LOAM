import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import '../../estado/estado_juego.dart';
import '../juego_supervivencia.dart';
import 'diamante.dart';

enum EstadoEnemigo { caminando, muriendo }
enum TipoMonstruo { limo, duende, espectro }

class Enemigo extends SpriteAnimationGroupComponent<EstadoEnemigo>
    with HasGameReference<JuegoSupervivencia>, CollisionCallbacks {
  final TipoMonstruo tipo;
  final EstadoJuego estadoJuego;

  late double vidaMax;
  late double vidaActual;
  late double velocidad;
  late double danio;
  late double xpOtorgada;

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
        vidaMax = 40.0 * mult;
        velocidad = 65.0 * (mult > 1.0 ? 1.3 : 1.0);
        danio = 8.0 * mult;
        xpOtorgada = 20.0;
        break;
      case TipoMonstruo.duende:
        vidaMax = 25.0 * mult;
        velocidad = 110.0 * (mult > 1.0 ? 1.25 : 1.0);
        danio = 6.0 * mult;
        xpOtorgada = 15.0;
        break;
      case TipoMonstruo.espectro:
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

    // Carga de hojas de sprites por carpeta: assets/images/monstruos/<tipo>_...
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
    add(CircleHitbox(radius: size.x * 0.35, anchor: Anchor.center, position: size / 2));
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

    // Orientación del sprite (flip horizontal según la trayectoria)
    if (direccion.x < 0 && scale.x > 0) {
      flipHorizontally();
    } else if (direccion.x > 0 && scale.x < 0) {
      flipHorizontally();
    }

    if (position.distanceTo(posicionJugador) <= (size.x * 0.4) + 16.0) {
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

    // Desactivar cajas de colisión para cesar el daño sobre el jugador
    children.whereType<CircleHitbox>().forEach((hitbox) => hitbox.removeFromParent());

    final subioNivel = estadoJuego.sumarXp(xpOtorgada);
    if (subioNivel) {
      game.activarSubidaNivel();
    }

    game.add(
      Diamante(
        estadoJuego: estadoJuego,
        posicionInicial: position.clone(),
      ),
    );
  }
}