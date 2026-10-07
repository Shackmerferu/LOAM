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

  // Arranca en BASIC; pasa a PRO solo con la compra simulada de la tienda.
  // No se persiste: al reiniciar/cerrar la app vuelve a BASIC.
  AccountType accountType = AccountType.basic;
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

  void comprarCuentaPro() {
    accountType = AccountType.pro;
    debugPrint('[DEBUG_ESTADO] Cuenta PRO activada (compra simulada)');
    notificarSeguro();
  }

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

  bool victoria = false;
  bool get isVictory => victoria;

  bool tiendaMinuto5Mostrada = false;

  void iniciarPartida() {
    debugPrint('[DEBUG_ESTADO] iniciarPartida() llamado');
    enJuego = true;
    enPausa = false;
    finPartida = false;
    victoria = false;
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
    diamantesRecolectados = 0;
    diamantesComprados = 0;
    vidasExtras = 0;
    nivelJugador = 1;
    xpActual = 0.0;
    xpObjetivo = 100.0;
    vidaMax = 150.0;
    vidaActual = 150.0;
    velocidadMovimiento = 150.0;
    asignarArmaInicialAleatoria();
    bonusDanioComprado = 0.0;
    mejorasDanioCompradas = 0;
    mejorasVelocidadCompradas = 0;
    mejorasSaludCompradas = 0;
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

  void ganarPartida() {
    debugPrint('[DEBUG_ESTADO] ganarPartida() llamado - 10 minutos completados');
    enJuego = false;
    enPausa = false;
    finPartida = false;
    victoria = true;
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

  /// Vidas extra compradas en la tienda simulada; consume una al morir.
  int vidasExtras = 0;

  void comprarVidaExtraSimulada() {
    vidasExtras += 1;
    debugPrint('[DEBUG_ESTADO] Vida extra comprada. Total: $vidasExtras');
    notificarSeguro();
  }

  void simularCompraIAP(int cantidad) {
    diamantesComprados += cantidad;
    notificarSeguro();
  }
  void buyDiamonds(int amount) => simularCompraIAP(amount);

  void dropDiamante([int cantidad = GameConstants.dropMinDiamantes]) {
    diamantesRecolectados += cantidad;
    puntaje += 15;
    notificarSeguro();
  }

  // Estadísticas del jugador
  int nivelJugador = 1;
  double xpActual = 0.0;
  double xpObjetivo = 100.0;
  double vidaMax = 150.0;
  double vidaActual = 150.0;
  double velocidadMovimiento = 150.0;
  double bonusDanioComprado = 0.0;
  int mejorasDanioCompradas = 0;
  int mejorasVelocidadCompradas = 0;
  int mejorasSaludCompradas = 0;

  double get damageMultiplier =>
      1.0 +
      (nivelEspada + nivelArco + nivelMagia - 3) * 0.15 +
      bonusDanioComprado;

  void aplicarDanioJugador(double cantidad) {
    vidaActual -= cantidad;
    if (vidaActual <= 0) {
      if (vidasExtras > 0) {
        // Vida extra: revive con la barra completa en lugar de morir.
        vidasExtras--;
        vidaActual = vidaMax;
        debugPrint('[DEBUG_ESTADO] Vida extra consumida. Restantes: $vidasExtras');
        notificarSeguro();
        return;
      }
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
      tiempoPartida = GameConstants.duracionMaximaPartida;
      ganarPartida();
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

  int costoMejora(String tipo) {
    final normalizado = tipo.toLowerCase();
    late final int costoBase;
    late final int compras;

    if (normalizado == 'damage' || normalizado == 'dano' || normalizado == 'daño') {
      costoBase = GameConstants.costoMejoraDanio;
      compras = mejorasDanioCompradas;
    } else if (normalizado == 'velocidad' || normalizado == 'speed') {
      costoBase = GameConstants.costoMejoraVelocidad;
      compras = mejorasVelocidadCompradas;
    } else if (normalizado == 'vida' || normalizado == 'health') {
      costoBase = GameConstants.costoMejoraSalud;
      compras = mejorasSaludCompradas;
    } else {
      throw ArgumentError.value(tipo, 'tipo', 'Tipo de mejora desconocido');
    }

    var costo = costoBase;
    for (var i = 0; i < compras; i++) {
      if (costo > 0x7fffffffffffffff ~/ GameConstants.multiplicadorCostoMejora) {
        return 0x7fffffffffffffff;
      }
      costo *= GameConstants.multiplicadorCostoMejora;
    }
    return costo;
  }

  bool comprarMejoraTienda(String tipo, int costo) {
    final normalizado = tipo.toLowerCase();
    if (normalizado != 'damage' &&
        normalizado != 'dano' &&
        normalizado != 'daño' &&
        normalizado != 'velocidad' &&
        normalizado != 'speed' &&
        normalizado != 'vida' &&
        normalizado != 'health') {
      return false;
    }

    final costoActual = costoMejora(normalizado);
    if (costo != costoActual || totalDiamantes < costoActual) return false;

    if (diamantesRecolectados >= costoActual) {
      diamantesRecolectados -= costoActual;
    } else {
      final restante = costoActual - diamantesRecolectados;
      diamantesRecolectados = 0;
      diamantesComprados -= restante;
    }

    if (normalizado == 'vida' || normalizado == 'health') {
      vidaMax += GameConstants.mejoraSaludPorCompra;
      vidaActual = (vidaActual + GameConstants.mejoraSaludPorCompra).clamp(
        0.0,
        vidaMax,
      );
      mejorasSaludCompradas++;
    } else if (normalizado == 'velocidad' || normalizado == 'speed') {
      velocidadMovimiento += GameConstants.mejoraVelocidadPorCompra;
      mejorasVelocidadCompradas++;
    } else {
      bonusDanioComprado += GameConstants.mejoraDanioPorCompra;
      mejorasDanioCompradas++;
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