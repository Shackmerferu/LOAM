import 'package:flutter/material.dart';
import '../../core/constantes.dart';
import '../../estado/estado_juego.dart';
import '../../juego/juego_supervivencia.dart';

class ModalSubirNivel extends StatelessWidget {
  final GameState estadoJuego;
  final JuegoSupervivencia juego;

  const ModalSubirNivel({
    super.key,
    required this.estadoJuego,
    required this.juego,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2E).withOpacity(0.96),
          borderRadius: BorderRadius.circular(24.0),
          border: Border.all(color: Colors.amberAccent, width: 2.5),
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
                '¡SUBIDA DE NIVEL!',
                style: TextStyle(
                  color: Colors.amberAccent,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Selecciona una mejora para tu arsenal',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 18),
              _construirCartaMejora(
                context: context,
                titulo: 'Espada de Viento',
                nivelActual: estadoJuego.swordLevel,
                icono: Icons.colorize,
                colorTema: Colors.cyanAccent,
                descripcionBase: 'Aumenta el radio y daño del corte circular.',
                nombreEvolucion: 'Cortes Dimensionales',
                onSeleccionar: () => _aplicarMejora('sword'),
              ),
              const SizedBox(height: 12),
              _construirCartaMejora(
                context: context,
                titulo: 'Arco Mágico',
                nivelActual: estadoJuego.bowLevel,
                icono: Icons.arrow_outward,
                colorTema: Colors.lightGreenAccent,
                descripcionBase: 'Dispara flechas triples con mayor velocidad.',
                nombreEvolucion: 'Ballesta Explosiva Automática',
                onSeleccionar: () => _aplicarMejora('bow'),
              ),
              const SizedBox(height: 12),
              _construirCartaMejora(
                context: context,
                titulo: 'Magia de Fuego',
                nivelActual: estadoJuego.fireMagicLevel,
                icono: Icons.local_fire_department,
                colorTema: Colors.deepOrangeAccent,
                descripcionBase: 'Dispara bolas de fuego concentrado de alto impacto.',
                nombreEvolucion: 'Llamarada Creciente Continua',
                onSeleccionar: () => _aplicarMejora('fireMagic'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirCartaMejora({
    required BuildContext context,
    required String titulo,
    required int nivelActual,
    required IconData icono,
    required Color colorTema,
    required String descripcionBase,
    required String nombreEvolucion,
    required VoidCallback onSeleccionar,
  }) {
    final esEvolucionSiguiente = nivelActual == GameConstants.maxWeaponLevel - 1;
    final esNivelMaximo = nivelActual >= GameConstants.maxWeaponLevel;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A3E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: esEvolucionSiguiente ? Colors.amberAccent : colorTema.withOpacity(0.4),
          width: esEvolucionSiguiente ? 2.0 : 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: esNivelMaximo ? null : onSeleccionar,
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: colorTema.withOpacity(0.2),
                  child: Icon(icono, color: colorTema, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            titulo,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: esNivelMaximo ? Colors.amber.shade700 : Colors.black45,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              esNivelMaximo ? 'MAX' : 'Nv. $nivelActual → ${nivelActual + 1}',
                              style: TextStyle(
                                color: esNivelMaximo ? Colors.black : Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      if (esEvolucionSiguiente) ...[
                        Text(
                          '¡MEJORA: $nombreEvolucion!',
                          style: const TextStyle(
                            color: Colors.amberAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ] else if (esNivelMaximo) ...[
                        Text(
                          'Evolucionado: $nombreEvolucion',
                          style: TextStyle(
                            color: colorTema,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ] else ...[
                        Text(
                          descripcionBase,
                          style: const TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _aplicarMejora(String arma) {
    estadoJuego.upgradeWeapon(arma);
    juego.reanudarDesdeOverlay('ModalSubirNivel');
  }
}
