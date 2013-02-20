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
    game.Stats[1] = window.localStorage.containsKey('win1') ? int.parse(window.localStorage['win1']) : 0;
    game.Stats[2] = window.localStorage.containsKey('win2') ? int.parse(window.localStorage['win2']) : 0;
    game.Stats[3] = window.localStorage.containsKey('win3') ? int.parse(window.localStorage['win3']) : 0;
    game.Stats[4] = window.localStorage.containsKey('win4') ? int.parse(window.localStorage['win4']) : 0;
    game.Stats[5] = window.localStorage.containsKey('win5') ? int.parse(window.localStorage['win5']) : 0;
    
    game.Options[1] = window.localStorage.containsKey('win6') ? int.parse(window.localStorage['win6']) : 0;
    game.Options[2] = window.localStorage.containsKey('win7') ? int.parse(window.localStorage['win7']) : 0;
    game.Options[3] = window.localStorage.containsKey('win8') ? int.parse(window.localStorage['win8']) : 0;
    game.Options[4] = window.localStorage.containsKey('win9') ? int.parse(window.localStorage['win9']) : 0;
    game.Options[5] = window.localStorage.containsKey('win10') ? int.parse(window.localStorage['win10']) : 0;
    game.Options[6] = window.localStorage.containsKey('win11') ? int.parse(window.localStorage['win11']) : 0;
    
    game.onGameOver.listen((e) => gameOver());
    game.onShipHit.listen((e) => shipHit());
  }
  
  void gameOver() {
    bgFade();
    
    window.localStorage['win1'] = game.Stats[1].toString();
    window.localStorage['win2'] = game.Stats[2].toString();
    window.localStorage['win3'] = game.Stats[3].toString();
    window.localStorage['win4'] = game.Stats[4].toString();
    window.localStorage['win5'] = game.Stats[5].toString();
    
    window.localStorage['win6'] = game.Options[1].toString();
    window.localStorage['win7'] = game.Options[2].toString();
    window.localStorage['win8'] = game.Options[3].toString();
    window.localStorage['win9'] = game.Options[4].toString();
    window.localStorage['win10'] = game.Options[5].toString();
    window.localStorage['win11'] = game.Options[6].toString();
  }
  
  void shipHit() {
    window.setTimeout(() => game.ship.opacity = 0, 25);
    window.setTimeout(() => game.ship.opacity = .2, 75);
    window.setTimeout(() => game.ship.opacity = 0, 150);
    window.setTimeout(() => game.ship.opacity = .2, 225);
    window.setTimeout(() => game.ship.opacity = 0, 300);
    window.setTimeout(() => game.ship.opacity = .2, 375);
  }
  
  void bossHit() {
    game.entities.where((e) => e is Enemy).forEach((e) { 
      if (e.type == "Boss") {
        window.setTimeout(() => e.opacity = 0, 25);
        window.setTimeout(() => e.opacity = .2, 75);
        window.setTimeout(() => e.opacity = 0, 150);
        window.setTimeout(() => e.opacity = .2, 225);
      }
    });
  }
  
  void motherShipHit() {
    game.entities.where((e) => e is Enemy).forEach((e) { 
      if (e.type == "MotherShip") {
        window.setTimeout(() => e.opacity = 0, 25);
        window.setTimeout(() => e.opacity = .2, 75);
        window.setTimeout(() => e.opacity = 0, 150);
        window.setTimeout(() => e.opacity = .2, 225);
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
    ctx.fillText("High Score: ${game.Stats[5]} ", 225, -(game.rect.halfHeight - 30));
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
