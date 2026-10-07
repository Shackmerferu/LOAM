import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constantes.dart';
import '../estado/estado_juego.dart';
import 'pantalla_juego.dart';

class PantallaInicio extends StatelessWidget {
  const PantallaInicio({super.key});

  void _iniciar(BuildContext context) {
    final estado = context.read<EstadoJuego>();
    estado.iniciarPartida();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const PantallaJuego()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final estado = context.watch<EstadoJuego>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [GameConstants.fondoOscuro, Color(0xFF2A1B4A)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              children: [
                const Spacer(),
                const Icon(
                  Icons.auto_fix_high,
                  size: 72,
                  color: GameConstants.acentoDiamante,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Supervivencia Mágica',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '¡Bienvenido, ${estado.username}!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.all(18.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(18.0),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _Instruccion(
                        icono: Icons.touch_app,
                        texto: 'Arrastra el dedo para mover al personaje.',
                      ),
                      _Instruccion(
                        icono: Icons.auto_awesome,
                        texto: 'Las armas atacan solas. ¡Sobreviví lo máximo!',
                      ),
                      _Instruccion(
                        icono: Icons.diamond,
                        texto: 'Recogé diamantes para comprar mejoras.',
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GameConstants.acentoMagico,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                    ),
                    icon: const Icon(Icons.play_arrow, size: 28),
                    label: const Text(
                      'INICIAR',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                      ),
                    ),
                    onPressed: () => _iniciar(context),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Instruccion extends StatelessWidget {
  final IconData icono;
  final String texto;

  const _Instruccion({required this.icono, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icono, color: GameConstants.acentoDiamante, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
