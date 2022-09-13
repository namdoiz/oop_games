class GuessingGame
  attr_accessor :guesses_remaining, :guessed_right
  attr_reader :number

  def initialize
    @number = (1..100).to_a.sample
    @guesses_remaining = 7
    @guessed_right = false
  end

  def play
    clear
    welcome_message
    loop do
      display_guesses_left
      ask_to_guess
      break if guessed_right || guesses_remaining == 0
    end
    if guesses_remaining == 0
      puts "You have no more guesses. You lost :("
      puts "The random number was #{number}"
    end
    good_bye_message
  end

  def display_guesses_left
    if guesses_remaining > 1 && guesses_remaining != 0
      puts "You have #{guesses_remaining} guesses remaining"
    else
      puts "You have #{guesses_remaining} guess remaining"
    end
  end

  def ask_to_guess
    puts "Guess the random number from 1 to 100!:"
    answer = nil
    loop do
      answer = gets.chomp.strip
      break unless /[a-zA-Z]/.match?(answer)
      puts "Sorry must enter a number from 1 to 100"
    end
    answer_logic(answer.to_i)
  end

  def answer_logic(answer)
    clear
    if answer == number
      puts "That's the number!"
      puts ""
      puts "You Won!"
      @guessed_right = true
    elsif answer > number && answer <= 100
      puts "Your guess is too high."
      self.guesses_remaining -= 1
    elsif answer < number && answer >= 1
      puts "Your guess is too low."
      self.guesses_remaining -= 1
    elsif answer < 1
      puts "Invalid guess. Enter a number between 1 and 100"
      self.guesses_remaining -= 1
    elsif answer > 100
      puts "Invalid guess. Enter a number between 1 and 100"
      self.guesses_remaining -= 1
    end
  end

  def clear
    system "clear"
  end

  def welcome_message
    puts "Welcome to Guess the Random Number!"
    puts ""
  end

  def good_bye_message
    puts "Thanks for playing Guess the Random Number"
    puts ""
    puts "Goodbye!"
  end
end

game = GuessingGame.new

game.play

=begin
Create an object-oriented number guessing class for numbers in the range 1 to 100, with a limit of 7 guesses per game. 
The game should play like this:

game = GuessingGame.new
game.play

You have 7 guesses remaining.
Enter a number between 1 and 100: 104
Invalid guess. Enter a number between 1 and 100: 50
Your guess is too low.

You have 6 guesses remaining.
Enter a number between 1 and 100: 75
Your guess is too low.

You have 5 guesses remaining.
Enter a number between 1 and 100: 85
Your guess is too high.

You have 4 guesses remaining.
Enter a number between 1 and 100: 0
Invalid guess. Enter a number between 1 and 100: 80

You have 3 guesses remaining.
Enter a number between 1 and 100: 81
That's the number!

You won!

game.play

You have 7 guesses remaining.
Enter a number between 1 and 100: 50
Your guess is too high.

You have 6 guesses remaining.
Enter a number between 1 and 100: 25
Your guess is too low.

You have 5 guesses remaining.
Enter a number between 1 and 100: 37
Your guess is too high.

You have 4 guesses remaining.
Enter a number between 1 and 100: 31
Your guess is too low.

You have 3 guesses remaining.
Enter a number between 1 and 100: 34
Your guess is too high.

You have 2 guesses remaining.
Enter a number between 1 and 100: 32
Your guess is too low.

You have 1 guesses remaining.
Enter a number between 1 and 100: 32
Your guess is too low.

You have no more guesses. You lost!
=end
