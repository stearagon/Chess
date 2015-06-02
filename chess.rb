class Game
  attr_accessor :board

  def initialize
    @board = Board.new
  end
end

class Board
  attr_accessor :grid
  def initialize
    @grid = Array.new(8) do
      Array.new(8) { nil }
    end
  end

  def fill_board
    # Fills board with all pieces in starting position
    bh1 = Bishop.new(self, [0, 0], :black)
    bh2 = Bishop.new(self, [3, 3], :black)
    self.grid[0][0] = bh1
    self.grid[3][3] = bh2
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
    moves =[]

    self.move_dirs.each do |x , y|
      pos_x = self.pos[0] + x
      pos_y = self.pos[1] + y

      until !pos_x.between?(0,7) ||
            !pos_y.between?(0,7) ||
            !self.board.grid[pos_x][pos_y].nil?
        moves << [pos_x, pos_y]
        pos_x += x
        pos_y += y
      end
    end

    moves

  end

  def selected_moves

  end

end

class Bishop < Sliding_Piece

  DELTAS = [
    [1,1],
    [1,-1],
    [-1,1],
    [-1,-1]
  ]

  def initialize(board, pos, color)
    super
  end

  def move_dirs
    DELTAS
  end

end
