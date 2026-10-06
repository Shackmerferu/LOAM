import 'dart:math';
import 'package:flutter/material.dart';
import '../core/constantes.dart';

enum AccountType { basic, pro }
typedef TipoCuenta = AccountType;

enum TipoArma { espada, arco, magia }

typedef GameState = EstadoJuego;

class EstadoJuego extends ChangeNotifier {
  // Identidad y tipo de cuenta
  String usuario = 'Hechicero_Invitado';
  String get username => usuario;
  set username(String value) {
    usuario = value;
    notificarSeguro();
  }

  AccountType accountType = AccountType.pro;
  AccountType get tipoCuenta => accountType;
  set tipoCuenta(AccountType value) {
    accountType = value;
    notificarSeguro();
  }

  void switchAccountType() {
    accountType = accountType == AccountType.basic ? AccountType.pro : AccountType.basic;
    notificarSeguro();
  }
  void alternarTipoCuenta() => switchAccountType();

  // Apariencia
  bool modoOscuro = true;
  bool get isDarkMode => modoOscuro;
  set isDarkMode(bool value) {
    modoOscuro = value;
    notificarSeguro();
  }
  void alternarTema() {
    modoOscuro = !modoOscuro;
    notificarSeguro();
  }
  void toggleTheme() => alternarTema();

  // Ciclo de vida
  bool enJuego = false;
  bool get isPlaying => enJuego;

  bool enPausa = false;
  bool get isPaused => enPausa;

  bool finPartida = false;
  bool get isGameOver => finPartida;

  bool tiendaMinuto5Mostrada = false;

  void iniciarPartida() {
    debugPrint('[DEBUG_ESTADO] iniciarPartida() llamado');
    enJuego = true;
    enPausa = false;
    finPartida = false;
    tiendaMinuto5Mostrada = false;
    notificarSeguro();
  }
  void startGame() => iniciarPartida();

  void pausarPartida() {
    debugPrint('[DEBUG_ESTADO] pausarPartida() llamado');
    enPausa = true;
    notificarSeguro();
  }
  void pauseGame() => pausarPartida();

  void reanudarPartida() {
    debugPrint('[DEBUG_ESTADO] reanudarPartida() llamado');
    enPausa = false;
    notificarSeguro();
  }
  void resumeGame() => reanudarPartida();

  void asignarArmaInicialAleatoria() {
    nivelEspada = 0;
    nivelArco = 0;
    nivelMagia = 0;
    final r = _random.nextInt(3);
    if (r == 0) {
      nivelEspada = 1;
    } else if (r == 1) {
      nivelArco = 1;
    } else {
      nivelMagia = 1;
    }
    debugPrint('[DEBUG_ESTADO] Arma inicial asignada - Espada: $nivelEspada, Arco: $nivelArco, Magia: $nivelMagia');
  }

  void reiniciarPartida() {
    debugPrint('[DEBUG_ESTADO] reiniciarPartida() llamado');
    tiempoPartida = 0.0;
    _ultimoSegundoNotificado = -1;
    puntaje = 0;
    nivelJugador = 1;
    xpActual = 0.0;
    xpObjetivo = 100.0;
    vidaMax = 100.0;
    vidaActual = 100.0;
    asignarArmaInicialAleatoria();
    tiendaMinuto5Mostrada = false;
    finPartida = false;
    iniciarPartida();
  }
  void resetGame() => reiniciarPartida();

  void terminarPartida() {
    enJuego = false;
    finPartida = true;
    diamantesRecolectados = max(0, diamantesRecolectados - GameConstants.penalizacionDiamantesMuerte);
    notificarSeguro();
  }

  // Tiempos y puntaje
  double tiempoPartida = 0.0;
  int _ultimoSegundoNotificado = -1;

  double get gameTime => tiempoPartida;
  set gameTime(double value) {
    tiempoPartida = value;
    notificarSeguro();
  }

  int puntaje = 0;
  int get score => puntaje;
  set score(int value) {
    puntaje = value;
    notificarSeguro();
  }

  // Economía
  int diamantesRecolectados = 0;
  int diamantesComprados = 0;
  int get totalDiamantes => diamantesRecolectados + diamantesComprados;
  int get diamonds => totalDiamantes;

  void simularCompraIAP(int cantidad) {
    diamantesComprados += cantidad;
    notificarSeguro();
  }
  void buyDiamonds(int amount) => simularCompraIAP(amount);

  void dropDiamante() {
    final ganancia = GameConstants.dropMinDiamantes +
        _random.nextInt(GameConstants.dropMaxDiamantes - GameConstants.dropMinDiamantes + 1);
    diamantesRecolectados += ganancia;
    puntaje += 15;
    notificarSeguro();
  }

  // Estadísticas del jugador
  int nivelJugador = 1;
  double xpActual = 0.0;
  double xpObjetivo = 100.0;
  double vidaMax = 100.0;
  double vidaActual = 100.0;
  double velocidadMovimiento = 150.0;

  double get damageMultiplier => 1.0 + (nivelEspada + nivelArco + nivelMagia - 3) * 0.15;

  void aplicarDanioJugador(double cantidad) {
    vidaActual -= cantidad;
    if (vidaActual <= 0) {
      vidaActual = 0;
      terminarPartida();
    } else {
      notificarSeguro();
    }
  }

  // Armas y niveles
  int nivelEspada = 1;
  int get swordLevel => nivelEspada;
  set swordLevel(int val) {
    nivelEspada = val;
    notificarSeguro();
  }

  int nivelArco = 1;
  int get bowLevel => nivelArco;
  set bowLevel(int val) {
    nivelArco = val;
    notificarSeguro();
  }

  int nivelMagia = 1;
  int get fireMagicLevel => nivelMagia;
  set fireMagicLevel(int val) {
    nivelMagia = val;
    notificarSeguro();
  }

  final Random _random = Random();

  bool get esHordaActiva => tiempoPartida >= GameConstants.tiempoHordaMinuto6;
  double get multiplicadorEnemigo => esHordaActiva
      ? GameConstants.multiplicadorHordaMinuto6
      : (1.0 + (tiempoPartida / 450.0));

  void actualizarTiempo(double dt) {
    if (!enJuego || enPausa || finPartida) return;
    tiempoPartida += dt;

    if (tiempoPartida >= GameConstants.duracionMaximaPartida) {
      terminarPartida();
      return;
    }

    final segundoActual = tiempoPartida.toInt();
    if (segundoActual != _ultimoSegundoNotificado) {
      _ultimoSegundoNotificado = segundoActual;
      notificarSeguro();
    }
  }

  bool sumarXp(double cantidad) {
    xpActual += cantidad;
    if (xpActual >= xpObjetivo) {
      xpActual -= xpObjetivo;
      nivelJugador++;
      xpObjetivo = (xpObjetivo * 1.35).roundToDouble();
      notificarSeguro();
      return true;
    }
    notificarSeguro();
    return false;
  }

  void subirNivelArma(TipoArma arma) {
    switch (arma) {
      case TipoArma.espada:
        if (nivelEspada < GameConstants.maxWeaponLevel) nivelEspada++;
        break;
      case TipoArma.arco:
        if (nivelArco < GameConstants.maxWeaponLevel) nivelArco++;
        break;
      case TipoArma.magia:
        if (nivelMagia < GameConstants.maxWeaponLevel) nivelMagia++;
        break;
    }
    notificarSeguro();
  }

  void upgradeWeapon(dynamic weapon) {
    final str = weapon.toString().toLowerCase();
    if (str.contains('espada') || str.contains('sword')) {
      subirNivelArma(TipoArma.espada);
    } else if (str.contains('arco') || str.contains('bow')) {
      subirNivelArma(TipoArma.arco);
    } else if (str.contains('magia') || str.contains('fire') || str.contains('magic')) {
      subirNivelArma(TipoArma.magia);
    }
  }

  bool comprarMejoraTienda(String tipo, int costo) {
    if (totalDiamantes < costo) return false;

    if (diamantesRecolectados >= costo) {
      diamantesRecolectados -= costo;
    } else {
      final restante = costo - diamantesRecolectados;
      diamantesRecolectados = 0;
      diamantesComprados -= restante;
    }

    if (tipo == 'vida' || tipo == 'health') {
      vidaMax += 30.0;
      vidaActual = (vidaActual + 30.0).clamp(0.0, vidaMax);
    } else if (tipo == 'velocidad' || tipo == 'speed') {
      velocidadMovimiento += 25.0;
    }
    notificarSeguro();
    return true;
  }

  bool purchaseStatUpgrade(String stat, int cost) => comprarMejoraTienda(stat, cost);

  void notificarSeguro() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (hasListeners) {
        notifyListeners();
      }
    });
  }
}