import 'package:flutter/material.dart';
import '../../estado/estado_juego.dart';
import '../../juego/juego_supervivencia.dart';

class ModalPausa extends StatelessWidget {
  final GameState estadoJuego;
  final JuegoSupervivencia juego;

  const ModalPausa({
    super.key,
    required this.estadoJuego,
    required this.juego,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black45,
      child: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          decoration: BoxDecoration(
            color: const Color(0xFF241F38),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.pause_circle_outline,
                size: 46,
                color: Color(0xFFEAC96B),
              ),
              const SizedBox(height: 12),
              const Text(
                'Pausa',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFEAC96B),
                    foregroundColor: const Color(0xFF241F38),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    juego.overlays.remove('Pausa');
                    estadoJuego.reanudarPartida();
                  },
                  child: const Text('Reanudar'),
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
                    estadoJuego.reiniciarPartida();
                    juego.reiniciar();
                  },
                  child: const Text('Reiniciar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}