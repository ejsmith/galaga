part of galaga_html;

class GalagaRenderer extends CanvasGameRenderer<GalagaGame> {
  num timeLeft = 0;

  PowerUpRenderer powerUpRenderer;
  EnemyRenderer enemyRenderer;
  ImageElement ship = new ImageElement();
  ImageElement enemy = new ImageElement();
  ImageElement enemy2 = new ImageElement();
  ImageElement boss = new ImageElement();
  ImageElement mothership = new ImageElement();
  ImageElement bosshp = new ImageElement();
  ImageElement spreadup = new ImageElement();
  ImageElement lifeup = new ImageElement();
  ImageElement multiplierup = new ImageElement();
  ImageElement bulletup = new ImageElement();
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

  bool enemyFlicker = false;
  bool shipFlicker = false;

  GalagaRenderer(String targetId) : super(targetId) {
    powerUpRenderer = new PowerUpRenderer(this);
    enemyRenderer = new EnemyRenderer(this);
    ship.src = '../web/images/Ship.png';
    enemy.src = '../web/images/enemy.png';
    enemy2.src = '../web/images/enemy2.png';
    boss.src = '../web/images/boss.png';
    mothership.src = '../web/images/mothership.png';
    bosshp.src = '../web/images/bosshp.png';
    spreadup.src = '../web/images/powerup1.png';
    lifeup.src = '../web/images/powerup2.png';
    multiplierup.src = '../web/images/powerup3.png';
    bulletup.src = '../web/images/powerup4.png';
    coin.src = '../web/images/coin.png';
    shipbullet.src = '../web/images/BulletUp.png';
    enemybullet.src = '../web/images/BulletDown.png';
    superBullet.src = '../web/images/SuperAttack.png';
    bossSuperBullet.src = '../web/images/bossShot.png';
    chargeBar.src = '../web/images/chargeBar.png';
    star1.src = '../web/images/star1.png';
    star2.src = '../web/images/star2.png';
    star3.src = '../web/images/star3.png';
    star4.src = '../web/images/star4.png';
    star5.src = '../web/images/star5.png';
    star6.src = '../web/images/star6.png';
    star7.src = '../web/images/star7.png';
  }

  void init() {
    game.Stats["killed"] = window.localStorage.containsKey('win1') ? int.parse(window.localStorage['win1']) : 0;
    game.Stats["wins"] = window.localStorage.containsKey('win2') ? int.parse(window.localStorage['win2']) : 0;
    game.Stats["loses"] = window.localStorage.containsKey('win3') ? int.parse(window.localStorage['win3']) : 0;
    game.Stats["totalGames"] = window.localStorage.containsKey('win4') ? int.parse(window.localStorage['win4']) : 0;
    game.Stats["highscore"] = window.localStorage.containsKey('win5') ? int.parse(window.localStorage['win5']) : 0;
    game.Stats["normalKills"] = window.localStorage.containsKey('win12') ? int.parse(window.localStorage['win12']) : 0;
    game.Stats["bossKills"] = window.localStorage.containsKey('win13') ? int.parse(window.localStorage['win13']) : 0;
    game.Stats["motherKills"] = window.localStorage.containsKey('win14') ? int.parse(window.localStorage['win14']) : 0;
    game.Stats["powerups"] = window.localStorage.containsKey('win15') ? int.parse(window.localStorage['win15']) : 0;

    game.Options["startLives"] = window.localStorage.containsKey('win6') ? int.parse(window.localStorage['win6']) : 3;
    game.Options["bulletCap"] = window.localStorage.containsKey('win7') ? int.parse(window.localStorage['win7']) : 3;
    game.Options["time"] = window.localStorage.containsKey('win8') ? int.parse(window.localStorage['win8']) : 60;
    game.Options["difficulty"] = window.localStorage.containsKey('win9') ? int.parse(window.localStorage['win9']) : 1;
    game.Options["powerups"] = window.localStorage.containsKey('win10') ? int.parse(window.localStorage['win10']) : 1;
    game.Options["soundeffects"] = window.localStorage.containsKey('win11') ? int.parse(window.localStorage['win11']) : 1;

    game.Highscores[1] = window.localStorage.containsKey('win16') ? int.parse(window.localStorage['win16']) : 0;
    game.Highscores[2] = window.localStorage.containsKey('win17') ? int.parse(window.localStorage['win17']) : 0;
    game.Highscores[3] = window.localStorage.containsKey('win18') ? int.parse(window.localStorage['win18']) : 0;
    game.Highscores[4] = window.localStorage.containsKey('win19') ? int.parse(window.localStorage['win19']) : 0;
    game.Highscores[5] = window.localStorage.containsKey('win20') ? int.parse(window.localStorage['win20']) : 0;
    game.Highscores[6] = window.localStorage.containsKey('win21') ? int.parse(window.localStorage['win21']) : 0;
    game.Highscores[7] = window.localStorage.containsKey('win22') ? int.parse(window.localStorage['win22']) : 0;
    game.Highscores[8] = window.localStorage.containsKey('win23') ? int.parse(window.localStorage['win23']) : 0;
    game.Highscores[9] = window.localStorage.containsKey('win24') ? int.parse(window.localStorage['win24']) : 0;
    game.Highscores[10] = window.localStorage.containsKey('win25') ? int.parse(window.localStorage['win25']) : 0;

    game.onGameOver.listen((e) => gameOver());
    game.onShipHit.listen((e) => shipHit());
    game.onStatUpdate.listen((e) => updateStats());
    game.onMotherShipHit.listen((e) => motherShipHit());
    game.onBossHit.listen((e) => bossHit());
    game.onNormalHit.listen((e) => normalShipHit());
  }

  void gameOver() {
    bgFade();
    updateStats();
  }

  void drawStar1() {
    game.entities.where((e) => e is Stars).forEach((Stars e) {
      if (e.momentum.yVel > 0 && e.starColor == 1) {
        ctx.strokeStyle = "rgba(255, 255, 255, 1.0)";
        ctx.lineWidth = 3;

        ctx.beginPath();
        ctx.drawImageScaled(star1, e.x - 4, e.y - 4, random(.5, 3.5), random(.5, 3.5));
        ctx.stroke();
      }
    });
  }

  void drawStar2() {
    game.entities.where((e) => e is Stars).forEach((Stars e) {
      if (e.momentum.yVel > 0 && e.starColor == 2) {
        ctx.strokeStyle = "rgba(255, 255, 255, 1.0)";
        ctx.lineWidth = 3;

        ctx.beginPath();
        ctx.drawImageScaled(star2, e.x - 4, e.y - 4, random(.5, 3.5), random(.5, 3.5));
        ctx.stroke();
      }
    });
  }

  void drawStar3() {
    game.entities.where((e) => e is Stars).forEach((Stars e) {
      if (e.momentum.yVel > 0 && e.starColor == 3) {
        ctx.strokeStyle = "rgba(255, 255, 255, 1.0)";
        ctx.lineWidth = 3;

        ctx.beginPath();
        ctx.drawImageScaled(star3, e.x - 4, e.y - 4, random(.5, 3.5), random(.5, 3.5));
        ctx.stroke();
      }
    });
  }

  void drawStar4() {
    game.entities.where((e) => e is Stars).forEach((Stars e) {
      if (e.momentum.yVel > 0 && e.starColor == 4) {
        ctx.strokeStyle = "rgba(255, 255, 255, 1.0)";
        ctx.lineWidth = 3;

        ctx.beginPath();
        ctx.drawImageScaled(star4, e.x - 4, e.y - 4, random(.5, 3.5), random(.5, 3.5));
        ctx.stroke();
      }
    });
  }

  void drawStar5() {
    game.entities.where((e) => e is Stars).forEach((Stars e) {
      if (e.momentum.yVel > 0 && e.starColor == 5) {
        ctx.strokeStyle = "rgba(255, 255, 255, 1.0)";
        ctx.lineWidth = 3;

        ctx.beginPath();
        ctx.drawImageScaled(star5, e.x - 4, e.y - 4, random(.5, 3.5), random(.5, 3.5));
        ctx.stroke();
      }
    });
  }

  void drawStar6() {
    game.entities.where((e) => e is Stars).forEach((Stars e) {
      if (e.momentum.yVel > 0 && e.starColor == 6) {
        ctx.strokeStyle = "rgba(255, 255, 255, 1.0)";
        ctx.lineWidth = 3;

        ctx.beginPath();
        ctx.drawImageScaled(star6, e.x - 4, e.y - 4, random(.5, 3.5), random(.5, 3.5));
        ctx.stroke();
      }
    });
  }

  void drawStar7() {
    game.entities.where((e) => e is Stars).forEach((Stars e) {
      if (e.momentum.yVel > 0 && e.starColor == 7) {
        ctx.strokeStyle = "rgba(255, 255, 255, 1.0)";
        ctx.lineWidth = 3;

        ctx.beginPath();
        ctx.drawImageScaled(star7, e.x - 4, e.y - 4, random(.5, 3.5), random(.5, 3.5));
        ctx.stroke();
      }
    });
  }

  void drawSuperBullet() {
    game.entities.where((e) => e is Bullet).forEach((Bullet e) {
      if (e.momentum.yVel < 0 && e.Type == "super") {
        ctx.strokeStyle = "rgba(255, 255, 255, 1.0)";
        ctx.lineWidth = 3;

        ctx.beginPath();
        ctx.drawImageScaled(superBullet, e.x - 8, e.y - 8, 64, 32);
        ctx.stroke();
      }
    });
  }

  void drawBossSuperBullet() {
    game.entities.where((e) => e is Bullet).forEach((Bullet e) {
      if (e.momentum.yVel > 0) {
        ctx.strokeStyle = "rgba(255, 255, 255, 1.0)";
        ctx.lineWidth = 3;

        ctx.beginPath();
        ctx.drawImageScaled(bossSuperBullet, e.x - 72, e.y - 8, 64, 64);
        ctx.stroke();
      }
    });
  }

  void drawBouncer() {
    game.entities.where((e) => e is bouncingBall).forEach((bouncingBall e) {
      ctx.strokeStyle = "rgba(255, 255, 255, 1.0)";
      ctx.lineWidth = 3;

      ctx.beginPath();
      if (e.Sprite == 1)
        ctx.drawImageScaled(spreadup, e.x - 22, e.y - 25, 42, 42);
      else if(e.Sprite == 2)
        ctx.drawImageScaled(lifeup, e.x - 22, e.y - 25, 36, 36);
      else if(e.Sprite == 3)
        ctx.drawImageScaled(multiplierup, e.x - 20, e.y - 20, 36, 36);
      else if(e.Sprite == 4)
        ctx.drawImageScaled(bulletup, e.x - 20, e.y - 20, 36, 36);
      else if(e.Sprite == 5)
        ctx.drawImageScaled(coin, e.x - 8, e.y - 8, 12, 12);
      else if(e.Sprite == 6)
        ctx.drawImageScaled(ship, e.x - 22, e.y - 25, 42, 42);
      else if(e.Sprite == 7)
        ctx.drawImageScaled(enemy, e.x - 20, e.y - 20, 42, 42);
      else if(e.Sprite == 8)
        ctx.drawImageScaled(mothership, e.x - 22, e.y - 22, 42, 42);
      else if(e.Sprite == 9)
        ctx.drawImageScaled(enemy2, e.x - 20, e.y - 20, 36, 36);
      else if(e.Sprite == 10)
        ctx.drawImageScaled(boss, e.x - 42, e.y - 42, 72, 72);

      ctx.stroke();
    });
  }

  void drawShipBullet() {
    game.entities.where((e) => e is Bullet).forEach((Bullet e) {
      if (e.momentum.yVel < 0 && e.Type != "super") {
        ctx.strokeStyle = "rgba(255, 255, 255, 1.0)";
        ctx.lineWidth = 3;

        ctx.beginPath();
        ctx.drawImageScaled(shipbullet, e.x - 8, e.y - 8, 16, 16);
        ctx.stroke();
      }
    });
  }

  void drawEnemyBullet() {
    game.entities.where((e) => e is Bullet).forEach((Bullet e) {
      if (e.momentum.yVel > 0 && e.Type != "super") {
        ctx.strokeStyle = "rgba(255, 255, 255, 1.0)";
        ctx.lineWidth = 3;

        ctx.beginPath();
        ctx.drawImageScaled(enemybullet, e.x - 8, e.y - 8, 16, 16);
        ctx.stroke();
      }
    });
  }

  void drawSpreadUp() {
    game.entities.where((e) => e is PowerUp).forEach((PowerUp e) {
      if (e.type == "SpiralShot") {
        ctx.strokeStyle = "rgba(255, 255, 255, 1.0)";
        ctx.lineWidth = 3;

        ctx.beginPath();
        ctx.drawImageScaled(spreadup, e.x - 20, e.y - 20, 36, 36);
        ctx.stroke();
      }
    });
  }

  void drawLifeUp() {
    game.entities.where((e) => e is PowerUp).forEach((PowerUp e) {
      if (e.type == "ExtraLife") {
        ctx.strokeStyle = "rgba(255, 255, 255, 1.0)";
        ctx.lineWidth = 3;

        ctx.beginPath();
        ctx.drawImageScaled(lifeup, e.x - 20, e.y - 20, 36, 36);
        ctx.stroke();
      }
    });
  }

  void drawMultiplierUp() {
    game.entities.where((e) => e is PowerUp).forEach((PowerUp e) {
      if (e.type == "Multiplier") {
        ctx.strokeStyle = "rgba(255, 255, 255, 1.0)";
        ctx.lineWidth = 3;

        ctx.beginPath();
        ctx.drawImageScaled(multiplierup, e.x - 20, e.y - 20, 36, 36);
        ctx.stroke();
      }
    });
  }

  void drawBulletUp() {
    game.entities.where((e) => e is PowerUp).forEach((PowerUp e) {
      if (e.type == "BulletIncrease") {
        ctx.strokeStyle = "rgba(255, 255, 255, 1.0)";
        ctx.lineWidth = 3;

        ctx.beginPath();
        ctx.drawImageScaled(bulletup, e.x - 20, e.y - 20, 36, 36);
        ctx.stroke();
      }
    });
  }

  void drawCoin() {
    game.entities.where((e) => e is PowerUp).forEach((PowerUp e) {
      if (e.type == "bulletPower") {
        ctx.strokeStyle = "rgba(255, 255, 255, 1.0)";
        ctx.lineWidth = 3;

        ctx.beginPath();
        ctx.drawImageScaled(coin, e.x - 8, e.y - 8, 12, 12);
        ctx.stroke();
      }
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
    ctx.strokeStyle = "rgba(255, 255, 255, 1.0)";
    ctx.lineWidth = 3;

    ctx.beginPath();
    ctx.drawImageScaled(ship, game.ship.x - 22, game.ship.y - 25, 42, 42);
    drawChargeBar();
    ctx.stroke();
  }

  void drawDrone() {
    game.entities.where((e) => e is Enemy).forEach((Enemy e) {
      if (e.type == "Drone" && e.flicker == false) {
        ctx.strokeStyle = "rgba(255, 255, 255, 1.0)";
        ctx.lineWidth = 3;

        ctx.beginPath();
        ctx.drawImageScaled(enemy, e.x - 22, e.y - 25, 12, 12);
        ctx.stroke();
      }
    });
  }

  void drawMotherShip() {
    game.entities.where((e) => e is Enemy).forEach((Enemy e) {
      if (e.type == "MotherShip" && e.flicker == false) {
        ctx.strokeStyle = "rgba(255, 255, 255, 1.0)";
        ctx.lineWidth = 3;

        ctx.beginPath();
        ctx.drawImageScaled(mothership, e.x - 22, e.y - 25, 42, 42);
        ctx.stroke();
      }
    });
  }

  void drawBoss() {
    game.entities.where((e) => e is Enemy).forEach((Enemy e) {
      if (e.type == "Boss") {
        ctx.strokeStyle = "rgba(255, 255, 255, 1.0)";
        ctx.lineWidth = 3;

        ctx.beginPath();
        if (e.flicker == false)
          ctx.drawImageScaled(boss, e.x - 22, e.y - 25, 72, 72);
        ctx.drawImageScaled(bosshp, -300, -250, e.health * 6, 12);
        ctx.stroke();
      }
    });
  }

  void drawEnemy() {
    game.entities.where((e) => e is Enemy).forEach((Enemy e) {
      if (e.type == "Normal" && e.flicker == false) {
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

  void subtleBgFade() {
    game.bgStyle = "rgba(0, 0, 0, 0.84)";

    new Timer(const Duration(milliseconds: 25), () => game.bgStyle = "rgba(0, 0, 0, 0.83)");
    new Timer(const Duration(milliseconds: 50), () => game.bgStyle = "rgba(0, 0, 0, 0.82)");
    new Timer(const Duration(milliseconds: 75), () => game.bgStyle = "rgba(0, 0, 0, 0.81)");
    new Timer(const Duration(milliseconds: 100), () => game.bgStyle = "rgba(0, 0, 0, 0.82)");
    new Timer(const Duration(milliseconds: 125), () => game.bgStyle = "rgba(0, 0, 0, 0.83)");
    new Timer(const Duration(milliseconds: 150), () => game.bgStyle = "rgba(0, 0, 0, 0.84)");
    new Timer(const Duration(milliseconds: 175), () => game.bgStyle = "rgba(0, 0, 0, 0.85)");
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

  void updateStats() {
    window.localStorage['win1'] = game.Stats["killed"].toString();
    window.localStorage['win2'] = game.Stats["wins"].toString();
    window.localStorage['win3'] = game.Stats["loses"].toString();
    window.localStorage['win4'] = game.Stats["totalGames"].toString();
    window.localStorage['win5'] = game.Stats["highscore"].toString();
    window.localStorage['win12'] = game.Stats["normalKills"].toString();
    window.localStorage['win13'] = game.Stats["bossKills"].toString();
    window.localStorage['win14'] = game.Stats["motherKills"].toString();
    window.localStorage['win15'] = game.Stats["powerups"].toString();

    window.localStorage['win6'] = game.Options["startLives"].toString();
    window.localStorage['win7'] = game.Options["bulletCap"].toString();
    window.localStorage['win8'] = game.Options["time"].toString();
    window.localStorage['win9'] = game.Options["difficulty"].toString();
    window.localStorage['win10'] = game.Options["powerups"].toString();
    window.localStorage['win11'] = game.Options["soundeffects"].toString();

    window.localStorage['win16'] = game.Highscores[1].toString();
    window.localStorage['win17'] = game.Highscores[2].toString();
    window.localStorage['win18'] = game.Highscores[3].toString();
    window.localStorage['win19'] = game.Highscores[4].toString();
    window.localStorage['win20'] = game.Highscores[5].toString();
    window.localStorage['win21'] = game.Highscores[6].toString();
    window.localStorage['win22'] = game.Highscores[7].toString();
    window.localStorage['win23'] = game.Highscores[8].toString();
    window.localStorage['win24'] = game.Highscores[9].toString();
    window.localStorage['win25'] = game.Highscores[10].toString();
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

  GameEntityRenderer getRenderer(GameEntity e) {

    if (e is Enemy && game.state == GalagaGameState.gameOver)
      return null;

    if (e is PowerUp)
      return powerUpRenderer;

    if (e is Enemy)
      return enemyRenderer;

    return super.getRenderer(e);
  }

  void drawBeforeCtxRestore() {
    drawBouncer();
    drawCountDown();
    drawStar1();
    drawStar2();
    drawStar3();
    drawStar4();
    drawStar5();
    drawStar6();
    drawStar7();
    if (game.state == GalagaGameState.playing || game.state == GalagaGameState.paused) {
      drawLives();
      if (!shipFlicker)
        drawShip();
      drawShipBullet();
      drawSuperBullet();
      drawEnemyBullet();
      drawCoin();
      drawLifeUp();
      drawSpreadUp();
      drawMultiplierUp();
      drawBulletUp();
      drawEnemy();
      drawBoss();
      drawDrone();
      drawMotherShip();
      drawTime();
      drawScore();
      drawHighScore();
      drawLevel();
    }
    super.drawBeforeCtxRestore();
  }

  void drawLevel() {
    ctx.fillStyle = "rgba(255, 255, 255, 1)";
    ctx.font = "32px cinnamoncake, Verdana";
    ctx.fillText("Level: ${game.level}", 375, (game.rect.halfHeight - 5));
  }

  void drawTime() {
    ctx.fillStyle = "rgba(255, 255, 255, 1)";
    ctx.font = "32px cinnamoncake, Verdana";
    ctx.fillText("Time: ${game.timer.gameTime.round()} ", -100, -(game.rect.halfHeight - 30));
  }

  void drawLives() {
    ctx.beginPath();
    for (num i = 0; i < game.ship.lives; i++) {
      ctx.drawImageScaled(ship, -475 + (45 * i), (game.rect.halfHeight - 45), 36, 36);
    }
    ctx.stroke();
  }

  void drawScore() {
    ctx.fillStyle = "rgba(255, 255, 255, 1)";
    ctx.font = "32px cinnamoncake, Verdana";
    ctx.fillText("Score: ${game.score} ", -475, -(game.rect.halfHeight - 30));
  }

  void drawCountDown() {
    if (game.state == GalagaGameState.levelEnd) {
    num temp = 0;
    ctx.fillStyle = "rgba(255, 255, 255, 1)";
    ctx.font = "52px cinnamoncake, Verdana";
    if (game.waiting == 1)
      temp = 3;
    if (game.waiting == 2)
      temp = 2;
    if (game.waiting == 3)
      temp = 1;
    ctx.fillText("Next Level In: ${temp}", -165, 0);
    }
  }

  void drawHighScore() {
    num textX = 225;
    int digits = 0;
    num tempHigh = game.Stats["highscore"];

    while (tempHigh != 0) {
      tempHigh /= 10;
      digits++;
    }

    textX = textX - digits / 10;
    //textX = textX - (game.Stats["highscore"] / 10000);

    ctx.fillStyle = "rgba(255, 255, 255, 1)";
    ctx.font = "32px cinnamoncake, Verdana";
    ctx.fillText("High Score: ${game.Stats["highscore"]} ", textX, -(game.rect.halfHeight - 30));
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
