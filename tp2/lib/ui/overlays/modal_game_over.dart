import 'package:material_ui/material_ui.dart';

import '../../estado/estado_juego.dart';
import '../../juego/juego_supervivencia.dart';

class ModalGameOver extends StatelessWidget {
  final GameState estadoJuego;
  final JuegoSupervivencia juego;

  const ModalGameOver({
    super.key,
    required this.estadoJuego,
    required this.juego,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.88),
      child: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1A2E),
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(color: Colors.redAccent.shade700, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.dangerous, size: 64, color: Colors.redAccent),
              const SizedBox(height: 12),
              const Text(
                '¡PERDISTE!',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Puntaje Final: ${estadoJuego.score}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Diamantes Recolectados: ${estadoJuego.diamonds}',
                style: const TextStyle(color: Colors.cyanAccent, fontSize: 14),
              ),
              const SizedBox(height: 16),
              const Text(
                'Presiona "Reiniciar" en la botonera inferior para volver a jugar.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
