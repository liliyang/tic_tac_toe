# Allows the user to play a game of tic-tac-toe on a n by n board. The user
# can choose to play against another player or the computer. However, keep
# in mind that while the computer can play any game, the computer strategy
# was designed with a traditional 3 by 3 board in mind.



# Creates an n by n tic-tac-toe grid, where n is the input. The top left
# square corresponds to coordinates (1,1) while the bottom right square
# corresponds to coordinates (n,n)
class Board
  
  attr_accessor :grid, :size

  def initialize(size, grid = {})
    @size = size
    @grid = grid
  end

  # Initializes the values on the playing board. I.e. sets all the squares
  # to nil to start.
  def set_board
    (1..@size).each do |row|
      (1..@size).each { |column| @grid[[column, row]] = nil }
    end
  end
  
  # Prints out tic-tac-toe board, depending on placement of x's and o's
  def print_board
    (1..@size).each do |row|
      @size.times { print_top }
      puts "" # Adds line breaks
      @size.times { print_mid }
      puts ""
      (1..@size).each do |column|
        if @grid[[column, row]]
          print "| #{@grid[[column, row]]} | "
        else
          print_mid
        end
      end
      puts ""
      @size.times { print_low }
      puts ""
    end
  end
  
  # Some helper print functions
  def print_top
    print " ___  "
  end

  def print_mid
    print "|   | "
  end

  def print_low
    print "|___| "
  end
  
  # Checks if the board is full, i.e. all of the squares have been taken
  def full?
    @grid.each_value do |value|
      return false if value.nil?
    end
    true
  end
  
  # Checks if the target ("X" or "O") player has won
  def wins?(target)
    new_grid = split_grid(target)
    wins_rows_columns(new_grid) || wins_diagonals(new_grid)
  end
  
  # Pick out the squares with a particular value ("X", "O", or nil). So 
  # that it is easier to check if there's a winner.
  def split_grid(target)
    @grid.select { |key, value| value == target }.keys
  end
  
  # Check for winning rows or columns
  def wins_rows_columns(grid)
    for i in [0, 1] # 0 => row values, 1 => column values
      line = grid.map { |coord| coord[i] }
      (1..@size).each do |x|
        if line.count(x) == @size
          return true
        end
      end
    end
    false
  end
  
  # Check for winning diagonals
  def wins_diagonals(grid)
    diagonal1 = (1..@size).map { |x| [x, x] }
    diagonal2 = (1..@size).map { |x| [x, @size - x + 1]}
    if (diagonal1 - grid).empty? || (diagonal2 - grid).empty?
      true
    else
      false
    end
  end
  
  def corners
    [[1, 1], [1, @size], [@size, 1], [@size, @size]]
  end
  
  def center
    if @size % 2 == 0
      [[@size/2, @size/2], [@size/2, @size/2 + 1], [@size/2 + 1, @size/2 + 1], [@size/2 + 1, @size/2]]
    else
      [[(@size + 1)/2, (@size + 1)/2]]
    end
  end
  
  # Makes a copy of the board
  def copy
    position = @grid.clone
    new_board = Board.new(@size, position)
  end
  
  # Updates the grid with "X" or "O" for a given coordinate. Target is 
  # either "X" or "O"
  def update_board!(coord, target)
    if @grid[coord] # Checks to see if the space is free
      puts "This square has already been used at this location!"
      false
    else
      @grid[coord] = target
      true
    end
  end
  
  # Asks for and checks the validity of player's move. Target is either "X"
  # or "O"
  def player_move(target)
    puts "Please input x coordinates: "
    x = player_input_coordinates
    puts "Please input y coordinates: "
    y = player_input_coordinates
    unless update_board!([x.to_i, y.to_i], target) # Checks if it's a valid move. Ask for inputs again if not.
      player_move(target)
    end
  end
  
  # Asks the player to input the x or y coordinates of the square they
  # want. Only positive integers in the board range accepted.
  def player_input_coordinates
    input = gets.chomp
    unless input =~ /^[+]?[0-9]+$/ && (1..@size).include?(input.to_i)
      puts "Incorrect input! Please select an integer between 1 and #{@size}."
      return player_input_coordinates
    end
    return input
  end
  
end


def start_game
  puts "What size game do you want to play? (Please pick a positive integer - 3 will give you the traditional 3x3 game.)"
  size = gets.chomp
  unless size =~ /^[+]?[0-9]+$/ && size.to_i > 0
    puts "That's not a positive integer! Try again."
    start_game
  end
  game_board = Board.new(size.to_i)
  game_board.set_board
  puts "Who would you like to play against? ([P]layer or [C]omputer)"
  choice = player_or_computer[0].downcase
  if choice == "p"
    results = player_v_player(game_board)
  else
    results = player_v_computer(game_board)
  end
  puts "#{results} Thanks for playing!"
end

# Starts a player vs player game.
def player_v_player(game_board)
  players = ["X", "O"]
  player_tracker = 1
  # This is the player that made the last move
  until game_board.full?
    player_tracker = 1 - player_tracker # Flips between players
    puts "It's player #{players[player_tracker]}'s turn."
    game_board.player_move(players[player_tracker])
    game_board.print_board
    if game_board.wins?(players[player_tracker])
      return "Player #{players[player_tracker]} wins!"
    end
  end
  "It's a draw!"
end

# Starts a player vs computer game.
def player_v_computer(game_board)
  computer_target = "O"
  human_target = "X" # By default - human player uses "X" and goes first
  loop do # Loops until a win or a draw occurs
    puts "It's your turn."
    game_board.player_move(human_target) # Player makes move
    game_board.print_board
    if game_board.wins?(human_target) # Checks game results
      return "You win!"
    elsif game_board.full?
      return "It's a draw!"
    end
    # Computer makes move
    computer_move(game_board, computer_target, human_target) 
    game_board.print_board
    if game_board.wins?(computer_target)
      return "Computer wins!"
    elsif game_board.full?
      return "It's a draw!"
    end
  end
end

# Asks whether user wants to play vs other player or computer
def player_or_computer
  choices = ["p", "c", "player", "computer"]
  choice = gets.chomp.downcase
  unless choices.include? choice
    puts "That's not a valid input. Please select either 'p' or 'c'."
    return player_or_computer
  end
  return choice
end

# The computer makes its move
def computer_move(game_board, computer_target, human_target)
  puts "It's the computer's turn."
  best_move = computer_checks_move(game_board, computer_target, human_target)
  game_board.update_board!(best_move, computer_target)
end

# The computer prioritizes moves in the following order: 
# 1. A winning move 
# 2. Blocking an opponent's winning move
# 3. The move that leads to creating a fork 
# 4. The move that blocks opponents from creating a fork
# 5. Center
# 6. Corners
# 7. Anything else
def computer_checks_move(game_board, computer_target, human_target)  
  available_moves = game_board.split_grid(nil) # All possible moves
  if available_moves.length > 1
    
    # Checks for rule 1
    check_move = check_win_move(game_board, computer_target, available_moves) 
    return check_move if check_move
    
    # Checks for rule 2
    check_move = check_win_move(game_board, human_target, available_moves) 
    return check_move if check_move
    
    # Checks for rule 3
    check_move = check_forks(game_board, computer_target, available_moves) 
    return check_move if check_move
    
    # Checks for rule 4
    check_move = check_forks(game_board, human_target, available_moves)
    # Reacts to opponent forks in two ways:
    # First, if there's a way to create a position that the opponent must
    # defend against without creating the fork, do that.
    # Otherwise, block the fork position
    if check_move
      block_fork = block_forks(game_board, computer_target, available_moves - [check_move]) 
      if block_fork
        return block_fork
      else
        return check_move
      end
    end
    
    # Checks rule 5
    unless (game_board.center & available_moves).empty? 
      return (game_board.center & available_moves).sample
    end
    
    # Checks rule 6
    unless (game_board.corners & available_moves).empty? 
      return (game_board.corners & available_moves).sample
    end
    
    return available_moves.sample # Any remaining moves
    
  else
    return available_moves[0]
  end
end

# Checks if next move is winning move for the target player
def check_win_move(game_board, target, available_moves)
  available_moves.each do |move|
    simulated_game_board = game_board.copy
    simulated_game_board.update_board!(move, target)
    if simulated_game_board.wins?(target)
      return move # If there's a winning move, return that move.
    end
  end
  return false
end

# Checks for forks
def check_forks(game_board, target, available_moves)
  available_moves.each do |move|
    simulated_game_board = game_board.copy
    simulated_game_board.update_board!(move, target)
    if (available_moves - [move]).length > 1
      count = 0
      (available_moves - [move]).each do |move|
        new_simulated_game_board = simulated_game_board.copy
        new_simulated_game_board.update_board!(move, target)
        if new_simulated_game_board.wins?(target)
          count += 1 # Count winning moves
        end
      end
      if count >= 2 # If a fork is created (i.e. more than one way to win)
        return move
      end
    end
  end
  return false
end

# Block opponent's forks by creating an almost winning position.
def block_forks(game_board, target, available_moves)
  available_moves.each do |move|
    simulated_game_board = game_board.copy
    simulated_game_board.update_board!(move, target)
    (available_moves - [move]).each do |move|
      new_simulated_game_board = simulated_game_board.copy
      new_simulated_game_board.update_board!(move, target)
      if new_simulated_game_board.wins?(target)
        return move
      end
    end
  end
  return false
end

start_game