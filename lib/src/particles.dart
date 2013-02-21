part of galaga_game;

class Particles extends GameEntity {
  Timer _deleteTimer;
  num _waiting = 0;
  
  Particles(Game game, num x, num y, num h, num w, num col, num xV, num yV) : super.withPosition(game, x, y, h, w) {
    
    opacity = random(.5, 1);
    
    if (col == 1)
      color = "204, 0, 51";
    if (col == 2)
      color = "102, 255, 51";
    if (col == 3)
      color = "51, 104, 204";
    if (col == 4)
      color = "105, 255, 105";
    if (col == 5)
      color = "204, 255, 51";
    if (col == 6)
      color = "255, 102, 153";
    if (col == 7)
      color = "255, 153, 51";
    
    momentum.yVel = yV;
    momentum.xVel = xV;
  }
  
  void update() {
    if (game.state == GalagaGameState.paused)
      return;
    
    _deleteTimer = new Timer.repeating(const Duration(milliseconds: 1000), (t) {    
        _waiting++;
      
      if (_waiting == 1) {
        removeFromGame();
        
        t.cancel();
      }
    });
    
    if (y > game.rect.halfHeight)
      removeFromGame();
    
    if (y < -game.rect.halfHeight)
      removeFromGame();
    
    if (x > game.rect.halfWidth)
      removeFromGame();
    
    if (x < -game.rect.halfWidth)
      removeFromGame();
    
    super.update();
  }
}

