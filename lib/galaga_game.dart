library galaga_game;

import "dart:math" as Math;
import "dart:async";
import "dart:html";
import "dart:isolate";
import 'package:dgame/dgame.dart';
import 'package:event_stream/event_stream.dart';

part "src/ship.dart";
part "src/enemy.dart";
part "src/powerup.dart";
part "src/bullet.dart";
part "src/stars.dart";
part "src/particles.dart";

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
  Map<num, bool> RankSelect = new Map<num, bool>();
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

  GalagaGame(Rectangle rect) : super(rect);
  GalagaGame.withServices(GameSound sound, GameInput input, GameRenderer renderer, GameLoop loop) : super.withServices(sound, input, renderer, loop);
  
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
    
    _waitingTimer = new Timer.repeating(const Duration(milliseconds: 1000), (t) {    
        _waiting++;
      
      if (_waiting == 3) {
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
    
    if (!RankSelect.containsKey(1))
      RankSelect[1] = true;
    if (!RankSelect.containsKey(2))
      RankSelect[2] = false;
    if (!RankSelect.containsKey(3))
      RankSelect[3] = false;
    if (!RankSelect.containsKey(4))
      RankSelect[4] = false;
    if (!RankSelect.containsKey(5))
      RankSelect[5] = false;
    if (!RankSelect.containsKey(6))
      RankSelect[6] = false;
    if (!RankSelect.containsKey(7))
      RankSelect[7] = false;
    if (!RankSelect.containsKey(8))
      RankSelect[8] = false;
    if (!RankSelect.containsKey(9))
      RankSelect[9] = false;
    
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
      sound.play("menu", .5, true);
    
    state = GalagaGameState.welcome;
    super.start();
  }
  
  void update() {
    if (state == GalagaGameState.playing || state == GalagaGameState.paused) {
      if (input.keyCode == 27)
        state = state == GalagaGameState.paused ? GalagaGameState.playing : GalagaGameState.paused;
      
      if (enemyAmount <= 0) {
        Stats["wins"] += 1;
        
        removeEntitiesByFilter((e) => e is PowerUp);
        removeEntitiesByFilter((e) => e is Bullet);
        removeEntitiesByFilter((e) => e is Enemy);
        
        if (soundEffectsOn)
          sound.play("cursorSelect2");
        removeEntitiesByGroup("levelEnd");
        createLevelEnd();
        
        state = GalagaGameState.levelEnd;
        
        waiting = 1;
        if (tutorial == false)
          level++;
        
        visualLevel++;
      }
      
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
          sound.play("cursorSelect2");
        removeEntitiesByGroup("levelEnd");
        createLevelEnd();
        
        state = GalagaGameState.levelEnd;
        
        waiting = 1;
        
        if (tutorial == false)
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
          sound.play("cursorMove", 1.0, false);  
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
      sound.play("explosion", .5, false);  
  }
  
  void newMiniExplosion(num x, num y) {
    
    newParticle(x, y, 50, 0);
    newParticle(x, y, -50, 0);
    
    newParticle(x, y, 0, 50);
    newParticle(x, y, 0, -50);
    
    if (soundEffectsOn)
      sound.play("explosion", .1, false);  
  }
  
  void newStar() {
    num rand = random(0, 1);
    
    if (rand > .09 || state == GalagaGameState.paused)
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
    if (random() >= .1)
      return;
    
    if (entities.where((e) => e is PowerUp).length >= 5)
      return;
    
    if (timer.gameTime < 5)
      return;
    
    if (lastPowerUp + 5 >= timer.gameTime)
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
        text: visualLevel == bonusCheck ? "Level ${visualLevel} Complete!" : "Prepare for Bonus Stage!",
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
    
    addEntity(new GameText(game: this, 
        x: 0, 
        y: -97, 
        text: "Welcome to Galaga!",
        size: 56,
        font: "cinnamoncake, Verdana",
        centered: true,
        color: "255, 255, 255",
        opacity: 0.4,
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
            sound.play("cursorSelect");
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
            sound.play("cursorSelect2");
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
            sound.play("cursorSelect2");
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
            sound.play("cursorSelect2");
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
    addEntity(new GameText(game: this, 
        x: 0, 
        y: -240, 
        text: "Leaderboard",
        size: 56,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.4,
        id: "",
        groupId: "leaders"));
    
    addEntity(new GameText(game: this, 
        x: -145, 
        y: -190, 
        text: "1: ${Highscores[1]}",
        size: 42,
        font: "cinnamoncake, Verdana",
        centered:  false,
        color: "255, 255, 255",
        opacity: 0.4,
        id: "",
        groupId: "leaders"));
    
    addEntity(new GameText(game: this, 
        x: -145, 
        y: -150, 
        text: "2: ${Highscores[2]}",
        size: 42,
        font: "cinnamoncake, Verdana",
        centered:  false,
        color: "255, 255, 255",
        opacity: 0.4,
        id: "",
        groupId: "leaders"));
    
    addEntity(new GameText(game: this, 
        x: -145, 
        y: -110, 
        text: "3: ${Highscores[3]}",
        size: 42,
        font: "cinnamoncake, Verdana",
        centered:  false,
        color: "255, 255, 255",
        opacity: 0.4,
        id: "",
        groupId: "leaders"));
    
    addEntity(new GameText(game: this, 
        x: -145, 
        y: -70, 
        text: "4: ${Highscores[4]}",
        size: 42,
        font: "cinnamoncake, Verdana",
        centered:  false,
        color: "255, 255, 255",
        opacity: 0.4,
        id: "",
        groupId: "leaders"));
    
    addEntity(new GameText(game: this, 
        x: -145, 
        y: -30, 
        text: "5: ${Highscores[5]}",
        size: 42,
        font: "cinnamoncake, Verdana",
        centered:  false,
        color: "255, 255, 255",
        opacity: 0.4,
        id: "",
        groupId: "leaders"));
    
    addEntity(new GameText(game: this, 
        x: -145, 
        y: 10, 
        text: "6: ${Highscores[6]}",
        size: 42,
        font: "cinnamoncake, Verdana",
        centered:  false,
        color: "255, 255, 255",
        opacity: 0.4,
        id: "",
        groupId: "leaders"));
    
    addEntity(new GameText(game: this, 
        x: -145, 
        y: 50, 
        text: "7: ${Highscores[7]}",
        size: 42,
        font: "cinnamoncake, Verdana",
        centered:  false,
        color: "255, 255, 255",
        opacity: 0.4,
        id: "",
        groupId: "leaders"));
    
    addEntity(new GameText(game: this, 
        x: -145, 
        y: 90, 
        text: "8: ${Highscores[8]}",
        size: 42,
        font: "cinnamoncake, Verdana",
        centered:  false,
        color: "255, 255, 255",
        opacity: 0.4,
        id: "",
        groupId: "leaders"));
    
    addEntity(new GameText(game: this, 
        x: -145, 
        y: 130, 
        text: "9: ${Highscores[9]}",
        size: 42,
        font: "cinnamoncake, Verdana",
        centered:  false,
        color: "255, 255, 255",
        opacity: 0.4,
        id: "",
        groupId: "leaders"));
    
    addEntity(new GameText(game: this, 
        x: -145, 
        y: 170, 
        text: "10: ${Highscores[10]}",
        size: 42,
        font: "cinnamoncake, Verdana",
        centered:  false,
        color: "255, 255, 255",
        opacity: 0.4,
        id: "",
        groupId: "leaders"));
    
    addEntity(new GameButton(game: this, 
        x: -420, 
        y: -280, 
        text: "Back", 
        buttonAction: () { 
          state = GalagaGameState.welcome;
          _statUpdateEvent.signal();
          if (soundEffectsOn)
            sound.play("cursorSelect2");
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
        opacity: 0.4,
        id: "",
        groupId: "stats"));
    
    addEntity(new GameText(game: this, 
        x: -400, 
        y: -200, 
        text: "Total Killed: ${Stats["killed"]}",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  false,
        color: "255, 255, 255",
        opacity: 0.4,
        id: "",
        groupId: "stats"));
    
    addEntity(new GameText(game: this, 
        x: -400, 
        y: -155, 
        text: "Groupies Annihilated: ${Stats["normalKills"]}",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  false,
        color: "255, 255, 255",
        opacity: 0.4,
        id: "",
        groupId: "stats"));
    
    addEntity(new GameText(game: this, 
        x: -400, 
        y: -110, 
        text: "Big Bosses Denominated: ${Stats["bossKills"]}",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  false,
        color: "255, 255, 255",
        opacity: 0.4,
        id: "",
        groupId: "stats"));
    
    addEntity(new GameText(game: this, 
        x: -400, 
        y: -65, 
        text: "Mother Ships Deflowered: ${Stats["motherKills"]}",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  false,
        color: "255, 255, 255",
        opacity: 0.4,
        id: "",
        groupId: "stats"));
    
    addEntity(new GameText(game: this, 
        x: -400, 
        y: -20, 
        text: "Powerups Absorbed: ${Stats["powerups"]}",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  false,
        color: "255, 255, 255",
        opacity: 0.4,
        id: "",
        groupId: "stats"));
    
    addEntity(new GameText(game: this, 
        x: -400, 
        y: 25, 
        text: "Total Wins: ${Stats["wins"]}",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  false,
        color: "255, 255, 255",
        opacity: 0.4,
        id: "",
        groupId: "stats"));
    
    addEntity(new GameText(game: this, 
        x: -400, 
        y: 70, 
        text: "Total Loses: ${Stats["loses"]}",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  false,
        color: "255, 255, 255",
        opacity: 0.4,
        id: "",
        groupId: "stats"));
    
    addEntity(new GameText(game: this, 
        x: -400, 
        y: 115, 
        text: "Total Games: ${Stats["totalGames"]}",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  false,
        color: "255, 255, 255",
        opacity: 0.4,
        id: "",
        groupId: "stats"));
    
    addEntity(new GameText(game: this, 
        x: -400, 
        y: 160, 
        text: "High Score: ${Stats["highscore"]}",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  false,
        color: "255, 255, 255",
        opacity: 0.4,
        id: "",
        groupId: "stats"));
    
    addEntity(new GameText(game: this, 
        x: 100, 
        y: -200, 
        text: "Jew",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  false,
        color: "255, 255, 255",
        opacity: RankSelect[1] == true ? .8 : .4,
        id: "",
        groupId: "stats"));
    
    addEntity(new GameText(game: this, 
        x: 100, 
        y: -155, 
        text: "Jewish Priest",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  false,
        color: "255, 255, 255",
        opacity: RankSelect[2] == true ? .8 : .4,
        id: "",
        groupId: "stats"));
    
    addEntity(new GameText(game: this, 
        x: 100, 
        y: -110, 
        text: "Amish Mastermind",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  false,
        color: "255, 255, 255",
        opacity: RankSelect[3] == true ? .8 : .4,
        id: "",
        groupId: "stats"));
    
    addEntity(new GameText(game: this, 
        x: 100, 
        y: -65, 
        text: "Road Warrior",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  false,
        color: "255, 255, 255",
        opacity: RankSelect[4] == true ? .8 : .4,
        id: "",
        groupId: "stats"));
    
    addEntity(new GameText(game: this, 
        x: 100, 
        y: -20, 
        text: "Space Recruit",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  false,
        color: "255, 255, 255",
        opacity: RankSelect[5] == true ? .8 : .4,
        id: "",
        groupId: "stats"));
    
    addEntity(new GameText(game: this, 
        x: 100, 
        y: 25, 
        text: "Space Cadet",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  false,
        color: "255, 255, 255",
        opacity: RankSelect[6] == true ? .8 : .4,
        id: "",
        groupId: "stats"));
    
    addEntity(new GameText(game: this, 
        x: 100, 
        y: 70, 
        text: "Space Captain",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  false,
        color: "255, 255, 255",
        opacity: RankSelect[7] == true ? .8 : .4,
        id: "",
        groupId: "stats"));
    
    addEntity(new GameText(game: this, 
        x: 100, 
        y: 115, 
        text: "Overlord of the Galaxy",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  false,
        color: "255, 255, 255",
        opacity: RankSelect[8] == true ? .8 : .4,
        id: "",
        groupId: "stats"));
    
    addEntity(new GameText(game: this, 
        x: 100, 
        y: 160, 
        text: "Overlord of the Universe",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  false,
        color: "255, 255, 255",
        opacity: RankSelect[9] == true ? .8 : .4,
        id: "",
        groupId: "stats"));
    
    addEntity(new GameButton(game: this, 
        x: -420, 
        y: -280, 
        text: "Back", 
        buttonAction: () { 
          state = GalagaGameState.welcome;
          _statUpdateEvent.signal();
          if (soundEffectsOn)
            sound.play("cursorSelect2");
        },
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.4,
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
        opacity: 0.4,
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
        x: 0, 
        y: -60, 
        text: "Starting Lives:",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.6,
        id: "",
        groupId: "options"));
    
    addEntity(new GameButton(game: this, 
        x: 120, 
        y: -60, 
        text: "${Options["startLives"]}", 
        buttonAction: (){
          
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
        opacity: 0.4,
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
        opacity: 0.6,
        id: "",
        groupId: "options"));
    
    addEntity(new GameButton(game: this, 
        x: 120, 
        y: -30, 
        text: "${Options["bulletCap"]}", 
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
        opacity: 0.4,
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
        opacity: 0.6,
        id: "",
        groupId: "options"));
    
    addEntity(new GameButton(game: this, 
        x: 120, 
        y: 0, 
        text: "${Options["time"]}", 
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
        opacity: 0.4,
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
        opacity: 0.6,
        id: "",
        groupId: "options"));
    
    addEntity(new GameButton(game: this, 
        x: 120, 
        y: 30, 
        text: "${Options["difficulty"]}", 
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
        opacity: 0.4,
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
        opacity: 0.6,
        id: "",
        groupId: "options"));
    
    addEntity(new GameButton(game: this, 
        x: 150, 
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
        opacity: 0.4,
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
        opacity: 0.6,
        id: "",
        groupId: "options"));
    
    addEntity(new GameButton(game: this, 
        x: 170, 
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
        opacity: 0.4,
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
        opacity: 0.6,
        id: "",
        groupId: "options"));
    
    addEntity(new GameButton(game: this, 
        x: 380, 
        y: -280, 
        text: "Instructions", 
        buttonAction: () { 
          state = GalagaGameState.instructions;
          _statUpdateEvent.signal();
          if (soundEffectsOn)
            sound.play("cursorSelect2");
        },
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.4,
        id: "",
        groupId: "options"));
    
    addEntity(new GameButton(game: this, 
        x: -420, 
        y: -280, 
        text: "Back", 
        buttonAction: () { 
          state = GalagaGameState.welcome;
          _statUpdateEvent.signal();
          if (soundEffectsOn)
            sound.play("cursorSelect2");
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
        y: -160, 
        text: "Instructions",
        size: 56,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.8,
        id: "",
        groupId: "instructions"));
    
    addEntity(new GameText(game: this, 
        x: 0, 
        y: -94, 
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
        y: -45, 
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
        y: 0, 
        text: "'S' PowerUp = You shoot 3 shots in 3 different directions, which move in a spiral formation.",
        size: 24,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.6,
        id: "",
        groupId: "instructions"));
    
    addEntity(new GameText(game: this, 
        x: 0, 
        y: 45, 
        text: "'x2' PowerUp = Multiplies your score additions by 2.",
        size: 24,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.6,
        id: "",
        groupId: "instructions"));
    
    addEntity(new GameText(game: this, 
        x: 0, 
        y: 90, 
        text: "'+' PowerUp = Increases the amount of bullets you can fire by 1.",
        size: 24,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.6,
        id: "",
        groupId: "instructions"));
    
    addEntity(new GameText(game: this, 
        x: 0, 
        y: 135, 
        text: "'Life' PowerUp = Increases your total lives by 1.",
        size: 24,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.6,
        id: "",
        groupId: "instructions"));
    
    addEntity(new GameButton(game: this, 
        x: 0, 
        y: 180, 
        text: "Back", 
        buttonAction: () { 
          state = GalagaGameState.options;
          _statUpdateEvent.signal();
          if (soundEffectsOn)
            sound.play("cursorSelect2");
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
  
  void resetStats() {
    Stats["killed"] = 0;
    Stats["wins"] = 0;
    Stats["loses"] = 0;
    Stats["totalGames"] = 0;
    Stats["highscore"] = 0;
    
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
    visualLevel = 2;
    level = 2;
    score = 0;
    pointMultiplier = 1;
    
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
    if (soundEffectsOn)
      sound.play("cursorSelect2");
    removeEntitiesByGroup("gameOver");
    createGameOverMenu();
    
    state = GalagaGameState.gameOver;
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
