import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import '../componentes/enemigo.dart';
import '../juego_supervivencia.dart';
import 'arma_base.dart';

class Arco extends ArmaBase {
  SpriteComponent? _visual;
  String? _rutaVisual;
  Vector2 _dirActual = Vector2(1, 0);

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
    final enemigos = game.world.children
        .whereType<Enemigo>()
        .where((e) => e.estaVivo)
        .toList();

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

        game.world.add(
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

        game.world.add(
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

class ProyectilFlecha extends SpriteComponent
    with HasGameReference<JuegoSupervivencia> {
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
    size: Vector2.all(esExplosiva ? 56.0 : 46.0),
    anchor: Anchor.center,
    priority: 4,
  ) {
    angle = atan2(direccion.y, direccion.x) + pi / 4;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = Sprite(
      game.images.fromCache(
        esExplosiva ? 'armas/flecha_explosiva.png' : 'armas/flecha.png',
      ),
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
      if (enemigo.position.distanceTo(position) <= enemigo.radio + 6.0) {
        _impactar(enemigo);
        return;
      }
    }

    if (_distanciaRecorrida >= alcanceMaximo) {
      removeFromParent();
    }
  }

  void _impactar(Enemigo enemigo) {
    if (esExplosiva) {
      _detonarArea();
    } else {
      enemigo.recibirDanio(danio);
    }
    removeFromParent();
  }

  void _detonarArea() {
    const radioExplosion = 85.0;
    parent?.add(EfectoExplosion(posicion: position.clone()));

    final enemigos = parent?.children.whereType<Enemigo>() ?? [];
    for (final enemigo in enemigos) {
      if (!enemigo.estaVivo) continue;
      if (enemigo.position.distanceTo(position) <= radioExplosion) {
        enemigo.recibirDanio(danio);
      }
    }
  }
}

class EfectoExplosion extends SpriteAnimationComponent
    with HasGameReference<JuegoSupervivencia> {
  EfectoExplosion({required Vector2 posicion})
      : super(
    position: posicion,
    size: Vector2(150, 190),
    anchor: Anchor.center,
    priority: 6,
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final hoja = SpriteSheet(
      image: game.images.fromCache('armas/explosion.png'),
      srcSize: Vector2(90, 114),
    );

    animation = hoja.createAnimation(
      row: 0,
      stepTime: 0.05,
      to: 8,
      loop: false,
    );
    removeOnFinish = true;
  }

  @override
  void update(double dt) {
    if (!game.estadoJuego.enJuego ||
        game.estadoJuego.enPausa ||
        game.estadoJuego.finPartida) {
      return;
    }

    super.update(dt);
    if (animationTicker?.done() ?? false) {
      removeFromParent();
    }
  }
}
