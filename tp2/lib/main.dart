import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'estado/estado_juego.dart';
import 'ui/pantalla_inicio.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // El juego está diseñado en vertical: bloqueamos la rotación para evitar
  // solapamientos de UI en horizontal (además del bloqueo nativo en los
  // AndroidManifest/Info.plist).
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
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