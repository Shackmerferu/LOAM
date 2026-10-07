import 'package:flame/game.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../core/constantes.dart';
import '../estado/estado_juego.dart';
import '../juego/juego_supervivencia.dart';
import 'overlays/modal_anuncio.dart';
import 'overlays/modal_game_over.dart';
import 'overlays/modal_subir_nivel.dart';
import 'overlays/modal_tienda.dart';
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

    if (estado.finPartida && !_juego.overlays.isActive('GameOver')) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _juego.overlays.add('GameOver');
      });
    }

    return Scaffold(
      backgroundColor: estado.modoOscuro
          ? GameConstants.fondoOscuro
          : GameConstants.fondoClaro,
      body: SafeArea(
        child: Stack(
          children: [
            // 1. El juego ocupa todo el fondo
            Positioned.fill(
              child: GameWidget<JuegoSupervivencia>(
                game: _juego,
                overlayBuilderMap: {
                  'ModalSubirNivel': (ctx, game) =>
                      ModalSubirNivel(estadoJuego: estado, juego: game),
                  'ModalTienda': (ctx, game) =>
                      ModalTienda(estadoJuego: estado, juego: game),
                  'ModalAnuncio': (ctx, game) =>
                      ModalAnuncio(estadoJuego: estado, juego: game),
                  'GameOver': (ctx, game) =>
                      ModalGameOver(estadoJuego: estado, juego: game),
                },
              ),
            ),
            // 2. Cabecera flotante arriba
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: CabeceraJuego(estadoJuego: estado),
            ),
            // 3. Botonera flotante abajo
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _construirBotoneraExterna(estado),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirBotoneraExterna(EstadoJuego estado) {
    final colorFondo = estado.modoOscuro
        ? GameConstants.superficieOscura
        : GameConstants.superficieClara;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: colorFondo.withValues(alpha: 0.92),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.play_arrow),
            label: const Text('Iniciar'),
            onPressed: estado.enJuego
                ? null
                : () {
                    debugPrint('[DEBUG_UI] Botón Iniciar presionado');
                    estado.iniciarPartida();
                  },
          ),
          ElevatedButton.icon(
            icon: Icon(estado.enPausa ? Icons.play_arrow : Icons.pause),
            label: Text(estado.enPausa ? 'Reanudar' : 'Pausar'),
            onPressed: !estado.enJuego
                ? null
                : () {
                    if (estado.enPausa) {
                      debugPrint('[DEBUG_UI] Botón Reanudar presionado');
                      estado.reanudarPartida();
                    } else {
                      debugPrint('[DEBUG_UI] Botón Pausar presionado');
                      estado.pausarPartida();
                    }
                  },
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Reiniciar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent.shade700,
            ),
            onPressed: () {
              debugPrint('[DEBUG_UI] Botón Reiniciar presionado');
              _juego.overlays.clear();
              estado.reiniciarPartida();
              _juego.reiniciar();
            },
          ),
        ],
      ),
    );
  }
}
