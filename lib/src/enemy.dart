part of galaga_game;

class Enemy extends GameEntity<GalagaGame> {
  String type;
  num startY = 0;
  num difficulty = 1;
  num bossDifficulty = 1;
  num health = 1;
  num bossHealth = 100;
  num maxHp = 1;
  num bossMaxHp = 100;
  bool belowHalfHp = false;
  bool flicker = false;
  bool isFalling = false;
  bool isGoingBack = false;
  num enemyType = 0;
  num cloneNum = 1;
  num idNum = 1;
  num switchAmount = 0;
  num targetX = 0;
  num motherShipType = 1;
  Timer _invincibleTimer;

  Enemy(GalagaGame game, num x, num y, num diff, String Type) : super.withPosition(game, x, y, 36, 36) {
    num rType = random();

    type = Type;
    difficulty = diff;
    opacity = 0.0;

    enemyType = random(0, 1);

    if (type == "Normal") {
      color = "255, 0, 255";
      momentum.xVel = 80;

      if (difficulty <= 2)
        health = difficulty;
    }

    if (type == "MotherShip") {
      color = "0, 0, 255";
      momentum.xVel = 40;
      health = 3;

      if (rType < .25) {
        motherShipType = 1;
      } else if (rType < .50) {
        motherShipType = 2;
      } else if (rType < .75) {
        motherShipType = 3;
      } else if (rType < 1) {
        motherShipType = 4;
      }

      width = 42;
      height = 42;
    }

    if (type == "Boss") {
      momentum.xVel = 0;
      width = 72;
      height = 72;
      health = bossHealth;
    }

    if (type == "Drone") {
      momentum.xVel = 80;
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
        game.score += 100 * game.pointMultiplier * difficulty;
        game.Stats["killed"]++;
        game.Stats["droneKills"]++;

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
      if (y > game.rect.halfHeight - 16)
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

      if (random() <= .05) {
        game.addEntity(new Bullet(game, x, y + 16, "straight", random(350,400), random(8,16)));
      }
    }

    if (type == "Boss") {
      if (health <= 0) {
        game.Stats["wins"] += 1;
        game.newExplosion(x, y);

        game.removeEntitiesByFilter((e) => e is PowerUp);
        game.removeEntitiesByFilter((e) => e is Bullet);
        game.removeEntitiesByFilter((e) => e is Enemy);

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

        game.score += 10000 * game.pointMultiplier * bossDifficulty;
        game.Stats["killed"] += 1;
        game.Stats["bossKills"] += 1;

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
            game.addEntity(new Bullet(game, x, y + 16, "left", random(350,400), random(8,16), "super"));
            game.addEntity(new Bullet(game, x, y + 16, "straight", random(350,400), random(8,16), "super"));
            game.addEntity(new Bullet(game, x, y + 16, "right", random(350,400), random(8,16), "super"));
          }

        } else if (bossDifficulty == 2) {
          if(random() <= .1) {
            game.addEntity(new Bullet(game, x, y + 16, "left", random(350,400), random(8,16), "super"));
            game.addEntity(new Bullet(game, x, y + 16, "straight", random(350,400), random(8,16), "super"));
            game.addEntity(new Bullet(game, x, y + 16, "right", random(350,400), random(8,16), "super"));
          }

        } else if (bossDifficulty == 3) {
          if (random() <= .07) {
            if (random() <= .1) {
              game.addEntity(new Bullet(game, x, y + 16, "left", random(350,400), random(8,16), "super"));
              game.addEntity(new Bullet(game, x, y + 16, "straight", random(350,400), random(8,16), "super"));
              game.addEntity(new Bullet(game, x, y + 16, "right", random(350,400), random(8,16), "super"));
            } else if(random() <= .1) {
              game.addEntity(new Bullet(game, x, y + 16, "left", random(350,400), random(8,16), "super"));
              game.addEntity(new Bullet(game, x, y + 16, "right", random(350,400), random(8,16), "super"));
            }
          }

        } else if (bossDifficulty == 4) {
          if (random() <= .1) {
            if (random() <= .3) {
              game.addEntity(new Bullet(game, x, y + 16, "left", random(350,400), random(8,16), "super"));
              game.addEntity(new Bullet(game, x, y + 16, "straight", random(350,400), random(8,16), "super"));
              game.addEntity(new Bullet(game, x, y + 16, "right", random(350,400), random(8,16), "super"));
            } else if(random() <= .3) {
              game.addEntity(new Bullet(game, x, y + 16, "left", random(350,400), random(8,16), "super"));
              game.addEntity(new Bullet(game, x, y + 16, "right", random(350,400), random(8,16), "super"));
            }
          }

        } else if (bossDifficulty == 5) {
          if (random() <= .2) {
            if (random() <= .5) {
              game.addEntity(new Bullet(game, x, y + 16, "left", random(350,400), random(8,16), "super"));
              game.addEntity(new Bullet(game, x, y + 16, "straight", random(350,400), random(8,16), "super"));
              game.addEntity(new Bullet(game, x, y + 16, "right", random(350,400), random(8,16), "super"));
            }  else if(random() <= .5) {
              game.addEntity(new Bullet(game, x, y + 16, "left", random(350,400), random(8,16), "super"));
              game.addEntity(new Bullet(game, x, y + 16, "right", random(350,400), random(8,16), "super"));
            }
            game.addEntity(new Bullet(game, x, y + 16, "straight", random(350,400), random(30,42), "super"));
            game.addEntity(new Bullet(game, x, y + 16, "left", random(350,400), random(30,42), "super"));
            game.addEntity(new Bullet(game, x, y + 16, "right", random(350,400), random(30,42), "super"));
          }
        }
      } else {
        if (bossDifficulty == 1) {
          if (random() <= .01) {
            game.addEntity(new Bullet(game, x, y + 16, "straight", random(350,400), random(30,42), "super"));
            game.addEntity(new Bullet(game, x, y + 16, "left", random(350,400), random(30,42), "super"));
            game.addEntity(new Bullet(game, x, y + 16, "right", random(350,400), random(30,42), "super"));
          }

        } else if (bossDifficulty == 2) {
          if (random() <= .03) {
            game.addEntity(new Bullet(game, x, y + 16, "straight", random(350,400), random(30,42), "super"));
            game.addEntity(new Bullet(game, x, y + 16, "left", random(350,400), random(30,42), "super"));
            game.addEntity(new Bullet(game, x, y + 16, "right", random(350,400), random(30,42), "super"));
          }

        } else if (bossDifficulty == 3) {
          if (random() <= .07) {
            if (random() <= .1) {
              game.addEntity(new Bullet(game, x, y + 16, "straight", random(350,400), random(42,54), "super"));
              game.addEntity(new Bullet(game, x, y + 16, "left", random(350,400), random(42,54), "super"));
              game.addEntity(new Bullet(game, x, y + 16, "right", random(350,400), random(42,54), "super"));
            } else if(random() <= .1) {
              game.addEntity(new Bullet(game, x, y + 16, "left", random(350,400), random(8,16), "super"));
              game.addEntity(new Bullet(game, x, y + 16, "right", random(350,400), random(8,16), "super"));
            }
          }

        } else if (bossDifficulty == 4) {
          if (random() <= .1) {
            if (random() <= .3) {
              game.addEntity(new Bullet(game, x, y + 16, "straight", random(350,400), random(42,54), "super"));
              game.addEntity(new Bullet(game, x, y + 16, "left", random(350,400), random(42,54), "super"));
              game.addEntity(new Bullet(game, x, y + 16, "right", random(350,400), random(42,54), "super"));
            } else if(random() <= .3) {
              game.addEntity(new Bullet(game, x, y + 16, "left", random(350,400), random(8,16), "super"));
              game.addEntity(new Bullet(game, x, y + 16, "right", random(350,400), random(8,16), "super"));
            }
          }

        } else if (bossDifficulty == 5) {
          if (random() <= .2) {
            if (random() <= .5) {
              game.addEntity(new Bullet(game, x, y + 16, "straight", random(350,400), random(42,54), "super"));
              game.addEntity(new Bullet(game, x, y + 16, "left", random(350,400), random(42,54), "super"));
              game.addEntity(new Bullet(game, x, y + 16, "right", random(350,400), random(42,54), "super"));
            }  else if(random() <= .5) {
              game.addEntity(new Bullet(game, x, y + 16, "left", random(350,400), random(8,16), "super"));
              game.addEntity(new Bullet(game, x, y + 16, "right", random(350,400), random(8,16), "super"));
            }
          } else {
            if (random() <= .01) {
              game.addEntity(new Bullet(game, x, y + 16, "straight", random(350,400), random(30,42), "super"));
              game.addEntity(new Bullet(game, x, y + 16, "left", random(350,400), random(30,42), "super"));
              game.addEntity(new Bullet(game, x, y + 16, "right", random(350,400), random(30,42), "super"));
            }
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

      momentum.xVel = 150;

      if (health <= 0) {
        game.score += 1000 * game.pointMultiplier * difficulty;
        game.Stats["killed"] += 1;
        game.Stats["motherKills"] += 1;

        if (random() > .5)
          game.newBulletPowerUp(x, y);

        game.newMiniExplosion(x, y);

        removeFromGame();
      }

      if (difficulty == 1) {
        if ((x + 16 >= game.ship.x && x - 16 <= game.ship.x) && random() <= .01) {
          game.addEntity(new Bullet(game, x, y + 16, "straight", random(350,400), random(8,16), "normal"));
        }

      } else if (difficulty == 2) {
        if ((x + 16 >= game.ship.x && x - 16 <= game.ship.x) && random() <= .03) {
          game.addEntity(new Bullet(game, x, y + 16, "straight", random(350,400), random(8,16), "normal"));
        }

      } else if (difficulty == 3) {
        if ((x + 16 >= game.ship.x && x - 16 <= game.ship.x) && random() <= .07) {
          game.addEntity(new Bullet(game, x, y + 16, "straight", random(350,400), random(8,16), "normal"));

          if(random() <= .1) {
            game.addEntity(new Bullet(game, x, y + 16, "left", random(350,400), random(8,16), "normal"));
            game.addEntity(new Bullet(game, x, y + 16, "right", random(350,400), random(8,16), "normal"));
          }
        }

      } else if (difficulty == 4) {
        if ((x + 16 >= game.ship.x && x - 16 <= game.ship.x) && random() <= .1) {
          game.addEntity(new Bullet(game, x, y + 16, "straight", random(350,400), random(8,16), "normal"));

          if(random() <= .3) {
            game.addEntity(new Bullet(game, x, y + 16, "left", random(350,400), random(8,16), "normal"));
            game.addEntity(new Bullet(game, x, y + 16, "right", random(350,400), random(8,16), "normal"));
          }
        }

      } else if (difficulty == 5) {
        if ((x + 16 >= game.ship.x && x - 16 <= game.ship.x) && random() <= .2) {
          game.addEntity(new Bullet(game, x, y + 16, "straight", random(350,400), random(8,16), "normal"));

          if(random() <= .5) {
            game.addEntity(new Bullet(game, x, y + 16, "left", random(350,400), random(8,16), "normal"));
            game.addEntity(new Bullet(game, x, y + 16, "right", random(350,400), random(8,16), "normal"));
          }
        }
      }
    }

    if (type == "Normal") {
      if (random() < .0001 && isFalling == false) {
        num startY = y;
        isFalling = true;
        momentum.yVel = 140;
      }

      game.entities.where((e) => e is Ship && collidesWith(e)).toList().forEach((e) {
        if (game.Cheats["invincibility"] != 1) {
          game.Stats["deaths"]++;
          game.ship.lives -= 1;
        }
        game._shipHitEvent.signal();

        if (game.Cheats["spreadshot"] == 2)
          game.resetPowerups();

        game.removeBullets();

        game.ship.bullet = game.ship.maxBullet;
        game.Cheats["invincibility"] = 1;

        _invincibleTimer = new Timer(const Duration(milliseconds: 3000), () {
          game.Cheats["invincibility"] = 0;
        });
      });

      if (y > (game.rect.halfHeight - 45)) {
        momentum.yVel = -140;
        isGoingBack = true;
      }

      if (isGoingBack == true) {
        game.matchCloneX();

        if (x < targetX) {
          momentum.xVel = 100;
        } else if (x > targetX) {
          momentum.xVel = -100;
        } else {
          momentum.xVel = 0;
        }
      }

      if (isFalling == true && isGoingBack == false) {
        if (random() < .1)
          momentum.xVel = random(-140,140);
        if (random() < .2)
          momentum.yVel = random(0,200);
        else if (random() < .05)
          momentum.yVel = random(-140,0);

        if (y < -(game.rect.halfHeight - 60))
          momentum.yVel *= -1;

        if (x + 16 > game.rect.halfWidth - 60 || x - 16 < -(game.rect.halfWidth) + 60)
          momentum.xVel *= -1;
      }

      if (y < startY && isGoingBack == true) {
        y = startY;
        momentum.yVel = 0;
        game.entities.where((c) => c is Clone).forEach((Clone c) {
          game.entities.where((e) => e is Enemy).forEach((Enemy e) {
            if (c.Id == e.cloneNum) {
              e.momentum.xVel = c.momentum.xVel;
            }
          });
        });
        isFalling = false;
        isGoingBack = false;
      }

      if (health <= 0) {
        game.score += 100 * game.pointMultiplier * difficulty;
        game.enemyAmount--;
        game.Stats["killed"] += 1;
        game.Stats["normalKills"] += 1;

        if (random() > .5)
          game.newBulletPowerUp(x, y);

        game.newMiniExplosion(x, y);

        game.entities.where((c) => c is Clone).forEach((Clone c) {
          game.entities.where((e) => e is Enemy).forEach((Enemy e) {
            if (c.Id == e.cloneNum) {
              c.removeFromGame();
            }
          });
        });

        removeFromGame();
      }

      if (x + 16 > game.rect.halfWidth || x - 16 < -(game.rect.halfWidth) && isFalling != true)
        game.switchDirection();

      if (difficulty == 1) {
        if ((x + 16 >= game.ship.x && x - 16 <= game.ship.x) && random() <= .01) {
          game.addEntity(new Bullet(game, x, y + 16, "straight", random(350,400), random(8,16), "normal"));
        }

      } else if (difficulty == 2) {
        if ((x + 16 >= game.ship.x && x - 16 <= game.ship.x) && random() <= .03) {
          game.addEntity(new Bullet(game, x, y + 16, "straight", random(350,400), random(8,16), "normal"));
        }

      } else if (difficulty == 3) {
        if ((x + 16 >= game.ship.x && x - 16 <= game.ship.x) && random() <= .07) {
          game.addEntity(new Bullet(game, x, y + 16, "straight", random(350,400), random(8,16), "normal"));

          if(random() <= .1) {
            game.addEntity(new Bullet(game, x, y + 16, "left", random(350,400), random(8,16), "normal"));
            game.addEntity(new Bullet(game, x, y + 16, "right", random(350,400), random(8,16), "normal"));
          }
        }

      } else if (difficulty == 4) {
        if ((x + 16 >= game.ship.x && x - 16 <= game.ship.x) && random() <= .1) {
          game.addEntity(new Bullet(game, x, y + 16, "straight", random(350,400), random(8,16), "normal"));

          if(random() <= .3) {
            game.addEntity(new Bullet(game, x, y + 16, "left", random(350,400), random(8,16), "normal"));
            game.addEntity(new Bullet(game, x, y + 16, "right", random(350,400), random(8,16), "normal"));
          }
        }

      } else if (difficulty == 5) {
        if ((x + 16 >= game.ship.x && x - 16 <= game.ship.x) && random() <= .2) {
          game.addEntity(new Bullet(game, x, y + 16, "straight", random(350,400), random(8,16), "normal"));

          if(random() <= .5) {
            game.addEntity(new Bullet(game, x, y + 16, "left", random(350,400), random(8,16), "normal"));
            game.addEntity(new Bullet(game, x, y + 16, "right", random(350,400), random(8,16), "normal"));
          }
        }
      }
    }
    super.update();
  }
}