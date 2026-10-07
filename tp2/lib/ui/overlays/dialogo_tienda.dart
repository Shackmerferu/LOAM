import 'package:flutter/material.dart';
import '../../estado/estado_juego.dart';

class DialogoTienda extends StatelessWidget {
  final GameState estadoJuego;

  const DialogoTienda({super.key, required this.estadoJuego});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E1E2E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
        side: const BorderSide(color: Colors.cyanAccent, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.shopping_bag, color: Colors.cyanAccent, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'COMPRA DE DIAMANTES',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Simulación de pasarela de pago para pruebas de monetización.',
              style: TextStyle(color: Colors.white60, fontSize: 12),
            ),
            const SizedBox(height: 18),
            _construirPaquete(
              context: context,
              diamantes: 100,
              precioSimulado: '\$0.99',
              icono: Icons.diamond_outlined,
            ),
            const SizedBox(height: 10),
            _construirPaquete(
              context: context,
              diamantes: 500,
              precioSimulado: '\$3.99',
              icono: Icons.diamond,
              destacado: true,
            ),
            const SizedBox(height: 10),
            _construirVidaExtra(context: context),
          ],
        ),
      ),
    );
  }

  Widget _construirVidaExtra({required BuildContext context}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C44),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.redAccent),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.favorite, color: Colors.redAccent, size: 24),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '1 Vida Extra',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Vidas extra: ${estadoJuego.vidasExtras}',
                    style: const TextStyle(color: Colors.white60, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
            onPressed: () {
              estadoJuego.comprarVidaExtraSimulada();
              Navigator.of(context).pop();
            },
            child: const Text('\$7.99'),
          ),
        ],
      ),
    );
  }

  Widget _construirPaquete({
    required BuildContext context,
    required int diamantes,
    required String precioSimulado,
    required IconData icono,
    bool destacado = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: destacado ? const Color(0xFF2C2C44) : const Color(0xFF252538),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: destacado ? Colors.cyanAccent : Colors.white12,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icono, color: Colors.cyanAccent, size: 24),
              const SizedBox(width: 10),
              Text(
                '$diamantes Diamantes',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: destacado ? Colors.cyanAccent : Colors.blueGrey.shade700,
              foregroundColor: destacado ? Colors.black : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
            onPressed: () {
              estadoJuego.buyDiamonds(diamantes);
              Navigator.of(context).pop();
            },
            child: Text(precioSimulado),
          ),
        ],
      ),
    );
  }
}
