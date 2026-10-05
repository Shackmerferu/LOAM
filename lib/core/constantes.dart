class GameConstants {
  // Tiempos de partida (en segundos)
  static const double matchDuration = 600.0; // 10 minutos
  static const double storeInterval = 300.0; // 5 minutos
  static const double hordeEventTime = 360.0; // 6 minutos

  // Mecánicas de horda especial (Minuto 6)
  static const double hordeStatMultiplier = 2.5;
  static const double arenaSquareSize = 400.0; // Tamaño del área delimitada

  // Spawner de enemigos
  static const int minEnemies = 10;
  static const int maxEnemies = 15;
  static const double spawnRadius = 350.0;

  // Economía y recompensas
  static const int minDiamondDrop = 10;
  static const int maxDiamondDrop = 100;

  // Sistema de armas
  static const int maxWeaponLevel = 7; // Umbral de evolución a mejora especial

  // Valores predeterminados del jugador
  static const double playerBaseSpeed = 150.0;
  static const double playerBaseHp = 100.0;
}