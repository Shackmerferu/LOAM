import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'estado/estado_juego.dart';
import 'ui/pantalla_inicio.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EstadoJuego()),
      ],
      child: const SurvivorApp(),
    ),
  );
}

class SurvivorApp extends StatelessWidget {
  const SurvivorApp({super.key});

  @override
  Widget build(BuildContext context) {
    final estado = context.watch<EstadoJuego>();

    return MaterialApp(
      title: 'Supervivencia Mágica',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: estado.modoOscuro ? Brightness.dark : Brightness.light,
      ),
      home: const PantallaInicio(),
    );
  }
}