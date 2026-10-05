import 'package:flame/game.dart';
import 'package:material_ui/material_ui.dart';
import '../estado/estado_juego.dart';
import '../juego/juego_supervivencia.dart';
import 'widgets/cabecera_juego.dart';
import 'widgets/barra_controles.dart';
import 'overlays/modal_subir_nivel.dart';
import 'overlays/modal_tienda.dart';
import 'overlays/modal_anuncio.dart';

class PantallaJuego extends StatefulWidget {
  final GameState estadoJuego;

  const PantallaJuego({super.key, required this.estadoJuego});

  @override
  State<PantallaJuego> createState() => _PantallaJuegoState();
}

class _PantallaJuegoState extends State<PantallaJuego> {
  late JuegoSupervivencia _juego;

  @override
  void initState() {
    super.initState();
    _juego = JuegoSupervivencia(estadoJuego: widget.estadoJuego);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CabeceraJuego(estadoJuego: widget.estadoJuego),
          Expanded(
            child: Stack(
              children: [
                GameWidget<JuegoSupervivencia>(
                  game: _juego,
                  overlayBuilderMap: {
                    'ModalSubirNivel': (context, game) => ModalSubirNivel(
                      estadoJuego: widget.estadoJuego,
                      juego: game,
                    ),
                    'ModalTienda': (context, game) => ModalTienda(
                      estadoJuego: widget.estadoJuego,
                      juego: game,
                    ),
                    'ModalAnuncio': (context, game) => ModalAnuncio(
                      estadoJuego: widget.estadoJuego,
                      juego: game,
                    ),
                  },
                ),
                ListenableBuilder(
                  listenable: widget.estadoJuego,
                  builder: (context, _) {
                    if (!widget.estadoJuego.isGameOver) {
                      return const SizedBox.shrink();
                    }
                    return Container(
                      color: Colors.black.withOpacity(0.8),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'FIN DE LA PARTIDA',
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Puntuación final: ${widget.estadoJuego.score}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.cyanAccent,
                                foregroundColor: Colors.black,
                              ),
                              onPressed: () {
                                _juego.reiniciar();
                                widget.estadoJuego.resetGame();
                              },
                              child: const Text('VOLVER A INTENTAR'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          BarraControles(
            estadoJuego: widget.estadoJuego,
            juego: _juego,
          ),
        ],
      ),
    );
  }
}