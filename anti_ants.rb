#!/usr/bin/env ruby
require 'rubygems'
require 'gosu'

class Window < Gosu::Window
  def initialize
        
    @cellsize = 4

    @window_title = "Ant"        
    @window_x = 640; @window_y = 480
    super(@window_x, @window_y, false)
    
    @color = Gosu::Color.new(0xFFFFFFFF)
    @ant = [Gosu::Color.new(0xffFFFF00), Gosu::Color.new(0xffFF00FF)]
    
    @steps = 0
    @start_time = Time.now
    
    calcuate_bounds
    
    @cells = []
    clear_cells
    @ant_count = 4
    place_ants
  end
  
  def calcuate_bounds
    @cells_x = (@window_x/@cellsize).to_i-1
    @cells_y = (@window_y/@cellsize).to_i-1
    update_title
  end
  
  def update_title
    sps = @steps / (Time.now - @start_time)
    self.caption = "#{@window_title} - #{@steps} steps - #{sps.round}/sec - cell size #{@cellsize}"
  end
    
  def clear_cells
    @cells_x.times do |x|
      @cells[x] = []
    end
  end
  
  def place_ants
    @ants = []
    @ant_count.times do
      @ants << [rand(@cells_x), rand(@cells_y), :up, rand(2)]
    end  
  end
  
  def ant_left(direction)
    case direction
    when :up
      :left
    when :left
      :down
    when :down
      :right
    when :right
      :up
    end
  end
  def ant_right(direction)
    case direction
    when :up
      :right
    when :right
      :down
    when :down
      :left
    when :left
      :up
    end
  end
    
  def update
    @ants.map!{|ant_x, ant_y, ant_direction, ant_type|
      case ant_direction
      when :up
        ant_y-=1
        ant_y=@cells_y if ant_y < 0
      when :down
        ant_y+=1
        ant_y=0 if ant_y > @cells_y
      when :left
        ant_x-=1
        ant_x=@cells_x if ant_x < 0
      when :right
        ant_x+=1
        ant_x=0 if ant_x > @cells_x      
      end
      if @cells[ant_y][ant_x] == 1
        ant_direction = case ant_type
          when 0
            ant_left(ant_direction)
          else
            ant_right(ant_direction)
          end
        @cells[ant_y][ant_x] = 0
      else
        ant_direction = case ant_type
          when 0
            ant_right(ant_direction)
          else
            ant_left(ant_direction)
          end
        @cells[ant_y][ant_x] = 1
      end
      [ant_x, ant_y, ant_direction, ant_type]
    }
    
    @steps += 1
    update_title if @steps % 100 == 0
  end
  
  def draw
    @cells.each_with_index do |cy, y|
      next if cy == []
      cy.each_with_index do |cx, x|
        if cx == 1
          point(x*@cellsize, y*@cellsize,@color)
        end
      end
    end

    @ants.each do |ant_x, ant_y, ant_direction, ant_type|
      draw_rectangle(ant_y*@cellsize, ant_x*@cellsize,(ant_y*@cellsize)+@cellsize,(ant_x*@cellsize)+@cellsize,@ant[ant_type])
    end
  end
  
  def draw_rectangle(top, left, bottom, right, color)
    self.draw_line(left, top, color, right, top, color)
    self.draw_line(right, top, color, right, bottom, color)
    self.draw_line(right, bottom, color, left, bottom, color)
    self.draw_line(left, bottom, color, left, top, color)
  end
  
  def point(x,y,color)
    draw_line(x,y,color,x+1,y+1,color)
  end
      
  def button_down(id)
    if id == Gosu::Button::KbEscape
      close
    end
    if id == Gosu::Button::KbDown
      @cellsize-=1
      calcuate_bounds
      randomize_cells
    end
    if id == Gosu::Button::KbUp
      @cellsize+=1
      calcuate_bounds
      randomize_cells
    end
    if id == Gosu::Button::KbC
      clear_cells
      place_ants
    end    
  end
end

window = Window.new
window.show
