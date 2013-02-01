import "dart:html";
import "package:galaga/galaga_game.dart";
import "package:galaga/galaga_html.dart";
import "package:dgame/dgame.dart";
import "package:dgame/dgame_html.dart";

void main() {
  var sound = new HtmlGameSound();
  var input = new HtmlGameInput();
  var renderer = new GalagaRenderer("surface");
  var loop  = new HtmlGameLoop();

  var game = new GalagaGame.withServices(sound, input, renderer, loop);
  //game.sound.enabled = false;
  Game.debugMode = false;
  game.start();  
}