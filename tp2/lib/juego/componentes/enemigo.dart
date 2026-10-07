import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:material_ui/material_ui.dart';

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

  String get _nombreCaminarAsset {
    switch (tipo) {
      case TipoMonstruo.limo:
        return 'limo_caminar';
      case TipoMonstruo.lobo:
        return 'lobo_caminar';
      case TipoMonstruo.slime:
        return 'slime_caminar';
      case TipoMonstruo.esqueleto:
        return 'esqueleto_caminar';
      case TipoMonstruo.miniGolem:
        return 'minigolem_caminar';
    }
  }

  String get _nombreMuerteAsset {
    switch (tipo) {
      case TipoMonstruo.limo:
        return 'limo_muerte';
      case TipoMonstruo.lobo:
        return 'lobo_muerte';
      case TipoMonstruo.slime:
        return 'slime_muerte';
      case TipoMonstruo.esqueleto:
        return 'esqueleto_muerte';
      case TipoMonstruo.miniGolem:
        return 'minigolem_muerte';
    }
  }

  int get _framesCaminar {
    switch (tipo) {
      case TipoMonstruo.limo:
      case TipoMonstruo.slime:
        return 8;
      case TipoMonstruo.lobo:
        return 11;
      case TipoMonstruo.esqueleto:
        return 7;
      case TipoMonstruo.miniGolem:
        return 8;
    }
  }

  int get _framesMuerte {
    switch (tipo) {
      case TipoMonstruo.limo:
      case TipoMonstruo.slime:
        return 3;
      case TipoMonstruo.lobo:
        return 2;
      case TipoMonstruo.esqueleto:
        return 5;
      case TipoMonstruo.miniGolem:
        return 6;
    }
  }

  Vector2 get _tamanoFrame {
    switch (tipo) {
      case TipoMonstruo.limo:
        return Vector2(32, 32);
      case TipoMonstruo.lobo:
        return Vector2(32, 32);
      case TipoMonstruo.slime:
        return Vector2(32, 32);
      case TipoMonstruo.esqueleto:
        return Vector2(32, 32);
      case TipoMonstruo.miniGolem:
        return Vector2(32, 32);
    }
  }

  Enemigo({
    required this.tipo,
    required this.estadoJuego,
    required Vector2 posicionInicial,
  }) : super(
         position: posicionInicial,
         size: Vector2.all(32),
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

    animations = {
      EstadoEnemigo.caminando: await _cargarAnimacion(
        'monstruos/$_nombreCaminarAsset.png',
        _framesCaminar,
        0.15,
      ),
      EstadoEnemigo.muriendo: await _cargarAnimacion(
        'monstruos/$_nombreMuerteAsset.png',
        _framesMuerte,
        0.08,
      ),
    };

    current = EstadoEnemigo.caminando;

    add(
      CircleHitbox(
        radius: radio,
        anchor: Anchor.center,
        position: Vector2.zero(),
      ),
    );
  }

  Future<SpriteAnimation> _cargarAnimacion(
    String path,
    int cantidadFrames,
    double stepTime,
  ) async {
    final image = await game.images.load(path);

    final spriteSheet = SpriteSheet(image: image, srcSize: _tamanoFrame);

    return spriteSheet.createAnimation(
      row: 0,
      stepTime: stepTime,
      to: cantidadFrames,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!estadoJuego.enJuego || estadoJuego.enPausa || estadoJuego.finPartida) {
      return;
    }

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

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (vidaActual < vidaMax) {
      const anchoBarra = 24.0;
      const altoBarra = 3.0;
      final x = (size.x - anchoBarra) / 2;

      canvas.drawRect(
        Rect.fromLTWH(x, -6, anchoBarra, altoBarra),
        Paint()..color = Colors.black54,
      );

      canvas.drawRect(
        Rect.fromLTWH(
          x,
          -6,
          anchoBarra * (vidaActual / vidaMax).clamp(0.0, 1.0),
          altoBarra,
        ),
        Paint()..color = const Color(0xFF00E676),
      );
    }
  }

  void recibirDanio(double cantidad) {
    if (current == EstadoEnemigo.muriendo) {
      return;
    }

    vidaActual -= cantidad;

    if (vidaActual <= 0) {
      _activarMuerte();
    }
  }

  void _activarMuerte() {
    current = EstadoEnemigo.muriendo;

    children.whereType<CircleHitbox>().forEach((hitbox) {
      hitbox.removeFromParent();
    });

    final subioNivel = estadoJuego.sumarXp(xpOtorgada);

    if (subioNivel) {
      game.activarSubidaNivel();
    }

    game.mundo.add(
      Diamante(estadoJuego: estadoJuego, posicionInicial: position.clone()),
    );

    game.respawnEnemigoTrasMuerte();
  }
}
