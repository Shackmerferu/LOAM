import 'dart:math';
import 'package:flame/components.dart';
import '../../estado/estado_juego.dart';
import '../juego_supervivencia.dart';
import 'enemigo.dart';

class GeneradorEnemigos extends Component
    with HasGameReference<JuegoSupervivencia> {
  final GameState estadoJuego;
  final Random _random = Random();
  double _temporizador = 0.0;
  double _intervaloSpawn = 1.4;

  GeneradorEnemigos({required this.estadoJuego});

  @override
  void update(double dt) {
    super.update(dt);

    if (!estadoJuego.isPlaying || estadoJuego.isPaused || estadoJuego.isGameOver) {
      return;
    }

    _intervaloSpawn = (1.4 - (estadoJuego.gameTime / 600)).clamp(0.35, 1.4);

    _temporizador += dt;
    if (_temporizador >= _intervaloSpawn) {
      _temporizador = 0.0;
      _generarEnemigo();
    }
  }

  void _generarEnemigo() {
    final enemigosActuales = game.children.whereType<Enemigo>().length;
    if (enemigosActuales >= 40) return;

    final angulo = _random.nextDouble() * 2 * pi;
    const distancia = 380.0;
    final centro = game.jugador.position;

    final posicionSpawn = Vector2(
      centro.x + cos(angulo) * distancia,
      centro.y + sin(angulo) * distancia,
    );

    TipoEnemigo tipo = TipoEnemigo.slime;
    final r = _random.nextDouble();
    if (r < 0.25) {
      tipo = TipoEnemigo.lobo;
    } else if (r < 0.40 && estadoJuego.gameTime > 60) {
      tipo = TipoEnemigo.esqueleto;
    }

    game.add(
      Enemigo(
        tipo: tipo,
        estadoJuego: estadoJuego,
        posicionInicial: posicionSpawn,
      ),
    );
  }
}
