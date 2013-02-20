part of galaga_html;

class PowerUpRenderer extends DefaultCanvasEntityRenderer<PowerUp> {
  PowerUpRenderer(GalagaRenderer gr) : super(gr);
  
  void render(PowerUp e) {
    super.render(e);
    
    gr.ctx.fillStyle = "rgba(0, 0, 0, .5)";
    gr.ctx.font = "24px Verdana";
    
    switch (e.type) {
      case 'SpiralShot':      
        gr.ctx.fillText("S", e.x - 8, e.y + 8);
        break;
      case 'Multiplier':      
        gr.ctx.fillText("x2", e.x - 12, e.y + 8);
        break;
      case 'BulletIncrease':      
        gr.ctx.font = "36px Verdana";
        gr.ctx.fillText("+", e.x - 14, e.y + 10);
        break;
      case 'ExtraLife':      
        gr.ctx.font = "12px Verdana";
        gr.ctx.fillText("Life", e.x - 10, e.y + 8);
        break;
    }
  }
}