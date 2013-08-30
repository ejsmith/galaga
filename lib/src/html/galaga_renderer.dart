part of galaga_html;

class GalagaRenderer extends CanvasGameRenderer<GalagaGame> {
  num timeLeft = 0;

  ImageElement ship = new ImageElement();
  ImageElement invincibleShip = new ImageElement();
  ImageElement upgradedShip = new ImageElement();
  ImageElement enemy = new ImageElement();
  ImageElement enemy2 = new ImageElement();
  ImageElement boss = new ImageElement();
  ImageElement mothership = new ImageElement();
  ImageElement bosshp = new ImageElement();
  ImageElement spreadup = new ImageElement();
  ImageElement lifeup = new ImageElement();
  ImageElement multiplierup = new ImageElement();
  ImageElement bulletup = new ImageElement();
  ImageElement invincible = new ImageElement();
  ImageElement timeUp = new ImageElement();
  ImageElement coin = new ImageElement();
  ImageElement shipbullet = new ImageElement();
  ImageElement enemybullet = new ImageElement();
  ImageElement superBullet = new ImageElement();
  ImageElement bossSuperBullet = new ImageElement();
  ImageElement chargeBar = new ImageElement();
  ImageElement star1 = new ImageElement();
  ImageElement star2 = new ImageElement();
  ImageElement star3 = new ImageElement();
  ImageElement star4 = new ImageElement();
  ImageElement star5 = new ImageElement();
  ImageElement star6 = new ImageElement();
  ImageElement star7 = new ImageElement();
  ImageElement skull = new ImageElement();
  ImageElement clone = new ImageElement();

  bool enemyFlicker = false;
  bool shipFlicker = false;

  GalagaRenderer(String targetId) : super(targetId) {
    ship.src = '../web/images/Ship.png';
    invincibleShip.src = '../web/images/InvincibleShip.png';
    upgradedShip.src = '../web/images/UpgradedShip.png';
    enemy.src = '../web/images/enemy.png';
    enemy2.src = '../web/images/enemy2.png';
    boss.src = '../web/images/boss.png';
    mothership.src = '../web/images/mothership.png';
    bosshp.src = '../web/images/bosshp.png';
    spreadup.src = '../web/images/powerup1.png';
    lifeup.src = '../web/images/powerup2.png';
    multiplierup.src = '../web/images/powerup3.png';
    bulletup.src = '../web/images/powerup4.png';
    invincible.src = '../web/images/invincible.png';
    timeUp.src = '../web/images/clock.png';
    coin.src = '../web/images/coin.png';
    shipbullet.src = '../web/images/BulletUp.png';
    enemybullet.src = '../web/images/BulletDown.png';
    superBullet.src = '../web/images/SuperAttack.png';
    bossSuperBullet.src = '../web/images/bossShot.png';
    chargeBar.src = '../web/images/chargeBar.png';
    star1.src = '../web/images/Star1.png';
    star2.src = '../web/images/Star2.png';
    star3.src = '../web/images/Star3.png';
    star4.src = '../web/images/Star4.png';
    star5.src = '../web/images/Star5.png';
    star6.src = '../web/images/Star6.png';
    star7.src = '../web/images/Star7.png';
    skull.src = '../web/images/skull.png';
    clone.src = '../web/images/clone.png';
  }

  void init() {
    game.Stats["killed"] = window.localStorage.containsKey('killed') ? int.parse(window.localStorage['killed'], onError: (val) => 0) : 0;
    game.Stats["wins"] = window.localStorage.containsKey('wins') ? int.parse(window.localStorage['wins'], onError: (val) => 0) : 0;
    game.Stats["loses"] = window.localStorage.containsKey('loses') ? int.parse(window.localStorage['loses'], onError: (val) => 0) : 0;
    game.Stats["totalGames"] = window.localStorage.containsKey('totalGames') ? int.parse(window.localStorage['totalGames'], onError: (val) => 0) : 0;
    game.Stats["highscore"] = window.localStorage.containsKey('highscore') ? int.parse(window.localStorage['highscore'], onError: (val) => 0) : 0;
    game.Stats["normalKills"] = window.localStorage.containsKey('normalKills') ? int.parse(window.localStorage['normalKills'], onError: (val) => 0) : 0;
    game.Stats["bossKills"] = window.localStorage.containsKey('bossKills') ? int.parse(window.localStorage['bossKills'], onError: (val) => 0) : 0;
    game.Stats["motherKills"] = window.localStorage.containsKey('motherKills') ? int.parse(window.localStorage['motherKills'], onError: (val) => 0) : 0;
    game.Stats["powerups"] = window.localStorage.containsKey('powerups') ? int.parse(window.localStorage['powerups'], onError: (val) => 0) : 0;
    game.Stats["percentage"] = window.localStorage.containsKey('percentage') ? int.parse(window.localStorage['percentage'], onError: (val) => 0) : 0;
    game.Stats["bulletsFired"] = window.localStorage.containsKey('bulletsFired') ? int.parse(window.localStorage['bulletsFired'], onError: (val) => 0) : 0;
    game.Stats["bulletsHit"] = window.localStorage.containsKey('bulletsHit') ? int.parse(window.localStorage['bulletsHit'], onError: (val) => 0) : 0;

    game.Options["startLives"] = window.localStorage.containsKey('startLives') ? int.parse(window.localStorage['startLives'], onError: (val) => 3) : 3;
    game.Options["bulletCap"] = window.localStorage.containsKey('bulletCap') ? int.parse(window.localStorage['bulletCap'], onError: (val) => 3) : 3;
    game.Options["time"] = window.localStorage.containsKey('time') ? int.parse(window.localStorage['time'], onError: (val) => 60) : 60;
    game.Options["difficulty"] = window.localStorage.containsKey('difficulty') ? int.parse(window.localStorage['difficulty'], onError: (val) => 1) : 1;
    game.Options["powerups"] = window.localStorage.containsKey('powerups') ? int.parse(window.localStorage['powerups'], onError: (val) => 1) : 1;
    game.Options["soundeffects"] = window.localStorage.containsKey('soundeffects') ? int.parse(window.localStorage['soundeffects'], onError: (val) => 1) : 1;
    game.Options["controls"] = window.localStorage.containsKey('controls') ? int.parse(window.localStorage['controls'], onError: (val) => 1) : 1;

    game.Highscores[1] = window.localStorage.containsKey('Score1') ? int.parse(window.localStorage['Score1'], onError: (val) => 0) : 0;
    game.Highscores[2] = window.localStorage.containsKey('Score2') ? int.parse(window.localStorage['Score2'], onError: (val) => 0) : 0;
    game.Highscores[3] = window.localStorage.containsKey('Score3') ? int.parse(window.localStorage['Score3'], onError: (val) => 0) : 0;
    game.Highscores[4] = window.localStorage.containsKey('Score4') ? int.parse(window.localStorage['Score4'], onError: (val) => 0) : 0;
    game.Highscores[5] = window.localStorage.containsKey('Score5') ? int.parse(window.localStorage['Score5'], onError: (val) => 0) : 0;
    game.Highscores[6] = window.localStorage.containsKey('Score6') ? int.parse(window.localStorage['Score6'], onError: (val) => 0) : 0;
    game.Highscores[7] = window.localStorage.containsKey('Score7') ? int.parse(window.localStorage['Score7'], onError: (val) => 0) : 0;
    game.Highscores[8] = window.localStorage.containsKey('Score8') ? int.parse(window.localStorage['Score8'], onError: (val) => 0) : 0;
    game.Highscores[9] = window.localStorage.containsKey('Score9') ? int.parse(window.localStorage['Score9'], onError: (val) => 0) : 0;
    game.Highscores[10] = window.localStorage.containsKey('Score10') ? int.parse(window.localStorage['Score10'], onError: (val) => 0) : 0;

    game.Cheats["spreadshot"] = window.localStorage.containsKey('spreadshot') ? int.parse(window.localStorage['spreadshot'], onError: (val) => 0) : 1;
    game.Cheats["invincibility"] = window.localStorage.containsKey('invincibility') ? int.parse(window.localStorage['invincibility'], onError: (val) => 0) : 1;
    game.Cheats["freeze"] = window.localStorage.containsKey('freeze') ? int.parse(window.localStorage['freeze'], onError: (val) => 0) : 1;
    game.Cheats["super"] = window.localStorage.containsKey('super') ? int.parse(window.localStorage['super'], onError: (val) => 0) : 1;

    game.onGameOver.listen((e) => gameOver());
    game.onShipHit.listen((e) => shipHit());
    game.onStatUpdate.listen((e) => updateStats());
    game.onMotherShipHit.listen((e) => motherShipHit());
    game.onBossHit.listen((e) => bossHit());
    game.onNormalHit.listen((e) => normalShipHit());
    game.onFadeEvent.listen((e) => subtleBgFade());
  }

  void gameOver() {
    subtleBgFade();
    updateStats();
  }

  void updateStats() {
    window.localStorage['killed'] = game.Stats["killed"].toString();
    window.localStorage['wins'] = game.Stats["wins"].toString();
    window.localStorage['loses'] = game.Stats["loses"].toString();
    window.localStorage['totalGames'] = game.Stats["totalGames"].toString();
    window.localStorage['highscore'] = game.Stats["highscore"].toString();
    window.localStorage['normalKills'] = game.Stats["normalKills"].toString();
    window.localStorage['bossKills'] = game.Stats["bossKills"].toString();
    window.localStorage['motherKills'] = game.Stats["motherKills"].toString();
    window.localStorage['powerups'] = game.Stats["powerups"].toString();
    window.localStorage['percentage'] = game.Stats["percentage"].toString();
    window.localStorage['powerups'] = game.Stats["powerups"].toString();
    window.localStorage['percentage'] = game.Stats["percentage"].toString();

    window.localStorage['startLives'] = game.Options["startLives"].toString();
    window.localStorage['bulletCap'] = game.Options["bulletCap"].toString();
    window.localStorage['time'] = game.Options["time"].toString();
    window.localStorage['difficulty'] = game.Options["difficulty"].toString();
    window.localStorage['powerups'] = game.Options["powerups"].toString();
    window.localStorage['soundeffects'] = game.Options["soundeffects"].toString();
    window.localStorage['controls'] = game.Options["controls"].toString();

    window.localStorage['score1'] = game.Highscores[1].toString();
    window.localStorage['score2'] = game.Highscores[2].toString();
    window.localStorage['score3'] = game.Highscores[3].toString();
    window.localStorage['score4'] = game.Highscores[4].toString();
    window.localStorage['score5'] = game.Highscores[5].toString();
    window.localStorage['score6'] = game.Highscores[6].toString();
    window.localStorage['score7'] = game.Highscores[7].toString();
    window.localStorage['score8'] = game.Highscores[8].toString();
    window.localStorage['score9'] = game.Highscores[9].toString();
    window.localStorage['score10'] = game.Highscores[10].toString();

    window.localStorage['spreadshot'] = game.Options["spreadshot"].toString();
    window.localStorage['invincibility'] = game.Options["invincibility"].toString();
    window.localStorage['freeze'] = game.Options["freeze"].toString();
    window.localStorage['super'] = game.Options["super"].toString();
  }

  void drawStars() {
    game.entities.where((e) => e is Stars).forEach((Stars e) {
        ctx.strokeStyle = "rgba(255, 255, 255, 1.0)";
        ctx.lineWidth = 3;

        ctx.beginPath();

        if (e.starColor == 1)
          ctx.drawImageScaled(star1, e.x - (e.width / 2), e.y - (e.height / 2), e.width, e.height);
        else if (e.starColor == 2)
          ctx.drawImageScaled(star2, e.x - (e.width / 2), e.y - (e.height / 2), e.width, e.height);
        else if (e.starColor == 3)
          ctx.drawImageScaled(star3, e.x - (e.width / 2), e.y - (e.height / 2), e.width, e.height);
        else if (e.starColor == 4)
          ctx.drawImageScaled(star4, e.x - (e.width / 2), e.y - (e.height / 2), e.width, e.height);
        else if (e.starColor == 5)
          ctx.drawImageScaled(star5, e.x - (e.width / 2), e.y - (e.height / 2), e.width, e.height);
        else if (e.starColor == 6)
          ctx.drawImageScaled(star6, e.x - (e.width / 2), e.y - (e.height / 2), e.width, e.height);
        else if (e.starColor == 7)
          ctx.drawImageScaled(star7, e.x - (e.width / 2), e.y - (e.height / 2), e.width, e.height);

        ctx.stroke();
    });
  }

  void drawBouncer() {
    game.entities.where((e) => e is bouncingBall).forEach((bouncingBall e) {
      ctx.strokeStyle = "rgba(255, 255, 255, 1.0)";
      ctx.lineWidth = 3;

      ctx.beginPath();
      if (e.Sprite == 1)
        ctx.drawImageScaled(spreadup, e.x - (e.width / 2), e.y - (e.height / 2), 42, 42);
      else if(e.Sprite == 2)
        ctx.drawImageScaled(lifeup, e.x - (e.width / 2), e.y - (e.height / 2), 36, 36);
      else if(e.Sprite == 3)
        ctx.drawImageScaled(multiplierup, e.x - (e.width / 2), e.y - (e.height / 2), 36, 36);
      else if(e.Sprite == 4)
        ctx.drawImageScaled(bulletup, e.x - (e.width / 2), e.y - (e.height / 2), 36, 36);
      else if(e.Sprite == 5)
        ctx.drawImageScaled(coin, e.x - (e.width / 2), e.y - (e.height / 2), 12, 12);
      else if(e.Sprite == 6)
        ctx.drawImageScaled(ship, e.x - (e.width / 2), e.y - (e.height / 2), 42, 42);
      else if(e.Sprite == 7)
        ctx.drawImageScaled(enemy, e.x - (e.width / 2), e.y - (e.height / 2), 42, 42);
      else if(e.Sprite == 8)
        ctx.drawImageScaled(mothership, e.x - (e.width / 2), e.y - (e.height / 2), 42, 42);
      else if(e.Sprite == 9)
        ctx.drawImageScaled(enemy2, e.x - (e.width / 2), e.y - (e.height / 2), 36, 36);
      else if(e.Sprite == 10)
        ctx.drawImageScaled(boss, e.x - (e.width / 2), e.y - (e.height / 2), 72, 72);
      else if(e.Sprite == 11)
        ctx.drawImageScaled(skull, e.x - (e.width / 2), e.y - (e.height / 2), 36, 36);
      else if(e.Sprite == 12)
        ctx.drawImageScaled(invincible, e.x - (e.width / 2), e.y - (e.height / 2), 62, 62);
      else if(e.Sprite == 13)
        ctx.drawImageScaled(timeUp, e.x - (e.width / 2), e.y - (e.height / 2), 42, 42);
      else if(e.Sprite == 14)
        ctx.drawImageScaled(invincibleShip, e.x - (e.width / 2), e.y - (e.height / 2), 62, 62);

      ctx.stroke();
    });
  }

  void drawBullets() {
    game.entities.where((e) => e is Bullet).forEach((Bullet e) {
      if (e.momentum.yVel < 0 && e.Type == "super") {
        ctx.strokeStyle = "rgba(255, 255, 255, 1.0)";
        ctx.lineWidth = 3;

        ctx.beginPath();
        ctx.drawImageScaled(superBullet, e.x - 8, e.y - 8, 64, 32);
        ctx.stroke();
      } else if (e.momentum.yVel > 0 && e.Type == "super") {
        ctx.strokeStyle = "rgba(255, 255, 255, 1.0)";
        ctx.lineWidth = 3;

        ctx.beginPath();
        ctx.drawImageScaled(bossSuperBullet, e.x - 72, e.y - 8, 64, 64);
        ctx.stroke();
      } else if (e.momentum.yVel < 0 && e.Type != "super") {
        ctx.strokeStyle = "rgba(255, 255, 255, 1.0)";
        ctx.lineWidth = 3;

        ctx.beginPath();
        ctx.drawImageScaled(shipbullet, e.x - 8, e.y - 8, 16, 16);
        ctx.stroke();
      } else if (e.momentum.yVel > 0 && e.Type != "super") {
        ctx.strokeStyle = "rgba(255, 255, 255, 1.0)";
        ctx.lineWidth = 3;

        ctx.beginPath();
        ctx.drawImageScaled(enemybullet, e.x - 8, e.y - 8, 16, 16);
        ctx.stroke();
      }
    });
  }

  void drawPowerUps() {
    game.entities.where((e) => e is PowerUp).forEach((PowerUp e) {
        ctx.strokeStyle = "rgba(255, 255, 255, 1.0)";
        ctx.lineWidth = 3;

        ctx.beginPath();
        if (e.type == "SpiralShot")
          ctx.drawImageScaled(spreadup, e.x - 20, e.y - 20, 36, 36);
        else if (e.type == "ExtraLife")
          ctx.drawImageScaled(lifeup, e.x - 20, e.y - 20, 36, 36);
        else if (e.type == "Multiplier")
          ctx.drawImageScaled(multiplierup, e.x - 20, e.y - 20, 36, 36);
        else if (e.type == "BulletIncrease")
          ctx.drawImageScaled(bulletup, e.x - 20, e.y - 20, 36, 36);
        else if (e.type == "bulletPower")
          ctx.drawImageScaled(coin, e.x - 8, e.y - 8, 12, 12);
        else if (e.type == "invincible")
          ctx.drawImageScaled(invincible, e.x - 31, e.y - 31, 62, 62);
        else if (e.type == "timeUp")
          ctx.drawImageScaled(timeUp, e.x - 22, e.y - 25, 42, 42);
        ctx.stroke();
    });
  }

  void drawChargeBar() {
    ctx.strokeStyle = "rgba(255, 255, 255, 1.0)";
    ctx.lineWidth = 3;

    ctx.beginPath();
    ctx.drawImageScaled(chargeBar, -300, -224, game.ship.chargedLevel * 15, 12);
    ctx.stroke();
  }

  void drawShip() {
    if (!shipFlicker) {
      ctx.strokeStyle = "rgba(255, 255, 255, 1.0)";
      ctx.lineWidth = 3;

      ctx.beginPath();
      if (game.Cheats["invincibility"] != 1)
        ctx.drawImageScaled(ship, game.ship.x - 22, game.ship.y - 25, 42, 42);
      else if (game.Cheats["invincibility"] == 1)
        ctx.drawImageScaled(invincibleShip, game.ship.x - 31, game.ship.y - 31, 62, 62);
      drawChargeBar();
      ctx.stroke();
    }
  }

  void drawEnemys() {
    game.entities.where((e) => e is Enemy).forEach((Enemy e) {
      if (e.type == "Drone" && e.flicker == false) {
        ctx.strokeStyle = "rgba(255, 255, 255, 1.0)";
        ctx.lineWidth = 3;

        ctx.beginPath();
        ctx.drawImageScaled(enemy, e.x - 22, e.y - 25, 12, 12);
        ctx.stroke();
      } else if (e.type == "MotherShip" && e.flicker == false) {
        ctx.strokeStyle = "rgba(255, 255, 255, 1.0)";
        ctx.lineWidth = 3;

        ctx.beginPath();
        ctx.drawImageScaled(mothership, e.x - 22, e.y - 25, 42, 42);
        ctx.stroke();
      } else if (e.type == "Boss") {
        ctx.strokeStyle = "rgba(255, 255, 255, 1.0)";
        ctx.lineWidth = 3;

        ctx.beginPath();
        if (e.flicker == false)
          ctx.drawImageScaled(boss, e.x - 22, e.y - 25, 72, 72);
        ctx.drawImageScaled(bosshp, -300, -250, e.health * 6, 12);
        ctx.stroke();
      } else if (e.type == "Normal" && e.flicker == false) {
        ctx.strokeStyle = "rgba(255, 255, 255, 1.0)";
        ctx.lineWidth = 3;

        ctx.beginPath();
        if (e.enemyType > .5)
          ctx.drawImageScaled(enemy, e.x - 22, e.y - 25, 42, 42);
        else {
          ctx.drawImageScaled(enemy2, e.x - 22, e.y - 25, 36, 36);
        }
        ctx.stroke();
      }
    });

  }

  void shipHit() {
    bgFade();

    new Timer(const Duration(milliseconds: 25), () => shipFlicker = true);
    new Timer(const Duration(milliseconds: 75), () => shipFlicker = false);
    new Timer(const Duration(milliseconds: 150), () => shipFlicker = true);
    new Timer(const Duration(milliseconds: 225), () => shipFlicker = false);
    new Timer(const Duration(milliseconds: 300), () => shipFlicker = true);
    new Timer(const Duration(milliseconds: 375), () => shipFlicker = false);

    subtleBgFade();
  }

  void bossHit() {
    game.entities.where((e) => e is Enemy).forEach((Enemy e) {
      if (e.type == "Boss" && e.idNum == game.targetId) {
        new Timer(const Duration(milliseconds: 25), () => e.flicker = true);
        new Timer(const Duration(milliseconds: 75), () => e.flicker = false);

        subtleBgFade();
      }
    });
  }

  void motherShipHit() {
    game.entities.where((e) => e is Enemy).forEach((Enemy e) {
      if (e.type == "MotherShip" && e.idNum == game.targetId) {
        new Timer(const Duration(milliseconds: 25), () => e.flicker = true);
        new Timer(const Duration(milliseconds: 75), () => e.flicker = false);
        new Timer(const Duration(milliseconds: 150), () => e.flicker = true);
        new Timer(const Duration(milliseconds: 225), () => e.flicker = false);
        new Timer(const Duration(milliseconds: 300), () => e.flicker = true);
        new Timer(const Duration(milliseconds: 375), () => e.flicker = false);

        subtleBgFade();
      }
    });
  }

  void normalShipHit() {
    game.entities.where((e) => e is Enemy).forEach((Enemy e) {
      if (e.type == "Normal" && e.idNum == game.targetId) {
        new Timer(const Duration(milliseconds: 25), () => e.flicker = true);
        new Timer(const Duration(milliseconds: 75), () => e.flicker = false);
        new Timer(const Duration(milliseconds: 150), () => e.flicker = true);
        new Timer(const Duration(milliseconds: 225), () => e.flicker = false);

        subtleBgFade();
      }
    });
  }

  void drawEtc() {
    num textX = 225;
    int digits = 0;
    num tempHigh = game.Stats["highscore"];

    while (tempHigh != 0) {
      tempHigh /= 10;
      digits++;
    }

    textX = textX - digits / 10;

    ctx.fillStyle = "rgba(255, 255, 255, 1)";
    ctx.font = "32px cinnamoncake, Verdana";
    ctx.fillText("High Score: ${game.Stats["highscore"]} ", textX, -(game.rect.halfHeight - 30));

    ctx.fillStyle = "rgba(255, 255, 255, 1)";
    ctx.font = "32px cinnamoncake, Verdana";
    ctx.fillText("Level: ${game.level}", 375, (game.rect.halfHeight - 5));

    ctx.fillStyle = "rgba(255, 255, 255, 1)";
    ctx.font = "32px cinnamoncake, Verdana";
    ctx.fillText("Time: ${game.timer.gameTime.round()} ", -100, -(game.rect.halfHeight - 30));

    ctx.fillStyle = "rgba(255, 255, 255, 1)";
    ctx.font = "32px cinnamoncake, Verdana";
    ctx.fillText("Score: ${game.score} ", -475, -(game.rect.halfHeight - 30));

    ctx.fillStyle = "rgba(255, 255, 255, 1)";
    ctx.font = "32px cinnamoncake, Verdana";
    ctx.fillText("x${game.pointMultiplier}", -475, -(game.rect.halfHeight - 60));

    ctx.beginPath();
    for (num i = 0; i < game.ship.lives; i++) {
      ctx.drawImageScaled(ship, -475 + (35 * i), (game.rect.halfHeight - 30), 24, 24);
    }
    ctx.stroke();
  }

  void drawCountDown() {
    if (game.state == GalagaGameState.levelEnd) {
      num temp = 0;
      ctx.fillStyle = "rgba(255, 255, 255, 1)";
      ctx.font = "52px cinnamoncake, Verdana";

      if (game.waiting == 1)
        temp = 3;
      else if (game.waiting == 2)
        temp = 2;
      else if (game.waiting == 3)
        temp = 1;

      ctx.fillText("Next Level In: ${temp}", -165, 0);
    }
  }

  GameEntityRenderer getRenderer(GameEntity e) {

    if (e is Enemy && game.state == GalagaGameState.gameOver)
      return null;

    return super.getRenderer(e);
  }

  void drawBeforeCtxRestore() {
    drawBouncer();
    drawCountDown();
    drawStars();

    if (game.state == GalagaGameState.playing || game.state == GalagaGameState.paused) {
      drawPowerUps();
      drawBullets();
      drawEtc();
      drawShip();
      drawEnemys();
    }
    super.drawBeforeCtxRestore();
  }

  void subtleBgFade() {
    game.bgStyle = "rgba(0, 0, 0, 0.85)";

    new Timer(const Duration(milliseconds: 25), () => game.bgStyle = "rgba(0, 0, 0, 0.83)");
    new Timer(const Duration(milliseconds: 50), () => game.bgStyle = "rgba(0, 0, 0, 0.81)");
    new Timer(const Duration(milliseconds: 75), () => game.bgStyle = "rgba(0, 0, 0, 0.79)");
    new Timer(const Duration(milliseconds: 100), () => game.bgStyle = "rgba(0, 0, 0, 0.77)");
    new Timer(const Duration(milliseconds: 125), () => game.bgStyle = "rgba(0, 0, 0, 0.75)");
    new Timer(const Duration(milliseconds: 150), () => game.bgStyle = "rgba(0, 0, 0, 0.73)");
    new Timer(const Duration(milliseconds: 175), () => game.bgStyle = "rgba(0, 0, 0, 0.71)");
    new Timer(const Duration(milliseconds: 200), () => game.bgStyle = "rgba(0, 0, 0, 0.69)");
    new Timer(const Duration(milliseconds: 225), () => game.bgStyle = "rgba(0, 0, 0, 0.67)");
    new Timer(const Duration(milliseconds: 175), () => game.bgStyle = "rgba(0, 0, 0, 0.65)");
    new Timer(const Duration(milliseconds: 200), () => game.bgStyle = "rgba(0, 0, 0, 0.63)");
    new Timer(const Duration(milliseconds: 225), () => game.bgStyle = "rgba(0, 0, 0, 0.61)");
    new Timer(const Duration(milliseconds: 175), () => game.bgStyle = "rgba(0, 0, 0, 0.59)");
    new Timer(const Duration(milliseconds: 200), () => game.bgStyle = "rgba(0, 0, 0, 0.57)");
    new Timer(const Duration(milliseconds: 225), () => game.bgStyle = "rgba(0, 0, 0, 0.55)");
    new Timer(const Duration(milliseconds: 250), () => game.bgStyle = "rgba(0, 0, 0, 0.53)");
    new Timer(const Duration(milliseconds: 275), () => game.bgStyle = "rgba(0, 0, 0, 0.55)");
    new Timer(const Duration(milliseconds: 300), () => game.bgStyle = "rgba(0, 0, 0, 0.57)");
    new Timer(const Duration(milliseconds: 325), () => game.bgStyle = "rgba(0, 0, 0, 0.59)");
    new Timer(const Duration(milliseconds: 350), () => game.bgStyle = "rgba(0, 0, 0, 0.61)");
    new Timer(const Duration(milliseconds: 375), () => game.bgStyle = "rgba(0, 0, 0, 0.63)");
    new Timer(const Duration(milliseconds: 400), () => game.bgStyle = "rgba(0, 0, 0, 0.65)");
    new Timer(const Duration(milliseconds: 425), () => game.bgStyle = "rgba(0, 0, 0, 0.67)");
    new Timer(const Duration(milliseconds: 450), () => game.bgStyle = "rgba(0, 0, 0, 0.69)");
    new Timer(const Duration(milliseconds: 475), () => game.bgStyle = "rgba(0, 0, 0, 0.71)");
    new Timer(const Duration(milliseconds: 500), () => game.bgStyle = "rgba(0, 0, 0, 0.73)");
    new Timer(const Duration(milliseconds: 525), () => game.bgStyle = "rgba(0, 0, 0, 0.75)");
    new Timer(const Duration(milliseconds: 550), () => game.bgStyle = "rgba(0, 0, 0, 0.77)");
    new Timer(const Duration(milliseconds: 575), () => game.bgStyle = "rgba(0, 0, 0, 0.79)");
    new Timer(const Duration(milliseconds: 600), () => game.bgStyle = "rgba(0, 0, 0, 0.81)");
    new Timer(const Duration(milliseconds: 625), () => game.bgStyle = "rgba(0, 0, 0, 0.83)");
    new Timer(const Duration(milliseconds: 650), () => game.bgStyle = "rgba(0, 0, 0, 0.85)");
  }

  void bgFade() {
    game.bgStyle = "rgba(0, 0, 0, 0.8)";
    new Timer(const Duration(milliseconds: 25), () => game.bgStyle = "rgba(0, 0, 0, 0.75)");
    new Timer(const Duration(milliseconds: 50), () => game.bgStyle = "rgba(0, 0, 0, 0.70)");
    new Timer(const Duration(milliseconds: 75), () => game.bgStyle = "rgba(0, 0, 0, 0.65)");
    new Timer(const Duration(milliseconds: 100), () => game.bgStyle = "rgba(0, 0, 0, 0.60)");
    new Timer(const Duration(milliseconds: 125), () => game.bgStyle = "rgba(0, 0, 0, 0.55)");
    new Timer(const Duration(milliseconds: 150), () => game.bgStyle = "rgba(0, 0, 0, 0.60)");
    new Timer(const Duration(milliseconds: 175), () => game.bgStyle = "rgba(0, 0, 0, 0.65)");
    new Timer(const Duration(milliseconds: 200), () => game.bgStyle = "rgba(0, 0, 0, 0.70)");
    new Timer(const Duration(milliseconds: 225), () => game.bgStyle = "rgba(0, 0, 0, 0.75)");
    new Timer(const Duration(milliseconds: 250), () => game.bgStyle = "rgba(0, 0, 0, 0.80)");
    new Timer(const Duration(milliseconds: 275), () => game.bgStyle = "rgba(0, 0, 0, 0.85)");
  }
}
