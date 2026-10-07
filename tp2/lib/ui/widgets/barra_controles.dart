import 'package:material_ui/material_ui.dart';

import '../../estado/estado_juego.dart';
import '../../juego/juego_supervivencia.dart';

class BarraControles extends StatelessWidget {
  final GameState estadoJuego;
  final JuegoSupervivencia juego;

  const BarraControles({
    super.key,
    required this.estadoJuego,
    required this.juego,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: estadoJuego,
      builder: (context, _) {
        final theme = Theme.of(context);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(0, -2),
                blurRadius: 4.0,
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (!estadoJuego.isPlaying)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('INICIAR'),
                    onPressed: () {
                      estadoJuego.startGame();
                    },
                  )
                else ...[
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: estadoJuego.isPaused
                          ? Colors.amber.shade700
                          : Colors.blueGrey,
                      foregroundColor: Colors.white,
                    ),
                    icon: Icon(
                      estadoJuego.isPaused ? Icons.play_arrow : Icons.pause,
                    ),
                    label: Text(estadoJuego.isPaused ? 'REANUDAR' : 'PAUSA'),
                    onPressed: () {
                      if (estadoJuego.isPaused) {
                        estadoJuego.resumeGame();
                      } else {
                        estadoJuego.pauseGame();
                      }
                    },
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent.shade700,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.refresh),
                    label: const Text('REINICIAR'),
                    onPressed: () {
                      // Disparo obligatorio del anuncio publicitario previo al reinicio
                      estadoJuego.pauseGame();
                      juego.overlays.add('ModalAnuncio');
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
