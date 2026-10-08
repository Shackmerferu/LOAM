import 'package:flutter_test/flutter_test.dart';
import 'package:survivor/estado/estado_juego.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('costo y compra de mejoras', () {
    test('cada compra aumenta su estadística en 15', () {
      final estado = EstadoJuego();
      estado.diamantesRecolectados = 1000;

      expect(estado.purchaseStatUpgrade('damage', 150), isTrue);
      expect(estado.bonusDanioComprado, 0.15);

      expect(estado.purchaseStatUpgrade('speed', 100), isTrue);
      expect(estado.velocidadMovimiento, 165);

      expect(estado.purchaseStatUpgrade('health', 120), isTrue);
      expect(estado.vidaMax, 165);
      expect(estado.vidaActual, 165);
    });

    test('triplica el precio de cada mejora de forma independiente', () {
      final estado = EstadoJuego();
      estado.diamantesRecolectados = 1000;

      expect(estado.costoMejora('speed'), 100);
      expect(estado.purchaseStatUpgrade('speed', 100), isTrue);
      expect(estado.costoMejora('speed'), 300);
      expect(estado.costoMejora('health'), 120);
      expect(estado.costoMejora('damage'), 150);
      expect(estado.purchaseStatUpgrade('speed', 300), isTrue);
      expect(estado.costoMejora('speed'), 900);
    });

    test('no cobra si el costo enviado no es el actual', () {
      final estado = EstadoJuego();
      estado.diamantesRecolectados = 1000;

      expect(estado.purchaseStatUpgrade('health', 360), isFalse);
      expect(estado.diamantesRecolectados, 1000);
      expect(estado.vidaMax, 150);
    });

    test('reiniciar la partida restablece los costos de mejoras', () {
      final estado = EstadoJuego();
      estado.diamantesRecolectados = 1000;
      estado.purchaseStatUpgrade('damage', 150);

      estado.reiniciarPartida();

      expect(estado.costoMejora('damage'), 150);
      expect(estado.bonusDanioComprado, 0);
      expect(estado.velocidadMovimiento, 150);
    });
  });

  group('volver al menú de inicio', () {
    test('limpia el ciclo de vida de la partida', () {
      final estado = EstadoJuego();
      estado.pausarPartida();
      expect(estado.isPaused, isTrue);

      estado.volverAlMenu();

      expect(estado.isPlaying, isFalse);
      expect(estado.isPaused, isFalse);
      expect(estado.isGameOver, isFalse);
      expect(estado.isVictory, isFalse);
    });

    test('borra game over y victoria para poder iniciar otra partida', () {
      final estado = EstadoJuego();
      estado.terminarPartida();
      expect(estado.isGameOver, isTrue);

      estado.volverAlMenu();
      expect(estado.isGameOver, isFalse);

      estado.ganarPartida();
      expect(estado.isVictory, isTrue);

      estado.volverAlMenu();
      expect(estado.isVictory, isFalse);
    });
  });
}
