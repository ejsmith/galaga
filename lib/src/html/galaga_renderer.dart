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
    
    game.RankSelect[1] = window.localStorage.containsKey('win26') ? int.parse(window.localStorage['win26']) : false;
    game.RankSelect[2] = window.localStorage.containsKey('win27') ? int.parse(window.localStorage['win27']) : false;
    game.RankSelect[3] = window.localStorage.containsKey('win28') ? int.parse(window.localStorage['win28']) : false;
    game.RankSelect[4] = window.localStorage.containsKey('win29') ? int.parse(window.localStorage['win29']) : false;
    game.RankSelect[5] = window.localStorage.containsKey('win30') ? int.parse(window.localStorage['win30']) : false;
    game.RankSelect[6] = window.localStorage.containsKey('win31') ? int.parse(window.localStorage['win31']) : false;
    game.RankSelect[7] = window.localStorage.containsKey('win32') ? int.parse(window.localStorage['win32']) : false;
    game.RankSelect[8] = window.localStorage.containsKey('win33') ? int.parse(window.localStorage['win33']) : false;
    game.RankSelect[9] = window.localStorage.containsKey('win34') ? int.parse(window.localStorage['win34']) : false;
    
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
    
    new Timer(const Duration(milliseconds: 25), () => game.ship.opacity = 0);
    new Timer(const Duration(milliseconds: 75), () => game.ship.opacity = .2);
    new Timer(const Duration(milliseconds: 150), () => game.ship.opacity = 0);
    new Timer(const Duration(milliseconds: 225), () => game.ship.opacity = .2);
    new Timer(const Duration(milliseconds: 300), () => game.ship.opacity = 0);
    new Timer(const Duration(milliseconds: 375), () => game.ship.opacity = .2);
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
    
    window.localStorage['win26'] = game.RankSelect[1].toString();
    window.localStorage['win27'] = game.RankSelect[2].toString();
    window.localStorage['win28'] = game.RankSelect[3].toString();
    window.localStorage['win29'] = game.RankSelect[4].toString();
    window.localStorage['win30'] = game.RankSelect[5].toString();
    window.localStorage['win31'] = game.RankSelect[6].toString();
    window.localStorage['win32'] = game.RankSelect[7].toString();
    window.localStorage['win33'] = game.RankSelect[8].toString();
    window.localStorage['win34'] = game.RankSelect[9].toString();
  }
  
  void bossHit() {
    game.entities.where((e) => e is Enemy).forEach((Enemy e) {
      if (e.type == "Boss" && e.idNum == game.targetId) {
        new Timer(const Duration(milliseconds: 25), () => e.opacity = 0);
        new Timer(const Duration(milliseconds: 75), () => e.opacity = 1);
      }
    });
  }
  
  void motherShipHit() {
    game.entities.where((e) => e is Enemy).forEach((Enemy e) { 
      if (e.type == "MotherShip" && e.idNum == game.targetId) {
        new Timer(const Duration(milliseconds: 25), () => e.opacity = 0);
        new Timer(const Duration(milliseconds: 75), () => e.opacity = 1);
        new Timer(const Duration(milliseconds: 150), () => e.opacity = 0);
        new Timer(const Duration(milliseconds: 225), () => e.opacity = 1);
        new Timer(const Duration(milliseconds: 300), () => e.opacity = 0);
        new Timer(const Duration(milliseconds: 375), () => e.opacity = 1);
      }
    });
  }
  
  void normalShipHit() {
    game.entities.where((e) => e is Enemy).forEach((Enemy e) { 
      if (e.type == "Normal" && e.idNum == game.targetId) {
        new Timer(const Duration(milliseconds: 25), () => e.opacity = 0);
        new Timer(const Duration(milliseconds: 75), () => e.opacity = 1);
        new Timer(const Duration(milliseconds: 150), () => e.opacity = 0);
        new Timer(const Duration(milliseconds: 225), () => e.opacity = 1);
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
