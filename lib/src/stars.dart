part of galaga_game;

class Stars extends GameEntity {
  num starColor = 1;

  Stars(Game game, num x, num y, num h, num w, num col) : super.withPosition(game, x, y, h, w) {

    opacity = 0;

    if (col == 1)
      starColor = 1;
    if (col == 2)
      starColor = 2;
    if (col == 3)
      starColor = 3;
    if (col == 4)
      starColor = 4;
    if (col == 5)
      starColor = 5;
    if (col == 6)
      starColor = 6;
    if (col == 7)
      starColor = 7;

    momentum.yVel = random(50, 150);
  }

  void update() {
    if (game.state == GalagaGameState.paused)
      return;

    if (y > game.rect.halfHeight)
      removeFromGame();

    super.update();
  }
}