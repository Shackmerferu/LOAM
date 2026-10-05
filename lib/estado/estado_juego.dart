import 'package:flutter/material.dart';
import '../core/constantes.dart';

enum AccountType { basic, pro }

class GameState extends ChangeNotifier {
  String username = 'Luciano';
  AccountType accountType = AccountType.basic;
  bool isDarkMode = true;

  bool isPlaying = false;
  bool isPaused = false;
  bool isGameOver = false;

  int score = 0;
  int diamonds = 0;
  double gameTime = 0.0;

  double playerHp = 100.0;
  double playerMaxHp = 100.0;
  double playerSpeed = 150.0;

  int swordLevel = 1;
  int bowLevel = 1;
  int fireMagicLevel = 1;
  double damageMultiplier = 1.0;

  bool get isHordeActive => gameTime >= 300.0;

  void startGame() {
    isPlaying = true;
    isPaused = false;
    isGameOver = false;
    notifyListeners();
  }

  void pauseGame() {
    isPaused = true;
    notifyListeners();
  }

  void resumeGame() {
    isPaused = false;
    notifyListeners();
  }

  void endGame() {
    isPlaying = false;
    isGameOver = true;
    notifyListeners();
  }

  void resetGame() {
    score = 0;
    diamonds = 0;
    gameTime = 0.0;
    playerHp = 100.0;
    playerMaxHp = 100.0;
    playerSpeed = 150.0;
    swordLevel = 1;
    bowLevel = 1;
    fireMagicLevel = 1;
    damageMultiplier = 1.0;
    isPlaying = false;
    isPaused = false;
    isGameOver = false;
    notifyListeners();
  }

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }

  void switchAccountType() {
    accountType = accountType == AccountType.basic ? AccountType.pro : AccountType.basic;
    notifyListeners();
  }

  void addScore(int amount) {
    score += amount;
    notifyListeners();
  }

  void addDiamonds(int amount) {
    diamonds += amount;
    notifyListeners();
  }

  void buyDiamonds(int amount) {
    diamonds += amount;
    notifyListeners();
  }

  void updateGameTime(double dt) {
    gameTime += dt;
    notifyListeners();
  }

  void upgradeWeapon(String weaponType) {
    switch (weaponType) {
      case 'sword':
        if (swordLevel < GameConstants.maxWeaponLevel) swordLevel++;
        break;
      case 'bow':
        if (bowLevel < GameConstants.maxWeaponLevel) bowLevel++;
        break;
      case 'fireMagic':
        if (fireMagicLevel < GameConstants.maxWeaponLevel) fireMagicLevel++;
        break;
    }
    notifyListeners();
  }

  bool purchaseStatUpgrade(String type, int cost) {
    if (diamonds < cost) return false;
    diamonds -= cost;

    switch (type) {
      case 'damage':
        damageMultiplier += 0.25;
        break;
      case 'speed':
        playerSpeed += 25.0;
        break;
      case 'health':
        playerMaxHp += 20.0;
        playerHp = (playerHp + 20.0).clamp(0.0, playerMaxHp);
        break;
    }
    notifyListeners();
    return true;
  }
}