require 'rubygems'
require 'gosu'
require 'serialport'

class GameWindow < Gosu::Window
  def initialize
    super 1920, 1080, true
    self.caption = "Gosu Tutorial Game"
    
    @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
    @value = 0
    @line = ''
    @reading = 0
    @average = 0
    @readings = []
    @averages = []
    @file = open('readings.csv','w+')
    Thread.new do
      loop do
        #puts "\nloopin"
        read_measures
      end
    end
  end

  def serial
    return @serial_port if @serial_port
    puts 'regenerating serial'
    @serial_port = SerialPort.new '/dev/ttyACM0', 38400
  end
  
  def clear_serial
    @serial_port = nil
  end

  def read_line(tries_left = 3)
    #puts 'try to read line'
    s = serial.readline.chomp
    #puts s
    s
  rescue EOFError => e
    raise e if tries_left == 0
    read_line(tries_left - 1)
  end

  def read_measures
    #puts "# reading measures"
    @line = read_line
    line = @line.match(/^one reading:\t(?<reading>[0-9\.]+)\t\| average:\t(?<average>[0-9\.]+)/)
    return if line.nil?
    @reading = line['reading'].to_f
    @average = line['average'].to_f
    @file.write "#{@reading},#{@average}\n"
    @file.flush
    @readings << @reading
    @averages << @average
    max_size = 50
    @readings.shift if @readings.length > max_size
    @averages.shift if @averages.length > max_size
  end

  def update
    @value += 1
  end

  def draw
    a = aqua = Gosu::Color::AQUA

    # draw(text, x, y, z, factor_x = 1, factor_y = 1, color = 0xffffffff, mode = :default)
    @font.draw("Current value is: #{@value}", 10, 10, 1.0, 2.0, 2.0, 0xffffff00)
    #@font.draw("\"#{read_line}\"", 10, 50, 1.0, 1.0, 1.0, 0xffffff00)
    @font.draw("\"#{@line}\"", 10, 70, 1.0, 2.0, 2.0, 0xffffff00)
    @font.draw("#{@reading}", 10, 140, 1.0, 2.0, 2.0, 0xffffff00)
    @font.draw("#{@average}", 150, 140, 1.0, 2.0, 2.0, 0xffffff00)

    draw_graph(50, 500, 1300, 400, datas=[@readings, @averages])
  end

  def button_down(id)
    puts id.inspect
    if id == Gosu::KbEscape then
      close
    end
  end

  def draw_graph(x, y, width, height, datas=[[1,2,3,9,5,7,2,1]], xticks=10, yticks=10)
    a = Gosu::Color::AQUA
    colors = [ Gosu::Color::AQUA, Gosu::Color::GREEN, Gosu::Color::FUCHSIA, Gosu::Color::CYAN, Gosu::Color::RED, Gosu::Color::YELLOW ]
    draw_grid(x, y, width, height, xticks=xticks, yticks=yticks)
    max_of_datas = datas.map(&:max).max || 0
    max = max_of_datas.nil? ? 0 : (max_of_datas/10).to_i * 10
    datas.each do |data|
      c = colors.rotate!.first
      data.map.with_index do |value, i|
        [ i.to_f / data.length, (value.to_f - data.min)/(data.max - data.min)]
        #[ i.to_f / data.length, (value.to_f)/(max)]
      end.map do |x_percent, y_percent|
        [ x + x_percent * width,
          y + height - y_percent * height ]
      end.each_cons(2) do |(x1,y1), (x2,y2)|
        draw_line x1, y1, c, x2, y2, c
        size = 3
        draw_quad(x2-size, y2-size, c, x2+size, y2-size, c, x2+size, y2+size, c, x2-size, y2+size, c)
      end
    end
    @font.draw("#{datas[0].min}", x-20, y + height, 1.0, 1.0, 1.0, 0xffffff00)
    #@font.draw("#{0}", x-20, y + height, 1.0, 1.0, 1.0, 0xffffff00)
    @font.draw("#{max}", x-20, y, 1.0, 1.0, 1.0, 0xffffff00)
  end

  def draw_grid(x, y, width, height, xticks=10, yticks=10)
    a = Gosu::Color::AQUA
    draw_line x, y, a, x, y+height, a
    draw_line x, y+height, a, x+width, y+height, a
    (x..x+width).step(width.to_f / xticks).each do |x_tick|
      draw_line x_tick, y+height, a, x_tick, y+height+5, a
    end
    (y..y+height).step(height.to_f / yticks).each do |y_tick|
      draw_line x, y_tick, a, x-5, y_tick, a
    end
  end

  def draw_line(x1, y1, c1, x2, y2, c2, z=0, mode=:default, stroke=1)
    draw_quad(x1, y1, c1,
              x2, y2, c2,
              x2+stroke, y2+stroke, c2,
              x1+stroke, y1+stroke, c1)
  end
end

window = GameWindow.new
window.show
