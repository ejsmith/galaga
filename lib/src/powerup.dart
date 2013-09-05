part of galaga_game;

class PowerUp extends GameEntity<GalagaGame> {
  String type;
  Timer _deactivate;

  PowerUp(GalagaGame game, num x, num y, [String Type = null]) : super.withPosition(game, x, y, 36, 36) {
    num rType = random();

    if (rType < game.teleporter) {
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

    if (type == "bulletPower")
      if (game.ship.x > x)
        momentum.xVel = 40;
      else
        momentum.xVel = -40;

    if (collidesWith(game.ship)) {
      switch (type) {
        case 'SpiralShot':
          if (game.ship.spiralShot)
            game.ship.spiralShot = false;
          if (!game.ship.spiralShot)
            game.ship.spiralShot = true;

          game.Stats["powerups"] += 1;
          game.score += 300 * game.pointMultiplier;
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
          break;
        case 'teleporter':
          game.entities.where((e) => e is Enemy).forEach((Enemy e) {
            e.removeFromGame();
            game.enemyAmount--;
          });

          new Timer(const Duration(milliseconds: 1000), () => game.rendererTemp2--);
          new Timer(const Duration(milliseconds: 2000), () => game.rendererTemp2--);
          new Timer(const Duration(milliseconds: 3000), () => game.rendererTemp2--);
          new Timer(const Duration(milliseconds: 4000), () => game.rendererTemp2--);
          new Timer(const Duration(milliseconds: 5000), () => game.rendererTemp2--);

          break;
      }

      removeFromGame();
    }

    if (y > game.rect.halfHeight + 20)
      removeFromGame();

    super.update();
  }
}