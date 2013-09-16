part of galaga_game;

class PowerUp extends GameEntity<GalagaGame> {
  String type;
  Timer _deactivate;

  PowerUp(GalagaGame game, num x, num y, [String Type = null]) : super.withPosition(game, x, y, 36, 36) {
    num rType = random();

    if (rType < game.magnet) {
      color = "0, 255, 0";
      type = 'magnet';
    } else if (rType < game.teleporter) {
      color = "0, 255, 0";
      type = 'teleporter';
    } else if (rType < game.spiral) {
      color = "0, 255, 0";
      type = 'SpiralShot';
    } else if (rType < game.multi) {
      color = "255, 0, 0";
      type = 'Multiplier';
    } else if (rType < game.bullet) {
      color = "0, 0, 255";
      type = 'BulletIncrease';
    } else if (rType < game.invincible) {
      color = "0, 255, 255";
      type = 'invincible';
    } else if (rType < game.time) {
      color = "0, 255, 255";
      type = 'timeUp';
    } else if (rType < game.life) {
      color = "255, 255, 0";
      type = 'ExtraLife';
    } else if (rType < game.death) {
      color = "255, 255, 0";
      type = 'Death';
    }

    if (Type != null) {
      type = Type;

      if (type == "bulletPower") {
        num rColor = random();

        if (rColor < .2)
          color = "0, 255, 0";
        else if (rColor < .4)
          color = "0, 255, 255";
        else if (rColor < .6)
          color = "0, 0, 255";
        else if (rColor < .1)
          color = "255, 255, 0";

        width = 12;
        height = 12;
      }
    }

    opacity = 0.0;

    momentum.yVel = 65;
  }

  void update() {
    if (game.state == GalagaGameState.paused || game.state == GalagaGameState.gameOver || game.state == GalagaGameState.welcome)
      return;

    if (game.Cheats["magnet"] == 1) {
      if (game.ship.x > x)
        momentum.xVel = 40;
      else
        momentum.xVel = -40;
    } else if (game.Cheats["magnet"] == 2) {
      if (game.ship.x > x)
        momentum.xVel = 60;
      else
        momentum.xVel = -60;
    } else if (game.Cheats["magnet"] == 3) {
      if (game.ship.x > x)
        momentum.xVel = 80;
      else
        momentum.xVel = -80;
    } else if (game.Cheats["magnet"] == 4) {
      if (game.ship.x > x)
        momentum.xVel = 100;
      else
        momentum.xVel = -100;
    } else if (game.Cheats["magnet"] >= 5) {
      if (game.ship.x > x)
        momentum.xVel = 120;
      else
        momentum.xVel = -120;
    }

    if (collidesWith(game.ship)) {
      switch (type) {
        case 'SpiralShot':
          if (game.ship.spiralShot)
            game.ship.spiralShot = false;
          if (!game.ship.spiralShot)
            game.ship.spiralShot = true;

          game.Stats["powerups"] += 1;
          game.score += 300 * game.pointMultiplier;

          new Timer(const Duration(milliseconds: 1000), () => game.rendererTemp2--);
          new Timer(const Duration(milliseconds: 2000), () => game.rendererTemp2--);
          new Timer(const Duration(milliseconds: 3000), () => game.rendererTemp2--);
          new Timer(const Duration(milliseconds: 4000), () => game.rendererTemp2--);
          new Timer(const Duration(milliseconds: 5000), () => game.rendererTemp2--);
          new Timer(const Duration(milliseconds: 6000), () => game.rendererTemp2--);
          new Timer(const Duration(milliseconds: 7000), () => game.rendererTemp2--);
          new Timer(const Duration(milliseconds: 8000), () => game.rendererTemp2--);
          new Timer(const Duration(milliseconds: 9000), () => game.rendererTemp2--);
          new Timer(const Duration(milliseconds: 10000), () => game.rendererTemp2--);
          new Timer(const Duration(milliseconds: 11000), () => game.rendererTemp2--);
          new Timer(const Duration(milliseconds: 12000), () => game.rendererTemp2--);
          new Timer(const Duration(milliseconds: 13000), () => game.rendererTemp2--);
          new Timer(const Duration(milliseconds: 14000), () => game.rendererTemp2--);
          new Timer(const Duration(milliseconds: 15000), () => game.rendererTemp2--);
          break;
        case 'Multiplier':
          game.pointMultiplier *= 2;
          game.Stats["powerups"] += 1;
          game.score += 300 * game.pointMultiplier;
          break;
        case 'BulletIncrease':
          game.ship.maxBullet++;
          game.Stats["powerups"] += 1;
          game.score += 300 * game.pointMultiplier;
          break;
        case 'ExtraLife':
          game.ship.lives++;
          game.Stats["powerups"] += 1;
          game.score += 300 * game.pointMultiplier;
          break;
        case 'bulletPower':
          game.score += 100 * game.pointMultiplier;
          game.ship.chargedLevel++;
          break;
        case 'invincible':
          game.score += 300 * game.pointMultiplier;
          if (game.Cheats["invincibility"] != 1) {
            game.Cheats["invincibility"] = 1;

            _deactivate = new Timer(const Duration(milliseconds: 5000), () {
              game.Cheats["invincibility"] = 0;
            });

            new Timer(const Duration(milliseconds: 1000), () => game.rendererTemp1--);
            new Timer(const Duration(milliseconds: 2000), () => game.rendererTemp1--);
            new Timer(const Duration(milliseconds: 3000), () => game.rendererTemp1--);
            new Timer(const Duration(milliseconds: 4000), () => game.rendererTemp1--);
            new Timer(const Duration(milliseconds: 5000), () => game.rendererTemp1--);
          }

          break;
        case 'timeUp':
            game.timer.gameTime += 15;
            game.Stats["powerups"] += 1;
            game.score += 300 * game.pointMultiplier;
          break;
        case 'teleporter':
          game.entities.where((e) => e is Enemy).forEach((Enemy e) {
            e.removeFromGame();
            game.enemyAmount--;
          });
          game.Stats["powerups"] += 1;
          game.score += 300 * game.pointMultiplier;
          break;
        case 'magnet':
          game.Cheats["magnet"]++;
          game.Stats["powerups"] += 1;
          game.score += 300 * game.pointMultiplier;
          break;
        case 'Death':
          game.ship.lives--;

          game.Stats["powerups"] += 1;
          game.score -= 300 * game.pointMultiplier;
          break;
      }

      removeFromGame();
    }

    if (y > game.rect.halfHeight + 20)
      removeFromGame();

    super.update();
  }
}