import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import '../componentes/enemigo.dart';
import '../juego_supervivencia.dart';
import 'arma_base.dart';

class Espada extends ArmaBase {
  Espada({required super.estadoJuego})
      : super(
    intervaloAtaque: 1.2,
    danioBase: 35.0,
  );

  @override
  int get nivel => estadoJuego.swordLevel;

  @override
  void ejecutarAtaque() {
    final jugador = game.jugador;
    final enemigos = game.world.children
        .whereType<Enemigo>()
        .where((e) => e.estaVivo)
        .toList();

    Vector2 direccion = Vector2(1, 0);
    if (enemigos.isNotEmpty) {
      enemigos.sort((a, b) => a.position
          .distanceTo(jugador.position)
          .compareTo(b.position.distanceTo(jugador.position)));
      direccion = (enemigos.first.position - jugador.position).normalized();
    }

    final angulo = atan2(direccion.y, direccion.x);

    if (!estaMejorada) {
      const radioCorte = 95.0;
      game.world.add(
        EfectoCorte(
          posicion: jugador.position.clone(),
          ruta: 'armas/espada_corte.png',
          cantidadFrames: 6,
          frameSize: Vector2(126, 150),
          angulo: angulo,
          ancho: 170.0,
          stepTime: 0.04,
        ),
      );

      for (final enemigo in enemigos) {
        if (enemigo.position.distanceTo(jugador.position) <= radioCorte) {
          enemigo.recibirDanio(danioFinal);
        }
      }
    } else {
      const cantidadCortes = 5;
      final random = Random();

      for (int i = 0; i < cantidadCortes; i++) {
        final anguloCorte = random.nextDouble() * pi;
        final offset = Vector2(
          (random.nextDouble() - 0.5) * 260.0,
          (random.nextDouble() - 0.5) * 260.0,
        );

        game.world.add(
          EfectoCorte(
            posicion: jugador.position + offset,
            ruta: 'armas/corte_dimensional.png',
            cantidadFrames: 4,
            frameSize: Vector2(126, 150),
            angulo: anguloCorte,
            ancho: 150.0,
            stepTime: 0.07,
          ),
        );
      }

      final danioEvolucionado = danioFinal * 1.8;
      for (final enemigo in enemigos) {
        if (enemigo.position.distanceTo(jugador.position) <= 180.0) {
          enemigo.recibirDanio(danioEvolucionado);
        }
      }
    }
  }
}

class EfectoCorte extends SpriteAnimationComponent
    with HasGameReference<JuegoSupervivencia> {
  final String ruta;
  final int cantidadFrames;
  final Vector2 frameSize;
  final double ancho;
  final double stepTime;

  EfectoCorte({
    required Vector2 posicion,
    required this.ruta,
    required this.cantidadFrames,
    required this.frameSize,
    required double angulo,
    required this.ancho,
    required this.stepTime,
  }) : super(
          position: posicion,
          size: Vector2(ancho, ancho * frameSize.y / frameSize.x),
          anchor: Anchor.center,
          angle: angulo,
          priority: 5,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final hoja = SpriteSheet(
      image: game.images.fromCache(ruta),
      srcSize: frameSize,
    );

    animation = hoja.createAnimation(
      row: 0,
      stepTime: stepTime,
      to: cantidadFrames,
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
