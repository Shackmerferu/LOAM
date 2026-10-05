import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import '../juego_supervivencia.dart';
import 'enemigo.dart';

class EfectoCorte extends SpriteAnimationComponent with HasGameReference<JuegoSupervivencia> {
  final Vector2 origen;
  final bool esDimensional;
  final double danio;

  EfectoCorte({
    required this.origen,
    required this.esDimensional,
    required this.danio,
  }) : super(
    position: origen,
    size: esDimensional ? Vector2(180, 180) : Vector2(100, 100),
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // assets/images/armas/corte_dimensional.png o corte_comun.png
    final ruta = esDimensional ? 'armas/corte_dimensional.png' : 'armas/corte_comun.png';
    animation = await game.loadSpriteAnimation(
      ruta,
      SpriteAnimationData.sequenced(
        amount: 5,
        stepTime: 0.05,
        textureSize: Vector2(64, 64),
        loop: false,
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    final radioEfectivo = size.x / 2;
    for (final enemigo in game.children.whereType<Enemigo>()) {
      if (enemigo.current == EstadoEnemigo.caminando &&
          position.distanceTo(enemigo.position) <= radioEfectivo) {
        enemigo.recibirDanio(danio * dt * 4);
      }
    }

    if (animationTicker?.done() ?? false) {
      removeFromParent();
    }
  }
}

class ProyectilFlecha extends SpriteComponent with HasGameReference<JuegoSupervivencia> {
  final Vector2 direccion;
  final bool esExplosivo;
  final double danio;
  final double velocidad = 340.0;
  double _vidaUtil = 2.0;

  ProyectilFlecha({
    required Vector2 posicionInicial,
    required this.direccion,
    required this.esExplosivo,
    required this.danio,
  }) : super(
    position: posicionInicial,
    size: esExplosivo ? Vector2(28, 14) : Vector2(22, 10),
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // assets/images/armas/proyectil_ballesta.png o proyectil_flecha.png
    final ruta = esExplosivo ? 'armas/proyectil_ballesta.png' : 'armas/proyectil_flecha.png';
    sprite = await game.loadSprite(ruta);
    angle = atan2(direccion.y, direccion.x);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.add(direccion * velocidad * dt);
    _vidaUtil -= dt;

    if (_vidaUtil <= 0) {
      removeFromParent();
      return;
    }

    for (final enemigo in game.children.whereType<Enemigo>()) {
      if (enemigo.current == EstadoEnemigo.caminando &&
          position.distanceTo(enemigo.position) <= 24.0) {
        if (esExplosivo) {
          for (final e in game.children.whereType<Enemigo>()) {
            if (position.distanceTo(e.position) <= 80.0) {
              e.recibirDanio(danio);
            }
          }
        } else {
          enemigo.recibirDanio(danio);
        }
        removeFromParent();
        break;
      }
    }
  }
}

class ProyectilFuego extends SpriteAnimationComponent with HasGameReference<JuegoSupervivencia> {
  final Vector2 direccion;
  final bool esLlamarada;
  final double danio;
  final double velocidad = 260.0;
  double _vidaUtil = 1.8;

  ProyectilFuego({
    required Vector2 posicionInicial,
    required this.direccion,
    required this.esLlamarada,
    required this.danio,
  }) : super(
    position: posicionInicial,
    size: esLlamarada ? Vector2(36, 36) : Vector2(24, 24),
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // assets/images/armas/llamarada_anim.png o bola_fuego_anim.png
    final ruta = esLlamarada ? 'armas/llamarada_anim.png' : 'armas/bola_fuego_anim.png';
    animation = await game.loadSpriteAnimation(
      ruta,
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.1,
        textureSize: Vector2(32, 32),
      ),
    );
    angle = atan2(direccion.y, direccion.x);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.add(direccion * velocidad * dt);
    _vidaUtil -= dt;

    if (_vidaUtil <= 0) {
      removeFromParent();
      return;
    }

    for (final enemigo in game.children.whereType<Enemigo>()) {
      if (enemigo.current == EstadoEnemigo.caminando &&
          position.distanceTo(enemigo.position) <= 24.0) {
        enemigo.recibirDanio(danio * (esLlamarada ? 1.5 : 1.0));
        if (!esLlamarada) {
          removeFromParent();
          break;
        }
      }
    }
  }
}