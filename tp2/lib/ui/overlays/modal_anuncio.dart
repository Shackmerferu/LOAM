import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
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
  static const String rutaVideo = 'assets/anuncios/redragon.mp4';

  int _segundosRestantes = 5;
  Timer? _temporizador;
  VideoPlayerController? _controladorVideo;
  bool _videoListo = false;
  bool _videoError = false;

  @override
  void initState() {
    super.initState();
    _cargarVideo();
    _iniciarCuentaRegresiva();
  }

  Future<void> _cargarVideo() async {
    final controlador = VideoPlayerController.asset(rutaVideo);
    _controladorVideo = controlador;
    try {
      await controlador.initialize();
      await controlador.setLooping(true);
      await controlador.setVolume(0.0);
      await controlador.play();
      if (!mounted) return;
      setState(() => _videoListo = true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _videoError = true);
    }
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
    final controlador = _controladorVideo;
    _controladorVideo = null;
    controlador?.dispose();
    super.dispose();
  }

  void _cerrar() {
    widget.juego.overlays.remove('ModalAnuncio');
    if (widget.estadoJuego.finPartida) {
      // Murió el usuario: tras el anuncio va la pantalla de derrota.
      widget.juego.overlays.add('GameOver');
    } else {
      widget.juego.reiniciar();
      widget.estadoJuego.resetGame();
    }
  }

  Widget _construirVideo() {
    if (_videoListo && _controladorVideo != null) {
      return Center(
        child: AspectRatio(
          aspectRatio: _controladorVideo!.value.aspectRatio,
          child: VideoPlayer(_controladorVideo!),
        ),
      );
    }

    if (_videoError) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.videocam_off, size: 40, color: Colors.white38),
          SizedBox(height: 8),
          Text(
            'No se pudo reproducir el anuncio',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      );
    }

    return const Center(
      child: CircularProgressIndicator(color: Colors.cyanAccent),
    );
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                    _segundosRestantes > 0 ? 'Espera $_segundosRestantes s' : 'Listo',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                height: 150,
                width: double.infinity,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: const Color(0xFF151520),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: _construirVideo(),
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
                  onPressed: _segundosRestantes == 0 ? _cerrar : null,
                  child: Text(_segundosRestantes == 0 ? 'CERRAR ANUNCIO' : 'ESPERE...'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
