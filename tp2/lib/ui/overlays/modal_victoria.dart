import 'package:flutter/material.dart';
import '../../estado/estado_juego.dart';
import '../../juego/juego_supervivencia.dart';

class ModalVictoria extends StatelessWidget {
  final GameState estadoJuego;
  final JuegoSupervivencia juego;

  const ModalVictoria({
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
            border: Border.all(color: Colors.amberAccent, width: 2),
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
              const Icon(Icons.emoji_events, size: 64, color: Colors.amberAccent),
              const SizedBox(height: 12),
              const Text(
                '¡HAS GANADO!',
                style: TextStyle(
                  color: Colors.amberAccent,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sobreviviste los 5 minutos completos.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
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
                style: const TextStyle(
                  color: Colors.cyanAccent,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.amberAccent,
                    foregroundColor: const Color(0xFF1E1A2E),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    // Reinicio total de la partida desde fuera del juego.
                    juego.reiniciar();
                  },
                  child: const Text('JUGAR DE NUEVO'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    juego.overlays.clear();
                    estadoJuego.volverAlMenu();
                    Navigator.of(context).maybePop();
                  },
                  child: const Text('Volver al inicio'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
