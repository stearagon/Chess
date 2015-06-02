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
    bh1 = Bishop.new(game1.board, [0, 0], :black)
    bh2 = Bishop.new(game1.board, [6, 6], :white)
  end

end

class Piece
  attr_accessor :board, :pos, :color

  def initialize(board, pos, color)
    @board = board
    @pos = pos # this is an array (e.g. [1,2] => [x, y])
    @color = color
    board_pos = board.grid[pos[0]][pos[1]] = self
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
            (!self.board.grid[pos_x][pos_y].nil? &&
            self.board.grid[pos_x][pos_y].color == self.color)
        moves << [pos_x, pos_y]
        break if !self.board.grid[pos_x][pos_y].nil? && self.board.grid[pos_x][pos_y].color != self.color
        pos_x += x
        pos_y += y
      end
    end

    moves

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
