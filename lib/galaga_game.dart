library galaga_game;

import "dart:math" as Math;
import "dart:async";
import "dart:html";
import "dart:isolate";
import "package:dgame/dgame.dart";
import 'package:event_stream/event_stream.dart';

part "src/ship.dart";
part "src/enemy.dart";
part "src/powerup.dart";
part "src/bullet.dart";
part "src/stars.dart";

class GalagaGame extends Game {
  num score = 0;
  num highScore = 0;
  num lastPowerUp = 5;
  num lastEnemy = 5;
  num lastStar = 0;
  num _state;
  num w = 0;
  Map<num, num> Stats = new Map<num,num>();
  Map<num, num> Options = new Map<num,num>();
  Map<num, String> Controls = new Map<num,String>();
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
  bool p1Dead, p2Dead;
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
    
    _waitingTimer = new Timer.repeating(1000, (t) {    
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
        timer.gameTime = Options[3];
        
        t.cancel();
      }
    });
  }
  
  void start() {
    if (!Stats.containsKey(1))
      Stats[1] = 0;
    if (!Stats.containsKey(2))
      Stats[2] = 0;
    if (!Stats.containsKey(3))
      Stats[3] = 0;
    if (!Stats.containsKey(4))
      Stats[4] = 0;
    if (!Stats.containsKey(5))
      Stats[5] = 0;
    
    if (!Options.containsKey(1))
      Options[1] = 3;
    if (!Options.containsKey(2))
      Options[2] = 3;
    if (!Options.containsKey(3))
      Options[3] = 60;
    if (!Options.containsKey(4))
      Options[4] = 1;
    if (!Options.containsKey(5))
      Options[5] = 1;
    if (!Options.containsKey(6))
      Options[6] = 1;
    
    if (!Controls.containsKey(1))
      Controls[1] = "left";
    if (!Controls.containsKey(2))
      Controls[2] = "right";
    if (!Controls.containsKey(3))
      Controls[3] = "space";
    
    if (Options[6] == 1)
      soundEffectsOn = true;
    else
      soundEffectsOn = false;
    
    createWelcomeMenu();
    createGameOverMenu();
    createStatsMenu();
    createPausedMenu();
    createControlsMenu();
    
    //sound.play("menu", .5, true);
    
    state = GalagaGameState.welcome;
    super.start();
  }
  
  void update() {
    if (state == GalagaGameState.playing || state == GalagaGameState.paused) {
      if (input.keyCode == 27)
        state = state == GalagaGameState.paused ? GalagaGameState.playing : GalagaGameState.paused;
      
      if (enemyAmount <= 0) {
        Stats[2] += 1;
        
        entities.where((e) => e is PowerUp).toList().forEach((e) => e.removeFromGame());
        entities.where((e) => e is Bullet).toList().forEach((e) => e.removeFromGame());
        entities.where((e) => e is Enemy).toList().forEach((e) => e.removeFromGame());
        
        sound.play("cursorSelect2");
        removeEntitiesByGroup("levelEnd");
        createLevelEnd();
        
        state = GalagaGameState.levelEnd;
        
        waiting = 1;
        if (tutorial == false)
          level++;
        
        visualLevel++;
      }
      
      if (state == GalagaGameState.playing && Options[5] == 1)
        newPowerUp();
      
      if (state == GalagaGameState.playing)
        newMotherShip();
      
      if (score > Stats[5]) {
        highScore = score;
        Stats[5] = highScore;
      }
      
      if (timer.gameTime <= 0 && !bonusStage)
        gameOver();
      else if (bonusStage && timer.gameTime <= 0) {
        Stats[2] += 1;
        
        entities.where((e) => e is PowerUp).toList().forEach((e) => e.removeFromGame());
        entities.where((e) => e is Bullet).toList().forEach((e) => e.removeFromGame());
        entities.where((e) => e is Enemy).toList().forEach((e) => e.removeFromGame());
        
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
    
    super.update();
    newStar();
  }
  
  void startStars() {
    w = random(.5, 3.5);
    Stars star = new Stars(this, 0, 0, w, w, colorCount);
    
    do {
      star.x = random(-rect.halfWidth, rect.halfWidth);
      star.y = random(-rect.halfHeight, rect.halfHeight);
      
    } while(entities.where((e) => e is Stars).any((e) => star.collidesWith(e)));
    
    addEntity(star);
  }
  
  void newStar() {
    num rand = random(0, 1);
    
    if (rand > .09 || state == GalagaGameState.paused)
      return;
    
    w = random(.5, 3.5);
    
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
     
      addEntity(enemy);
    }
  }
  
  void newMotherShip([num difficulty = 1]) {
    int x = 0;
    
    entities.where((e) => e is Enemy).forEach((e) {
      var enemy = e as Enemy;
      
      if (enemy.type == "MotherShip") {
        x++;
      }
    });
    
    if (x >=2)
      return;
    
    num rand = random(0, 1);
    
    if (rand < .001) {
      Enemy enemy = new Enemy(this, -(rect.halfWidth), -225, difficulty, "MotherShip");
     
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
  
  num getEnemyX(String Type) {
    entities.where((e) => e is Enemy).forEach((e) {
      var enemy = e as Enemy;
      
      if (enemy.type == Type && enemy.isFalling == true) {
        return e.x;
      }
    });
  }
  
  num getEnemyY(String Type) {
    entities.where((e) => e is Enemy).toList().forEach((e) { 
      var enemy = e as Enemy;
      
      if (enemy.type == Type && enemy.isFalling == true) {
        return enemy.y;
      }
    });
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
    _gameOverEvent.signal(EventArgs.empty);
    
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
          _gameOverEvent.signal();
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
          
          _gameOverEvent.signal();
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
          
          _gameOverEvent.signal();
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
          
          entities.where((e) => e is PowerUp).toList().forEach((e) => e.removeFromGame());
          entities.where((e) => e is Bullet).toList().forEach((e) => e.removeFromGame());
          entities.where((e) => e is Enemy).toList().forEach((e) => e.removeFromGame());
          
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
  
  void createStatsMenu() {
    
    addEntity(new GameText(game: this, 
        x: 0, 
        y: -160, 
        text: "Statistics",
        size: 56,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.4,
        id: "",
        groupId: "stats"));
    
    addEntity(new GameText(game: this, 
        x: 0, 
        y: -94, 
        text: "Total Killed: ${Stats[1]}",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.4,
        id: "",
        groupId: "stats"));
    
    addEntity(new GameText(game: this, 
        x: 0, 
        y: -49, 
        text: "Total Wins: ${Stats[2]}",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.4,
        id: "",
        groupId: "stats"));
    
    addEntity(new GameText(game: this, 
        x: 0, 
        y: -10, 
        text: "Total Loses: ${Stats[3]}",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.4,
        id: "",
        groupId: "stats"));
    
    addEntity(new GameText(game: this, 
        x: 0, 
        y: 29, 
        text: "Total Games: ${Stats[4]}",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.4,
        id: "",
        groupId: "stats"));
    
    addEntity(new GameText(game: this, 
        x: 0, 
        y: 63, 
        text: "High Score: ${Stats[5]}",
        size: 36,
        font: "cinnamoncake, Verdana",
        centered:  true,
        color: "255, 255, 255",
        opacity: 0.4,
        id: "",
        groupId: "stats"));
    
    addEntity(new GameButton(game: this, 
        x: -420, 
        y: -280, 
        text: "Back", 
        buttonAction: () { 
          state = GalagaGameState.welcome;
          _gameOverEvent.signal();
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
        y: 105, 
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
        text: "${Options[1]}", 
        buttonAction: (){
          
          if (Options[1] >= 10) {
            Options[1] = 1;
          }
          else {
            Options[1]++;
          }
          
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
        text: "${Options[2]}", 
        buttonAction: () {
          
          if (Options[2] >= 10)
            Options[2] = 1;
          else
            Options[2]++;
          
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
        text: "${Options[3]}", 
        buttonAction: () {
          
          if (Options[3] >= 180)
            Options[3] = 0;
          else
            Options[3] += 20;
          
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
        text: "${Options[4]}", 
        buttonAction: () {
          
          if (Options[4] >= 5)
            Options[4] = 1;
          else
            Options[4] += 1;
          
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
        text: Options[5] == 1 ? "True" : "False",
        buttonAction: () {
          
          if (Options[5] >= 2)
            Options[5] = 1;
          else
            Options[5] += 1;
          
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
        text: Options[6] == 1 ? "True" : "False",
        buttonAction: () {
          
          if (Options[6] >= 2)
            Options[6] = 1;
          else
            Options[6] += 1;
          
          if (Options[6] == 1)
            soundEffectsOn = true;
          else
            soundEffectsOn = false;
          
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
          _gameOverEvent.signal();
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
          _gameOverEvent.signal();
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
          _gameOverEvent.signal();
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
    Stats[1] = 0;
    Stats[2] = 0;
    Stats[3] = 0;
    Stats[4] = 0;
    Stats[5] = 0;
    
    state = GalagaGameState.welcome;
    
    removeEntitiesByGroup("stats");
    createStatsMenu();
    
    state = GalagaGameState.stats;
  }
  
  void resetOptions() {
    Options[1] = 3;
    Options[2] = 3;
    Options[3] = 60;
    Options[4] = 1;
    Options[5] = 1;
    
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
    
    entities.where((e) => e is PowerUp).toList().forEach((e) => e.removeFromGame());
    entities.where((e) => e is Bullet).toList().forEach((e) => e.removeFromGame());
    entities.where((e) => e is Enemy).toList().forEach((e) => e.removeFromGame());
    
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
    ship.lives = Options[1];
    
    Stats[4] += 1;
    state = GalagaGameState.playing;
    timer.timeDecrease = true;
    timer.gameTime = Options[3];
  }
  
  void gameOver() {
    entities.where((e) => e is PowerUp).toList().forEach((e) => e.removeFromGame());
    entities.where((e) => e is Bullet).toList().forEach((e) => e.removeFromGame());
    entities.where((e) => e is Enemy).toList().forEach((e) => e.removeFromGame());
    
    Stats[3] += 1;
    _gameOverEvent.signal();
    if (soundEffectsOn)
      sound.play("cursorSelect2");
    removeEntitiesByGroup("gameOver");
    createGameOverMenu();
    
    state = GalagaGameState.gameOver;
  }
  
  void switchDirection() {
    goingRight = !goingRight;
    entities.where((e) => e is Enemy).forEach((e) {
      var enemy = e as Enemy;
      
      if (enemy.type == "Normal") {
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
    entities.where((e) => e is Enemy).forEach((e) { 
      var enemy = e as Enemy;
      
      if (enemy.type == "Normal" && enemy.isFalling == true) {
        x++;
      }
    });
    if (x >= 3)
      return false;
    else
      return true;
  }
  
  void removeBullets() {
    entities.where((e) => e is Bullet).forEach((e) { 
      e.removeFromGame();
    });
  }
  
  final EventStream _gameOverEvent = new EventStream();
  Stream<EventArgs> get onGameOver => _gameOverEvent.stream;
  
  final EventStream _shipHitEvent = new EventStream();
  Stream<EventArgs> get onShipHit => _shipHitEvent.stream;
  
  final EventStream _bossHitEvent = new EventStream();
  Stream<EventArgs> get onBossHit => _bossHitEvent.stream;
  
  final EventStream _motherShipEvent = new EventStream();
  Stream<EventArgs> get onMotherShipHit => _motherShipEvent.stream;
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
}
