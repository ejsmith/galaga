library galaga_game;

import "dart:math" as Math;
import "dart:async";
import "dart:isolate";
import "package:dgame/dgame.dart";
import "package:event_stream/event_stream.dart";

part "src/ship.dart";
part "src/enemy.dart";
part "src/powerup.dart";
part "src/bullet.dart";
part "src/stars.dart";
part "src/particles.dart";
part "src/bouncingBall.dart";
part "src/clone.dart";

class GalagaGame extends Game {
  num score = 0;
  num highScore = 0;
  num lastPowerUp = 5;
  num lastEnemy = 5;
  num lastStar = 0;
  num _state;
  Map<String, num> Stats = new Map<String,num>();
  Map<String, num> Options = new Map<String,num>();
  Map<String, String> Controls = new Map<String,String>();
  Map<num, num> Highscores = new Map<num, num>();
  Map<num, String> HighscoresRank = new Map<num, String>();
  Map<String, num> Cheats = new Map<String, num>();
  String rank = "Jew";
  num pointMultiplier = 1;
  num enemyX = -400;
  num enemyY = -165;
  num bulletCap = 3;
  num shipStartLives = 3;
  num colorCount = 1;
  num enemyCount = 0;
  num enemyAmount = 33;
  num defaultTimer = 60;
  num level = 1;
  bool p1Dead;
  bool goingRight = true;
  Timer _countdownTimer;
  Timer _waitingTimer;
  num _waiting = 0;
  num difficulty = 1;
  num bonusCheck = 3;
  bool bonusStage = false;
  bool soundEffectsOn = true;
  bool tutorial = true;
  num visualLevel = 1;
  Ship ship;
  num nextId = 1;
  num targetId = 0;
  String powerupChoice = "All";
  num teleporter = .05;
  num spiral = .06;
  num multi = .25;
  num bullet = .55;
  num invincible = .70;
  num time = .80;
  num life = 1;
  num cloneId = 1;
  num spreadWaiting = 0;
  num rendererTemp1 = 5;
  num rendererTemp2 = 15;

  GalagaGame(Rectangle rect) : super(rect);
  GalagaGame.withServices(GameInput input, GameRenderer renderer, GameLoop loop) : super.withServices(input, renderer, loop);

  num get state => _state;
  set state(num value) {
    if (_state == value)
      return;

    _state = value;
    disableEntitiesByGroup("welcome");
    disableEntitiesByGroup("gameOver");
    disableEntitiesByGroup("stats");
    disableEntitiesByGroup("paused");
    disableEntitiesByGroup("options");
    disableEntitiesByGroup("instructions");
    disableEntitiesByGroup("levelEnd");
    disableEntitiesByGroup("leaders");
    disableEntitiesByGroup("cheats");

    if (_state == GalagaGameState.welcome)
      enableEntitiesByGroup("welcome");
    else if (_state == GalagaGameState.gameOver)
      enableEntitiesByGroup("gameOver");
    else if (_state == GalagaGameState.stats)
      enableEntitiesByGroup("stats");
    else if (_state == GalagaGameState.paused)
      enableEntitiesByGroup("paused");
    else if (_state == GalagaGameState.options)
      enableEntitiesByGroup("options");
    else if (_state == GalagaGameState.instructions)
      enableEntitiesByGroup("instructions");
    else if (_state == GalagaGameState.levelEnd)
      enableEntitiesByGroup("levelEnd");
    else if (_state == GalagaGameState.leaderboard)
      enableEntitiesByGroup("leaders");
    else if (_state == GalagaGameState.cheats)
      enableEntitiesByGroup("cheats");

  }

  num get waiting => _waiting;
  set waiting(num value) {
    _waiting = value;
    if (_waitingTimer != null)
      _waitingTimer.cancel();

    disableEntitiesByGroup("welcome");
    disableEntitiesByGroup("gameOver");
    disableEntitiesByGroup("stats");
    disableEntitiesByGroup("paused");
    disableEntitiesByGroup("options");
    disableEntitiesByGroup("instructions");
    disableEntitiesByGroup("leaders");
    disableEntitiesByGroup("cheats");

    _waitingTimer = new Timer.periodic(const Duration(milliseconds: 1000), (t) {
        _waiting++;

      if (_waiting == 4) {
        entities.where((e) => e is Stars).toList().forEach((e) => e.removeFromGame());
        for (int i = 0; i < 50; i++)
          startStars();

        enemyX = -400;
        enemyY = -165;
        enemyAmount = 33;

        if (difficulty < 5)
          difficulty++;

        if (visualLevel >= bonusCheck) {
          bonusStage = true;
          tutorial = false;
          bonusCheck += 3;
        } else
          bonusStage = false;

        if (bonusStage == true)
          newBoss();
        else
          for (int i = 0; i < 33; i++) {
            newEnemy(difficulty);
          }
        cloneId = 1;

        state = GalagaGameState.playing;
        timer.timeDecrease = true;
        timer.gameTime = Options["time"];

        t.cancel();
      }
    });
  }

  void start() {
    if (!Stats.containsKey("killed"))
      Stats["killed"] = 0;
    if (!Stats.containsKey("wins"))
      Stats["wins"] = 0;
    if (!Stats.containsKey("deaths"))
      Stats["deaths"] = 0;
    if (!Stats.containsKey("totalGames"))
      Stats["totalGames"] = 0;
    if (!Stats.containsKey("highscore"))
      Stats["highscore"] = 0;
    if (!Stats.containsKey("normalKills"))
      Stats["normalKills"] = 0;
    if (!Stats.containsKey("bossKills"))
      Stats["bossKills"] = 0;
    if (!Stats.containsKey("droneKills"))
      Stats["droneKills"] = 0;
    if (!Stats.containsKey("motherKills"))
      Stats["motherKills"] = 0;
    if (!Stats.containsKey("powerups"))
      Stats["powerups"] = 0;
    if (!Stats.containsKey("percentage"))
      Stats["percentage"] = 0;
    if (!Stats.containsKey("bulletsHit"))
      Stats["bulletsHit"] = 0;
    if (!Stats.containsKey("bulletsFired"))
      Stats["bulletsFired"] = 0;

    if (!Options.containsKey("startLives"))
      Options["startLives"] = 3;
    if (!Options.containsKey("bulletCap"))
      Options["bulletCap"] = 3;
    if (!Options.containsKey("time"))
      Options["time"] = 60;
    if (!Options.containsKey("difficulty"))
      Options["difficulty"] = 1;
    if (!Options.containsKey("powerups"))
      Options["powerups"] = 1;
    if (!Options.containsKey("soundeffects"))
      Options["soundeffects"] = 1;
    if (!Options.containsKey("controls"))
      Options["controls"] = 1;

    if (!Controls.containsKey("left"))
      Controls["left"] = "left";
    if (!Controls.containsKey("right"))
      Controls["right"] = "right";
    if (!Controls.containsKey("fire"))
      Controls["fire"] = "space";

    if (!Highscores.containsKey(1))
      Highscores[1] = 0;
    if (!Highscores.containsKey(2))
      Highscores[2] = 0;
    if (!Highscores.containsKey(3))
      Highscores[3] = 0;
    if (!Highscores.containsKey(4))
      Highscores[4] = 0;
    if (!Highscores.containsKey(5))
      Highscores[5] = 0;
    if (!Highscores.containsKey(6))
      Highscores[6] = 0;
    if (!Highscores.containsKey(7))
      Highscores[7] = 0;
    if (!Highscores.containsKey(8))
      Highscores[8] = 0;
    if (!Highscores.containsKey(9))
      Highscores[9] = 0;
    if (!Highscores.containsKey(10))
      Highscores[10] = 0;

    if (!Cheats.containsKey("spreadshot"))
      Cheats["spreadshot"] = 0;
    if (!Cheats.containsKey("invincibility"))
      Cheats["invincibility"] = 0;
    if (!Cheats.containsKey("super"))
      Cheats["super"] = 0;

    if (Options["soundeffects"] == 1)
      soundEffectsOn = true;
    else
      soundEffectsOn = false;

    createWelcomeMenu();
    createGameOverMenu();
    createStatsMenu();
    createPausedMenu();
    createInstructionsMenu();
    createLeaderBoardMenu();
    createCheatsMenu();

    for (int i = 0; i < 50; i++)
      startStars();

    state = GalagaGameState.welcome;
    super.start();
  }

  void update() {
    if (state == GalagaGameState.playing || state == GalagaGameState.paused) {
      score = score.ceil();
      if (input.isKeyJustPressed(27))
        state = state == GalagaGameState.paused ? GalagaGameState.playing : GalagaGameState.paused;

      if (enemyAmount <= 0) {
        Stats["wins"] += 1;

        removeEntitiesByFilter((e) => e is PowerUp);
        removeEntitiesByFilter((e) => e is Bullet);
        removeEntitiesByFilter((e) => e is Clone);
        removeEntitiesByFilter((e) => e is Enemy);
        removeEntitiesByGroup("levelEnd");
        createLevelEnd();

        state = GalagaGameState.levelEnd;

        waiting = 1;
        if (tutorial == false)
          level++;

        visualLevel++;
      }

      if (score > Stats["highscore"])
        Stats["highscore"] = score;

      if (state == GalagaGameState.playing && Options["soundeffects"] == 1)
        newPowerUp();

      if (state == GalagaGameState.playing)
        newMotherShip();

      if (timer.gameTime <= 0 && !bonusStage)
        gameOver();
      else if (bonusStage && timer.gameTime <= 0) {
        Stats["wins"] += 1;

        removeEntitiesByFilter((e) => e is PowerUp);
        removeEntitiesByFilter((e) => e is Bullet);
        removeEntitiesByFilter((e) => e is Enemy);
        removeEntitiesByFilter((e) => e is Clone);
        removeEntitiesByGroup("levelEnd");
        createLevelEnd();

        state = GalagaGameState.levelEnd;

        waiting = 1;

        level++;

        visualLevel++;
      }
    }

    entities.where((e) => e is GameButton).forEach((e) {
      if (e.opacity == 1.0 && e.isHighlighted && e.soundReady) {
        e.soundReady = false;
      } else if (e.opacity < 1.0)
        e.soundReady = true;
    });

    newStar();
    super.update();
  }

  void startStars() {
    if (colorCount < 7)
      colorCount++;
    else if (colorCount >= 7)
      colorCount = 1;

    num w = random(.5, 3.5);
    Stars star = new Stars(this, 0, 0, w, w, colorCount);

    star.x = random(-rect.halfWidth, rect.halfWidth);
    star.y = random(-rect.halfHeight, rect.halfHeight);

    addEntity(star);
  }

  void newParticle(num x, num y, xVel, yVel) {
    num w = random(.5, 3.5);

    Particles particle = new Particles(this, x, y, w, w, colorCount, xVel, yVel);

    addEntity(particle);
  }

  void newExplosion(num x, num y) {
    num xV = 50;
    num yV = 80;

    for (int i = 0; i < 3; i++) {
      newParticle(x, y, xV, yV);
      yV -= 80;
    }

    xV *= -1;
    yV = 80;
    for (int i = 0; i < 3; i++) {
      newParticle(x, y, xV, yV);
      yV -= 80;
    }

    newParticle(x, y, 0, 100);
    newParticle(x, y, 0, -100);
  }

  void newMiniExplosion(num x, num y) {

    newParticle(x, y, 50, 0);
    newParticle(x, y, -50, 0);

    newParticle(x, y, 0, 50);
    newParticle(x, y, 0, -50);
  }

  void newStar() {
    num rand = random(0, 1);

    if (rand > .09 || state == GalagaGameState.paused)
      return;

    num w = random(.5, 3.5);

    colorCount++;

    if (colorCount > 7)
      colorCount = 1;

    Stars star = new Stars(this, random(-rect.halfWidth, rect.halfWidth), -(rect.halfHeight) - 20, w, w, colorCount);

    lastStar = timer.gameTime;
    addEntity(star);
  }

  void newBoss() {
    Enemy enemy = new Enemy(this, 0, 0, difficulty, "Boss");

    enemy.idNum = nextId;
    nextId++;
    enemy.y = -200;

    addEntity(enemy);
  }

  void newBouncer(num sprite) {
    bouncingBall bouncer = new bouncingBall(this, 0, 0, 36, 36, sprite);

    if (sprite == 1) {
      bouncer.height = 42;
      bouncer.width = 42;
    } else if (sprite == 5) {
      bouncer.height = 12;
      bouncer.width = 12;
    } else if (sprite == 6) {
      bouncer.height = 42;
      bouncer.width = 42;
    } else if (sprite == 7) {
      bouncer.height = 42;
      bouncer.width = 42;
    } else if (sprite == 8) {
      bouncer.height = 42;
      bouncer.width = 42;
    } else if (sprite == 9) {
      bouncer.height = 72;
      bouncer.width = 72;
    } else if (sprite == 10) {
      bouncer.height = 36;
      bouncer.width = 36;
    } else if (sprite == 11) {
      bouncer.height = 62;
      bouncer.width = 62;
    } else if (sprite == 12) {
      bouncer.height = 42;
      bouncer.width = 42;
    } else if (sprite == 13) {
      bouncer.height = 62;
      bouncer.width = 62;
    }  else if (sprite == 14) {
      bouncer.height = 42;
      bouncer.width = 42;
    } else if (sprite == 15) {
      bouncer.height = 42;
      bouncer.width = 42;
    } else if (sprite == 16) {
      bouncer.height = 42;
      bouncer.width = 42;
    } else if (sprite == 17) {
      bouncer.height = 42;
      bouncer.width = 42;
    }  else if (sprite == 18) {
      bouncer.height = 42;
      bouncer.width = 42;
    }

    addEntity(bouncer);
  }

  void newBossDrone(num x, num y) {
    int x = 0;

    entities.where((e) => e is Enemy).forEach((e) {
      var enemy = e as Enemy;

      if (enemy.type == "Drone") {
        x++;
      }
    });

    if (x >= 6)
      return;

    num rand = random(0, 1);

    if (rand < .01) {
      Enemy enemy = new Enemy(this, x, y, difficulty, "Drone");

      enemy.idNum = nextId;
      nextId++;

      addEntity(enemy);
    }
  }

  void newMotherShip({num difficulty: 1}) {
    int x = 0;

    entities.where((e) => e is Enemy).forEach((Enemy e) {
      if (e.type == "MotherShip") {
        x++;
      }
    });

    if (x >=2)
      return;

    num rand = random(0, 1);

    if (rand < .001) {
      Enemy enemy = new Enemy(this, -(rect.halfWidth), -225, difficulty, "MotherShip");

      enemy.idNum = nextId;
      nextId++;

      addEntity(enemy);
    }
  }

  void newEnemy([num difficulty = 1]) {

    Enemy enemy = new Enemy(this, enemyX, enemyY, difficulty, "Normal");
    Clone clone = new Clone(this, enemy.x, enemy.y);

    enemy.startY = enemyY;

    enemy.cloneNum = cloneId;
    clone.Id = cloneId;
    cloneId++;

    enemyX += 70;
    enemyCount++;

    if (enemyCount > 10) {
     enemyY += 65;
     enemyX = -400;
     enemyCount = 0;
    }

    enemy.idNum = nextId;
    nextId++;

    lastEnemy = timer.gameTime;
    addEntity(enemy);
    addEntity(clone);
  }

  void newBulletPowerUp(num x, num y) {
    PowerUp powerUp = new PowerUp(this, x, y, "bulletPower");

    addEntity(powerUp);
  }

  void newPowerUp() {
    num rand = random(0, 1);

    if (rand > .001)
      return;

    PowerUp powerUp = new PowerUp(this, 0, 0);

    do {
      powerUp.x = random(-rect.halfWidth + 50, rect.halfWidth - 50);
      powerUp.y = -rect.halfHeight;

    } while(entities.where((e) => e is PowerUp).any((e) => powerUp.collidesWith(e)));

    lastPowerUp = timer.gameTime;
    addEntity(powerUp);
  }

  num getEnemyX(String type) {
    entities.where((e) => e is Enemy).forEach((Enemy e) {
      if (e.type == type)
        return e.x;
    });

    return 0;
  }

  num getEnemyY(String type) {
    entities.where((e) => e is Enemy).toList().forEach((Enemy e) {
      if (e.type == type)
        return e.y;
    });

    return 0;
  }

  void createCheatsMenu() {
    addEntity(new GameText(game: this,
        x: 0,
        y: -240,
        text: "ECSTACY!",
        size: 56,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.8,
        id: "",
        groupId: "cheats"));

    addEntity(new GameText(game: this,
        x: -38,
        y: -94,
        text: "SpreadShot:",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.7,
        id: "",
        groupId: "cheats"));

    addEntity(new GameButton(game: this,
        x: 200,
        y: -94,
        text: Cheats["spreadshot"] == 1 ? "On" : "Off",
        buttonAction: () {
          if (Cheats["spreadshot"] >= 2)
            Cheats["spreadshot"] = 1;
          else
            Cheats["spreadshot"] += 1;

          _statUpdateEvent.signal();

          state = GalagaGameState.welcome;

          removeEntitiesByGroup("cheats");
          createCheatsMenu();

          state = GalagaGameState.cheats;
        },
        size: 36,
        font: "cinnamoncake, Verdana",
        centered: true,
        color: "255, 255, 255",
        opacity: 0.7,
        id: "",
        groupId: "cheats"));

    addEntity(new GameText(game: this,
        x: -38,
        y: -64,
        text: "Invincibility:",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.7,
        id: "",
        groupId: "cheats"));

    addEntity(new GameButton(game: this,
        x: 200,
        y: -64,
        text: Cheats["invincibility"] == 1 ? "On" : "Off",
        buttonAction: () {
          if (Cheats["invincibility"] >= 2)
            Cheats["invincibility"] = 1;
          else
            Cheats["invincibility"] += 1;

          _statUpdateEvent.signal();

          state = GalagaGameState.welcome;

          removeEntitiesByGroup("cheats");
          createCheatsMenu();

          state = GalagaGameState.cheats;
        },
        size: 36,
        font: "cinnamoncake, Verdana",
        centered: true,
        color: "255, 255, 255",
        opacity: 0.7,
        id: "",
        groupId: "cheats"));

    addEntity(new GameText(game: this,
        x: -38,
        y: -30,
        text: "SuperShot:",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.7,
        id: "",
        groupId: "cheats"));

    addEntity(new GameButton(game: this,
        x: 200,
        y: -30,
        text: Cheats["super"] == 1 ? "On" : "Off",
        buttonAction: () {
          if (Cheats["super"] >= 2)
            Cheats["super"] = 1;
          else
            Cheats["super"] += 1;

          _statUpdateEvent.signal();

          state = GalagaGameState.welcome;

          removeEntitiesByGroup("cheats");
          createCheatsMenu();

          state = GalagaGameState.cheats;
        },
        size: 36,
        font: "cinnamoncake, Verdana",
        centered: true,
        color: "255, 255, 255",
        opacity: 0.7,
        id: "",
        groupId: "cheats"));

    addEntity(new GameText(game: this,
        x: -38,
        y: 0,
        text: "Powerups:",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.8,
        id: "",
        groupId: "cheats"));

    addEntity(new GameText(game: this,
        x: 200,
        y: 0,
        text: "${powerupChoice}",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.8,
        id: "",
        groupId: "cheats"));

    addEntity(new GameButton(game: this,
        x: 325,
        y: 0,
        text: "->",
        buttonAction: () {
         if (powerupChoice == "All") {
           powerupChoice = "SpiralShot";
           spiral = 1;
           multi = 0;
           bullet = 0;
           invincible = 0;
           time = 0;
           life = 0;
           teleporter = 0;

         } else if (powerupChoice == "SpiralShot") {
           powerupChoice = "Multiplier";
           spiral = 0;
           multi = 1;
           bullet = 0;
           invincible = 0;
           time = 0;
           life = 0;
           teleporter = 0;

         } else if (powerupChoice == "Multiplier") {
           powerupChoice = "BulletIncrease";
           spiral = 0;
           multi = 0;
           bullet = 1;
           invincible = 0;
           time = 0;
           life = 0;
           teleporter = 0;

         } else if (powerupChoice == "BulletIncrease") {
           powerupChoice = "Invincible";
           spiral = 0;
           multi = 0;
           bullet = 0;
           invincible = 1;
           time = 0;
           life = 0;
           teleporter = 0;

         } else if (powerupChoice == "Invincible") {
           powerupChoice = "TimeUp";
           spiral = 0;
           multi = 0;
           bullet = 0;
           invincible = 0;
           time = 1;
           life = 0;
           teleporter = 0;

         } else if (powerupChoice == "TimeUp") {
           powerupChoice = "ExtraLife";
           spiral = 0;
           multi = 0;
           bullet = 0;
           invincible = 0;
           time = 0;
           life = 1;
           teleporter = 0;

         }  else if (powerupChoice == "ExtraLife") {
           powerupChoice = "Teleporter";
           spiral = 0;
           multi = 0;
           bullet = 0;
           invincible = 0;
           time = 0;
           life = 0;
           teleporter = 1;

         }else if (powerupChoice == "Teleporter") {
           powerupChoice = "All";
           teleporter = .05;
           spiral = .06;
           multi = .25;
           bullet = .55;
           invincible = .70;
           time = .80;
           life = 1;

         }

          _statUpdateEvent.signal();

          state = GalagaGameState.welcome;

          removeEntitiesByGroup("cheats");
          createCheatsMenu();

          state = GalagaGameState.cheats;
        },
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.8,
        id: "",
        groupId: "cheats"));

    addEntity(new GameButton(game: this,
        x: 70,
        y: 0,
        text: "<-",
        buttonAction: () {
          if (powerupChoice == "Teleporter") {
            powerupChoice = "ExtraLife";
            spiral = 0;
            multi = 0;
            bullet = 0;
            invincible = 0;
            time = 0;
            life = 1;
            teleporter = 0;

          } else if (powerupChoice == "All") {
            powerupChoice = "Teleporter";
            spiral = 0;
            multi = 0;
            bullet = 0;
            invincible = 0;
            time = 0;
            life = 0;
            teleporter = 1;

          }else if (powerupChoice == "SpiralShot") {
            powerupChoice = "All";
            teleporter = .05;
            spiral = .06;
            multi = .25;
            bullet = .55;
            invincible = .70;
            time = .80;
            life = 1;

          } else if (powerupChoice == "Multiplier") {
            powerupChoice = "SpiralShot";
            spiral = 1;
            multi = 0;
            bullet = 0;
            invincible = 0;
            time = 0;
            life = 0;
            teleporter = 0;

          } else if (powerupChoice == "BulletIncrease") {
            powerupChoice = "Multiplier";
            spiral = 0;
            multi = 1;
            bullet = 0;
            invincible = 0;
            time = 0;
            life = 0;
            teleporter = 0;

          } else if (powerupChoice == "Invincible") {
            powerupChoice = "BulletIncrease";
            spiral = 0;
            multi = 0;
            bullet = 1;
            invincible = 0;
            time = 0;
            life = 0;
            teleporter = 0;

          } else if (powerupChoice == "TimeUp") {
            powerupChoice = "Invincible";
            spiral = 0;
            multi = 0;
            bullet = 0;
            invincible = 1;
            time = 0;
            life = 0;
            teleporter = 0;

          } else if (powerupChoice == "ExtraLife") {
            powerupChoice = "TimeUp";
            spiral = 0;
            multi = 0;
            bullet = 0;
            invincible = 0;
            time = 1;
            life = 0;
            teleporter = 0;

          }

          _statUpdateEvent.signal();

          state = GalagaGameState.welcome;

          removeEntitiesByGroup("cheats");
          createCheatsMenu();

          state = GalagaGameState.cheats;
        },
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.8,
        id: "",
        groupId: "cheats"));

    addEntity(new GameButton(game: this,
        x: 400,
        y: 275,
        text: "Made by Cody Smith",
        buttonAction: () {
          removeEntitiesByGroup("welcome");
          createWelcomeMenu();

          state = GalagaGameState.welcome;

          _fadeEvent.signal();
        },
        size: 16,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.7,
        id: "",
        groupId: "cheats"));

    disableEntitiesByGroup("cheats");
  }

  void createLevelEnd() {
    addEntity(new GameText(game: this,
        x: 0,
        y: -97,
        text: visualLevel != bonusCheck ? "Level ${visualLevel} Complete!" : "Prepare for Bonus Stage!",
        size: 56,
        font: "cinnamoncake, Verdana",
        centered: true,
        color: "255, 255, 255",
        opacity: 0.7,
        id: "",
        groupId: "levelEnd"));

    disableEntitiesByGroup("levelEnd");
  }

  void createWelcomeMenu() {
    _gameOverEvent.signal();

    num highscore = Highscores[1];

    if (highscore >= 1000000)
      rank = "Pablo Manrequez";
    else if (highscore >= 500000)
      rank = "God of all Dimensions";
    else if (highscore >= 200000)
      rank = "Commander of Multi-verse";
    else if (highscore >= 100000)
      rank = "Overseer of Multi-verse";
    else if (highscore >= 95000)
      rank = "Overlord of the Universe";
    else if (highscore >= 85000)
      rank = "Commander of the Universe";
    else if (highscore >= 75000)
      rank = "President of the Universe";
    else if (highscore >= 65000)
      rank = "Overlord of the Galaxy";
    else if (highscore >= 55000)
      rank = "Space Captain";
    else if (highscore >= 45000)
      rank = "Space Cadet";
    else if (highscore >= 35000)
      rank = "Space Recruit";
    else if (highscore >= 25000)
      rank = "Road Warrior";
    else if (highscore >= 15000)
      rank = "Amish Mastermind";
    else if (highscore >= 10000)
      rank = "Jewish Priest";
    else if ((highscore >= 5000 || highscore <= 5000) && highscore != 0)
      rank = "Jew";
    else if (highscore == 0)
      rank = "";

    addEntity(new GameText(game: this,
        x: 0,
        y: -275,
        text: "You're: ${rank}",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: .65,
        id: "",
        groupId: "welcome"));

    addEntity(new GameText(game: this,
        x: 0,
        y: -97,
        text: "Welcome to Galaga Ecstacy X!",
        size: 56,
        font: "cinnamoncake, Verdana",
        centered: true,
        color: "255, 255, 255",
        opacity: 0.8,
        id: "",
        groupId: "welcome"));

    addEntity(new GameText(game: this,
        x: 400,
        y: 275,
        text: "Made by Cody Smith",
        size: 16,
        font: "cinnamoncake, Verdana",
        centered: true,
        color: "255, 255, 255",
        opacity: 0.7,
        id: "",
        groupId: "welcome"));

    addEntity(new GameButton(game: this,
        x: 0,
        y: -31,
        text: "Start Game",
        buttonAction: () {
          newGame();
          _statUpdateEvent.signal();
        },
        size: 36,
        font: "cinnamoncake, Verdana",
        centered: true,
        color: "255, 255, 255",
        opacity: 0.7,
        id: "",
        groupId: "welcome"));

    addEntity(new GameButton(game: this,
        x: 0,
        y: 14,
        text: "Statistics",
        buttonAction: () {
          removeEntitiesByGroup("stats");
          createStatsMenu();

          state = GalagaGameState.stats;

          _fadeEvent.signal();
          _statUpdateEvent.signal();
        },
        size: 36,
        font: "cinnamoncake, Verdana",
        centered: true,
        color: "255, 255, 255",
        opacity: 0.7,
        id: "",
        groupId: "welcome"));

    addEntity(new GameButton(game: this,
        x: 0,
        y: 48,
        text: "Options",
        buttonAction: () {
          removeEntitiesByGroup("options");
          createOptionsMenu();

          state = GalagaGameState.options;

          _fadeEvent.signal();
          _statUpdateEvent.signal();
        },
        size: 36,
        font: "cinnamoncake, Verdana",
        centered: true,
        color: "255, 255, 255",
        opacity: 0.7,
        id: "",
        groupId: "welcome"));

    addEntity(new GameButton(game: this,
        x: 0,
        y: 82,
        text: "Leaderboard",
        buttonAction: () {
          removeEntitiesByGroup("leaders");
          createLeaderBoardMenu();

          state = GalagaGameState.leaderboard;

          _fadeEvent.signal();
          _statUpdateEvent.signal();
        },
        size: 36,
        font: "cinnamoncake, Verdana",
        centered: true,
        color: "255, 255, 255",
        opacity: 0.7,
        id: "",
        groupId: "welcome"));

    disableEntitiesByGroup("welcome");
  }

  void createPausedMenu() {
    addEntity(new GameText(game: this,
        x: 0,
        y: -31,
        text: "PAUSED",
        size: 56,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.7,
        id: "",
        groupId: "paused"));


    addEntity(new GameButton(game: this,
        x: 0,
        y: 15,
        text: "Quit",
        buttonAction: () {
          if (ship != null)
            ship.removeFromGame();

          removeEntitiesByFilter((e) => e is PowerUp);
          removeEntitiesByFilter((e) => e is Clone);
          removeEntitiesByFilter((e) => e is Bullet);
          removeEntitiesByFilter((e) => e is Enemy);

          _statUpdateEvent.signal();

          updateLeaderboard();

          _gameOverEvent.signal();
          _statUpdateEvent.signal();

          removeEntitiesByGroup("welcome");
          createWelcomeMenu();

          state = GalagaGameState.welcome;
      },
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.7,
        id: "",
        groupId: "paused"));

    disableEntitiesByGroup("paused");
  }

  void createLeaderBoardMenu() {
    for (int i = 1; i < 11; i++) {
      num iScore = Highscores[i];

      if (iScore >= 1000000)
        HighscoresRank[i] = "Pablo Manrequez";
      else if (iScore >= 500000)
        HighscoresRank[i] = "God of all Dimensions";
      else if (iScore >= 200000)
        HighscoresRank[i] = "Commander of Multi-verse";
      else if (iScore >= 100000)
        HighscoresRank[i] = "Overseer of Multi-verse";
      else if (iScore >= 95000)
        HighscoresRank[i] = "Overlord of the Universe";
      else if (iScore >= 85000)
        HighscoresRank[i] = "Commander of the Universe";
      else if (iScore >= 75000)
        HighscoresRank[i] = "President of the Universe";
      else if (iScore >= 65000)
        HighscoresRank[i] = "Overlord of the Galaxy";
      else if (iScore >= 55000)
        HighscoresRank[i] = "Space Captain";
      else if (iScore >= 45000)
        HighscoresRank[i] = "Space Cadet";
      else if (iScore >= 35000)
        HighscoresRank[i] = "Space Recruit";
      else if (iScore >= 25000)
        HighscoresRank[i] = "Road Warrior";
      else if (iScore >= 15000)
        HighscoresRank[i] = "Amish Mastermind";
      else if (iScore >= 10000)
        HighscoresRank[i] = "Jewish Priest";
      else if ((iScore >= 5000 || iScore <= 5000) && iScore != 0)
        HighscoresRank[i] = "Jew";
      else if (iScore == 0)
        HighscoresRank[i] = "";
    }

    addEntity(new GameText(game: this,
        x: 0,
        y: -240,
        text: "Leaderboard",
        size: 56,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.8,
        id: "",
        groupId: "leaders"));

    addEntity(new GameText(game: this,
        x: 400,
        y: 275,
        text: "Made by Cody Smith",
        size: 16,
        font: "cinnamoncake, Verdana",
        centered: true,
        color: "255, 255, 255",
        opacity: 0.7,
        id: "",
        groupId: "leaders"));

    addEntity(new GameText(game: this,
        x: -160,
        y: -175,
        text: "Score",
        size: 42,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.8,
        id: "",
        groupId: "leaders"));

    addEntity(new GameText(game: this,
        x: 160,
        y: -175,
        text: "Ranking",
        size: 42,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.8,
        id: "",
        groupId: "leaders"));

    addEntity(new GameText(game: this,
        x: -160,
        y: -135,
        text: Highscores[1] <= 0 ? "" : "1: ${Highscores[1]}",
        size: 42,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.7,
        id: "",
        groupId: "leaders"));

    addEntity(new GameText(game: this,
        x: 160,
        y: -135,
        text: "${HighscoresRank[1]}",
        size: 42,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.7,
        id: "",
        groupId: "leaders"));

    addEntity(new GameText(game: this,
        x: -160,
        y: -95,
        text: Highscores[2] <= 0 ? "" : "2: ${Highscores[2]}",
        size: 42,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.7,
        id: "",
        groupId: "leaders"));

    addEntity(new GameText(game: this,
        x: 160,
        y: -95,
        text: "${HighscoresRank[2]}",
        size: 42,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.7,
        id: "",
        groupId: "leaders"));

    addEntity(new GameText(game: this,
        x: -160,
        y: -55,
        text: Highscores[3] <= 0 ? "" : "3: ${Highscores[3]}",
        size: 42,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.7,
        id: "",
        groupId: "leaders"));

    addEntity(new GameText(game: this,
        x: 160,
        y: -55,
        text: "${HighscoresRank[3]}",
        size: 42,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.7,
        id: "",
        groupId: "leaders"));

    addEntity(new GameText(game: this,
        x: -160,
        y: -15,
        text: Highscores[4] <= 0 ? "" : "4: ${Highscores[4]}",
        size: 42,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.7,
        id: "",
        groupId: "leaders"));

    addEntity(new GameText(game: this,
        x: 160,
        y: -15,
        text: "${HighscoresRank[4]}",
        size: 42,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.7,
        id: "",
        groupId: "leaders"));

    addEntity(new GameText(game: this,
        x: -160,
        y: 25,
        text: Highscores[5] <= 0 ? "" : "5: ${Highscores[5]}",
        size: 42,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.7,
        id: "",
        groupId: "leaders"));

    addEntity(new GameText(game: this,
        x: 160,
        y: 25,
        text: "${HighscoresRank[5]}",
        size: 42,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.7,
        id: "",
        groupId: "leaders"));

    addEntity(new GameText(game: this,
        x: -160,
        y: 65,
        text: Highscores[6] <= 0 ? "" : "6: ${Highscores[6]}",
        size: 42,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.7,
        id: "",
        groupId: "leaders"));

    addEntity(new GameText(game: this,
        x: 160,
        y: 65,
        text: "${HighscoresRank[6]}",
        size: 42,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.7,
        id: "",
        groupId: "leaders"));

    addEntity(new GameText(game: this,
        x: -160,
        y: 105,
        text: Highscores[7] <= 0 ? "" : "7: ${Highscores[7]}",
        size: 42,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.7,
        id: "",
        groupId: "leaders"));

    addEntity(new GameText(game: this,
        x: 160,
        y: 105,
        text: "${HighscoresRank[7]}",
        size: 42,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.7,
        id: "",
        groupId: "leaders"));

    addEntity(new GameText(game: this,
        x: -160,
        y: 145,
        text: Highscores[8] <= 0 ? "" : "8: ${Highscores[8]}",
        size: 42,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.7,
        id: "",
        groupId: "leaders"));

    addEntity(new GameText(game: this,
        x: 160,
        y: 145,
        text: "${HighscoresRank[8]}",
        size: 42,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.7,
        id: "",
        groupId: "leaders"));

    addEntity(new GameText(game: this,
        x: -160,
        y: 185,
        text: Highscores[9] <= 0 ? "" : "9: ${Highscores[9]}",
        size: 42,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.7,
        id: "",
        groupId: "leaders"));

    addEntity(new GameText(game: this,
        x: 160,
        y: 185,
        text: "${HighscoresRank[9]}",
        size: 42,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.7,
        id: "",
        groupId: "leaders"));

    addEntity(new GameText(game: this,
        x: -160,
        y: 225,
        text: Highscores[10] <= 0 ? "" : "10: ${Highscores[10]}",
        size: 42,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.8,
        id: "",
        groupId: "leaders"));

    addEntity(new GameText(game: this,
        x: 160,
        y: 225,
        text: "${HighscoresRank[10]}",
        size: 42,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.8,
        id: "",
        groupId: "leaders"));

    addEntity(new GameButton(game: this,
        x: 0,
        y: 275,
        text: "RESET",
        buttonAction: () => resetLeaderBoard(),
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.7,
        id: "",
        groupId: "leaders"));

    addEntity(new GameButton(game: this,
        x: -420,
        y: -280,
        text: "Back",
        buttonAction: () {
          removeEntitiesByGroup("welcome");
          createWelcomeMenu();

          state = GalagaGameState.welcome;
          _fadeEvent.signal();
          _statUpdateEvent.signal();
        },
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.7,
        id: "",
        groupId: "leaders"));

    disableEntitiesByGroup("leaders");
  }

  void createStatsMenu() {
    addEntity(new GameText(game: this,
        x:  0,
        y: -280,
        text: "Statistics",
        size: 56,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.8,
        id: "",
        groupId: "stats"));

    addEntity(new GameText(game: this,
        x: 400,
        y: 275,
        text: "Made by Cody Smith",
        size: 16,
        font: "cinnamoncake, Verdana",
        centered: true,
        color: "255, 255, 255",
        opacity: 0.7,
        id: "",
        groupId: "stats"));

    addEntity(new GameText(game: this,
        x: 0,
        y: -200,
        text: "Total Killed: ${Stats["killed"]}",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.8,
        id: "",
        groupId: "stats"));

    addEntity(new GameText(game: this,
        x: 0,
        y: -155,
        text: "Groupies Annihilated: ${Stats["normalKills"]}",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.8,
        id: "",
        groupId: "stats"));

    addEntity(new GameText(game: this,
        x: 0,
        y: -110,
        text: "Motherships Deflowered: ${Stats["bossKills"]}",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.8,
        id: "",
        groupId: "stats"));

    addEntity(new GameText(game: this,
        x: 0,
        y: -65,
        text: "Mothership Drones Overkilled: ${Stats["droneKills"]}",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.8,
        id: "",
        groupId: "stats"));

    addEntity(new GameText(game: this,
        x: 0,
        y: -20,
        text: "UFO's Eviscerated: ${Stats["motherKills"]}",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.8,
        id: "",
        groupId: "stats"));

    addEntity(new GameText(game: this,
        x: 0,
        y: 25,
        text: "Powerups Absorbed: ${Stats["powerups"]}",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.8,
        id: "",
        groupId: "stats"));

    addEntity(new GameText(game: this,
        x: 0,
        y: 70,
        text: "Total Completed Levels: ${Stats["wins"]}",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.8,
        id: "",
        groupId: "stats"));

    addEntity(new GameText(game: this,
        x: 0,
        y: 115,
        text: "Total Deaths: ${Stats["deaths"]}",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.8,
        id: "",
        groupId: "stats"));

    addEntity(new GameText(game: this,
        x: 0,
        y: 160,
        text: "Total Games: ${Stats["totalGames"]}",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.8,
        id: "",
        groupId: "stats"));

    addEntity(new GameText(game: this,
        x: 0,
        y: 205,
        text: "High Score: ${Stats["highscore"]}",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.8,
        id: "",
        groupId: "stats"));

    addEntity(new GameButton(game: this,
        x: -420,
        y: -280,
        text: "Back",
        buttonAction: () {
          removeEntitiesByGroup("welcome");
          createWelcomeMenu();

          state = GalagaGameState.welcome;
          _fadeEvent.signal();
          _statUpdateEvent.signal();
        },
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.8,
        id: "",
        groupId: "stats"));

    addEntity(new GameButton(game: this,
        x: 0,
        y: 250,
        text: "RESET",
        buttonAction: () => resetStats(),
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.8,
        id: "",
        groupId: "stats"));

    disableEntitiesByGroup("stats");
  }

  void createOptionsMenu() {
    _gameOverEvent.signal();

    addEntity(new GameText(game: this,
        x: 0,
        y: -160,
        text: "Options",
        size: 56,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.8,
        id: "",
        groupId: "options"));

    addEntity(new GameButton(game: this,
        x: 400,
        y: 275,
        text: "Made by Cody Smith",
        buttonAction: () {
          removeEntitiesByGroup("cheats");
          createCheatsMenu();

          state = GalagaGameState.cheats;

          newBouncer(10);
          newBouncer(10);
          newBouncer(10);
          newBouncer(10);
          newBouncer(10);
          newBouncer(10);

          _fadeEvent.signal();
        },
        size: 16,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.8,
        id: "",
        groupId: "options"));

    addEntity(new GameText(game: this,
        x: 0,
        y: -30,
        text: "Starting Lives:",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.8,
        id: "",
        groupId: "options"));

    addEntity(new GameText(game: this,
        x: 200,
        y: -30,
        text: "${Options["startLives"]}",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.8,
        id: "",
        groupId: "options"));

    addEntity(new GameButton(game: this,
        x: 245,
        y: -30,
        text: "->",
        buttonAction: () {
          if (Options["startLives"] >= 10) {
            Options["startLives"] = 1;
          }
          else {
            Options["startLives"]++;
          }

          _statUpdateEvent.signal();

          state = GalagaGameState.welcome;

          removeEntitiesByGroup("options");
          createOptionsMenu();

          state = GalagaGameState.options;
        },
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.8,
        id: "",
        groupId: "options"));

    addEntity(new GameButton(game: this,
        x: 160,
        y: -30,
        text: "<-",
        buttonAction: () {
          if (Options["startLives"] <= 1) {
            Options["startLives"] = 10;
          }
          else {
            Options["startLives"]--;
          }

          _statUpdateEvent.signal();

          state = GalagaGameState.welcome;

          removeEntitiesByGroup("options");
          createOptionsMenu();

          state = GalagaGameState.options;
        },
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.8,
        id: "",
        groupId: "options"));

    addEntity(new GameText(game: this,
        x: 300,
        y: -30,
        text: "x${3 / Options["startLives"]}",
        size: 26,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.8,
        id: "",
        groupId: "options"));

    addEntity(new GameText(game: this,
        x: 0,
        y: 0,
        text: "Time:",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.8,
        id: "",
        groupId: "options"));

    addEntity(new GameText(game: this,
        x: 200,
        y: 0,
        text: "${Options["time"]}",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.8,
        id: "",
        groupId: "options"));

    addEntity(new GameButton(game: this,
        x: 245,
        y: 0,
        text: "->",
        buttonAction: () {
          if (Options["time"] >= 180)
            Options["time"] = 0;
          else
            Options["time"] += 20;

          _statUpdateEvent.signal();

          state = GalagaGameState.welcome;

          removeEntitiesByGroup("options");
          createOptionsMenu();

          state = GalagaGameState.options;
        },
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.8,
        id: "",
        groupId: "options"));

    addEntity(new GameButton(game: this,
        x: 160,
        y: 0,
        text: "<-",
        buttonAction: () {
          if (Options["time"] <= 0)
            Options["time"] = 180;
          else
            Options["time"] -= 20;

          _statUpdateEvent.signal();

          state = GalagaGameState.welcome;

          removeEntitiesByGroup("options");
          createOptionsMenu();

          state = GalagaGameState.options;
        },
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.8,
        id: "",
        groupId: "options"));

    addEntity(new GameText(game: this,
        x: 300,
        y: 0,
        text: "x${60 / Options["time"]}",
        size: 26,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.8,
        id: "",
        groupId: "options"));

    addEntity(new GameText(game: this,
        x: 0,
        y: 30,
        text: "Difficulty:",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.8,
        id: "",
        groupId: "options"));

    addEntity(new GameText(game: this,
        x: 200,
        y: 30,
        text: "${Options["difficulty"]}",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.8,
        id: "",
        groupId: "options"));

    addEntity(new GameButton(game: this,
        x: 245,
        y: 30,
        text: "->",
        buttonAction: () {
          if (Options["difficulty"] >= 5)
            Options["difficulty"] = 1;
          else
            Options["difficulty"] += 1;

          _statUpdateEvent.signal();

          state = GalagaGameState.welcome;

          removeEntitiesByGroup("options");
          createOptionsMenu();

          state = GalagaGameState.options;
        },
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.8,
        id: "",
        groupId: "options"));

    addEntity(new GameButton(game: this,
        x: 160,
        y: 30,
        text: "<-",
        buttonAction: () {
          if (Options["difficulty"] <= 1)
            Options["difficulty"] = 5;
          else
            Options["difficulty"] -= 1;

          _statUpdateEvent.signal();

          state = GalagaGameState.welcome;

          removeEntitiesByGroup("options");
          createOptionsMenu();

          state = GalagaGameState.options;
        },
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.8,
        id: "",
        groupId: "options"));

    addEntity(new GameText(game: this,
        x: 300,
        y: 30,
        text: "x${Options["difficulty"]}.0",
        size: 26,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.8,
        id: "",
        groupId: "options"));

    addEntity(new GameText(game: this,
        x: -38,
        y: -64,
        text: "Powerups Enabled:",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.8,
        id: "",
        groupId: "options"));

    addEntity(new GameButton(game: this,
        x: 200,
        y: -64,
        text: Options["powerups"] == 1 ? "On" : "Off",
        buttonAction: () {

          if (Options["powerups"] >= 2)
            Options["powerups"] = 1;
          else
            Options["powerups"] += 1;

          _statUpdateEvent.signal();

          state = GalagaGameState.welcome;

          removeEntitiesByGroup("options");
          createOptionsMenu();

          state = GalagaGameState.options;
        },
        size: 36,
        font: "cinnamoncake, Verdana",
        centered: true,
        color: "255, 255, 255",
        opacity: 0.8,
        id: "",
        groupId: "options"));

    addEntity(new GameText(game: this,
        x: 300,
        y: -64,
        text: Options["powerups"] == 1 ? "x1.0" : "x2.0",
        size: 26,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.8,
        id: "",
        groupId: "options"));

//    addEntity(new GameText(game: this,
//        x: -38,
//        y: 60,
//        text: "Sound Effects Enabled:",
//        size: 36,
//        font: "cinnamoncake, Verdana",
//        centered:  true,
//        color: "255, 255, 255",
//        opacity: 0.8,
//        id: "",
//        groupId: "options"));
//
//    addEntity(new GameButton(game: this,
//        x: 200,
//        y: 60,
//        text: Options["soundeffects"] == 1 ? "On" : "Off",
//        buttonAction: () {
//
//          if (Options["soundeffects"] >= 2)
//            Options["soundeffects"] = 1;
//          else
//            Options["soundeffects"] += 1;
//
//          if (Options["soundeffects"] == 1)
//            soundEffectsOn = true;
//          else
//            soundEffectsOn = false;
//
//          _statUpdateEvent.signal();
//
//          state = GalagaGameState.welcome;
//
//          removeEntitiesByGroup("options");
//          createOptionsMenu();
//
//          state = GalagaGameState.options;
//        },
//        size: 36,
//        font: "cinnamoncake, Verdana",
//        centered: true,
//        color: "255, 255, 255",
//        opacity: 0.8,
//        id: "",
//        groupId: "options"));

    addEntity(new GameText(game: this,
        x: 0,
        y: 60,
        text: "Input Type:",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.8,
        id: "",
        groupId: "options"));

    addEntity(new GameButton(game: this,
        x: 200,
        y: 60,
        text: Options["controls"] == 1 ? "Keyboard" : "Mouse",
        buttonAction: () {

          if (Options["controls"] >= 2)
            Options["controls"] = 1;
          else
            Options["controls"] += 1;

          _statUpdateEvent.signal();

          state = GalagaGameState.welcome;

          removeEntitiesByGroup("options");
          createOptionsMenu();

          state = GalagaGameState.options;
        },
        size: 36,
        font: "cinnamoncake, Verdana",
        centered: true,
        color: "255, 255, 255",
        opacity: 0.7,
        id: "",
        groupId: "options"));

    addEntity(new GameText(game: this,
        x: 300,
        y: 90,
        text: Options["powerups"] == 2 ? "x${2 * ((60 / Options["time"]) + Options["difficulty"] + (3 / Options["startLives"]))}" : "x${(60 / Options["time"]) + Options["difficulty"] + (3 / Options["startLives"])}",
        size: 26,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.8,
        id: "",
        groupId: "options"));

    addEntity(new GameButton(game: this,
        x: 10,
        y: 150,
        text: "Set to Defaults",
        buttonAction: () => resetOptions(),
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.7,
        id: "",
        groupId: "options"));

    addEntity(new GameButton(game: this,
        x: 380,
        y: -280,
        text: "Instructions",
        buttonAction: () {
          newBouncer(1);
          newBouncer(2);
          newBouncer(3);
          newBouncer(4);
          newBouncer(5);
          newBouncer(6);
          newBouncer(7);
          newBouncer(8);
          newBouncer(9);
          newBouncer(10);
          newBouncer(12);
          newBouncer(13);
          newBouncer(14);
          newBouncer(15);
          newBouncer(16);
          newBouncer(17);
          newBouncer(18);

          state = GalagaGameState.welcome;

          removeEntitiesByGroup("instructions");
          createInstructionsMenu();

          state = GalagaGameState.instructions;
          _statUpdateEvent.signal();
        },
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.7,
        id: "",
        groupId: "options"));

    addEntity(new GameButton(game: this,
        x: -420,
        y: -280,
        text: "Back",
        buttonAction: () {
          removeEntitiesByGroup("welcome");
          createWelcomeMenu();

          state = GalagaGameState.welcome;
          _fadeEvent.signal();
          _statUpdateEvent.signal();
        },
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.7,
        id: "",
        groupId: "options"));

    disableEntitiesByGroup("options");
  }

  void createInstructionsMenu() {
    addEntity(new GameText(game: this,
        x: 0,
        y: -225,
        text: "Instructions",
        size: 56,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.8,
        id: "",
        groupId: "instructions"));

    addEntity(new GameText(game: this,
        x: 400,
        y: 275,
        text: "Made by Cody Smith",
        size: 16,
        font: "cinnamoncake, Verdana",
        centered: true,
        color: "255, 255, 255",
        opacity: 0.7,
        id: "",
        groupId: "instructions"));

    addEntity(new GameText(game: this,
        x: 0,
        y: -145,
        text: Options["controls"] == 1 ? "Move left/right: Left and Right arrow keys." : "Move left/right: Mouse movement.",
        size: 24,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.8,
        id: "",
        groupId: "instructions"));

    addEntity(new GameText(game: this,
        x: 0,
        y: -96,
        text: Options["controls"] == 1 ? "Fire: Spacebar." : "Fire: Left mouse click.",
        size: 24,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.8,
        id: "",
        groupId: "instructions"));

    addEntity(new GameText(game: this,
        x: 0,
        y: -47,
        text: Options["controls"] == 1 ? "Super Bullet: Shift Key. (Needs 15 coins to charge.)" : "Super Bullet: Spacebar. (Needs 15 coins to charge.)",
        size: 24,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.8,
        id: "",
        groupId: "instructions"));

    addEntity(new GameText(game: this,
        x: 0,
        y: 2,
        text: "Powerups:",
        size: 24,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: .9,
        id: "",
        groupId: "instructions"));

    addEntity(new GameText(game: this,
        x: 0,
        y: 40,
        text: "FIRE FLOWER: Spread shot upgrade for 15 seconds.",
        size: 24,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.8,
        id: "",
        groupId: "instructions"));

    addEntity(new GameText(game: this,
        x: 0,
        y: 70,
        text: "ENERGY CANISTER: Extra life.",
        size: 24,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.8,
        id: "",
        groupId: "instructions"));

    addEntity(new GameText(game: this,
        x: 0,
        y: 100,
        text: "APPLE: Multiplier times two.",
        size: 24,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.8,
        id: "",
        groupId: "instructions"));

    addEntity(new GameText(game: this,
        x: 0,
        y: 130,
        text: "LIGHTNING BALL: Extra bullet",
        size: 24,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.8,
        id: "",
        groupId: "instructions"));

    addEntity(new GameText(game: this,
        x: 0,
        y: 160,
        text: "COIN: Plus 100 points + Super Bullet charge (1/15).",
        size: 24,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.8,
        id: "",
        groupId: "instructions"));

    addEntity(new GameText(game: this,
        x: 0,
        y: 190,
        text: "SHIELD: Invincible for 5 seconds.",
        size: 24,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.8,
        id: "",
        groupId: "instructions"));

    addEntity(new GameText(game: this,
        x: 0,
        y: 220,
        text: "CLOCK: Extra 15 seconds added.",
        size: 24,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.8,
        id: "",
        groupId: "instructions"));

    addEntity(new GameButton(game: this,
        x: -420,
        y: -280,
        text: "Back",
        buttonAction: () {
          state = GalagaGameState.options;
          _fadeEvent.signal();
          _statUpdateEvent.signal();
        },
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.7,
        id: "",
        groupId: "instructions"));

    disableEntitiesByGroup("instructions");
  }

  void createGameOverMenu() {
    addEntity(new GameText(game: this,
        x: 0,
        y: -97,
        text: enemyAmount <= 0 ? "You Won!" : "You Lost!",
        size: 56,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.8,
        id: "",
        groupId: "gameOver"));

    addEntity(new GameText(game: this,
        x: 0,
        y: -31,
        text: "Play again?",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.8,
        id: "",
        groupId: "gameOver"));

    addEntity(new GameButton(game: this,
        x: 0,
        y: 15,
        text: "Yes",
        buttonAction: () {
          newGame();
        },
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.8,
        id: "",
        groupId: "gameOver"));

    addEntity(new GameButton(game: this,
        x: 0,
        y: 60,
        text: "No",
        buttonAction: () {
            removeEntitiesByFilter((e) => e is PowerUp);
            removeEntitiesByFilter((e) => e is Bullet);

            if (ship != null)
              ship.removeFromGame();

            removeEntitiesByGroup("welcome");
            createWelcomeMenu();

            state = GalagaGameState.welcome;
          },
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.8,
        id: "",
        groupId: "gameOver"));

    disableEntitiesByGroup("gameOver");
  }

  void resetLeaderBoard() {
    Highscores[1] = 0;
    Highscores[2] = 0;
    Highscores[3] = 0;
    Highscores[4] = 0;
    Highscores[5] = 0;
    Highscores[6] = 0;
    Highscores[7] = 0;
    Highscores[8] = 0;
    Highscores[9] = 0;
    Highscores[10] = 0;

    state = GalagaGameState.welcome;

    removeEntitiesByGroup("leaders");
    createLeaderBoardMenu();

    state = GalagaGameState.leaderboard;
  }

  void resetStats() {
    Stats["killed"] = 0;
    Stats["wins"] = 0;
    Stats["loses"] = 0;
    Stats["totalGames"] = 0;
    Stats["highscore"] = 0;
    Stats["normalKills"] = 0;
    Stats["bossKills"] = 0;
    Stats["motherKills"] = 0;
    Stats["powerups"] = 0;
    Stats["percentage"] = 0;

    state = GalagaGameState.welcome;

    removeEntitiesByGroup("stats");
    createStatsMenu();

    state = GalagaGameState.stats;
  }

  void resetOptions() {
    Options["startLives"] = 3;
    Options["bulletCap"] = 3;
    Options["time"] = 60;
    Options["difficulty"] = 1;
    Options["soundeffects"] = 1;
    Options["controls"] = 1;

    state = GalagaGameState.welcome;

    removeEntitiesByGroup("options");
    createOptionsMenu();

    state = GalagaGameState.options;
  }

  void resetPowerups() {
     ship.spiralShot = false;
     ship.bulletPower = 8;
  }

  void matchCloneX() {
    entities.where((c) => c is Clone).forEach((Clone c) {
      entities.where((e) => e is Enemy).forEach((Enemy e) {
        if (c.Id == e.cloneNum) {
          e.targetX = c.x;
        }
      });
    });
  }

  void switchDirection() {
    goingRight = !goingRight;
    entities.where((e) => e is Enemy).forEach((Enemy e) {
        if (e.type == "Normal") {
          e.momentum.xVel *= -1;

        if (e.momentum.xVel >= 0)
          e.x += 3;
        else
          e.x -= 3;
      }
    });

    entities.where((e) => e is Clone).forEach((Clone e) {
        e.momentum.xVel *= -1;

        if (e.momentum.xVel >= 0)
          e.x += 3;
        else
          e.x -= 3;
    });
  }

  bool canEnemyFall() {
    int x = 0;
    entities.where((e) => e is Enemy).forEach((Enemy e) {
      if (e.type == "Normal") {
        x++;
      }
    });

    if (x >= 3)
      return false;
    else
      return true;
  }

  void removeBullets() {
    removeEntitiesByFilter((e) => e is Bullet);
  }

  void updateLeaderboard() {
    Map<num, num> tempMap = new Map<num, num>();
    for (int k = 1; k < 11; k++) {
      tempMap[k] = Highscores[k];
    }

    for (int i = 1; i <= 10; i++) {
      if (score > Highscores[i]) {
        for (int j = i + 1; j < 10; j++) {
          Highscores[j] = tempMap[j - 1];
        }

        Highscores[i] = score;
        Stats["highScore"] = Highscores[i];
        break;
      }
    }

    Stats["highscore"] = Highscores[1];
  }

  void newGame() {
    entities.where((e) => e is Stars).forEach((e) => e.removeFromGame());
    for (int i = 0; i < 50; i++)
      startStars();

    score = 0;

    if (ship != null)
      ship.removeFromGame();

    removeEntitiesByFilter((e) => e is PowerUp);
    removeEntitiesByFilter((e) => e is Bullet);
    removeEntitiesByFilter((e) => e is Enemy);
    removeEntitiesByFilter((e) => e is Clone);

    enemyX = -400;
    enemyY = -165;
    enemyAmount = 33;

    bonusCheck = 3;
    bonusStage = false;
    visualLevel = 1;
    level = 1;
    score = 0;
    pointMultiplier = (60 / Options["time"]) + Options["difficulty"] + (3 / Options["startLives"]);

    if (Options["powerups"] == 1)
      pointMultiplier *= 2;

    pointMultiplier = pointMultiplier / 2;

    if (level >= bonusCheck) {
      bonusStage = true;
      bonusCheck += 3;
    } else {
      bonusStage = false;
    }

    for (int i = 0; i < 33; i++)
      newEnemy();

    ship = new Ship(this, 0, (rect.halfHeight - 45));
    addEntity(ship);
    p1Dead = false;

    ship.lives = Options["startLives"];

    Stats["totalGames"] += 1;
    state = GalagaGameState.playing;
    timer.timeDecrease = true;
    timer.gameTime = Options["time"];
  }

  void gameOver() {
    removeEntitiesByFilter((e) => e is PowerUp);
    removeEntitiesByFilter((e) => e is Bullet);
    removeEntitiesByFilter((e) => e is Enemy);
    removeEntitiesByFilter((e) => e is Clone);

    updateLeaderboard();

    _gameOverEvent.signal();
    _statUpdateEvent.signal();
    removeEntitiesByGroup("gameOver");
    createGameOverMenu();

    state = GalagaGameState.gameOver;
  }

  final EventStream _statUpdateEvent = new EventStream();
  Stream<EventArgs> get onStatUpdate => _statUpdateEvent.stream;

  final EventStream _gameOverEvent = new EventStream();
  Stream<EventArgs> get onGameOver => _gameOverEvent.stream;

  final EventStream _shipHitEvent = new EventStream();
  Stream<EventArgs> get onShipHit => _shipHitEvent.stream;

  final EventStream _bossHitEvent = new EventStream();
  Stream<EventArgs> get onBossHit => _bossHitEvent.stream;

  final EventStream _bossKilledEvent = new EventStream();
  Stream<EventArgs> get onBossKilled => _bossKilledEvent.stream;

  final EventStream _motherShipEvent = new EventStream();
  Stream<EventArgs> get onMotherShipHit => _motherShipEvent.stream;

  final EventStream _normalHitEvent = new EventStream();
  Stream<EventArgs> get onNormalHit => _normalHitEvent.stream;

  final EventStream _fadeEvent = new EventStream();
  Stream<EventArgs> get onFadeEvent => _normalHitEvent.stream;
}

class GalagaGameState {
  static final num welcome = 1;
  static final num paused = 2;
  static final num playing = 3;
  static final num gameOver = 4;
  static final num stats = 5;
  static final num options = 6;
  static final num instructions = 7;
  static final num levelEnd = 8;
  static final num leaderboard = 9;
  static final num cheats = 10;
}
