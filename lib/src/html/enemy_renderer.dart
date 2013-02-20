part of galaga_html;

class EnemyRenderer extends DefaultCanvasEntityRenderer<Enemy> {
  EnemyRenderer(GalagaRenderer gr) : super(gr);
  
  void render(Enemy e) {
    super.render(e);
    
    gr.ctx.fillStyle = "rgba(0, 0, 0, .5)";
    gr.ctx.font = "24px Verdana";
    
    switch (e.type) {
      case 'Boss':      
        gr.ctx.fillText("${e.health}", e.x - 8, e.y + 8);
        break;
    }
  }
}