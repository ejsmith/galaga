part of galaga_game;

class Clone extends GameEntity {
  num Id;

  Clone(GalagaGame game, num x, num y) : super.withPosition(game, x, y, 36, 36) {
    momentum.xVel = 80;
    opacity = 0;
    color = "0, 255, 0";
  }

  void update() {
    if (game.state == GalagaGameState.paused)
      return;

    if (x + 16 > game.rect.halfWidth || x - 16 < -(game.rect.halfWidth))
      game.switchDirection();

    super.update();
  }
}