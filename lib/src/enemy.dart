part of galaga_game;

class Enemy extends GameEntity<GalagaGame> {
  String type;
  bool yReset = false;
  bool isFalling = false;
  num creationTime = 0;
  num startY = 0;
  num difficulty = 1;
  num bossDifficulty = 1;
  num health = 1;
  num bossHealth = 100;
  num maxHp = 1;
  num bossMaxHp = 100;
  bool belowHalfHp = false;
  num idNum = 1;
  
  
  Enemy(GalagaGame game, num x, num y, num diff, String Type) : super.withPosition(game, x, y, 36, 36) {
    num rType = random();
    creationTime = game.timer.gameTime;
    
    type = Type;
    difficulty = diff;
    
    if (type == "Normal")
      color = "255, 0, 255";
    if (type == "MotherShip")
      color = "0, 0, 255";
    
    if (type == "Normal")
      momentum.xVel = 80;
    if (type == "MotherShip")
      momentum.xVel = 40;
    if (type == "Boss")
      momentum.xVel = 0;
    if (type == "Drone")
      momentum.xVel = 80;
    
    if (type == "Normal")
      health = difficulty;
    if (type == "MotherShip")
      health = 3;
    if (type == "Boss") {
      width = 72;
      height = 72;
      health = bossHealth;
    }
    if (type == "Drone") {
      width = 16;
      height = 16;
      health = bossDifficulty;
    }
    
    maxHp = health;
    bossMaxHp = bossHealth;
    
    bossDifficulty = game.level / 3;
    
    startY = y;
  }
  
  void update() {
    if (game.state == GalagaGameState.paused || game.state == GalagaGameState.gameOver || game.state == GalagaGameState.welcome)
      return;
    
    if (health < (maxHp / 2) || bossHealth < (bossMaxHp / 2)) {
      belowHalfHp = true;
    }
    
    if (type == "Drone") {
      if (health <= 0) {
        game.score += 100 * game.pointMultiplier;
        game.Stats["killed"] += 1;
        
        if (random() > .5)
          game.newBulletPowerUp(x, y);
        
        game.newMiniExplosion(x, y);
        
        removeFromGame();
      }
      
      if (random() <= .01) {
        if (momentum.yVel != 0)
          momentum.yVel *= -1;
        else
          momentum.yVel = 60;
      }
      
      if (random() <= .01) {
        if (momentum.xVel != 0)
          momentum.xVel *= -1;
        else
          momentum.xVel = 60;
      }
      
      // Movement based on distance from the Boss so that they hover/rotate around it
      if (y > game.rect.halfHeight - 80)
        momentum.yVel *= -1;
      
      if (y < -(game.rect.halfHeight) + 16)
        momentum.yVel *= -1;
      
      if (x > game.rect.halfWidth - 16)
        momentum.xVel *= -1;
      
      if (x < -(game.rect.halfWidth) + 16)
        momentum.xVel *= -1;
      
      if (x > game.getEnemyX("Boss")) {
        if (random() <= .05)  
          momentum.xVel *= -1;
      }
      
      if (x < game.getEnemyX("Boss")) {
        if (random() <= .05)  
          momentum.xVel *= -1;
      }
      
      if (y > game.getEnemyY("Boss")) {
        if (random() <= .05)  
          momentum.yVel *= -1;
      }
      
      if (y < game.getEnemyY("Boss")) {
        if (random() <= .05)  
          momentum.yVel *= -1;
      }
      
      if (bossDifficulty == 1) {
        if (random() <= .01) {
          game.addEntity(new Bullet(game, x, y + 16, "straight", random(350,400), random(8,16)));
          if (game.soundEffectsOn)
            game.sound.play("enemyFire", .3);
        }
        
      } else if (bossDifficulty == 2) {
        if (random() <= .03) {
          game.addEntity(new Bullet(game, x, y + 16, "straight", random(350,400), random(8,16)));
          if (game.soundEffectsOn)
            game.sound.play("enemyFire", .3);
        }
        
      } else if (bossDifficulty == 3) {
        if (random() <= .07) {
          game.addEntity(new Bullet(game, x, y + 16, "straight", random(350,400), random(8,16)));
          
        if(random() <= .1) {
          game.addEntity(new Bullet(game, x, y + 16, "left", random(350,400), random(8,16)));
          game.addEntity(new Bullet(game, x, y + 16, "right", random(350,400), random(8,16)));
        } else if(random() <= .1) {
          game.addEntity(new Bullet(game, x, y + 16, "left", random(350,400), random(8,16), "exploding"));
          game.addEntity(new Bullet(game, x, y + 16, "right", random(350,400), random(8,16), "exploding"));
        }
          if (game.soundEffectsOn)
            game.sound.play("enemyFire", .3);
        }
        
      } else if (bossDifficulty == 4) {
        if (random() <= .1) {
          game.addEntity(new Bullet(game, x, y + 16, "straight", random(350,400), random(8,16)));
          
        if(random() <= .3) {
          game.addEntity(new Bullet(game, x, y + 16, "left", random(350,400), random(8,16)));
          game.addEntity(new Bullet(game, x, y + 16, "right", random(350,400), random(8,16)));
        } else if(random() <= .3) {
          game.addEntity(new Bullet(game, x, y + 16, "left", random(350,400), random(8,16), "exploding"));
          game.addEntity(new Bullet(game, x, y + 16, "right", random(350,400), random(8,16), "exploding"));
        }
          if (game.soundEffectsOn)
            game.sound.play("enemyFire", .3);
        }
        
      } else if (bossDifficulty == 5) {
        if (random() <= .2) {
          game.addEntity(new Bullet(game, x, y + 16, "straight", random(350,400), random(8,16)));
          
        if(random() <= .5) {
          game.addEntity(new Bullet(game, x, y + 16, "left", random(350,400), random(8,16)));
          game.addEntity(new Bullet(game, x, y + 16, "right", random(350,400), random(8,16)));
        } else if(random() <= .5) {
          game.addEntity(new Bullet(game, x, y + 16, "left", random(350,400), random(8,16), "exploding"));
          game.addEntity(new Bullet(game, x, y + 16, "right", random(350,400), random(8,16), "exploding"));
        }
        
          if (game.soundEffectsOn)
            game.sound.play("enemyFire", .3);
        }
    }
  }
    
    if (type == "Boss") {
      if (health <= 0) {
        game.Stats["wins"] += 1;
        game.newExplosion(x, y);
        
        game.removeEntitiesByFilter((e) => e is PowerUp);
        game.removeEntitiesByFilter((e) => e is Bullet);
        game.removeEntitiesByFilter((e) => e is Enemy);
        
        if (game.soundEffectsOn)
          game.sound.play("cursorSelect2");
        game.removeEntitiesByGroup("levelEnd");
        game.createLevelEnd();
        
        game.state = GalagaGameState.levelEnd;
        
        game.waiting = 1;
        
        game.bonusCheck = 3;
        game.bonusStage = false;
        
        game.level++;
        
        bossHealth += 50;
        
        if (game.level >= game.bonusCheck) {
          game.bonusStage = true;
          game.bonusCheck += 3;
        } else {
          game.bonusStage = false;
        }
        
        game.score += 10000 * game.pointMultiplier;
        game.Stats["killed"] += 1;
        
        game.bonusStage = false;
        
        removeFromGame();
      }
      
      if (random() <= .01) {
        if (momentum.yVel != 0)
          momentum.yVel *= -1;
        else
          momentum.yVel = 60;
      }
      
      if (random() <= .01) {
        if (momentum.xVel != 0)
          momentum.xVel *= -1;
        else
          momentum.xVel = 60;
      }
      
      if (y > game.rect.halfHeight - 250 && random() <= .07)
        momentum.yVel *= -1;
      
      if (y > game.rect.halfHeight - 115)
        momentum.yVel *= -1;
      
      if (y < -(game.rect.halfHeight) + 72)
        momentum.yVel *= -1;
      
      if (x > game.rect.halfWidth - 72)
        momentum.xVel *= -1;
      
      if (x < -(game.rect.halfWidth) + 72)
        momentum.xVel *= -1;
      
      if (belowHalfHp) {
        if (bossDifficulty == 1) {
          if(random() <= .1) {
            game.addEntity(new Bullet(game, x, y + 16, "left", random(350,400), random(8,16), "exploding"));
            game.addEntity(new Bullet(game, x, y + 16, "straight", random(350,400), random(8,16), "exploding"));
            game.addEntity(new Bullet(game, x, y + 16, "right", random(350,400), random(8,16), "exploding"));
            
            if (game.soundEffectsOn)
              game.sound.play("enemyFire", .3);
          }
          
        } else if (bossDifficulty == 2) {
          if(random() <= .1) {
            game.addEntity(new Bullet(game, x, y + 16, "left", random(350,400), random(8,16), "exploding"));
            game.addEntity(new Bullet(game, x, y + 16, "straight", random(350,400), random(8,16), "exploding"));
            game.addEntity(new Bullet(game, x, y + 16, "right", random(350,400), random(8,16), "exploding"));
            
            if (game.soundEffectsOn)
              game.sound.play("enemyFire", .3);
          }
          
        } else if (bossDifficulty == 3) {
          if (random() <= .07) {
            if (random() <= .1) {
              game.addEntity(new Bullet(game, x, y + 16, "left", random(350,400), random(8,16), "exploding"));
              game.addEntity(new Bullet(game, x, y + 16, "straight", random(350,400), random(8,16), "exploding"));
              game.addEntity(new Bullet(game, x, y + 16, "right", random(350,400), random(8,16), "exploding"));
            } else if(random() <= .1) {
              game.addEntity(new Bullet(game, x, y + 16, "left", random(350,400), random(8,16), "exploding"));
              game.addEntity(new Bullet(game, x, y + 16, "right", random(350,400), random(8,16), "exploding"));
            }
            if (game.soundEffectsOn)
              game.sound.play("enemyFire", .3);
          }
          
        } else if (bossDifficulty == 4) {
          if (random() <= .1) {
            if (random() <= .3) {
              game.addEntity(new Bullet(game, x, y + 16, "left", random(350,400), random(8,16), "exploding"));
              game.addEntity(new Bullet(game, x, y + 16, "straight", random(350,400), random(8,16), "exploding"));
              game.addEntity(new Bullet(game, x, y + 16, "right", random(350,400), random(8,16), "exploding"));
            } else if(random() <= .3) {
              game.addEntity(new Bullet(game, x, y + 16, "left", random(350,400), random(8,16), "exploding"));
              game.addEntity(new Bullet(game, x, y + 16, "right", random(350,400), random(8,16), "exploding"));
            }
            if (game.soundEffectsOn)
              game.sound.play("enemyFire", .3);
          }
          
        } else if (bossDifficulty == 5) {
          if (random() <= .2) {
            if (random() <= .5) {
              game.addEntity(new Bullet(game, x, y + 16, "left", random(350,400), random(8,16), "exploding"));
              game.addEntity(new Bullet(game, x, y + 16, "straight", random(350,400), random(8,16), "exploding"));
              game.addEntity(new Bullet(game, x, y + 16, "right", random(350,400), random(8,16), "exploding"));
            }  else if(random() <= .5) {
              game.addEntity(new Bullet(game, x, y + 16, "left", random(350,400), random(8,16), "exploding"));
              game.addEntity(new Bullet(game, x, y + 16, "right", random(350,400), random(8,16), "exploding"));
            }
            game.addEntity(new Bullet(game, x, y + 16, "straight", random(350,400), random(30,42)));
            game.addEntity(new Bullet(game, x, y + 16, "left", random(350,400), random(30,42)));
            game.addEntity(new Bullet(game, x, y + 16, "right", random(350,400), random(30,42)));
            if (game.soundEffectsOn)
              game.sound.play("enemyFire", .3);
          }
        }
      } else {
        if (bossDifficulty == 1) {
          if (random() <= .01) {
            game.addEntity(new Bullet(game, x, y + 16, "straight", random(350,400), random(30,42)));
            game.addEntity(new Bullet(game, x, y + 16, "left", random(350,400), random(30,42)));
            game.addEntity(new Bullet(game, x, y + 16, "right", random(350,400), random(30,42)));
            if (game.soundEffectsOn)
              game.sound.play("enemyFire", .3);
          }
          
        } else if (bossDifficulty == 2) {
          if (random() <= .03) {
            game.addEntity(new Bullet(game, x, y + 16, "straight", random(350,400), random(30,42)));
            game.addEntity(new Bullet(game, x, y + 16, "left", random(350,400), random(30,42)));
            game.addEntity(new Bullet(game, x, y + 16, "right", random(350,400), random(30,42)));
            if (game.soundEffectsOn)
              game.sound.play("enemyFire", .3);
          }
          
        } else if (bossDifficulty == 3) {
          if (random() <= .07) {
            if (random() <= .1) {
              game.addEntity(new Bullet(game, x, y + 16, "straight", random(350,400), random(42,54)));
              game.addEntity(new Bullet(game, x, y + 16, "left", random(350,400), random(42,54)));
              game.addEntity(new Bullet(game, x, y + 16, "right", random(350,400), random(42,54)));
            } else if(random() <= .1) {
              game.addEntity(new Bullet(game, x, y + 16, "left", random(350,400), random(8,16), "exploding"));
              game.addEntity(new Bullet(game, x, y + 16, "right", random(350,400), random(8,16), "exploding"));
            }
            game.addEntity(new Bullet(game, x, y + 16, "straight", random(350,400), random(30,42)));
            game.addEntity(new Bullet(game, x, y + 16, "left", random(350,400), random(30,42)));
            game.addEntity(new Bullet(game, x, y + 16, "right", random(350,400), random(30,42)));
            if (game.soundEffectsOn)
              game.sound.play("enemyFire", .3);
          }
          
        } else if (bossDifficulty == 4) {
          if (random() <= .1) {
            if (random() <= .3) {
              game.addEntity(new Bullet(game, x, y + 16, "straight", random(350,400), random(42,54)));
              game.addEntity(new Bullet(game, x, y + 16, "left", random(350,400), random(42,54)));
              game.addEntity(new Bullet(game, x, y + 16, "right", random(350,400), random(42,54)));
            } else if(random() <= .3) {
              game.addEntity(new Bullet(game, x, y + 16, "left", random(350,400), random(8,16), "exploding"));
              game.addEntity(new Bullet(game, x, y + 16, "right", random(350,400), random(8,16), "exploding"));
            }
            game.addEntity(new Bullet(game, x, y + 16, "straight", random(350,400), random(30,42)));
            game.addEntity(new Bullet(game, x, y + 16, "left", random(350,400), random(30,42)));
            game.addEntity(new Bullet(game, x, y + 16, "right", random(350,400), random(30,42)));
            if (game.soundEffectsOn)
              game.sound.play("enemyFire", .3);
          }
          
        } else if (bossDifficulty == 5) {
          if (random() <= .2) {
            if (random() <= .5) {
              game.addEntity(new Bullet(game, x, y + 16, "straight", random(350,400), random(42,54)));
              game.addEntity(new Bullet(game, x, y + 16, "left", random(350,400), random(42,54)));
              game.addEntity(new Bullet(game, x, y + 16, "right", random(350,400), random(42,54)));
            }  else if(random() <= .5) {
              game.addEntity(new Bullet(game, x, y + 16, "left", random(350,400), random(8,16), "exploding"));
              game.addEntity(new Bullet(game, x, y + 16, "right", random(350,400), random(8,16), "exploding"));
            }
            game.addEntity(new Bullet(game, x, y + 16, "straight", random(350,400), random(30,42)));
            game.addEntity(new Bullet(game, x, y + 16, "left", random(350,400), random(30,42)));
            game.addEntity(new Bullet(game, x, y + 16, "right", random(350,400), random(30,42)));
            if (game.soundEffectsOn)
              game.sound.play("enemyFire", .3);
          }
          
        }
      }
      
      if (random() <= .5)
        game.newBossDrone(x, y - 50);
      else 
        game.newBossDrone(x + 72, y - 50);
    }
    
    if (type == "MotherShip") {
      if (x > game.rect.halfWidth)
        removeFromGame();
      
      if (health <= 0) {
        game.score += 1000 * game.pointMultiplier;
        game.Stats["killed"] += 1;
        
        if (random() > .5)
          game.newBulletPowerUp(x, y);
        
        game.newMiniExplosion(x, y);
        
        removeFromGame();
      }
      
      if (difficulty == 1) {
        if ((x + 16 >= game.ship.x && x - 16 <= game.ship.x) && random() <= .01) {
          game.addEntity(new Bullet(game, x, y + 16, "straight", random(350,400), random(8,16)));
          if (game.soundEffectsOn)
            game.sound.play("motherShipFire", .3);
        }
        
      } else if (difficulty == 2) {
        if ((x + 16 >= game.ship.x && x - 16 <= game.ship.x) && random() <= .03) {
          game.addEntity(new Bullet(game, x, y + 16, "straight", random(350,400), random(8,16)));
          if (game.soundEffectsOn)
            game.sound.play("motherShipFire", .3);
        }
        
      } else if (difficulty == 3) {
        if ((x + 16 >= game.ship.x && x - 16 <= game.ship.x) && random() <= .07) {
          game.addEntity(new Bullet(game, x, y + 16, "straight", random(350,400), random(8,16)));
          
        if(random() <= .1) {
          game.addEntity(new Bullet(game, x, y + 16, "left", random(350,400), random(8,16)));
          game.addEntity(new Bullet(game, x, y + 16, "right", random(350,400), random(8,16)));
        } else if(random() <= .1) {
          game.addEntity(new Bullet(game, x, y + 16, "left", random(350,400), random(8,16), "exploding"));
          game.addEntity(new Bullet(game, x, y + 16, "right", random(350,400), random(8,16), "exploding"));
        }
          if (game.soundEffectsOn)
            game.sound.play("motherShipFire", .3);
        }
        
      } else if (difficulty == 4) {
        if ((x + 16 >= game.ship.x && x - 16 <= game.ship.x) && random() <= .1) {
          game.addEntity(new Bullet(game, x, y + 16, "straight", random(350,400), random(8,16)));
          
        if(random() <= .3) {
          game.addEntity(new Bullet(game, x, y + 16, "left", random(350,400), random(8,16)));
          game.addEntity(new Bullet(game, x, y + 16, "right", random(350,400), random(8,16)));
        } else if(random() <= .3) {
          game.addEntity(new Bullet(game, x, y + 16, "left", random(350,400), random(8,16), "exploding"));
          game.addEntity(new Bullet(game, x, y + 16, "right", random(350,400), random(8,16), "exploding"));
        }
          if (game.soundEffectsOn)
            game.sound.play("motherShipFire", .3);
        }
        
      } else if (difficulty == 5) {
        if ((x + 16 >= game.ship.x && x - 16 <= game.ship.x) && random() <= .2) {
          game.addEntity(new Bullet(game, x, y + 16, "straight", random(350,400), random(8,16)));
          
        if(random() <= .5) {
          game.addEntity(new Bullet(game, x, y + 16, "left", random(350,400), random(8,16)));
          game.addEntity(new Bullet(game, x, y + 16, "right", random(350,400), random(8,16)));
        } else if(random() <= .5) {
          game.addEntity(new Bullet(game, x, y + 16, "left", random(350,400), random(8,16), "exploding"));
          game.addEntity(new Bullet(game, x, y + 16, "right", random(350,400), random(8,16), "exploding"));
        }
          if (game.soundEffectsOn)
            game.sound.play("motherShipFire", .3);
        }
      }
    }
    
    if (type == "Normal") {
      if (random() < .0002 && game.canEnemyFall == true)
        momentum.yVel = 140;
      
      if (health <= 0) {
        game.score += 100 * game.pointMultiplier;
        game.enemyAmount--;
        game.Stats["killed"] += 1;
        
        if (random() > .5)
          game.newBulletPowerUp(x, y);
        
        game.newMiniExplosion(x, y);
        
        removeFromGame();
      }
      
      if (y >= 350 && !yReset) {
        y = -350;
        yReset = true;
      }
      
      if (yReset) {
        if (game.goingRight)
          momentum.xVel = 80;
        else
          momentum.xVel = -80;
        
      }
      
      if (y >= startY && yReset) {
        momentum.yVel = 0;
        y = startY;
        
        yReset = false;
      }
      
      if (random() <= .01 && game.canEnemyFall()) {
        momentum.yVel *= -1;
        
        isFalling = true;
        yReset = false;
      }
      
  //    if (game.ship.x > x && momentum.yVel > 0 && !yReset)
  //      momentum.xVel = 30;
  //    else if (game.ship.x < x && momentum.yVel > 0 && !yReset)
  //      momentum.xVel = -30;
      
      if (x + 16 > game.rect.halfWidth || x - 16 < -(game.rect.halfWidth))
        game.switchDirection();
        
      if (collidesWith(game.ship)) {
        game._gameOverEvent.signal();
        if (game.soundEffectsOn)
          game.sound.play("sweep");
        
        removeFromGame();
        
        game.ship.lives -= 1;
      }
      
      if (x < -(game.rect.halfWidth)) {
        game.gameOver();
      }
      
      if (difficulty == 1) {
        if ((x + 16 >= game.ship.x && x - 16 <= game.ship.x) && random() <= .01) {
          game.addEntity(new Bullet(game, x, y + 16, "straight", random(350,400), random(8,16)));
          if (game.soundEffectsOn)
            game.sound.play("enemyFire", .3);
        }
        
      } else if (difficulty == 2) {
        if ((x + 16 >= game.ship.x && x - 16 <= game.ship.x) && random() <= .03) {
          game.addEntity(new Bullet(game, x, y + 16, "straight", random(350,400), random(8,16)));
          if (game.soundEffectsOn)
            game.sound.play("enemyFire", .3);
        }
        
      } else if (difficulty == 3) {
        if ((x + 16 >= game.ship.x && x - 16 <= game.ship.x) && random() <= .07) {
          game.addEntity(new Bullet(game, x, y + 16, "straight", random(350,400), random(8,16)));
          
        if(random() <= .1) {
          game.addEntity(new Bullet(game, x, y + 16, "left", random(350,400), random(8,16)));
          game.addEntity(new Bullet(game, x, y + 16, "right", random(350,400), random(8,16)));
        } else if(random() <= .1) {
          game.addEntity(new Bullet(game, x, y + 16, "left", random(350,400), random(8,16), "exploding"));
          game.addEntity(new Bullet(game, x, y + 16, "right", random(350,400), random(8,16), "exploding"));
        }
          if (game.soundEffectsOn)
            game.sound.play("enemyFire", .3);
        }
        
      } else if (difficulty == 4) {
        if ((x + 16 >= game.ship.x && x - 16 <= game.ship.x) && random() <= .1) {
          game.addEntity(new Bullet(game, x, y + 16, "straight", random(350,400), random(8,16)));
          
        if(random() <= .3) {
          game.addEntity(new Bullet(game, x, y + 16, "left", random(350,400), random(8,16)));
          game.addEntity(new Bullet(game, x, y + 16, "right", random(350,400), random(8,16)));
        } else if(random() <= .3) {
          game.addEntity(new Bullet(game, x, y + 16, "left", random(350,400), random(8,16), "exploding"));
          game.addEntity(new Bullet(game, x, y + 16, "right", random(350,400), random(8,16), "exploding"));
        }
          if (game.soundEffectsOn)
            game.sound.play("enemyFire", .3);
        }
        
      } else if (difficulty == 5) {
        if ((x + 16 >= game.ship.x && x - 16 <= game.ship.x) && random() <= .2) {
          game.addEntity(new Bullet(game, x, y + 16, "straight", random(350,400), random(8,16)));
          
        if(random() <= .5) {
          game.addEntity(new Bullet(game, x, y + 16, "left", random(350,400), random(8,16)));
          game.addEntity(new Bullet(game, x, y + 16, "right", random(350,400), random(8,16)));
        } else if(random() <= .5) {
          game.addEntity(new Bullet(game, x, y + 16, "left", random(350,400), random(8,16), "exploding"));
          game.addEntity(new Bullet(game, x, y + 16, "right", random(350,400), random(8,16), "exploding"));
        }
          if (game.soundEffectsOn)
            game.sound.play("enemyFire", .3);
        }
      }
    }
    super.update();
  }
}