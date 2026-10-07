import 'package:flame/components.dart';
import '../../core/constantes.dart';
import '../../estado/estado_juego.dart';
import '../juego_supervivencia.dart';

abstract class ArmaBase extends PositionComponent
    with HasGameReference<JuegoSupervivencia> {
  final GameState estadoJuego;

  double temporizador = 0.0;
  double intervaloAtaque;
  double danioBase;

  ArmaBase({
    required this.estadoJuego,
    required this.intervaloAtaque,
    required this.danioBase,
  });

  int get nivel;

  bool get estaMejorada =>
      nivel >= GameConstants.maxWeaponLevel;

  double get danioFinal =>
      danioBase *
      (1.0 + (nivel - 1) * 0.2) *
      estadoJuego.damageMultiplier;

  @override
  void update(double dt) {
    super.update(dt);

    if (!estadoJuego.isPlaying ||
        estadoJuego.isPaused ||
        estadoJuego.isGameOver) {
      return;
    }

    temporizador += dt;

    if (temporizador >= intervaloAtaque) {
      temporizador = 0.0;
      ejecutarAtaque();
    }
  }

  void ejecutarAtaque();
}
