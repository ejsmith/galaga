part of galaga_game;

class Ship extends GameEntity<GalagaGame> {
  num bulletPower = 8;
  num bullet = 3;
  num maxBullet = 3;
  num bulletsFired = 0;
  num bulletsHit = 0;
  num lives = 3;
  num soundLevel = 0;
  num chargedLevel = 0;
  num superCharged = 0;
  bool isPoweringUp = false;
  bool spiralShot = false;
  num lastShotFired = 0;
  num _spreadWaiting = 0;
  Timer _invincibleTimer;

  Ship(Game game, num x, num y) : super.withPosition(game, x, y, 36, 36) {
    opacity = 0.2;

    maxBullet = 3;
    bullet = maxBullet;
  }


  num get spreadWaiting => _spreadWaiting;


  void update() {
    if (game.state == GalagaGameState.paused || game.state == GalagaGameState.gameOver || game.state == GalagaGameState.welcome)
      return;

    width = 32;
    height = 32;
    opacity = 0.0;

    if (width > 36 || height > 36) {
      width = 36;
      height = 36;
    }

    if (lives <= 0) {
      game.p1Dead = true;

      removeFromGame();
      game.gameOver();
    }

    if (game.Cheats["spreadshot"] == 1)
      spiralShot = true;

    if (spiralShot == true && game.Cheats["spreadshot"] != 1) {
      _invincibleTimer = new Timer(const Duration(milliseconds: 15000), () {
        _spreadWaiting++;
        spiralShot = false;
      });
    }

    if (game.Options["controls"] == 1) {
      if (game.input.isKeyDown(37))
        momentum.xVel = -250;
      else if (game.input.isKeyDown(39))
        momentum.xVel = 250;
      else
        momentum.xVel = 0;
    }

    if (bullet > maxBullet)
      bullet = maxBullet;

    if (bullet < 0)
      bullet = 0;

    if (game.state == GalagaGameState.welcome)
      return;

    if (game.input.mouse != null && game.Options["controls"] == 2) {
      x = game.input.mouse.x;
    }

    if (x + 16 > game.rect.halfWidth)
      x = game.rect.halfWidth - 16;

    if (x - 16 < -(game.rect.halfWidth))
      x = -(game.rect.halfWidth) + 16;

    if (chargedLevel >= 15) {
      superCharged++;
      chargedLevel = 0;
    }

  if (bullet > 0) {
    if (game.input.isKeyJustPressed(32) && game.Options["controls"] == 1)
      fire();

    if (game.input.click != null && game.Options["controls"] == 2)
      fire();

    if ((game.Cheats["super"] == 1 && game.input.isKeyJustPressed(16)) || (game.input.isKeyJustPressed(16) && superCharged > 0 && game.Options["controls"] == 1))
      superFire();

    if ((game.Cheats["super"] == 1 && game.input.isKeyJustPressed(32)) || (game.input.isKeyJustPressed(32) && superCharged > 0 && game.Options["controls"] == 2))
      superFire();
    }

    super.update();
  }

  void superFire() {
    game.addEntity(new Bullet(game, x - 25, y - 30, "straight", -350, bulletPower, "super"));
    superCharged--;
  }

  void fire() {
    soundLevel = bulletPower * .02;

    if (soundLevel > 1)
      soundLevel = 1;

    if (spiralShot) {
      game.addEntity(new Bullet(game, x, y - 30, "straight", -350, bulletPower, "normal"));
      game.addEntity(new Bullet(game, x, y - 30, "right", -350, bulletPower, "normal"));
      game.addEntity(new Bullet(game, x, y - 30, "left", -350, bulletPower, "normal"));
      game.Stats["bulletsHit"] += 3;
    } else {
      game.addEntity(new Bullet(game, x, y - 30, "straight", -350, bulletPower, "normal"));
      game.Stats["bulletsHit"]++;
    }

    if (bullet > 0)
      bullet--;
  }
}
