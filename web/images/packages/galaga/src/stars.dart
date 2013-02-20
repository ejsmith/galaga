part of galaga_game;

class Stars extends GameEntity {
  
  Stars(Game game, num x, num y, num h, num w, num col) : super.withPosition(game, x, y, h, w) {
    
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
    
    momentum.yVel = random(50, 75);
  }
  
  void update() {
    if (game.state == GalagaGameState.paused)
      return;
    
    if (y > game.rect.halfWidth)
      removeFromGame();
    
    super.update();
  }
}