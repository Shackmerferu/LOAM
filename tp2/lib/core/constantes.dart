import 'package:flutter/material.dart';

class GameConstants {
  // Tiempos (segundos)
  static const double duracionMaximaPartida = 600.0;
  static const double tiempoTiendaMinuto5 = 300.0;
  static const double tiempoHordaMinuto6 = 360.0;

  // Horda y área
  static const int minEnemigos = 10;
  static const int maxEnemigos = 15;
  static const double multiplicadorHordaMinuto6 = 2.5;
  static const double tamanoAreaRestringida = 360.0;

  // Progresión y armas
  static const int maxWeaponLevel = 7;
  static const int nivelEvolucionArma = maxWeaponLevel;

  // Economía
  static const int dropMinDiamantes = 10;
  static const int dropMaxDiamantes = 100;
  static const int penalizacionDiamantesMuerte = 50;

  // Paleta de colores para la UI
  static const Color fondoOscuro = Color(0xFF110E1B);
  static const Color fondoClaro = Color(0xFFECEFF4);
  static const Color superficieOscura = Color(0xFF1E1A2E);
  static const Color superficieClara = Color(0xFFFFFFFF);
  static const Color acentoMagico = Color(0xFF8A3FFC);
  static const Color acentoDiamante = Color(0xFF00E5FF);
}
