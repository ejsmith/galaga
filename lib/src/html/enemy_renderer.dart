part of galaga_html;

class EnemyRenderer extends DefaultCanvasEntityRenderer<Enemy> {
  EnemyRenderer(GalagaRenderer gr) : super(gr);

  void render(Enemy e) {
    super.render(e);

    gr.ctx.fillStyle = "rgba(0, 0, 0, .5)";
    gr.ctx.font = "36px Verdana";

    switch (e.type) {

    }
  }
}