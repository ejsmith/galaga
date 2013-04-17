part of galaga_game;

class bouncingBall extends GameEntity {
  num Sprite = 0;
  
  bouncingBall(Game game, num x, num y, num h, num w, num sprite) : super.withPosition(game, x, y, h, w) {
    Sprite = sprite;
    
    opacity = 0.0;
    
    momentum.yVel = random(-200, 200);
    momentum.xVel = random(-200, 200);
  }
  
  void update() {
    if (game.state != GalagaGameState.instructions)
      removeFromGame();
    
    if (y > game.rect.halfHeight) {
      momentum.yVel *= -1;
    }
    
    if (y < -(game.rect.halfHeight)) {
      momentum.yVel *= -1;
    }
    
    if (x > game.rect.halfWidth) {
      momentum.xVel *= -1;
    }
    
    if (x < -(game.rect.halfWidth)) {
      momentum.xVel *= -1;
    }
    
    super.update();
  }
}

