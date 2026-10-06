import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../core/constantes.dart';
import '../estado/estado_juego.dart';
import 'componentes/enemigo.dart';
import 'componentes/jugador.dart';

class FondoCuadricula extends Component with HasGameReference<JuegoSupervivencia> {
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
  late final World mundo;
  late final CameraComponent camara;

  final Random _random = Random();
  double _timerSpawn = 0.0;

  JuegoSupervivencia({required this.estadoJuego});

  @override
  Color backgroundColor() => const Color(0xFF0D0A18);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    mundo = World();
    await add(mundo);
    await mundo.add(FondoCuadricula());

    jugador = Jugador(estadoJuego: estadoJuego);
    await mundo.add(jugador);

    camara = CameraComponent(world: mundo);
    camara.viewfinder.anchor = Anchor.center;
    camara.follow(jugador);
    await add(camara);
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
    if (_timerSpawn >= 0.6) {
      _timerSpawn = 0.0;
      _regularHorda();
    }
  }

  void _regularHorda() {
    final cantidadActual = mundo.children.whereType<Enemigo>().length;
    if (cantidadActual >= GameConstants.maxEnemigos) return;

    final faltantes = GameConstants.minEnemigos - cantidadActual;
    final porGenerar = faltantes > 0 ? faltantes : 1;

    for (int i = 0; i < porGenerar; i++) {
      if (mundo.children.whereType<Enemigo>().length >= GameConstants.maxEnemigos) break;

      final angulo = _random.nextDouble() * 2 * pi;
      const double distancia = 420.0;
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

      mundo.add(Enemigo(
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
    estadoJuego.reiniciarPartida();
  }
}