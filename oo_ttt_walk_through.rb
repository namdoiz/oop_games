require 'pry'

class Board
  attr_accessor :human_marker

  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] + # rows
                  [[1, 4, 7], [2, 5, 8], [3, 6, 9]] + # cols
                  [[1, 5, 9], [3, 5, 7]]              # diagonals

  def initialize
    @squares = {}
    reset_board_and_current_marker
    @human_marker = nil
  end

  def []=(key, marker)
    @squares[key].marker = marker
  end

  def unmarked_keys
    @squares.select { |key, _| @squares[key].unmarked? }.keys
  end

  def full?
    unmarked_keys.empty?
  end

  def someone_won?
    !!winning_marker
  end

  def all_squares_same_marker?(squares)
    squares.map(&:marker).all? { |let| let == squares[0].marker }
  end

  # returns winning marker or nil
  def winning_marker
    WINNING_LINES.each do |line|
      if count_marker(@squares.values_at(*line)) == 3
        return @squares[line[0]].marker
      end
    end
    nil
  end

  def human_in_two_out_of_three_squares?(line)
    marker_at_lines(@squares.values_at(*line), human_marker) == 2 &&
      marker_at_lines(@squares.values_at(*line), Square::INITIAL_MARKER) == 1
  end

  def computer_in_two_out_of_three_squares?(line)
    marker_at_lines(@squares.values_at(*line), TTTGame::COMPUTER_MARKER) == 2 &&
      marker_at_lines(@squares.values_at(*line), Square::INITIAL_MARKER) == 1
  end

  def marker_at_lines(line_values, marker)
    line_values.map(&:marker).count(marker)
  end

  def human_about_to_win?
    WINNING_LINES.each do |line|
      if human_in_two_out_of_three_squares?(line)
        return true
      end
    end
    nil
  end

  def computer_about_to_win?
    WINNING_LINES.each do |line|
      if computer_in_two_out_of_three_squares?(line)
        return true
      end
    end
    nil
  end

  def last_square_for_human_winning
    WINNING_LINES.each do |line|
      if human_in_two_out_of_three_squares?(line)
        return @squares.key(winning_line(line)[0])
      end
    end
  end

  def last_square_for_computer_winning
    WINNING_LINES.each do |line|
      if computer_in_two_out_of_three_squares?(line)
        return @squares.key(winning_line(line)[0])
      end
    end
  end

  def five_empty?
    @squares[5].marker == Square::INITIAL_MARKER
  end

  def winning_line(line)
    @squares.values_at(*line).select { |square| square.marker == " " }
  end

  def reset_board_and_current_marker
    (1..9).each do |k, _|
      @squares[k] = Square.new
    end
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength

  def draw
    puts ""
    puts "     |     |"
    puts "  #{@squares[1]}  |  #{@squares[2]}  |  #{@squares[3]}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{@squares[4]}  |  #{@squares[5]}  |  #{@squares[6]}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{@squares[7]}  |  #{@squares[8]}  |  #{@squares[9]}"
    puts "     |     |"
    puts ""
  end

  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  private

  # returns count of markers that are not empty space
  def count_marker(squares) # argument is array of square objects
    return unless all_squares_same_marker?(squares)
    squares.map(&:marker).count { |let| let =~ /[^\s]+/ }
  end
end

class Square
  INITIAL_MARKER = ' '

  attr_accessor :marker

  def initialize(marker = INITIAL_MARKER)
    @marker = marker
  end

  def to_s
    @marker
  end

  def unmarked?
    marker == INITIAL_MARKER
  end
end

class Player
  attr_reader :marker
  attr_accessor :score, :name

  def initialize(marker)
    @marker = marker
    @score = 0
    @name = nil
  end

  def set_human_name
    puts "Enter your name"
    answer = nil
    loop do
      answer = gets.chomp.strip
      break if !answer.empty?
      puts "Sorry must input name"
    end
    @name = answer
  end
end

class TTTGame
  attr_reader :board, :human, :computer
  attr_accessor :human_marker

  COMPUTER_MARKER = 'O'
  FIRST_TO_MOVE = @human_marker

  def play
    clear
    display_welcome_message
    ask_mode
    display_goodbye_message
  end

  def self.current_human_marker
    @human
  end

  private

  def initialize
    @board = Board.new
    @human_marker = choose_marker
    @board.human_marker = @human_marker
    @human = Player.new(@human_marker)
    @computer = Player.new(COMPUTER_MARKER)
    @current_marker = FIRST_TO_MOVE
    @human.name = human.set_human_name
    @computer.name = "TGBTG"
  end

  def ask_mode
    game_mode_aesthetics
    answer = nil
    loop do
      prompt_for_user_mode_choice
      answer = gets.chomp.strip
      break if ['1', '2'].include?(answer)
      puts "Sorry must be 1 or 2"
    end
    mode_path(answer)
  end

  def prompt_for_user_mode_choice
    puts "Enter game mode:"
    puts ""
    puts "(1) One game\n(2) First to 5"
  end

  def game_mode_aesthetics
    puts "**** GAME MODE ****"
    puts ""
  end

  # directs game play mode flow
  def mode_path(answer)
    case answer
    when '1'
      one_game_mode
    else
      first_to_five_mode
    end
  end

  def display_welcome_message
    puts "Welcome to Tic Tac Toe!"
    puts ""
  end

  def display_goodbye_message
    puts "Thanks for playing Tic Tac Toe! Goodbye!"
  end

  def display_board_for_one_game
    clear
    display_name_and_marker
    board.draw
    puts ""
  end

  def display_name_and_marker
    puts "#{human.name} is #{human.marker}"
    puts "#{computer.name} is #{computer.marker}"
    puts ""
  end

  def human_moves
    puts "Choose a square (#{joinor(board.unmarked_keys)})"
    square = nil
    loop do
      square = gets.chomp.to_i
      break if (board.unmarked_keys).include?(square)
      puts "Sorry, that's not a valid choice."
    end
    board[square] = human.marker
  end

  def joinor(arr, sep = ',', last = "or")
    array_size =  arr.size
    if array_size == 1
      arr[0]
    elsif array_size == 2
      arr.join(" " + last + " ")
    elsif array_size > 2
      last_element = arr.pop
      arr.join("#{sep} ") + " " + last + " " + last_element.to_s
    end
  end

  # Options the computer takes depending on the board state
  def computer_moves
    if board.computer_about_to_win?
      computer_attack
    elsif board.human_about_to_win?
      computer_defends
    elsif board.five_empty?
      computer_takes_5
    else
      board[board.unmarked_keys.sample] = computer.marker
    end
  end

  def computer_defends
    board[board.last_square_for_human_winning] = computer.marker
  end

  def computer_attack
    board[board.last_square_for_computer_winning] = computer.marker
  end

  def computer_takes_5
    board[5] = computer.marker
  end

  def display_result_for_one_game
    clear_screen_and_display_board_for_one_game
    case board.winning_marker
    when human.marker
      puts "#{human.name} won!"
    when computer.marker
      puts "#{computer.name} Won"
    else
      puts "It's a tie!"
    end
  end

  def display_result_for_first_to_5
    clear_screen_and_display_board_for_first_to_5
    case board.winning_marker
    when human.marker
      after_human_wins
    when computer.marker
      after_computer_wins
    else
      puts "It's a tie!"
    end
  end

  def after_human_wins
    human.score += 1
    clear_screen_and_display_board_for_first_to_5
    puts "#{human.name} won!"
  end

  def after_computer_wins
    computer.score += 1
    clear_screen_and_display_board_for_first_to_5
    puts "#{computer.name} Won"
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp.downcase
      break if %w(y n).include? answer
      puts "Sorry, must be y or n"
    end

    answer == 'y'
  end

  def clear
    system "clear"
  end

  def clear_screen_and_display_board_for_one_game
    clear
    display_board_for_one_game
  end

  def clear_screen_and_display_board_for_first_to_5
    clear
    display_board_for_first_to_5
  end

  def reset_board_and_current_marker
    board.reset_board_and_current_marker
    @current_marker = FIRST_TO_MOVE
    clear
  end

  def display_play_again_message
    puts "Let's play again!"
    puts ""
    puts "Your score: #{human.score}\nComputer score: #{computer.score}"
    puts ""
  end

  def current_player_moves
    if human_turn?
      human_moves
      @current_marker = COMPUTER_MARKER
    else
      computer_moves
      @current_marker = human_marker
    end
  end

  def human_turn?
    @current_marker == human_marker
  end

  def player_move_for_one_game
    loop do
      current_player_moves
      break if board.someone_won? || board.full?
      clear_screen_and_display_board_for_one_game if human_turn?
    end
  end

  def player_move_for_first_to_5
    loop do
      current_player_moves
      break if board.someone_won? || board.full?
      clear_screen_and_display_board_for_first_to_5 if human_turn?
    end
  end

  def one_game_mode
    loop do
      ask_who_chooses_who_goes_first
      display_board_for_one_game
      player_move_for_one_game
      display_result_for_one_game
      break unless play_again?
      reset_board_and_current_marker
    end
  end

  def first_to_five_mode
    loop do
      loop do
        first_to_five_main_loop
        break if human.score == 5 || computer.score == 5
        reset_board_and_current_marker
        display_play_again_message
      end
      break unless play_again?
      reset_score_board_and_current_marker
    end
  end

  def reset_score_board_and_current_marker
    human.score = 0
    computer.score = 0
    reset_board_and_current_marker
  end

  def first_to_five_main_loop
    ask_who_chooses_who_goes_first
    display_board_for_first_to_5
    player_move_for_first_to_5
    display_result_for_first_to_5
  end

  def ask_who_chooses_who_goes_first
    puts ""
    puts "Do you want to choose who goes first or you want computer to choose"
    puts ""
    puts "(1) I'll choose\n(2) Let computer choose"
    puts ""
    who_chooses = answer_loop_for_who_goes_first
    who_goes_first(who_chooses)
  end

  # Deciding who goes first
  def who_goes_first(answer)
    clear
    who_goes_first_main_case(answer)
  end

  def who_goes_first_main_case(answer)
    case answer
    when "1"
      puts "Do you want to go first or you want computer to go first"
      puts ""
      puts "(1) I'll go first\n(2) Let computer go first"
      human_decides = answer_loop_for_who_goes_first
      human_decides_who_goes_first(human_decides)
    when "2"
      @current_marker = [human_marker, COMPUTER_MARKER].sample
    end
  end

  def human_decides_who_goes_first(answer)
    case answer
    when "1"
      @current_marker = human_marker
    when "2"
      @current_marker = COMPUTER_MARKER
    end
  end

  def answer_loop_for_who_goes_first
    answer = nil
    loop do
      answer = gets.chomp.strip
      break if ["1", "2"].include?(answer)
      puts "Sorry must be 1 or 2"
    end
    answer
  end

  def display_board_for_first_to_5
    clear
    display_name_and_marker
    puts "Your score: #{human.score}\nComputer score: #{computer.score}"
    puts ""
    board.draw
    puts ""
  end

  def choose_marker
    puts "Choose your marker. Marker must be a single letter or digit"
    answer = nil
    loop do
      answer = gets.chomp.strip
      break if answer.size == 1 && /[a-zA-Z0-9]/.match?(answer)
      puts "Sorry marker must be a single letter or digit"
    end
    answer
  end
end
game = TTTGame.new
game.play
