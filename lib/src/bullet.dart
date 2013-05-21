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

    opacity = 0.0;

    if (size >= 36)
      size = 36;

    if (type == "super") {
      width = 64;
      height = 32;
    }
  }

  void update() {
    if (game.state == GalagaGameState.paused || game.state == GalagaGameState.gameOver || game.state == GalagaGameState.welcome)
      return;

    super.update();

    if (right)
      momentum.xVel = 40;
    else if (left)
      momentum.xVel = -40;
    else if (straight)
      momentum.xVel = 0;

    if (width <= 0 || height <= 0) {
      if (momentum.yVel > 0) {
        game.score += 100;
      }

      removeFromGame();
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
          game.ship.bullet++;
          e.removeFromGame();
        }
      });
    }

    if (momentum.yVel < 0) {
      game.entities.where((e) => e is Enemy && collidesWith(e)).toList().forEach((Enemy enemy) {
        if (width > enemy.width && height > enemy.height) {
          width -= enemy.width;
          height -= enemy.height;
        } else if (Type != "super")
          removeFromGame();

        game.targetId = enemy.idNum;

        game.ship.bulletsHit++;

        if (game.ship.bullet < 3)
          game.ship.bullet++;

        if (game.soundEffectsOn)
          game.enemyHit.play(game.enemyHit.Sound, game.enemyHit.Volume, game.enemyHit.Looping);

        if (enemy.type == "MotherShip") {
          game._motherShipEvent.signal();
        } else if (enemy.type == "Boss") {
          game._bossHitEvent.signal();
        } else if (enemy.type == "Normal") {
          game._normalHitEvent.signal();
        }

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
          game.shipHit.play(game.shipHit.Sound, game.shipHit.Volume, game.shipHit.Looping);

        game.resetPowerups();
        game.removeBullets();

        game.ship.bullet = game.ship.maxBullet;
      });
    }
  }
}