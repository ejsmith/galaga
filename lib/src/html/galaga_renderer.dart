part of galaga_html;

class GalagaRenderer extends CanvasGameRenderer<GalagaGame> {
  num timeLeft = 0;
  
  PowerUpRenderer powerUpRenderer;
  EnemyRenderer enemyRenderer;
  
  GalagaRenderer(String targetId) : super(targetId) {
    powerUpRenderer = new PowerUpRenderer(this);
    enemyRenderer = new EnemyRenderer(this);
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
    
    game.Options["startLives"] = window.localStorage.containsKey('win6') ? int.parse(window.localStorage['win6']) : 0;
    game.Options["bulletCap"] = window.localStorage.containsKey('win7') ? int.parse(window.localStorage['win7']) : 0;
    game.Options["time"] = window.localStorage.containsKey('win8') ? int.parse(window.localStorage['win8']) : 0;
    game.Options["difficulty"] = window.localStorage.containsKey('win9') ? int.parse(window.localStorage['win9']) : 0;
    game.Options["powerups"] = window.localStorage.containsKey('win10') ? int.parse(window.localStorage['win10']) : 0;
    game.Options["soundeffects"] = window.localStorage.containsKey('win11') ? int.parse(window.localStorage['win11']) : 0;
    
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
  
  void shipHit() {
    bgFade();
    
    window.setTimeout(() => game.ship.opacity = 0, 25);
    window.setTimeout(() => game.ship.opacity = .2, 75);
    window.setTimeout(() => game.ship.opacity = 0, 150);
    window.setTimeout(() => game.ship.opacity = .2, 225);
    window.setTimeout(() => game.ship.opacity = 0, 300);
    window.setTimeout(() => game.ship.opacity = .2, 375);
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
  }
  
  void bossHit() {
    game.entities.where((e) => e is Enemy).forEach((Enemy e) {
      if (e.type == "Boss" && e.idNum == game.targetId) {
        window.setTimeout(() => e.opacity = 0, 25);
        window.setTimeout(() => e.opacity = 1, 75);
      }
    });
  }
  
  void motherShipHit() {
    game.entities.where((e) => e is Enemy).forEach((Enemy e) { 
      if (e.type == "MotherShip" && e.idNum == game.targetId) {
        window.setTimeout(() => e.opacity = 0, 25);
        window.setTimeout(() => e.opacity = 1, 75);
        window.setTimeout(() => e.opacity = 0, 150);
        window.setTimeout(() => e.opacity = 1, 225);
        window.setTimeout(() => e.opacity = 0, 300);
        window.setTimeout(() => e.opacity = 1, 375);
      }
    });
  }
  
  void normalShipHit() {
    game.entities.where((e) => e is Enemy).forEach((Enemy e) { 
      if (e.type == "Normal" && e.idNum == game.targetId) {
        window.setTimeout(() => e.opacity = 0, 25);
        window.setTimeout(() => e.opacity = 1, 75);
        window.setTimeout(() => e.opacity = 0, 150);
        window.setTimeout(() => e.opacity = 1, 225);
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
    
    if (game.state == GalagaGameState.playing || game.state == GalagaGameState.paused) {
      drawTime();
      drawScore();
      drawHighScore();
      drawLives();
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
    ctx.fillStyle = "rgba(255, 255, 255, 1)";
    ctx.font = "32px cinnamoncake, Verdana";
    ctx.fillText("Lives: ${game.ship.lives} ", -475, (game.rect.halfHeight - 5));
  }
  
  void drawScore() {
    ctx.fillStyle = "rgba(255, 255, 255, 1)";
    ctx.font = "32px cinnamoncake, Verdana";
    ctx.fillText("Score: ${game.score} ", -475, -(game.rect.halfHeight - 30));
  }
  
  void drawHighScore() {
    ctx.fillStyle = "rgba(255, 255, 255, 1)";
    ctx.font = "32px cinnamoncake, Verdana";
    ctx.fillText("High Score: ${game.Stats["highscore"]} ", 225, -(game.rect.halfHeight - 30));
  }
  
  void bgFade() {
    game.bgStyle = "rgba(0, 0, 0, 0.8)";
    window.setTimeout(() => game.bgStyle = "rgba(0, 0, 0, 0.75)", 25);
    window.setTimeout(() => game.bgStyle = "rgba(0, 0, 0, 0.70)", 50);
    window.setTimeout(() => game.bgStyle = "rgba(0, 0, 0, 0.65)", 75);
    window.setTimeout(() => game.bgStyle = "rgba(0, 0, 0, 0.60)", 100);
    window.setTimeout(() => game.bgStyle = "rgba(0, 0, 0, 0.55)", 125);
    window.setTimeout(() => game.bgStyle = "rgba(0, 0, 0, 0.60)", 150);
    window.setTimeout(() => game.bgStyle = "rgba(0, 0, 0, 0.65)", 175);
    window.setTimeout(() => game.bgStyle = "rgba(0, 0, 0, 0.70)", 200);
    window.setTimeout(() => game.bgStyle = "rgba(0, 0, 0, 0.75)", 225);
    window.setTimeout(() => game.bgStyle = "rgba(0, 0, 0, 0.80)", 250);
    window.setTimeout(() => game.bgStyle = "rgba(0, 0, 0, 0.85)", 275);
  }
}
