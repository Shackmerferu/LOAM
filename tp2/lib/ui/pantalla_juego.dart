import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constantes.dart';
import '../estado/estado_juego.dart';
import '../juego/juego_supervivencia.dart';
import 'overlays/modal_anuncio.dart';
import 'overlays/modal_game_over.dart';
import 'overlays/modal_pausa.dart';
import 'overlays/modal_subir_nivel.dart';
import 'overlays/modal_tienda.dart';
import 'overlays/modal_victoria.dart';
import 'widgets/cabecera_juego.dart';

class PantallaJuego extends StatefulWidget {
  const PantallaJuego({super.key});

  @override
  State<PantallaJuego> createState() => _PantallaJuegoState();
}

class _PantallaJuegoState extends State<PantallaJuego> {
  late JuegoSupervivencia _juego;

  @override
  void initState() {
    super.initState();
    final estado = Provider.of<EstadoJuego>(context, listen: false);
    _juego = JuegoSupervivencia(estadoJuego: estado);
  }

  @override
  Widget build(BuildContext context) {
    final estado = context.watch<EstadoJuego>();

    // Al morir: primero el anuncio (con video) y al cerrarlo el GameOver.
    if (estado.finPartida &&
        !_juego.overlays.isActive('ModalAnuncio') &&
        !_juego.overlays.isActive('GameOver')) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _juego.overlays.add('ModalAnuncio');
      });
    }

    if (estado.victoria && !_juego.overlays.isActive('Victoria')) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _juego.overlays.add('Victoria');
      });
    }

    return Scaffold(
      backgroundColor: estado.modoOscuro
          ? GameConstants.fondoOscuro
          : GameConstants.fondoClaro,
      body: SafeArea(
        // El header se ancla al borde superior real del teléfono y su fondo
        // cubre la franja de la status bar.
        top: false,
        child: Stack(
          children: [
            // 1. El juego ocupa todo el fondo
            Positioned.fill(
              child: GameWidget<JuegoSupervivencia>(
                game: _juego,
                overlayBuilderMap: {
                  'Pausa': (ctx, game) =>
                      ModalPausa(estadoJuego: estado, juego: game),
                  'ModalSubirNivel': (ctx, game) =>
                      ModalSubirNivel(estadoJuego: estado, juego: game),
                  'ModalTienda': (ctx, game) =>
                      ModalTienda(estadoJuego: estado, juego: game),
                  'ModalAnuncio': (ctx, game) =>
                      ModalAnuncio(estadoJuego: estado, juego: game),
                  'GameOver': (ctx, game) =>
                      ModalGameOver(estadoJuego: estado, juego: game),
                  'Victoria': (ctx, game) =>
                      ModalVictoria(estadoJuego: estado, juego: game),
                },
              ),
            ),
            // 2. Cabecera flotante arriba (contiene los controles fuera del
            //    juego: pausa, reiniciar y volver al inicio)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: CabeceraJuego(estadoJuego: estado, juego: _juego),
            ),
          ],
        ),
      ),
    );
  }
}
