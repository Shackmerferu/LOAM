import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../core/constantes.dart';
import '../estado/estado_juego.dart';
import 'armas/arco.dart';
import 'armas/espada.dart';
import 'armas/magia_fuego.dart';
import 'componentes/enemigo.dart';
import 'componentes/jugador.dart';

class FondoCuadricula extends Component {
  final Paint _paintLinea = Paint()
    ..color = const Color(0xFF26203D)
    ..strokeWidth = 1.0
    ..style = PaintingStyle.stroke;

  static const double tamanoCelda = 64.0;
  static const double tamanoMundo = 3000.0;

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(
      const Rect.fromLTWH(-tamanoMundo / 2, -tamanoMundo / 2, tamanoMundo, tamanoMundo),
      Paint()..color = const Color(0xFF131022),
    );

    for (double x = -tamanoMundo / 2; x <= tamanoMundo / 2; x += tamanoCelda) {
      canvas.drawLine(Offset(x, -tamanoMundo / 2), Offset(x, tamanoMundo / 2), _paintLinea);
    }
    for (double y = -tamanoMundo / 2; y <= tamanoMundo / 2; y += tamanoCelda) {
      canvas.drawLine(Offset(-tamanoMundo / 2, y), Offset(tamanoMundo / 2, y), _paintLinea);
    }
  }
}

class JuegoSupervivencia extends FlameGame with HasCollisionDetection, DragCallbacks {
  final EstadoJuego estadoJuego;
  late final Jugador jugador;

  World get mundo => world;

  final Random _random = Random();
  double _timerSpawn = 0.0;

  JuegoSupervivencia({required this.estadoJuego});

  @override
  Color backgroundColor() => const Color(0xFF0D0A18);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    await world.add(FondoCuadricula());

    jugador = Jugador(estadoJuego: estadoJuego);
    await world.add(jugador);

    // Integración del arsenal en el World
    await world.add(Espada(estadoJuego: estadoJuego));
    await world.add(Arco(estadoJuego: estadoJuego));
    await world.add(MagiaFuego(estadoJuego: estadoJuego));

    camera.viewfinder.anchor = Anchor.center;
    camera.follow(jugador);

    if (!estadoJuego.enJuego) {
      estadoJuego.iniciarPartida();
    }

    _spawnOleadaInicial();
  }

  void _spawnOleadaInicial() {
    for (int i = 0; i < 4; i++) {
      final angulo = (i / 4) * 2 * pi;
      const double distancia = 380.0;
      final spawn = Vector2(cos(angulo) * distancia, sin(angulo) * distancia);

      world.add(Enemigo(
        tipo: TipoMonstruo.limo,
        estadoJuego: estadoJuego,
        posicionInicial: spawn,
      ));
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (estadoJuego.enJuego && !estadoJuego.enPausa && !estadoJuego.finPartida) {
      jugador.mover(event.localDelta);
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    jugador.mover(Vector2.zero());
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!estadoJuego.enJuego || estadoJuego.enPausa || estadoJuego.finPartida) return;

    estadoJuego.actualizarTiempo(dt);

    if (estadoJuego.tiempoPartida >= GameConstants.tiempoTiendaMinuto5 &&
        !estadoJuego.tiendaMinuto5Mostrada) {
      estadoJuego.tiendaMinuto5Mostrada = true;
      pausarPorOverlay('ModalTienda');
    }

    _timerSpawn += dt;
    if (_timerSpawn >= 0.8) {
      _timerSpawn = 0.0;
      _regularHorda();
    }
  }

  void _regularHorda() {
    final cantidadActual = world.children.whereType<Enemigo>().length;
    if (cantidadActual >= GameConstants.maxEnemigos) return;

    final faltantes = GameConstants.minEnemigos - cantidadActual;
    final porGenerar = faltantes > 0 ? faltantes.clamp(1, 3) : 1;

    for (int i = 0; i < porGenerar; i++) {
      if (world.children.whereType<Enemigo>().length >= GameConstants.maxEnemigos) break;

      final angulo = _random.nextDouble() * 2 * pi;
      const double distancia = 400.0;
      final spawn = Vector2(
        jugador.position.x + cos(angulo) * distancia,
        jugador.position.y + sin(angulo) * distancia,
      );

      final r = _random.nextDouble();
      TipoMonstruo tipo = TipoMonstruo.limo;
      if (r < 0.35) {
        tipo = TipoMonstruo.lobo;
      } else if (r < 0.60 && estadoJuego.tiempoPartida > 90) {
        tipo = TipoMonstruo.esqueleto;
      }

      world.add(Enemigo(
        tipo: tipo,
        estadoJuego: estadoJuego,
        posicionInicial: spawn,
      ));
    }
  }

  void activarSubidaNivel() {
    jugador.animarSubidaNivel();
    pausarPorOverlay('ModalSubirNivel');
  }

  void pausarPorOverlay(String nombre) {
    estadoJuego.pausarPartida();
    overlays.add(nombre);
  }

  void reanudarDesdeOverlay(String nombre) {
    overlays.remove(nombre);
    estadoJuego.reanudarPartida();
  }

  void reiniciar() {
    overlays.clear();
    world.children.whereType<Enemigo>().forEach((e) => e.removeFromParent());
    estadoJuego.reiniciarPartida();
    _spawnOleadaInicial();
  }
}