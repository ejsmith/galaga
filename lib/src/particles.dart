part of galaga_game;

class Particles extends GameEntity {
  Timer _deleteTimer;
  num _waiting = 0;

  Particles(Game game, num x, num y, num h, num w, num col, num xVel, num yVel) : super.withPosition(game, x, y, h, w) {

    opacity = random(.5, 1);

    if (col == 1)
      color = "200, 0, 50";
    if (col == 2)
      color = "100, 255, 50";
    if (col == 3)
      color = "20, 100, 200";
    if (col == 4)
      color = "105, 255, 100";
    if (col == 5)
      color = "200, 255, 50";
    if (col == 6)
      color = "255, 100, 150";
    if (col == 7)
      color = "255, 150, 50";

    momentum.yVel = yVel;
    momentum.xVel = xVel;
  }

  void update() {
    if (game.state == GalagaGameState.paused)
      return;

    _deleteTimer = new Timer(const Duration(milliseconds: 1000), () => removeFromGame());

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

