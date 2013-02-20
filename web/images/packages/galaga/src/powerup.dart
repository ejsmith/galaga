part of galaga_game;

class PowerUp extends GameEntity<GalagaGame> {
  String type;
  num creationTime = 0;
  
  PowerUp(GalagaGame game, num x, num y, [String Type = null]) : super.withPosition(game, x, y, 36, 36) {
    num rType = random();
    creationTime = game.timer.gameTime;
    
    if (rType < .2) {
      color = "0, 255, 0";
      type = 'SpiralShot';
    } else if (rType < .4) {
      color = "255, 0, 0";
      type = 'Multiplier';
    } else if (rType < .6) {
      color = "0, 0, 255";
      type = 'BulletIncrease';
    } else if (rType < 1) {
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
    
    momentum.yVel = 65;
  }
  
  void update() {
    if (game.state == GalagaGameState.paused || game.state == GalagaGameState.gameOver || game.state == GalagaGameState.welcome)
      return;
    
    if (type == "bulletPower") {
      if (game.ship.x > x)
        momentum.xVel = 40;
      else 
        momentum.xVel = -40;
    }
    
    if (collidesWith(game.ship)) {
      switch (type) {
        case 'SpiralShot':
          SpiralUpdate();
          break;
        case 'Multiplier':
          game.pointMultiplier *= 2;
          break;
        case 'BulletIncrease':
          game.ship.maxBullet++;
          break;
        case 'ExtraLife':
          game.ship.lives++;
          break;
        case 'bulletPower':
          game.ship.bulletPower += 1;
          break;
      }
      
      if (game.soundEffectsOn)
        game.sound.play("powerUp");
      removeFromGame();
    }
    
    if (y > game.rect.halfHeight + 20)
      removeFromGame();
   
    super.update();
  }
  
  void SpiralUpdate() {
    game.score += 100 * game.pointMultiplier;
    game.ship.spiralShot = true;
  }
  
}