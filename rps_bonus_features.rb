module MoveInstanceVariables
  def rock?
    @value == 'rock'
  end

  def paper?
    @value == 'paper'
  end

  def scissors?
    @value == 'scissors'
  end

  def lizard?
    @value == 'lizard'
  end

  def spock?
    @value == 'spock'
  end
end

class Scissors
  include MoveInstanceVariables
  attr_reader :value

  def initialize
    @value = 'scissors'
  end

  def >(other_move)
    return true if scissors? && (other_move.paper? || other_move.lizard?)
    false
  end

  def <(other_move)
    if scissors? && (other_move.rock? || other_move.spock?)
      return true
    end
    false
  end

  def to_s
    @value
  end
end

class Rock
  include MoveInstanceVariables
  attr_reader :value

  def initialize
    @value = 'rock'
  end

  def >(other_move)
    if rock? && (other_move.scissors? || other_move.lizard?)
      return true
    end
    false
  end

  def <(other_move)
    if rock? && (other_move.paper? || other_move.spock?)
      return true
    end
    false
  end

  def to_s
    'rock'
  end
end

class Paper
  include MoveInstanceVariables
  attr_reader :value

  def initialize
    @value = 'paper'
  end

  def >(other_move)
    if paper? && (other_move.rock? || other_move.spock?)
      return true
    end
    false
  end

  def <(other_move)
    if paper? && (other_move.scissors? || other_move.lizard?)
      return true
    end
    false
  end

  def to_s
    'paper'
  end
end

class Lizard
  include MoveInstanceVariables
  attr_reader :value

  def initialize
    @value = 'lizard'
  end

  def >(other_move)
    if lizard? && (other_move.spock? || other_move.paper?)
      return true
    end
    false
  end

  def <(other_move)
    if lizard? && (other_move.rock? || other_move.scissors?)
      return true
    end
    false
  end

  def to_s
    'lizard'
  end
end

class Spock
  include MoveInstanceVariables
  attr_reader :value

  def initialize
    @value = 'spock'
  end

  def >(other_move)
    if spock? && (other_move.scissors? || other_move.rock?)
      return true
    end
    false
  end

  def <(other_move)
    if spock? && (other_move.lizard? || other_move.paper?)
      return true
    end
    false
  end

  def to_s
    'spock'
  end
end

VALUES = ['rock', 'paper', 'scissors', 'lizard', 'spock']

# A mixin module for the human and computer class that initializes new objects
# based on what move the user or computer makes.
# depending on the choice, the move method the human and computer classes
# inherit from the Player class is set to the value the choice
# (which is the key)is set to

module WhatMoveClass
  MOVES_HASH = {
    'scissors' => Scissors.new,
    'lizard' => Lizard.new,
    'paper' => Paper.new,
    'rock' => Rock.new,
    'spock' => Spock.new
  }

  def move_class?(move)
    MOVES_HASH[move]
  end
end

class Player
  include Comparable
  attr_accessor :move, :name, :score
  attr_reader :previous_moves

  def initialize
    set_name
    @score = 0
    @previous_moves = []
  end

  def <=>(other)
    score <=> other.score
  end
end

class Human < Player
  include WhatMoveClass
  def set_name
    n = ''
    loop do
      puts "Enter name!"
      n = gets.chomp
      break unless n.empty?
      puts "Sorry, must enter a value."
    end
    self.name = n
  end

  def choose
    choice = nil
    loop do
      puts "Please choose rock, paper, scissors, lizard or spock:"
      choice = gets.chomp
      break if VALUES.include?(choice)
      puts "Sorry, invalid choice."
    end
    previous_moves << choice
    self.move = move_class?(choice)
  end
end

class Computer < Player
  include WhatMoveClass
  def set_name
    self.name = ['R2D2', 'Hal', 'Chappie', 'Sonny', 'Number 5'].sample
  end

  def choose
    choice = VALUES.sample
    previous_moves << choice
    self.move = move_class?(choice)
  end
end

# Game Orchestration Engine

class RPSgame
  GAME_MODES = { 1 => "One at a time", 2 => "First to 5", 3 => "First to 10" }
  attr_accessor :human, :computer, :game_mode, :user_mode_answer

  # Creation of human and computer objects
  def initialize
    system "clear"
    @human = Human.new
    @computer = Computer.new
    @game_mode = nil
  end

  def display_welcome_message
    puts "Welcome to Rock, Paper, Scissors, Lizard - Spock!"
  end

  def display_goodbye_message
    puts "Thanks for playing Rock, Paper, Sissors, Lizard - Spock. Good bye!"
  end

  def display_moves
    puts "#{human.name} chose #{human.move}"
    puts "#{computer.name} chose #{computer.move}"
    puts ""
  end

  def display_winner
    if human.move > computer.move
      puts "#{human.name} won!"
    elsif human.move < computer.move
      puts "#{computer.name} won!"
    else
      puts "It's a tie!"
    end
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp
      break if ['y', 'n'].include?(answer.downcase)
      puts "Sorry, must be y or n."
    end

    return false if answer.downcase == 'n'
    return true if answer.downcase == 'y'
  end

  # Asks user what mode they want to play

  def ask_mode
    answer = nil
    loop do
      puts "Game Mode:\n(1) One at a time\n(2) First to 5\n(3) First to 10"
      answer = gets.chomp.to_i
      break if [1, 2, 3].include?(answer)
      system "clear"
      puts "Sorry, must be 1, 2 or 3."
    end
    self.user_mode_answer = answer
    self.game_mode = GAME_MODES[user_mode_answer]
  end

  # Runs the mode the user wants to play depending on
  # the answer from the ask_mode method

  def choose_mode
    puts "Playing #{game_mode}"
    if user_mode_answer == 1
      one_at_a_time_mode
    elsif user_mode_answer == 2
      first_to_5_mode
      display_final_score_for_5_and_10
    else
      first_to_10_mode
      display_final_score_for_5_and_10
    end
  end

  # The one at a time game mode

  def one_at_a_time_mode
    loop do
      human.choose
      computer.choose
      system "clear"
      display_moves
      display_winner
      break unless play_again?
    end
  end

  # The first to 5 game mode

  def first_to_5_mode
    loop do
      human.choose
      computer.choose
      system "clear"
      puts "First to 5 points!"
      puts ""
      displaying_moves_winner_and_score_for_modes_10_and_5
      break if human.score == 5 || computer.score == 5
    end
  end

  # The first to 10 game mode

  def first_to_10_mode
    loop do
      human.choose
      computer.choose
      system "clear"
      puts "First to 10 points!"
      puts ""
      displaying_moves_winner_and_score_for_modes_10_and_5
      break if human.score == 10 || computer.score == 10
    end
  end

  def displaying_moves_winner_and_score_for_modes_10_and_5
    display_moves
    display_winner_for_5_and_10_modes
    display_score
  end

  def display_winner_for_5_and_10_modes
    if human.move > computer.move
      human_won_round
    elsif human.move < computer.move
      computer_won_round
    else
      round_draw
    end
  end

  def human_won_round
    puts "#{human.name} won this time"
    puts ""
    human.score += 1
  end

  def computer_won_round
    puts "#{computer.name} won this time"
    puts ""
    computer.score += 1
  end

  def round_draw
    puts "It's a tie!"
    puts ""
    human.score += 1
    computer.score += 1
  end

  def display_score
    puts "SCORES:"
    puts "#{human.name}: #{human.score}\n#{computer.name}: #{computer.score}"
    puts ""
  end

  def display_final_score_for_5_and_10
    if human.score > computer.score
      puts "#{human.name} won!"
    elsif human.score < computer.score
      puts "#{computer.name} won!"
    end
  end

  def play
    display_welcome_message
    ask_mode
    choose_mode
    display_goodbye_message
  end
end

# Main game initialization
RPSgame.new.play
