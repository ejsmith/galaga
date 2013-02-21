part of galaga_game;

class Bullet extends GameEntity<GalagaGame> {
  num temp = 0;
  num startX = 0;
  String Type;
  Timer _deleteTimer;
  num _waiting = 0;
  bool farRight = false;
  bool farLeft = false;
  bool right = false;
  bool left = false;
  bool straight = false;
  
  Bullet(GalagaGame game, num x, num y, String dir, num yVel, num size, [String type = "normal"]) : super.withPosition(game, x, y, size, size) {
    color = "255, 0, 0";
    momentum.yVel = yVel;
    startX = x;
    
    if (dir == "right")
      right = true;
    else if (dir == "left")
      left = true;
    else if (dir == "straight")
      straight = true;
    else if (dir == "farLeft")
      farLeft = true;
    else if (dir == "farRight")
      farRight = true;
    
    Type = type;
    
    if (size >= 36)
      size = 36;
  }
  
  void update() {
    if (game.state == GalagaGameState.paused || game.state == GalagaGameState.gameOver || game.state == GalagaGameState.welcome)
      return;
    
    super.update();
    
    if (Type == "exploding") {
        _deleteTimer = new Timer.repeating(const Duration(milliseconds: 1000), (t) {    
          _waiting++;
        
        if (_waiting == 1) {
          game.newMiniExplosion(x, y);
          
          game.addEntity(new Bullet(game, x, y + 16, "straight", random(350,400), random(8,16), "normal"));
          game.addEntity(new Bullet(game, x, y + 16, "left", random(350,400), random(8,16), "normal"));
          game.addEntity(new Bullet(game, x, y + 16, "right", random(350,400), random(8,16), "normal"));
          game.addEntity(new Bullet(game, x, y + 16, "farLeft", random(350,400), random(8,16), "normal"));
          game.addEntity(new Bullet(game, x, y + 16, "farRight", random(350,400), random(8,16), "normal"));
          removeFromGame();
          
          t.cancel();
        }
      });
    }
    
    if (right)
      momentum.xVel = 40;
    else if (left)
      momentum.xVel = -40;
    else if (straight)
      momentum.xVel = 0;
    else if (farLeft)
      momentum.xVel = -60;
    else if (farRight)
      momentum.xVel = 60;
    
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
    } else if (game.ship.spiralShot && farLeft && startX > (x + (width / 2)) + 40) {
      farLeft = false;
      farRight = true;
    } else if (game.ship.spiralShot && farRight && startX > (x + (width / 2)) + 40) {
      farRight = false;
      farLeft = true;
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
      game.entities.where((e) => e is Enemy && collidesWith(e)).toList().forEach((Enemy enemy) {
        if (width > enemy.width && height > enemy.height) {
          width -= enemy.width;
          height -= enemy.height;
        } else
          removeFromGame();
        
        game.targetId = enemy.idNum;
        
        if (game.ship.bullet < 3)
          game.ship.bullet++;
        
        if (game.soundEffectsOn)
          game.sound.play("enemyHit", .5);
        
        if (enemy.type == "MotherShip") {
          game._motherShipEvent.signal();
        } else if (enemy.type == "Boss")
          game._bossHitEvent.signal();
        else if (enemy.type == "Normal")
          game._normalHitEvent.signal();
        
        if (enemy.type != "Boss") {
          enemy.width -= 8;
          enemy.height -= 8;
        }
        
        enemy.health--;
      });
    }
    
    if (momentum.yVel > 0) {
      game.entities.where((e) => e is Ship && collidesWith(e)).toList().forEach((e) {
        game.ship.lives -= 1;
        
        game._shipHitEvent.signal();
        
        if (game.soundEffectsOn)
          game.sound.play("shipHit", .5);
        
        game.removeBullets();
        
        game.ship.bullet = game.ship.maxBullet;
      });
    }
  }
}