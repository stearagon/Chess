class Game
  attr_accessor :board

  def initialize
    @board = Board.new
  end
end

class Board
  def initialize
    @grid = Array.new(8) do
      Array.new(8) { "x" }
    end
  end

end

class Piece
  attr_accessor :board, :pos, :color

  def initialize(board, pos, color)
    @board = board
    @pos = pos # this is an array (e.g. [1,2] => [x, y])
    @color = color
  end
end

class Sliding_Piece < Piece
  def initialize(board, pos, color)
    super
  end
  def moves
    # return an array of places a piece can move to.
    # DELTAS.map do |x , y|
    #   [pos[0] + x, pos[1] + y]
    # end
    moves =[]

    Bishop::DELTAS.each do |x , y|
      pos_x = self.pos[0] + x
      pos_y = self.pos[1] + y

      until !pos_x.between?(0,7) || !pos_y.between?(0,7)
        moves << [pos_x, pos_y]
        pos_x += x
        pos_y += y
      end
    end

    moves
  end
end

class Bishop < Sliding_Piece
  def initialize(board, pos, color)
    super
  end

  DELTAS = [
    [1,1],
    [1,-1],
    [-1,1],
    [-1,-1]
  ]

end
