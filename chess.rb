require 'byebug'

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
    # create white pieces
    q_w = Queen.new(self, [7,3], :white)
    r1_w = Rook.new(self, [7,0], :white)
    r2_w = Rook.new(self, [7,7], :white)
    b1_w = Bishop.new(self, [7,2], :white)
    b2_w = Bishop.new(self, [7,5], :white)
    kn1_w = Knight.new(self, [7,1], :white)
    kn2_w = Knight.new(self, [7,6], :white)
    k_w = King.new(self, [7,4], :white)
    p1_w = Pawn.new(self, [6,0], :white)
    p2_w = Pawn.new(self, [6,1], :white)
    p3_w = Pawn.new(self, [6,2], :white)
    p4_w = Pawn.new(self, [6,3], :white)
    p5_w = Pawn.new(self, [6,4], :white)
    p6_w = Pawn.new(self, [6,5], :white)
    p7_w = Pawn.new(self, [6,6], :white)
    p8_w = Pawn.new(self, [6,7], :white)
    # create black pieces
    q_b = Queen.new(self, [0,3], :black)
    r1_b = Rook.new(self, [0,0], :black)
    r2_b = Rook.new(self, [0,7], :black)
    b1_b = Bishop.new(self, [0,2], :black)
    b2_b = Bishop.new(self, [0,5], :black)
    kn1_b = Knight.new(self, [0,1], :black)
    kn2_b = Knight.new(self, [0,6], :black)
    k_b = King.new(self, [0,4], :black)
    p1_b = Pawn.new(self, [1,0], :black)
    p2_b = Pawn.new(self, [1,1], :black)
    p3_b = Pawn.new(self, [1,2], :black)
    p4_b = Pawn.new(self, [1,3], :black)
    p5_b = Pawn.new(self, [1,4], :black)
    p6_b = Pawn.new(self, [1,5], :black)
    p7_b = Pawn.new(self, [1,6], :black)
    p8_b = Pawn.new(self, [1,7], :black)

    display
  end

  def display
    new_display = Array.new(8) { Array.new(8) { "" } }

    i = 0
    while i < 8
      j = 0
      while j < 8
        new_display[i][j] = "___" if self.grid[i][j] == nil
        new_display[i][j] = "r" if self.grid[i][j].is_a?(Rook)
        new_display[i][j] = "b" if self.grid[i][j].is_a?(Bishop)
        new_display[i][j] = "Q" if self.grid[i][j].is_a?(Queen)
        new_display[i][j] = "k" if self.grid[i][j].is_a?(Knight)
        new_display[i][j] = "K" if self.grid[i][j].is_a?(King)
        new_display[i][j] = "p" if self.grid[i][j].is_a?(Pawn)

        unless self.grid[i][j].nil?
          new_display[i][j].concat("_w") if self.grid[i][j].color == :white
          new_display[i][j].concat("_b") if self.grid[i][j].color == :black
        end

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
    self.grid[end_pos[0]][end_pos[1]].pos = [ end_pos[0], end_pos[1] ]
  end

  def in_check?(color)
    king_pos = nil

    self.grid.each do |row|
      row.each do |tile|
        king_pos = tile.pos if tile.is_a?(King) && tile.color == color
      end
    end

    self.grid.each do |row|
      row.each do |tile|
        return true if !tile.nil? && tile.moves.include?(king_pos)
      end
    end

    false

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

class Stepping_Piece < Piece
  def initialize(board, pos, color)
    super
  end

  def moves
    moves =[]

    self.move_dirs.each do |x , y|
      pos_x = self.pos[0] + x
      pos_y = self.pos[1] + y

      unless !pos_x.between?(0,7) || !pos_y.between?(0,7) ||
            (!self.board.grid[pos_x][pos_y].nil? &&
            self.board.grid[pos_x][pos_y].color == self.color)
        moves << [pos_x, pos_y]
      end
    end

    moves

  end


end

class Pawn < Piece
  BLACK_START_ROW = 1
  WHITE_START_ROW = 6

  DELTAS_NORMAL = [
    [1,0]
  ]
  FIRST_MOVE = [
    [2,0]
  ]
  CAPTURE_MOVES = [
    [1,1],
    [1,-1]
  ]

  def initialize(board, pos, color)
    super
  end

  def moves
    #debugger
    moves =[]

    color_constant = self.color == :black ?  BLACK_START_ROW : WHITE_START_ROW


      DELTAS_NORMAL.each do |x , y|
      if self.color == :black
        pos_x = self.pos[0] + x
      else
        pos_x = self.pos[0] - x
      end
        pos_y = self.pos[1] + y



        unless !pos_x.between?(0,7) || !pos_y.between?(0,7) ||
              (!self.board.grid[pos_x][pos_y].nil?)
          moves << [pos_x, pos_y]
        end
      end

      FIRST_MOVE.each do |x , y|
        if self.color == :black
          pos_x = self.pos[0] + x
        else
          pos_x = self.pos[0] - x
        end
          pos_y = self.pos[1] + y

        unless !pos_x.between?(0,7) || !pos_y.between?(0,7) ||
              (!self.board.grid[pos_x][pos_y].nil?) || self.pos[0] != color_constant
          moves << [pos_x, pos_y]
        end
      end

      CAPTURE_MOVES.each do |x , y|
        if self.color == :black
          pos_x = self.pos[0] + x
        else
          pos_x = self.pos[0] - x
        end
          pos_y = self.pos[1] + y

        if pos_x.between?(0,7) && pos_y.between?(0,7) &&
              (!self.board.grid[pos_x][pos_y].nil?) &&
              (self.board.grid[pos_x][pos_y].color != self.color)
          moves << [pos_x, pos_y]
        end
      end


    moves

  end

end

class King < Stepping_Piece

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

class Knight < Stepping_Piece

  DELTAS = [
    [2,1],
    [2,-1],
    [-2,-1],
    [-2,1],
    [1,2],
    [1,-2],
    [-1,-2],
    [-1,2]
  ]

  def initialize(board, pos, color)
    super
  end

  def move_dirs
    DELTAS
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
