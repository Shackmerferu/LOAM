import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/constantes.dart';
import '../estado/estado_juego.dart';
import 'armas/arco.dart';
import 'armas/espada.dart';
import 'armas/magia_fuego.dart';
import 'componentes/diamante.dart';
import 'componentes/enemigo.dart';
import 'componentes/jugador.dart';
import 'componentes/mascara_oscuridad.dart';
import 'componentes/trader.dart';

class FondoGameplay extends Component
    with HasGameReference<JuegoSupervivencia> {
  static const double _tamanoFondo = 12000.0;
  static const String _rutaImagen =
      'assets/Fondos/DFG_Free_Sampler_Preview_Ritual_Dark_Magic_1200.jpg';

  late final ui.Image _imagen;
  late final Paint _pinturaFondo;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final datos = await rootBundle.load(_rutaImagen);
    final codec = await ui.instantiateImageCodec(datos.buffer.asUint8List());
    _imagen = (await codec.getNextFrame()).image;
    codec.dispose();
    _pinturaFondo = Paint()
      ..filterQuality = ui.FilterQuality.high
      ..shader = ui.ImageShader(
        _imagen,
        ui.TileMode.repeated,
        ui.TileMode.repeated,
        Float64List.fromList(const [
          1,
          0,
          0,
          0,
          0,
          1,
          0,
          0,
          0,
          0,
          1,
          0,
          0,
          0,
          0,
          1,
        ]),
      );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(
      const Rect.fromLTWH(
        -_tamanoFondo / 2,
        -_tamanoFondo / 2,
        _tamanoFondo,
        _tamanoFondo,
      ),
      _pinturaFondo,
    );
  }
}

class JuegoSupervivencia extends FlameGame
    with HasCollisionDetection, DragCallbacks {
  final EstadoJuego estadoJuego;
  late final Jugador jugador;

  /// Centro de la arena restringida; se fija al iniciar la horda del minuto 6.
  Vector2 centroArena = Vector2.zero();
  bool _centroArenaFijado = false;

  World get mundo => world;

  final Random _random = Random();
  double _timerSpawn = 0.0;

  JuegoSupervivencia({required this.estadoJuego});

  @override
  Color backgroundColor() => const Color(0xFF0D0A18);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    debugPrint('[DEBUG_JUEGO] onLoad() iniciado - Precaricando imágenes...');

    await images.loadAll([
      'personajes/jugador_quieto.png',
      'personajes/jugador_caminar.png',
      'personajes/jugador_herido.png',
      'personajes/jugador_muerte.png',
      'personajes/jugador_levelup.png',
      'monstruos/limo_caminar.png',
      'monstruos/limo_muerte.png',
      'monstruos/lobo_caminar.png',
      'monstruos/lobo_muerte.png',
      'monstruos/slime_caminar.png',
      'monstruos/slime_muerte.png',
      'monstruos/esqueleto_caminar.png',
      'monstruos/esqueleto_muerte.png',
      'monstruos/minigolem_caminar.png',
      'monstruos/minigolem_muerte.png',
      'items/diamante.png',
      'personajes/trader_comerciar.png',
      'armas/espada_corte.png',
      'armas/corte_dimensional.png',
      'armas/flecha.png',
      'armas/flecha_explosiva.png',
      'armas/explosion.png',
      'armas/boladefuego.png',
      'armas/llamarada.png',
    ]);
    debugPrint('[DEBUG_JUEGO] Imágenes precarizadas con éxito');

    await world.add(FondoGameplay());
    await world.add(MascaraOscuridad());

    jugador = Jugador(estadoJuego: estadoJuego);
    await world.add(jugador);
    debugPrint(
      '[DEBUG_JUEGO] Jugador añadido al mundo en posición: ${jugador.position}',
    );

    estadoJuego.asignarArmaInicialAleatoria();
    _inicializarArmaActual();

    camera.viewfinder.anchor = Anchor.center;
    camera.follow(jugador);

    _spawnOleadaInicial();
    debugPrint('[DEBUG_JUEGO] onLoad() finalizado correctamente');
  }

  void _spawnOleadaInicial() {
    for (int i = 0; i < 4; i++) {
      final angulo = (i / 4) * 2 * pi;
      const double distancia = 380.0;
      final spawn = Vector2(cos(angulo) * distancia, sin(angulo) * distancia);

      world.add(
        Enemigo(
          tipo: TipoMonstruo.limo,
          estadoJuego: estadoJuego,
          posicionInicial: spawn,
        ),
      );
    }
  }

  Vector2 _vectorDrag = Vector2.zero();
  bool _estaArrastrando = false;

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    _vectorDrag = Vector2.zero();
    _estaArrastrando = true;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (estadoJuego.enJuego &&
        !estadoJuego.enPausa &&
        !estadoJuego.finPartida) {
      if (_estaArrastrando) {
        _vectorDrag += event.localDelta;
        if (_vectorDrag.length > 2.0) {
          jugador.mover(_vectorDrag.normalized());
        }
      }
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    _estaArrastrando = false;
    _vectorDrag = Vector2.zero();
    jugador.mover(Vector2.zero());
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    _estaArrastrando = false;
    _vectorDrag = Vector2.zero();
    jugador.mover(Vector2.zero());
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!estadoJuego.enJuego || estadoJuego.enPausa || estadoJuego.finPartida)
      return;

    if (estadoJuego.swordLevel > 0 &&
        world.children.whereType<Espada>().isEmpty) {
      world.add(Espada(estadoJuego: estadoJuego));
    }
    if (estadoJuego.bowLevel > 0 && world.children.whereType<Arco>().isEmpty) {
      world.add(Arco(estadoJuego: estadoJuego));
    }
    if (estadoJuego.fireMagicLevel > 0 &&
        world.children.whereType<MagiaFuego>().isEmpty) {
      world.add(MagiaFuego(estadoJuego: estadoJuego));
    }

    estadoJuego.actualizarTiempo(dt);

    if (estadoJuego.esHordaActiva && !_centroArenaFijado) {
      _centroArenaFijado = true;
      centroArena = jugador.position.clone();
      debugPrint(
        '[DEBUG_JUEGO] Horda iniciada - arena centrada en $centroArena',
      );
    }

    if (estadoJuego.tiempoPartida >= GameConstants.tiempoTiendaMinuto5 &&
        !estadoJuego.tiendaMinuto5Mostrada) {
      estadoJuego.tiendaMinuto5Mostrada = true;
      _spawnComerciante();
    }

    _timerSpawn += dt;
    if (_timerSpawn >= 0.8) {
      _timerSpawn = 0.0;
      _regularHorda();
    }
  }

  void _regularHorda() {
    final cantidadActual = world.children
        .whereType<Enemigo>()
        .where((e) => e.current != EstadoEnemigo.muriendo)
        .length;
    if (cantidadActual >= GameConstants.maxEnemigos) return;

    final faltantes = GameConstants.minEnemigos - cantidadActual;
    final porGenerar = faltantes > 0 ? faltantes.clamp(1, 3) : 1;

    for (int i = 0; i < porGenerar; i++) {
      if (world.children
              .whereType<Enemigo>()
              .where((e) => e.current != EstadoEnemigo.muriendo)
              .length >=
          GameConstants.maxEnemigos)
        break;

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

      world.add(
        Enemigo(tipo: tipo, estadoJuego: estadoJuego, posicionInicial: spawn),
      );
    }
  }

  void respawnEnemigoTrasMuerte() {
    final cantidadActual = world.children
        .whereType<Enemigo>()
        .where((e) => e.current != EstadoEnemigo.muriendo)
        .length;
    if (cantidadActual >= GameConstants.maxEnemigos) return;

    final angulo = _random.nextDouble() * 2 * pi;
    const double distancia = 380.0;
    final spawn = Vector2(
      jugador.position.x + cos(angulo) * distancia,
      jugador.position.y + sin(angulo) * distancia,
    );

    final r = _random.nextDouble();
    TipoMonstruo tipo = TipoMonstruo.limo;
    if (r < 0.35) {
      tipo = TipoMonstruo.lobo;
    } else if (r < 0.65 && estadoJuego.tiempoPartida > 60) {
      tipo = TipoMonstruo.esqueleto;
    } else if (r < 0.85 && estadoJuego.tiempoPartida > 120) {
      tipo = TipoMonstruo.miniGolem;
    }

    world.add(
      Enemigo(tipo: tipo, estadoJuego: estadoJuego, posicionInicial: spawn),
    );
  }

  void _spawnComerciante() {
    final posicion = jugador.position + Vector2(140, 90);
    world.add(Trader(estadoJuego: estadoJuego, posicionInicial: posicion));
    debugPrint('[DEBUG_JUEGO] Comerciante spawneado en el minuto 5');
  }

  void eliminarComerciante() {
    world.children.whereType<Trader>().forEach((t) => t.removeFromParent());
    debugPrint('[DEBUG_JUEGO] Comerciante eliminado tras cerrar la tienda');
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

  void _inicializarArmaActual() {
    if (estadoJuego.swordLevel > 0) {
      world.add(Espada(estadoJuego: estadoJuego));
    } else if (estadoJuego.bowLevel > 0) {
      world.add(Arco(estadoJuego: estadoJuego));
    } else if (estadoJuego.fireMagicLevel > 0) {
      world.add(MagiaFuego(estadoJuego: estadoJuego));
    }
  }

  void reiniciar() {
    debugPrint('[DEBUG_JUEGO] reiniciar() llamado');
    overlays.clear();
    world.children.whereType<Enemigo>().forEach((e) => e.removeFromParent());
    world.children.whereType<Espada>().forEach((e) => e.removeFromParent());
    world.children.whereType<Arco>().forEach((e) => e.removeFromParent());
    world.children.whereType<MagiaFuego>().forEach((e) => e.removeFromParent());
    world.children.whereType<Trader>().forEach((e) => e.removeFromParent());
    world.children.whereType<Diamante>().forEach((e) => e.removeFromParent());
    world.children.whereType<ProyectilFlecha>().forEach(
      (e) => e.removeFromParent(),
    );
    world.children.whereType<ProyectilBolaFuego>().forEach(
      (e) => e.removeFromParent(),
    );
    world.children.whereType<EfectoLlamaradaContinua>().forEach(
      (e) => e.removeFromParent(),
    );
    world.children.whereType<EfectoCorte>().forEach(
      (e) => e.removeFromParent(),
    );
    world.children.whereType<EfectoExplosion>().forEach(
      (e) => e.removeFromParent(),
    );
    centroArena = Vector2.zero();
    _centroArenaFijado = false;
    estadoJuego.reiniciarPartida();
    _inicializarArmaActual();
    _spawnOleadaInicial();
  }
}
