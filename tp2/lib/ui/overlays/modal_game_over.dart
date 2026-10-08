import 'package:flutter/material.dart';
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
      color: Colors.black45,
      child: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          decoration: BoxDecoration(
            color: const Color(0xFF262138),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.mood_bad,
                size: 46,
                color: Color(0xFFE8845A),
              ),
              const SizedBox(height: 12),
              const Text(
                'Perdiste',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              _fila('Puntaje', '${estadoJuego.score}'),
              const SizedBox(height: 8),
              _fila('Diamantes', '${estadoJuego.diamonds}'),
              const SizedBox(height: 18),
              const Text(
                'Toca «Reiniciar» para volver a intentarlo.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fila(String etiqueta, String valor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          etiqueta,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        Text(
          valor,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}