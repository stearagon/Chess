require 'byebug'

class Game
  attr_accessor :board

  def initialize
    @board = Board.new
  end
end

class Board

  DIMENSIONS = 8

  PIECE_SYMBOLS = {
    King => "K",
    Queen => "Q",
    Bishop => "b",
    Rook => "r",
    Knight => "k",
    Pawn => "p",
    NilClass => "___"
  }

  attr_accessor :grid
  def initialize(grid = nil)
    @grid = grid || Array.new(DIMENSIONS) do
      Array.new(DIMENSIONS) { nil }
    end
  end

  def fill_board
    (0...DIMENSIONS).each do |col|
      Pawn.new(self, [Pawn::BLACK_START_ROW,col], :black)
      Pawn.new(self, [Pawn::WHITE_START_ROW,col], :white)
    end

    start_row = [ [0, :white] , [DIMENSIONS-1, :black] ]

    start_row.each do |row,color|
      Queen.new(self, [row,3], color)
      Rook.new(self, [row,0], color)
      Rook.new(self, [row,7], color)
      Bishop.new(self, [row,2], color)
      Bishop.new(self, [row,5], color)
      Knight.new(self, [row,1], color)
      Knight.new(self, [row,6], color)
      King.new(self, [row,4], color)
    end

    display
  end

  def display
    duped_board = Array.new(DIMENSIONS) { Array.new(DIMENSIONS) { "" } }

    (0...DIMENSIONS).each do |i|
      (0...DIMENSIONS).each do |j|
        duped_board[i][j] = PIECE_SYMBOLS[self.grid[i][j].class]
        unless self.grid[i][j].nil?
          duped_board[i][j] += self.grid[i][j].color == :white ? "_w" : "_b"
        end
      end
    end

    grid_labels_top
    duped_board.each_with_index { |row, index| puts "#{index}  #{row}" }
    grid_labels_bottom
    return nil
  end

  def grid_labels_top
    puts "\n\n\n\n"
    puts "      a      b      c      d      e      f      g      h"
    puts "      0      1      2      3      4      5      6      7"
    puts "\n"
  end

  def grid_labels_bottom
    puts "\n      0      1      2      3      4      5      6      7"
    puts "\n\n\n\n"
  end

  def move(start_pos, end_pos)
    unless self.grid[start_pos[0]][start_pos[1]].valid_moves.include?(end_pos)
      raise "Not a legal move."
    end

    self.grid[end_pos[0]][end_pos[1]] = self.grid[start_pos[0]][start_pos[1]]
    self.grid[start_pos[0]][start_pos[1]] = nil
    self.grid[end_pos[0]][end_pos[1]].pos = [ end_pos[0], end_pos[1] ]

    display
    nil
  end

  def move!(start_pos, end_pos)
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

  def deep_dup
    duped_board = Array.new(DIMENSIONS) { Array.new(DIMENSIONS) { "" } }

    (0...DIMENSIONS).each do |i|
      (0...DIMENSIONS).each do |j|
        duped_board[i][j] = self.grid[i][j].nil? ? nil : self.grid[i][j].dup
      end
    end

    duped_board = Board.new(duped_board)

    duped_board.grid.each do |row|
      row.each do |tile|
        tile.board = duped_board if !tile.nil?
      end
    end

    duped_board
  end

  def checkmate?(color)
    if self.in_check?(color)
      self.grid.each do |row|
        row.each do |tile|
          if !tile.nil? && tile.color == color
            return false if tile.valid_moves.length > 0
          end
        end
      end
    end

    true
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

  def valid_moves
      potential_moves = self.moves
      valid_moves = []
      potential_moves.each do |move|
          duped_board = self.board.deep_dup
          duped_board.move!(self.pos, move)
          valid_moves << move unless duped_board.in_check?(self.color)
      end

    valid_moves
  end

end

class Sliding_Piece < Piece
  def initialize(board, pos, color)
    super
  end

  def moves
    moves =[]

    self.move_dirs.each do |x , y|
      pos_x, pos_y = self.pos[0] + x, self.pos[1] + y

      until
        !pos_x.between?(0,Board::DIMENSIONS-1) ||
        !pos_y.between?(0,Board::DIMENSIONS-1) ||
        (!self.board.grid[pos_x][pos_y].nil? &&
          self.board.grid[pos_x][pos_y].color == self.color)

        moves << [pos_x, pos_y]

        break if
          !self.board.grid[pos_x][pos_y].nil? &&
            self.board.grid[pos_x][pos_y].color != self.color

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
      pos_x, pos_y = self.pos[0] + x, self.pos[1] + y

      unless
        !pos_x.between?(0,Board::DIMENSIONS-1) ||
        !pos_y.between?(0,Board::DIMENSIONS-1) ||
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
    moves =[]

    color_constant = self.color == :black ?  BLACK_START_ROW : WHITE_START_ROW


      DELTAS_NORMAL.each do |x , y|
      if self.color == :black
        pos_x = self.pos[0] + x
      else
        pos_x = self.pos[0] - x
      end
        pos_y = self.pos[1] + y



        unless
          !pos_x.between?(0,7) ||
          !pos_y.between?(0,7) ||
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

        unless
          !pos_x.between?(0,7) ||
          !pos_y.between?(0,7) ||
          (!self.board.grid[pos_x][pos_y].nil?) ||
            self.pos[0] != color_constant

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

        if
          pos_x.between?(0,7) &&
          pos_y.between?(0,7) &&
          !self.board.grid[pos_x][pos_y].nil? &&
          self.board.grid[pos_x][pos_y].color != self.color

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
