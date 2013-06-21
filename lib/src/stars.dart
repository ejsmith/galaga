part of galaga_game;

class Stars extends GameEntity {
  num starColor = 1;

  Stars(Game game, num x, num y, num h, num w, num col) : super.withPosition(game, x, y, h, w) {

    opacity = 0;

    starColor = random(1, 7);
    starColor = starColor.ceil();

    //print("${starColor}");

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