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
  bool superSpiral = false;
  num lastShotFired = 0;

  Ship(Game game, num x, num y) : super.withPosition(game, x, y, 36, 36) {
    opacity = 0.2;

    maxBullet = this.game.Options["bulletCap"];
    bullet = maxBullet;
  }

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
      game.Stats["loses"] += 1;
      game.p1Dead = true;

      removeFromGame();

      game.gameOver();
    }
    
    if (game.input.isKeyDown(37))
      momentum.xVel = -250;
    else if (game.input.isKeyDown(39))
      momentum.xVel = 250;
    else
      momentum.xVel = 0;

    if (bullet > maxBullet)
      bullet = 3;

    if (bullet < 0)
      bullet = 0;

    if (game.state == GalagaGameState.welcome)
      return;

//    if (game.input.mouse != null) {
//      x = game.input.mouse.x;
//    }

    if (x + 16 > game.rect.halfWidth)
      x = game.rect.halfWidth - 16;

    if (x - 16 < -(game.rect.halfWidth))
      x = -(game.rect.halfWidth) + 16;

    if (chargedLevel >= 15) {
      superCharged++;
      chargedLevel = 0;
    }

    if (bullet > 0) {
//      if (game.input.mouseDown)
//        isPoweringUp = true;
    
    if (game.input.isKeyJustPressed(32) || game.input.click != null)
      fire();
    
//      if (isPoweringUp)
//        bulletPower += .25;
    }
    
    super.update();
  }

  void superFire() {
    game.addEntity(new Bullet(game, x, y, "straight", -350, bulletPower, "super"));
    superCharged--;
  }

  void fire() {
    if (superCharged > 0)
      return superFire();
    
    soundLevel = bulletPower * .02;

    if (soundLevel > 1)
      soundLevel = 1;

    if (superSpiral) {
      game.addEntity(new Bullet(game, x, y, "straight", -350, bulletPower));
      game.addEntity(new Bullet(game, x, y, "right", -350, bulletPower));
      game.addEntity(new Bullet(game, x, y, "left", -350, bulletPower));
      game.addEntity(new Bullet(game, x, y, "right", -350, bulletPower));
      game.addEntity(new Bullet(game, x, y, "left", -350, bulletPower));
    }
    
    if (spiralShot) {
      game.addEntity(new Bullet(game, x, y, "straight", -350, bulletPower));
      game.addEntity(new Bullet(game, x, y, "right", -350, bulletPower));
      game.addEntity(new Bullet(game, x, y, "left", -350, bulletPower));
      bulletsFired += 3;

      if (game.soundEffectsOn)
        game.shipFire.play(game.shipFire.Sound, game.shipFire.Volume, game.shipFire.Looping);
    } else {
      game.addEntity(new Bullet(game, x, y, "straight", -350, bulletPower));
      bulletsFired++;
      if (game.soundEffectsOn)
        game.shipFire.play(game.shipFire.Sound, game.shipFire.Volume, game.shipFire.Looping);
    }

    if (bullet > 0)
      bullet--;
  }
}
