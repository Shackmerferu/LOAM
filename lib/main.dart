import 'dart:async';
import 'package:material_ui/material_ui.dart';

void main() {
  runApp(const MiJuegoApp());
}

class MiJuegoApp extends StatelessWidget {
  const MiJuegoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: PantallaJuego(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PantallaJuego extends StatefulWidget {
  const PantallaJuego({super.key});

  @override
  State<PantallaJuego> createState() => _PantallaJuegoState();
}

class _PantallaJuegoState extends State<PantallaJuego> {
  double posX = 100.0;
  double posY = 0.0;
  int puntaje = 0;
  double velocidad = 5.0;
  Timer? _temporizador;

  @override
  void initState() {
    super.initState();
    _temporizador = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      setState(() {
        posY += velocidad;
        if (posY > 500) {
          posY = 0;
          puntaje = 0;
          velocidad = 5.0;
        }
      });
    });
  }

  void _atrapado() {
    setState(() {
      puntaje++;
      posY = 0;
      posX = (posX + 120) % 250;
      velocidad += 0.5;
    });
  }

  @override
  void dispose() {
    _temporizador?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: Text('Puntaje: $puntaje'),
      ),
      body: Stack(
        children: [
          Positioned(
            left: posX,
            top: posY,
            child: GestureDetector(
              onTap: _atrapado,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}