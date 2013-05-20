library galaga_game;

import "dart:math" as Math;
import "dart:async";
import "dart:html";
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
  num rank = 1;
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
  GameSound menuSong = new GameSound("Menu", 1.0, false);
  GameSound optionSong = new GameSound("Options", 1.0, true);
  GameSound gameStart = new GameSound("GameStart", 1.0, false);
  GameSound gameSong = new GameSound("Game", 1.0, true);
  GameSound cursorMove = new GameSound("cursorMove", .3, false);
  GameSound cursorSelect = new GameSound("cursorSelect", .3, false);
  GameSound cursorSelect2 = new GameSound("cursorSelect2", .3, false);
  GameSound enemyFire = new GameSound("enemyFire", .3, false);
  GameSound enemyHit = new GameSound("enemyHit", .3, false);
  GameSound explosion = new GameSound("explosion", .3, false);
  GameSound motherShipFire = new GameSound("mothershipfire", .3, false);
  GameSound shipFire = new GameSound("shipFire", .3, false);
  GameSound shipHit = new GameSound("shipHit", .3, false);
  GameSound powerUp = new GameSound("powerUp", .3, false);


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

    _waitingTimer = new Timer.periodic(const Duration(milliseconds: 1000), (t) {
        _waiting++;

      if (_waiting == 4) {
        entities.where((e) => e is Stars).toList().forEach((e) => e.removeFromGame());
        for (int i = 0; i < 50; i++) {

          if (colorCount < 7)
            colorCount++;
          else if (colorCount >= 7)
            colorCount = 1;

          startStars();
        }

        enemyX = -400;
        enemyY = -165;
        enemyAmount = 33;

        if (difficulty < 5)
          difficulty++;

        if (visualLevel >= bonusCheck) {
          bonusStage = true;
          tutorial = false;
          bonusCheck += 3;
        } else {
          bonusStage = false;
        }

        if (bonusStage == true) {
          newBoss();

        } else {
          for (int i = 0; i < 33; i++)
            newEnemy(difficulty);
        }
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
    if (!Stats.containsKey("loses"))
      Stats["loses"] = 0;
    if (!Stats.containsKey("totalGames"))
      Stats["totalGames"] = 0;
    if (!Stats.containsKey("highscore"))
      Stats["highscore"] = 0;
    if (!Stats.containsKey("normalKills"))
      Stats["normalKills"] = 0;
    if (!Stats.containsKey("bossKills"))
      Stats["bossKills"] = 0;
    if (!Stats.containsKey("motherKills"))
      Stats["motherKills"] = 0;
    if (!Stats.containsKey("powerups"))
      Stats["powerups"] = 0;

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

    if (Options["soundeffects"] == 1)
      soundEffectsOn = true;
    else
      soundEffectsOn = false;

    createWelcomeMenu();
    createGameOverMenu();
    createStatsMenu();
    createPausedMenu();
    createControlsMenu();
    createLeaderBoardMenu();

    if (soundEffectsOn)
      menuSong.play(menuSong.Sound, menuSong.Volume, menuSong.Looping);

    menuSong.remove();

    // update pubsec


    state = GalagaGameState.welcome;
    super.start();
  }

  void update() {
    if (state == GalagaGameState.playing || state == GalagaGameState.paused) {
      score = score.ceil();
      if (input.keyCode == 27)
        state = state == GalagaGameState.paused ? GalagaGameState.playing : GalagaGameState.paused;

//      if (state == GalagaGameState.paused) {
//        timer.paused = true;
//      }
      if (enemyAmount <= 0) {
        Stats["wins"] += 1;

        removeEntitiesByFilter((e) => e is PowerUp);
        removeEntitiesByFilter((e) => e is Bullet);
        removeEntitiesByFilter((e) => e is Enemy);

        if (soundEffectsOn)
          cursorSelect2.play(cursorSelect2.Sound, cursorSelect2.Volume, cursorSelect2.Looping);
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

        if (soundEffectsOn)
          cursorSelect2.play(cursorSelect2.Sound, cursorSelect2.Volume, cursorSelect2.Looping);
        removeEntitiesByGroup("levelEnd");
        createLevelEnd();

        state = GalagaGameState.levelEnd;

        waiting = 1;

        //if (tutorial == false)
          level++;

        visualLevel++;
      }
    }

    if (colorCount < 7)
      colorCount++;
    else if (colorCount >= 7)
      colorCount = 1;

    entities.where((e) => e is GameButton).forEach((e) {
      if (e.opacity == 1.0 && e.isHighlighted && e.soundReady) {
        if (soundEffectsOn)
          cursorMove.play(cursorMove.Sound, cursorMove.Volume, cursorMove.Looping);
        e.soundReady = false;
      } else if (e.opacity < 1.0)
        e.soundReady = true;
    });

    newStar();
    super.update();
  }

  void startStars() {
    num w = random(.5, 3.5);
    Stars star = new Stars(this, 0, 0, w, w, colorCount);

    do {
      star.x = random(-rect.halfWidth, rect.halfWidth);
      star.y = random(-rect.halfHeight, rect.halfHeight);

    } while(entities.where((e) => e is Stars).any((e) => star.collidesWith(e)));

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

    if (soundEffectsOn)
      explosion.play(explosion.Sound, explosion.Volume, explosion.Looping);
  }

  void newMiniExplosion(num x, num y) {

    newParticle(x, y, 50, 0);
    newParticle(x, y, -50, 0);

    newParticle(x, y, 0, 50);
    newParticle(x, y, 0, -50);

    if (soundEffectsOn)
      explosion.play(explosion.Sound, explosion.Volume, explosion.Looping);
  }

  void newStar() {
    num rand = random(0, 1);

    if (rand > .01 || state == GalagaGameState.paused)
      return;

    num w = random(.5, 3.5);

    Stars star = new Stars(this, 0, 0, w, w, colorCount);

    do {
      star.x = random(-rect.halfWidth, rect.halfWidth);
      star.y = -(rect.halfHeight);

    } while(entities.where((e) => e is Stars).any((e) => star.collidesWith(e)));

    lastStar = timer.gameTime;
    addEntity(star);
  }

  void newBoss() {
    Enemy enemy = new Enemy(this, 0, 0, difficulty, "Boss");

    enemy.idNum = nextId;
    nextId++;

    addEntity(enemy);
  }

  void newBouncer(num sprite) {
    bouncingBall bouncer = new bouncingBall(this, 0, 0, 36, 36, sprite);

    if (sprite == 1) {
      bouncer.height = 42;
      bouncer.width = 42;
    }
    if (sprite == 5) {
      bouncer.height = 12;
      bouncer.width = 12;
    }
    if (sprite == 8) {
      bouncer.height = 42;
      bouncer.width = 42;
    }
    if (sprite == 10) {
      bouncer.height = 72;
      bouncer.width = 72;
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

    enemy.startY = enemyY;

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
      if (e.type == type && e.isFalling == true) {
        return e.x;
      }
    });

    return 0;
  }

  num getEnemyY(String type) {
    entities.where((e) => e is Enemy).toList().forEach((Enemy e) {
      if (e.type == type && e.isFalling == true) {
        return e.y;
      }
    });

    return 0;
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
        opacity: 0.4,
        id: "",
        groupId: "levelEnd"));

    disableEntitiesByGroup("levelEnd");
  }

  void createWelcomeMenu() {
    _gameOverEvent.signal();

    if (Highscores[1] <= 5000 && Highscores[1] >= 0)
      rank = 1;
    if (Highscores[1] <= 10000 && Highscores[1] >= 5001)
      rank = 2;
    if (Highscores[1] <= 15000 && Highscores[1] >= 10001)
      rank = 3;
    if (Highscores[1] <= 20000 && Highscores[1] >= 15001)
      rank = 4;
    if (Highscores[1] <= 25000 && Highscores[1] >= 20001)
      rank = 5;
    if (Highscores[1] <= 30000 && Highscores[1] >= 25001)
      rank = 6;
    if (Highscores[1] <= 35000 && Highscores[1] >= 30001)
      rank = 7;
    if (Highscores[1] <= 40000 && Highscores[1] >= 35001)
      rank = 8;
    if (Highscores[1] <= 45000 && Highscores[1] >= 40001)
      rank = 9;
    if (Highscores[1] <= 50000 && Highscores[1] >= 45001)
      rank = 10;
    if (Highscores[1] <= 55000 && Highscores[1] >= 50001)
      rank = 11;
    if (Highscores[1] <= 60000 && Highscores[1] >= 55001)
      rank = 12;
    if (Highscores[1] >= 150000 && Highscores[1] >= 100001)
      rank = 13;
    if (Highscores[1] <= 200000 && Highscores[1] >= 150001)
      rank = 14;
    if (Highscores[1] <= 250000 && Highscores[1] >= 200001)
      rank = 15;
    if (Highscores[1] <= 300000 && Highscores[1] >= 250001)
      rank = 16;
    if (Highscores[1] >= 400000)
      rank = 17;

    addEntity(new GameText(game: this,
        x: 0,
        y: -275,
        text: "You're a: Jew",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: rank == 1 ? .8 : 0,
        id: "",
        groupId: "welcome"));

    addEntity(new GameText(game: this,
        x: 0,
        y: -275,
        text: "You're a: Jewish Priest",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: rank == 2 ? .8 : 0,
        id: "",
        groupId: "welcome"));

    addEntity(new GameText(game: this,
        x: 0,
        y: -275,
        text: "You're a: Amish Mastermind",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: rank == 3 ? .8 : 0,
        id: "",
        groupId: "welcome"));

    addEntity(new GameText(game: this,
        x: 0,
        y: -275,
        text: "You're a: Road Warrior",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: rank == 4 ? .8 : 0,
        id: "",
        groupId: "welcome"));

    addEntity(new GameText(game: this,
        x: 0,
        y: -275,
        text: "You're a: Space Recruit",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: rank == 5 ? .8 : 0,
        id: "",
        groupId: "welcome"));

    addEntity(new GameText(game: this,
        x: 0,
        y: -275,
        text: "You're a: Space Cadet",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: rank == 6 ? .8 : 0,
        id: "",
        groupId: "welcome"));

    addEntity(new GameText(game: this,
        x: 0,
        y: -275,
        text: "You're a: Space Captain",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: rank == 7 ? .8 : 0,
        id: "",
        groupId: "welcome"));

    addEntity(new GameText(game: this,
        x: 0,
        y: -275,
        text: "You're: The Overlord of the Galaxy",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: rank == 8 ? .8 : 0,
        id: "",
        groupId: "welcome"));

    addEntity(new GameText(game: this,
        x: 0,
        y: -275,
        text: "You're: The President of the Universe",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: rank == 9 ? .8 : 0,
        id: "",
        groupId: "welcome"));

    addEntity(new GameText(game: this,
        x: 0,
        y: -275,
        text: "You're: The Commander of the Universe",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: rank == 10 ? .8 : 0,
        id: "",
        groupId: "welcome"));

    addEntity(new GameText(game: this,
        x: 0,
        y: -275,
        text: "You're: The Overlord of the Universe",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: rank == 11 ? .8 : 0,
        id: "",
        groupId: "welcome"));

    addEntity(new GameText(game: this,
        x: 0,
        y: -275,
        text: "You're: The Overseer of the Multi-verse",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: rank == 12 ? .8 : 0,
        id: "",
        groupId: "welcome"));

    addEntity(new GameText(game: this,
        x: 0,
        y: -275,
        text: "You're: The Commander of the Multi-verse",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: rank == 13 ? .8 : 0,
        id: "",
        groupId: "welcome"));

    addEntity(new GameText(game: this,
        x: 0,
        y: -275,
        text: "You're: The Overlord of the Multi-verse",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: rank == 14 ? .8 : 0,
        id: "",
        groupId: "welcome"));

    addEntity(new GameText(game: this,
        x: 0,
        y: -275,
        text: "You're: The God of this Dimension",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: rank == 15 ? .8 : 0,
        id: "",
        groupId: "welcome"));

    addEntity(new GameText(game: this,
        x: 0,
        y: -275,
        text: "You're: The God of all Dimensions",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: rank == 16 ? .8 : 0,
        id: "",
        groupId: "welcome"));

    addEntity(new GameText(game: this,
        x: 0,
        y: -275,
        text: "You're: Pablo Manrequez De Montoya De La Qruez the Third",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: rank == 17 ? .8 : 0,
        id: "",
        groupId: "welcome"));

    addEntity(new GameText(game: this,
        x: 0,
        y: -97,
        text: "Welcome to Galaga!",
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
        opacity: 0.5,
        id: "",
        groupId: "welcome"));

    addEntity(new GameButton(game: this,
        x: 0,
        y: -31,
        text: "Start Game",
        buttonAction: () {
          newGame();
          _statUpdateEvent.signal();
          if (soundEffectsOn)
            cursorSelect.play(cursorSelect.Sound, cursorSelect.Volume, cursorSelect.Looping);
        },
        size: 36,
        font: "cinnamoncake, Verdana",
        centered: true,
        color: "255, 255, 255",
        opacity: 0.4,
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

          _statUpdateEvent.signal();
          if (soundEffectsOn)
            cursorSelect2.play(cursorSelect2.Sound, cursorSelect2.Volume, cursorSelect2.Looping);
        },
        size: 36,
        font: "cinnamoncake, Verdana",
        centered: true,
        color: "255, 255, 255",
        opacity: 0.4,
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

          _statUpdateEvent.signal();
          if (soundEffectsOn)
            cursorSelect2.play(cursorSelect2.Sound, cursorSelect2.Volume, cursorSelect2.Looping);
        },
        size: 36,
        font: "cinnamoncake, Verdana",
        centered: true,
        color: "255, 255, 255",
        opacity: 0.4,
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

          _statUpdateEvent.signal();
          if (soundEffectsOn)
            cursorSelect2.play(cursorSelect2.Sound, cursorSelect2.Volume, cursorSelect2.Looping);
        },
        size: 36,
        font: "cinnamoncake, Verdana",
        centered: true,
        color: "255, 255, 255",
        opacity: 0.4,
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
        opacity: 0.4,
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
          removeEntitiesByFilter((e) => e is Bullet);
          removeEntitiesByFilter((e) => e is Enemy);

          _statUpdateEvent.signal();

          gameOver();

          removeEntitiesByGroup("welcome");
          createWelcomeMenu();

          state = GalagaGameState.welcome;
      },
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.4,
        id: "",
        groupId: "paused"));

    disableEntitiesByGroup("paused");
  }

  void createLeaderBoardMenu() {
    for (int i = 1; i < 11; i++) {
      if (Highscores[i] <= 0)
        HighscoresRank[i] = "None";
      else if (Highscores[i] <= 5000 && Highscores[i] > 0)
        HighscoresRank[i] = "Jew";
      else if (Highscores[i] <= 20000 && Highscores[i] >= 5001)
        HighscoresRank[i] = "Jewish Priest";
      else if (Highscores[i] <= 35000 && Highscores[i] >= 20001)
        HighscoresRank[i] = "Amish Mastermind";
      else if (Highscores[i] <= 45000 && Highscores[i] >= 35001)
        HighscoresRank[i] = "Road Warrior";
      else if (Highscores[i] <= 65000 && Highscores[i] >= 45001)
        HighscoresRank[i] = "Space Recruit";
      else if (Highscores[i] <= 80000 && Highscores[i] >= 65001)
        HighscoresRank[i] = "Space Cadet";
      else if (Highscores[i] <= 90000 && Highscores[i] >= 80001)
        HighscoresRank[i] = "Space Captain";
      else if (Highscores[i] <= 100000 && Highscores[i] >= 90001)
        HighscoresRank[i] = "Overlord of the Galaxy";
      else if (Highscores[i] <= 150000 && Highscores[i] >= 100001)
        HighscoresRank[i] = "President of the Universe";
      else if (Highscores[i] <= 200000 && Highscores[i] >= 150001)
        HighscoresRank[i] = "Commander of the Universe";
      else if (Highscores[i] <= 250000 && Highscores[i] >= 200001)
        HighscoresRank[i] = "Overlord of the Universe";
      else if (Highscores[i] <= 350000 && Highscores[i] >= 250001)
        HighscoresRank[i] = "Overseer of Multi-verse";
      else if (Highscores[i] <= 450000 && Highscores[i] >= 350001)
        HighscoresRank[i] = "Commander of Multi-verse";
      else if (Highscores[i] <= 500000 && Highscores[i] >= 450001)
        HighscoresRank[i] = "Overlord of Multi-verse";
      else if (Highscores[i] <= 550000 && Highscores[i] >= 500001)
        HighscoresRank[i] = "God of this Dimension";
      else if (Highscores[i] <= 700000 && Highscores[i] >= 550001)
        HighscoresRank[i] = "God of all Dimensions";
      else if (Highscores[i] >= 1000000)
        HighscoresRank[i] = "Pablo Manrequez";
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
        opacity: 0.5,
        id: "",
        groupId: "leaders"));

    addEntity(new GameText(game: this,
        x: -160,
        y: -175,
        text: "Scores",
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
        text: "Ranks",
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
        text: "1: ${Highscores[1]}",
        size: 42,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.6,
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
        opacity: 0.6,
        id: "",
        groupId: "leaders"));

    addEntity(new GameText(game: this,
        x: -160,
        y: -95,
        text: "2: ${Highscores[2]}",
        size: 42,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.6,
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
        opacity: 0.6,
        id: "",
        groupId: "leaders"));

    addEntity(new GameText(game: this,
        x: -160,
        y: -55,
        text: "3: ${Highscores[3]}",
        size: 42,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.6,
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
        opacity: 0.6,
        id: "",
        groupId: "leaders"));

    addEntity(new GameText(game: this,
        x: -160,
        y: -15,
        text: "4: ${Highscores[4]}",
        size: 42,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.6,
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
        opacity: 0.6,
        id: "",
        groupId: "leaders"));

    addEntity(new GameText(game: this,
        x: -160,
        y: 25,
        text: "5: ${Highscores[5]}",
        size: 42,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.6,
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
        opacity: 0.6,
        id: "",
        groupId: "leaders"));

    addEntity(new GameText(game: this,
        x: -160,
        y: 65,
        text: "6: ${Highscores[6]}",
        size: 42,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.6,
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
        opacity: 0.6,
        id: "",
        groupId: "leaders"));

    addEntity(new GameText(game: this,
        x: -160,
        y: 105,
        text: "7: ${Highscores[7]}",
        size: 42,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.6,
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
        opacity: 0.6,
        id: "",
        groupId: "leaders"));

    addEntity(new GameText(game: this,
        x: -160,
        y: 145,
        text: "8: ${Highscores[8]}",
        size: 42,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.6,
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
        opacity: 0.6,
        id: "",
        groupId: "leaders"));

    addEntity(new GameText(game: this,
        x: -160,
        y: 185,
        text: "9: ${Highscores[9]}",
        size: 42,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.6,
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
        opacity: 0.6,
        id: "",
        groupId: "leaders"));

    addEntity(new GameText(game: this,
        x: -160,
        y: 225,
        text: "10: ${Highscores[10]}",
        size: 42,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.6,
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
        opacity: 0.6,
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
        opacity: 0.4,
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
          _statUpdateEvent.signal();
          if (soundEffectsOn)
            cursorSelect2.play(cursorSelect2.Sound, cursorSelect2.Volume, cursorSelect2.Looping);
        },
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.4,
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
        opacity: 0.5,
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
        opacity: 0.6,
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
        opacity: 0.6,
        id: "",
        groupId: "stats"));

    addEntity(new GameText(game: this,
        x: 0,
        y: -110,
        text: "Big Bosses Denominated: ${Stats["bossKills"]}",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.6,
        id: "",
        groupId: "stats"));

    addEntity(new GameText(game: this,
        x: 0,
        y: -65,
        text: "Mother Ships Deflowered: ${Stats["motherKills"]}",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.6,
        id: "",
        groupId: "stats"));

    addEntity(new GameText(game: this,
        x: 0,
        y: -20,
        text: "Powerups Absorbed: ${Stats["powerups"]}",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.6,
        id: "",
        groupId: "stats"));

    addEntity(new GameText(game: this,
        x: 0,
        y: 25,
        text: "Total Completed Levels: ${Stats["wins"]}",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.6,
        id: "",
        groupId: "stats"));

    addEntity(new GameText(game: this,
        x: 0,
        y: 70,
        text: "Total Loses: ${Stats["loses"]}",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.6,
        id: "",
        groupId: "stats"));

    addEntity(new GameText(game: this,
        x: 0,
        y: 115,
        text: "Total Games: ${Stats["totalGames"]}",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.6,
        id: "",
        groupId: "stats"));

    addEntity(new GameText(game: this,
        x: 0,
        y: 160,
        text: "High Score: ${Stats["highscore"]}",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.6,
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
          _statUpdateEvent.signal();
          if (soundEffectsOn)
            cursorSelect2.play(cursorSelect2.Sound, cursorSelect2.Volume, cursorSelect2.Looping);
        },
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.6,
        id: "",
        groupId: "stats"));

    addEntity(new GameButton(game: this,
        x: 0,
        y: 225,
        text: "RESET",
        buttonAction: () => resetStats(),
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.6,
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

    addEntity(new GameText(game: this,
        x: 400,
        y: 275,
        text: "Made by Cody Smith",
        size: 16,
        font: "cinnamoncake, Verdana",
        centered: true,
        color: "255, 255, 255",
        opacity: 0.5,
        id: "",
        groupId: "options"));

    addEntity(new GameText(game: this,
        x: 0,
        y: -60,
        text: "Starting Lives:",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.7,
        id: "",
        groupId: "options"));

    addEntity(new GameText(game: this,
        x: 200,
        y: -60,
        text: "${Options["startLives"]}",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.7,
        id: "",
        groupId: "options"));

    addEntity(new GameButton(game: this,
        x: 245,
        y: -60,
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
        opacity: 0.7,
        id: "",
        groupId: "options"));

    addEntity(new GameButton(game: this,
        x: 160,
        y: -60,
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
        opacity: 0.7,
        id: "",
        groupId: "options"));

    addEntity(new GameText(game: this,
        x: 0,
        y: -30,
        text: "Bullet Cap:",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.7,
        id: "",
        groupId: "options"));

    addEntity(new GameText(game: this,
        x: 200,
        y: -30,
        text: "${Options["bulletCap"]}",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.7,
        id: "",
        groupId: "options"));

    addEntity(new GameButton(game: this,
        x: 245,
        y: -30,
        text: "->",
        buttonAction: () {
          if (Options["bulletCap"] >= 10)
            Options["bulletCap"] = 1;
          else
            Options["bulletCap"]++;

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
        opacity: 0.7,
        id: "",
        groupId: "options"));

    addEntity(new GameButton(game: this,
        x: 160,
        y: -30,
        text: "<-",
        buttonAction: () {
          if (Options["bulletCap"] <= 1)
            Options["bulletCap"] = 10;
          else
            Options["bulletCap"]--;

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
        opacity: 0.7,
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
        opacity: 0.7,
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
        opacity: 0.7,
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
        opacity: 0.7,
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
        opacity: 0.7,
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
        opacity: 0.7,
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
        opacity: 0.7,
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
        opacity: 0.7,
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
        opacity: 0.7,
        id: "",
        groupId: "options"));

    addEntity(new GameText(game: this,
        x: -38,
        y: -94,
        text: "Powerups Enabled:",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.7,
        id: "",
        groupId: "options"));

    addEntity(new GameButton(game: this,
        x: 200,
        y: -94,
        text: Options["powerups"] == 1 ? "True" : "False",
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
        opacity: 0.7,
        id: "",
        groupId: "options"));

    addEntity(new GameText(game: this,
        x: -38,
        y: 60,
        text: "Sound Effects Enabled:",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.7,
        id: "",
        groupId: "options"));

    addEntity(new GameButton(game: this,
        x: 200,
        y: 60,
        text: Options["soundeffects"] == 1 ? "True" : "False",
        buttonAction: () {

          if (Options["soundeffects"] >= 2)
            Options["soundeffects"] = 1;
          else
            Options["soundeffects"] += 1;

          if (Options["soundeffects"] == 1)
            soundEffectsOn = true;
          else
            soundEffectsOn = false;

          //if (!soundEffectsOn) {
            menuSong.remove();
          //}

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

    addEntity(new GameButton(game: this,
        x: 10,
        y: 120,
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
          state = GalagaGameState.instructions;
          _statUpdateEvent.signal();
          if (soundEffectsOn)
            cursorSelect2.play(cursorSelect2.Sound, cursorSelect2.Volume, cursorSelect2.Looping);
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
          _statUpdateEvent.signal();
          if (soundEffectsOn)
            cursorSelect2.play(cursorSelect2.Sound, cursorSelect2.Volume, cursorSelect2.Looping);
        },
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.4,
        id: "",
        groupId: "options"));

    disableEntitiesByGroup("options");
  }

  void createControlsMenu() {
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
        opacity: 0.5,
        id: "",
        groupId: "instructions"));

    addEntity(new GameText(game: this,
        x: 0,
        y: -145,
        text: "Move left/right: Mouse swipe",
        size: 24,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.6,
        id: "",
        groupId: "instructions"));

    addEntity(new GameText(game: this,
        x: 0,
        y: -96,
        text: "Fire: Left Mouse Button",
        size: 24,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.6,
        id: "",
        groupId: "instructions"));

    addEntity(new GameText(game: this,
        x: 0,
        y: -47,
        text: "SpaceBar: Shoots a super bullet if you have a total of 15 charges or more.",
        size: 24,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.6,
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
        y: 51,
        text: "Fire Flower: Spread shot upgrade.",
        size: 24,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.6,
        id: "",
        groupId: "instructions"));

    addEntity(new GameText(game: this,
        x: 0,
        y: 100,
        text: "Energy Canister: Extra life.",
        size: 24,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.6,
        id: "",
        groupId: "instructions"));

    addEntity(new GameText(game: this,
        x: 0,
        y: 149,
        text: "Apple: Multiplier times two.",
        size: 24,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.6,
        id: "",
        groupId: "instructions"));

    addEntity(new GameText(game: this,
        x: 0,
        y: 198,
        text: "Energy Ball: Extra bullet",
        size: 24,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.6,
        id: "",
        groupId: "instructions"));

    addEntity(new GameText(game: this,
        x: 0,
        y: 247,
        text: "Coin: Plus 100 points.",
        size: 24,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.6,
        id: "",
        groupId: "instructions"));

    addEntity(new GameButton(game: this,
        x: -420,
        y: -280,
        text: "Back",
        buttonAction: () {
          state = GalagaGameState.options;
          _statUpdateEvent.signal();
          if (soundEffectsOn)
            cursorSelect2.play(cursorSelect2.Sound, cursorSelect2.Volume, cursorSelect2.Looping);
        },
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.4,
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
        opacity: 0.4,
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
        opacity: 0.4,
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
        opacity: 0.4,
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
        opacity: 0.4,
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

    state = GalagaGameState.welcome;

    removeEntitiesByGroup("options");
    createOptionsMenu();

    state = GalagaGameState.options;
  }

  void newGame() {
    entities.where((e) => e is Stars).forEach((e) => e.removeFromGame());
    for (int i = 0; i < 50; i++) {

      if (colorCount < 7)
        colorCount++;
      else if (colorCount >= 7)
        colorCount = 1;

      startStars();
    }

    score = 0;

    if (ship != null)
      ship.removeFromGame();

    removeEntitiesByFilter((e) => e is PowerUp);
    removeEntitiesByFilter((e) => e is Bullet);
    removeEntitiesByFilter((e) => e is Enemy);

    enemyX = -400;
    enemyY = -165;
    enemyAmount = 33;

    bonusCheck = 3;
    bonusStage = false;
    visualLevel = 1;
    level = 1;
    score = 0;
    pointMultiplier = (60 / Options["time"]) + Options["difficulty"] + (3 / Options["startLives"]) + (3 / Options["bulletCap"]);

    if (Options["powerups"] == 1)
      pointMultiplier *= 2;

    if (level >= bonusCheck) {
      bonusStage = true;
      bonusCheck += 3;
    } else {
      bonusStage = false;
    }

    for (int i = 0; i < 33; i++)
      newEnemy();

    ship = new Ship(this, 0, (rect.halfHeight - 30));
    addEntity(ship);
    p1Dead = false;

    ship.spiralShot = true;
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

    updateLeaderboard();

    Stats["loses"] += 1;
    _gameOverEvent.signal();
    _statUpdateEvent.signal();
    if (soundEffectsOn)
      cursorSelect2.play(cursorSelect2.Sound, cursorSelect2.Volume, cursorSelect2.Looping);
    removeEntitiesByGroup("gameOver");
    createGameOverMenu();

    state = GalagaGameState.gameOver;
  }

  void resetPowerups() {
     ship.spiralShot = false;
     ship.superSpiral = false;
     ship.bulletPower = 8;
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
  }

  bool canEnemyFall() {
    int x = 0;
    entities.where((e) => e is Enemy).forEach((Enemy e) {
      if (e.type == "Normal" && e.isFalling == true) {
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
}
