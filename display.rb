require 'gosu'

class GameWindow < Gosu::Window
  def initialize
    super(640, 480, false)
    self.caption = "Gosu Tutorial Game"

    @background_image = Gosu::Image.from_text(self, "asdf asdf asdf", '', 22)
  end

  def update
  end

  def draw
    @background_image.draw(10, 20, 0)
    a = Gosu::Color::AQUA
    draw_line 200, 300, a, 100, 100, a
    draw_quad 100, 300, a, 200, 300, a, 200, 400, a, 100, 400, a
    draw_triangle 100, 300, a, 300, 300, a, 200, 100, a
  end
end

window = GameWindow.new
window.show