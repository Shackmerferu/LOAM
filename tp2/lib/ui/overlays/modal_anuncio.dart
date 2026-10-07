import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../estado/estado_juego.dart';
import '../../juego/juego_supervivencia.dart';

class ModalAnuncio extends StatefulWidget {
  final GameState estadoJuego;
  final JuegoSupervivencia juego;

  const ModalAnuncio({
    super.key,
    required this.estadoJuego,
    required this.juego,
  });

  @override
  State<ModalAnuncio> createState() => _ModalAnuncioState();
}

class _ModalAnuncioState extends State<ModalAnuncio> {
  int _segundosRestantes = 5;
  Timer? _temporizador;

  @override
  void initState() {
    super.initState();
    _iniciarCuentaRegresiva();
  }

  void _iniciarCuentaRegresiva() {
    _temporizador = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_segundosRestantes > 1) {
        setState(() {
          _segundosRestantes--;
        });
      } else {
        _temporizador?.cancel();
        setState(() {
          _segundosRestantes = 0;
        });
      }
    });
  }

  @override
  void dispose() {
    _temporizador?.cancel();
    super.dispose();
  }

  void _cerrarYReiniciar() {
    widget.juego.overlays.remove('ModalAnuncio');
    widget.juego.reiniciar();
    widget.estadoJuego.resetGame();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      child: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: const Color(0xFF212130),
            borderRadius: BorderRadius.circular(18.0),
            border: Border.all(color: Colors.white24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade800,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'PUBLICIDAD',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    _segundosRestantes > 0
                        ? 'Espera $_segundosRestantes s'
                        : 'Listo',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF151520),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.videogame_asset,
                      size: 48,
                      color: Colors.cyanAccent,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Anuncio Simulado',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Reanudación tras reinicio',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _segundosRestantes == 0
                        ? Colors.green.shade600
                        : Colors.grey.shade700,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _segundosRestantes == 0 ? _cerrarYReiniciar : null,
                  child: Text(
                    _segundosRestantes == 0
                        ? 'CERRAR Y REINICIAR'
                        : 'ESPERE...',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
