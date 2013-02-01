part of galaga_game;

class Bullet extends GameEntity<GalagaGame> {
  num temp = 0;
  num startX = 0;
  bool right = false;
  bool left = false;
  bool straight = false;
  
  Bullet(GalagaGame game, num x, num y, String dir, num yVel, num size) : super.withPosition(game, x, y, size, size) {
    color = "255, 0, 0";
    momentum.yVel = yVel;
    startX = x;
    
    if (dir == "right")
      right = true;
    else if (dir == "left")
      left = true;
    else if (dir == "straight")
      straight = true;
    
    if (size >= 36)
      size = 36;
  }
  
  void update() {
    if (game.state == GalagaGameState.paused || game.state == GalagaGameState.gameOver || game.state == GalagaGameState.welcome)
      return;
    
    super.update();
    
    if (right)
      momentum.xVel = 40;
    else if (left)
      momentum.xVel = -40;
    else if (straight)
      momentum.xVel = 0;
    
    if (width <= 0 || height <= 0) {
      if (momentum.yVel > 0) {
        game.score += 100;
      }
      
      removeFromGame();
    }
    
    if (game.ship.spiralShot && right && startX < (x - (width / 2)) - 25) {
      right = false;
      left = true;
    } else if (game.ship.spiralShot && left && startX > (x + (width / 2)) + 25) {
      left = false;
      right = true;
    }
    
    if (y < -(game.rect.halfHeight)) {
      if (game.ship.bullet < 3)
        game.ship.bullet++;
      
      removeFromGame();
    }
    
    if (momentum.yVel != 0) {
      game.entities.where((e) => e is Bullet && collidesWith(e)).toList().forEach((e) {
        if (width > e.width && height > e.height && (e.x != x && e.y != y)) {
          width -= e.width;
          height -= e.height;
          e.removeFromGame();
        }
      });
    }
    
    if (momentum.yVel < 0) {
      game.entities.where((e) => e is Enemy && collidesWith(e)).toList().forEach((e) {
        var enemy = e as Enemy;
        
        if (width > enemy.width && height > enemy.height) {
          width -= enemy.width;
          height -= enemy.height;
        } else
          removeFromGame();
        
        if (game.ship.bullet < 3)
          game.ship.bullet++;
        
        if (game.soundEffectsOn)
          game.sound.play("enemyHit", .5);
        
        if (enemy.type != "MotherShip")
          game._motherShipEvent.signal();
        
        if (enemy.type != "Boss") {
          if (random() > .5)
            game.newBulletPowerUp(e.x, e.y);
          
          enemy.width -= 8;
          enemy.height -= 8;
          
          game._bossHitEvent.signal();
        }
        
        enemy.health--;
      });
    }
    
    if (momentum.yVel > 0) {
      game.entities.where((e) => e is Ship && collidesWith(e)).toList().forEach((e) {
        game.ship.lives -= 1;
        
        game._shipHitEvent.signal();
        game._gameOverEvent.signal();
        
        if (game.soundEffectsOn)
          game.sound.play("shipHit", .5);
        
        game.removeBullets();
        
        game.ship.bullet = game.ship.maxBullet;
      });
    }
  }
}