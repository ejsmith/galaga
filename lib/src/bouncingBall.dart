part of galaga_game;

class bouncingBall extends GameEntity {
  num Sprite = 0;

  bouncingBall(Game game, num x, num y, num h, num w, num sprite) : super.withPosition(game, x, y, h, w) {
    Sprite = sprite;

    opacity = 0.0;

    momentum.yVel = random(-250, 250);
    momentum.xVel = random(-250, 250);
  }

  void update() {
    if (game.state != GalagaGameState.instructions && game.state != GalagaGameState.cheats)
      removeFromGame();

    if (y > game.rect.halfHeight - (height / 2)) {
      momentum.yVel *= -1;
      y -= 2;
    }

    if (y < -(game.rect.halfHeight) + (height / 2)) {
      momentum.yVel *= -1;
      y += 2;
    }

    if (x > game.rect.halfWidth - (width / 2)) {
      momentum.xVel *= -1;
      x -= 2;
    }

    if (x < -(game.rect.halfWidth) + (width / 2)) {
      momentum.xVel *= -1;
      x += 2;
    }

    super.update();
  }
}