part of galaga_game;

class Ship extends GameEntity<GalagaGame> {
  num bulletPower = 8;
  num bullet = 3;
  num maxBullet = 3;
  num lives = 3;
  num soundLevel = 0;
  bool isPoweringUp = false;
  bool spiralShot = false;
  bool superSpiral = false;
  
  Ship(Game game, num x, num y) : super.withPosition(game, x, y, 36, 36) {
    opacity = 0.2;
    
    maxBullet = this.game.Options["bulletCap"];
    bullet = maxBullet;
  }
  
  void update() {
    if (game.state == GalagaGameState.paused || game.state == GalagaGameState.gameOver || game.state == GalagaGameState.welcome)
      return;
     
    width = 10 * lives;
    height = 10 * lives;
    
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
    
    if (bullet > maxBullet)
      bullet = 3;
    
    if (bullet < 0)
      bullet = 0;
    
    if (game.state == GalagaGameState.welcome)
      return;
    
    if (game.input.mouse != null) {
      x = game.input.mouse.x;
    }
    
    if (x + 16 > game.rect.halfWidth)
      x = game.rect.halfWidth - 16;
    
    if (x - 16 < -(game.rect.halfWidth))
      x = -(game.rect.halfWidth) + 16;
    
    if (bullet > 0) {
//      if (game.input.mouseDown)
//        isPoweringUp = true;
      
      if (game.input.click != null)
        fire();
      
//      if (isPoweringUp)
//        bulletPower += .25;
    }
    
    super.update();
  }
  
  void fire() {
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
      if (game.soundEffectsOn)
        game.sound.play("shipFire", soundLevel);
    } else {
      game.addEntity(new Bullet(game, x, y, "straight", -350, bulletPower));
      if (game.soundEffectsOn)
        game.sound.play("shipFire", soundLevel);
    }
    
    if (bullet > 0)
      bullet--;
  }
  
  void fade() {
//    opacity = 0.5;
//    html.window.setTimeout(() { opacity = 0.4;}, 50);
//    html.window.setTimeout(() { opacity = 0.3;}, 100);
//    html.window.setTimeout(() { opacity = 0.2;}, 150);
  }
}
