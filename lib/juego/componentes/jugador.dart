import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import '../../core/constantes.dart';
import '../../estado/estado_juego.dart';
import '../juego_supervivencia.dart';
import 'proyectiles.dart';

enum EstadoJugador { quieto, caminando }

class Jugador extends SpriteAnimationGroupComponent<EstadoJugador>
    with HasGameReference<JuegoSupervivencia>, CollisionCallbacks {
  final EstadoJuego estadoJuego;
  Vector2 direccionMovimiento = Vector2.zero();

  double _timerEspada = 0.0;
  double _timerArco = 0.0;
  double _timerMagia = 0.0;

  Jugador({required this.estadoJuego})
      : super(
    size: Vector2(48, 48),
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    position = game.size / 2;

    // Carga de animaciones: assets/images/personajes/jugador_...
    final animQuieto = await game.loadSpriteAnimation(
      'personajes/jugador_quieto.png',
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.2,
        textureSize: Vector2(32, 32),
      ),
    );

    final animCaminando = await game.loadSpriteAnimation(
      'personajes/jugador_caminar.png',
      SpriteAnimationData.sequenced(
        amount: 6,
        stepTime: 0.12,
        textureSize: Vector2(32, 32),
      ),
    );

    animations = {
      EstadoJugador.quieto: animQuieto,
      EstadoJugador.caminando: animCaminando,
    };

    current = EstadoJugador.quieto;
    add(CircleHitbox(radius: 16.0, anchor: Anchor.center, position: size / 2));
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!estadoJuego.enJuego || estadoJuego.enPausa || estadoJuego.finPartida) return;

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
    _procesarArsenal(dt);
  }

  void _confinarLimites() {
    if (estadoJuego.esHordaActiva) {
      final centro = game.size / 2;
      const mitad = GameConstants.tamanoAreaRestringida / 2;
      position.x = position.x.clamp(centro.x - mitad + 24, centro.x + mitad - 24);
      position.y = position.y.clamp(centro.y - mitad + 24, centro.y + mitad - 24);
    } else {
      position.x = position.x.clamp(24.0, game.size.x - 24.0);
      position.y = position.y.clamp(24.0, game.size.y - 24.0);
    }
  }

  void _procesarArsenal(double dt) {
    // 1. ESPADA (Corte / Cortes dimensionales expansivos en Nivel 7)
    _timerEspada += dt;
    final cadenciaEspada = estadoJuego.nivelEspada == 7 ? 0.75 : 1.3;
    if (_timerEspada >= cadenciaEspada) {
      _timerEspada = 0.0;
      game.add(EfectoCorte(
        origen: position.clone(),
        esDimensional: estadoJuego.nivelEspada == 7,
        danio: estadoJuego.nivelEspada == 7 ? 75.0 : 25.0 * estadoJuego.nivelEspada,
      ));
    }

    // 2. ARCO (3 flechas simultáneas / Ballesta explosiva en Nivel 7)
    _timerArco += dt;
    final cadenciaArco = estadoJuego.nivelArco == 7 ? 0.45 : 1.1;
    if (_timerArco >= cadenciaArco) {
      _timerArco = 0.0;
      final esBallesta = estadoJuego.nivelArco == 7;
      final angulos = esBallesta ? [0.0] : [-0.25, 0.0, 0.25];
      final direccionObjetivo = _obtenerDireccionEnemigoMasCercano();

      for (final angulo in angulos) {
        final rotacion = Matrix2.rotation(angulo);
        final dirFinal = rotacion.transform(direccionObjetivo);
        game.add(ProyectilFlecha(
          posicionInicial: position.clone(),
          direccion: dirFinal,
          esExplosivo: esBallesta,
          danio: esBallesta ? 85.0 : 22.0 * estadoJuego.nivelArco,
        ));
      }
    }

    // 3. MAGIA (Bolas de fuego / Llamarada progresiva en Nivel 7)
    _timerMagia += dt;
    final cadenciaMagia = estadoJuego.nivelMagia == 7 ? 0.25 : 1.4;
    if (_timerMagia >= cadenciaMagia) {
      _timerMagia = 0.0;
      final dir = _obtenerDireccionEnemigoMasCercano();
      game.add(ProyectilFuego(
        posicionInicial: position.clone(),
        direccion: dir,
        esLlamarada: estadoJuego.nivelMagia == 7,
        danio: estadoJuego.nivelMagia == 7 ? 35.0 : 30.0 * estadoJuego.nivelMagia,
      ));
    }
  }

  Vector2 _obtenerDireccionEnemigoMasCercano() {
    final enemigos = game.children.whereType<Enemigo>().where((e) => e.current == EstadoEnemigo.caminando).toList();
    if (enemigos.isEmpty) return Vector2(1, 0);

    enemigos.sort((a, b) => position.distanceTo(a.position).compareTo(position.distanceTo(b.position)));
    return (enemigos.first.position - position).normalized();
  }

  void recibirDanio(double cantidad) {
    estadoJuego.vidaActual -= cantidad;
    if (estadoJuego.vidaActual <= 0) {
      estadoJuego.vidaActual = 0;
      estadoJuego.terminarPartida();
    }
    estadoJuego.notifyListeners();
  }
}