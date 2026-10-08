import 'dart:ui';
import 'package:flame/components.dart';
import '../../core/constantes.dart';
import '../juego_supervivencia.dart';

/// Cubre con negro puro todo lo que queda fuera de la arena restringida
/// cuando se cierra el círculo (3:30), dejando visible unicamente el cuadrado
/// central donde se desarrolla el combate.
class MascaraOscuridad extends Component with HasGameReference<JuegoSupervivencia> {
  static const double _alcanceMundo = 3000.0;

  final Paint _pinturaNegra = Paint()..color = const Color(0xFF000000);

  MascaraOscuridad() : super(priority: 1000);

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (!game.estadoJuego.esHordaActiva) return;

    final centro = game.centroArena;
    final mitad = GameConstants.tamanoAreaRestringida / 2;

    final izquierda = centro.x - mitad;
    final derecha = centro.x + mitad;
    final arriba = centro.y - mitad;
    final abajo = centro.y + mitad;

    canvas.drawRect(
      Rect.fromLTRB(centro.x - _alcanceMundo, centro.y - _alcanceMundo, centro.x + _alcanceMundo, arriba),
      _pinturaNegra,
    );
    canvas.drawRect(
      Rect.fromLTRB(centro.x - _alcanceMundo, abajo, centro.x + _alcanceMundo, centro.y + _alcanceMundo),
      _pinturaNegra,
    );
    canvas.drawRect(
      Rect.fromLTRB(centro.x - _alcanceMundo, arriba, izquierda, abajo),
      _pinturaNegra,
    );
    canvas.drawRect(
      Rect.fromLTRB(derecha, arriba, centro.x + _alcanceMundo, abajo),
      _pinturaNegra,
    );
  }
}
