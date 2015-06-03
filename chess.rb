class Game
  attr_accessor :board

  def initialize
    @board = Board.new
  end
end

class Board
  PIECE_SYMBOLS = {

  }

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

  def display
    new_display = Array.new(8) { Array.new(8) { "" } }

    i = 0
    while i < 8
      j = 0
      while j < 8
        new_display[i][j] = "_" if self.grid[i][j] == nil
        new_display[i][j] = "R" if self.grid[i][j].is_a?(Rook)
        new_display[i][j] = "B" if self.grid[i][j].is_a?(Bishop)
        new_display[i][j] = "Q" if self.grid[i][j].is_a?(Queen)
        j +=1
      end
      i += 1
    end

    new_display.each_with_index { |row, index| puts "#{index}  #{row}" }
    return nil
  end

  def move(start_pos, end_pos)
    unless self.grid[start_pos[0]][start_pos[1]].moves.include?(end_pos)
      raise "Not a legal move."
    end

    self.grid[end_pos[0]][end_pos[1]] = self.grid[start_pos[0]][start_pos[1]]
    self.grid[start_pos[0]][start_pos[1]] = nil
  end

end

class Piece
  attr_accessor :board, :pos, :color

  def initialize(board, pos, color)
    @board = board
    @pos = pos # this is an array (e.g. [1,2] => [x, y])
    @color = color
    board.grid[pos[0]][pos[1]] = self
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

class Rook < Sliding_Piece

  DELTAS = [
    [1,0],
    [-1,0],
    [0,1],
    [0,-1]
  ]

  def initialize(board, pos, color)
    super
  end

  def move_dirs
    DELTAS
  end

end

class Queen < Sliding_Piece

  DELTAS = [
    [1,1],
    [1,-1],
    [-1,1],
    [-1,-1],
    [1,0],
    [-1,0],
    [0,1],
    [0,-1]
  ]

  def initialize(board, pos, color)
    super
  end

  def move_dirs
    DELTAS
  end

end
