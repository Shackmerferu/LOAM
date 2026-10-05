import 'package:flutter/material.dart';
import '../../estado/estado_juego.dart';
import '../overlays/dialogo_tienda.dart';

class CabeceraJuego extends StatelessWidget {
  final GameState estadoJuego;

  const CabeceraJuego({super.key, required this.estadoJuego});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: estadoJuego,
      builder: (context, _) {
        final theme = Theme.of(context);
        final minutos = (estadoJuego.gameTime / 60).floor().toString().padLeft(2, '0');
        final segundos = (estadoJuego.gameTime % 60).floor().toString().padLeft(2, '0');

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(0, 2),
                blurRadius: 4.0,
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          estadoJuego.username,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: estadoJuego.switchAccountType,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: estadoJuego.accountType == AccountType.pro
                                  ? Colors.amber.shade700
                                  : Colors.grey.shade600,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              estadoJuego.accountType == AccountType.pro ? 'PRO' : 'BASIC',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(
                        estadoJuego.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                        size: 20,
                      ),
                      onPressed: estadoJuego.toggleTheme,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'SCORE: ${estadoJuego.score}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Text(
                      'TIEMPO: $minutos:$segundos',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => DialogoTienda(estadoJuego: estadoJuego),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.cyan.shade900.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.cyanAccent),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.diamond, color: Colors.cyanAccent, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${estadoJuego.diamonds}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.cyanAccent,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.add_circle, color: Colors.greenAccent, size: 14),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}