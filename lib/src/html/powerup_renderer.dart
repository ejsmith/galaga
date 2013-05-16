part of galaga_html;

class PowerUpRenderer extends DefaultCanvasEntityRenderer<PowerUp> {
  PowerUpRenderer(GalagaRenderer gr) : super(gr);

  void render(PowerUp e) {
    super.render(e);

    gr.ctx.fillStyle = "rgba(0, 0, 0, .5)";
    gr.ctx.font = "24px Verdana";

    switch (e.type) {

    }
  }
}