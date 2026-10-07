import 'package:material_ui/material_ui.dart';

import '../../estado/estado_juego.dart';
import '../../juego/juego_supervivencia.dart';

class ModalTienda extends StatefulWidget {
  final GameState estadoJuego;
  final JuegoSupervivencia juego;

  const ModalTienda({
    super.key,
    required this.estadoJuego,
    required this.juego,
  });

  @override
  State<ModalTienda> createState() => _ModalTiendaState();
}

class _ModalTiendaState extends State<ModalTienda> {
  String? mensajeError;

  void _intentarCompra(String tipo, int costo) {
    final exito = widget.estadoJuego.purchaseStatUpgrade(tipo, costo);
    if (!exito) {
      setState(() {
        mensajeError = 'Diamantes insuficientes.';
      });
    } else {
      setState(() {
        mensajeError = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final estado = widget.estadoJuego;

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E).withValues(alpha: 0.97),
          borderRadius: BorderRadius.circular(24.0),
          border: Border.all(color: Colors.cyanAccent, width: 2.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.black87,
              blurRadius: 20.0,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'TIENDA INTERMEDIA (MINUTO 5)',
                style: TextStyle(
                  color: Colors.cyanAccent,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Mejora tus estadísticas base antes de la gran horda',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.diamond, color: Colors.cyanAccent, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    '${estado.diamonds} Diamantes disponibles',
                    style: const TextStyle(
                      color: Colors.cyanAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (mensajeError != null) ...[
                const SizedBox(height: 8),
                Text(
                  mensajeError!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                ),
              ],
              const SizedBox(height: 16),
              _construirOpcionCompra(
                titulo: '+25% Daño Global',
                descripcion: 'Incrementa la potencia de todas las armas.',
                costo: 150,
                icono: Icons.flash_on,
                colorIcono: Colors.amberAccent,
                onComprar: () => _intentarCompra('damage', 150),
              ),
              const SizedBox(height: 10),
              _construirOpcionCompra(
                titulo: '+25 Velocidad de Movimiento',
                descripcion: 'Facilita esquivar ataques en áreas reducidas.',
                costo: 100,
                icono: Icons.directions_run,
                colorIcono: Colors.greenAccent,
                onComprar: () => _intentarCompra('speed', 100),
              ),
              const SizedBox(height: 10),
              _construirOpcionCompra(
                titulo: '+20 Salud Máxima y Curación',
                descripcion: 'Aumenta el límite de vida y restaura salud.',
                costo: 120,
                icono: Icons.favorite,
                colorIcono: Colors.redAccent,
                onComprar: () => _intentarCompra('health', 120),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    widget.juego.reanudarDesdeOverlay('ModalTienda');
                  },
                  child: const Text('CONTINUAR PARTIDA'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirOpcionCompra({
    required String titulo,
    required String descripcion,
    required int costo,
    required IconData icono,
    required Color colorIcono,
    required VoidCallback onComprar,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF252538),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: colorIcono.withValues(alpha: 0.15),
            child: Icon(icono, color: colorIcono, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  descripcion,
                  style: const TextStyle(color: Colors.white60, fontSize: 11),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyan.shade900,
              foregroundColor: Colors.cyanAccent,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
            onPressed: onComprar,
            child: Row(
              children: [
                const Icon(Icons.diamond, size: 14),
                const SizedBox(width: 4),
                Text('$costo'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
