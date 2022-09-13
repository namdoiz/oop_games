=begin
In the previous exercise, you wrote a number guessing game that determines 
a secret number between 1 and 100, and gives the user 7 opportunities to guess 
the number.

Update your solution to accept a low and high value when you create a 
GuessingGame object, and use those values to compute a secret number for the game. 
You should also change the number of guesses allowed so the user can always win if 
she uses a good strategy. You can compute the number of guesses with:

Math.log2(size_of_range).to_i + 1
=end

class GuessingGame
  attr_accessor :guesses_remaining, :guessed_right
  attr_reader :number

  def initialize(low_value, high_value)
    @number = (low_value..high_value).to_a.sample
    @guesses_remaining = Math.log2((low_value..high_value).to_a.size).to_i + 1
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

game = GuessingGame.new(501, 1500)

game.play

=begin
Examples:

game = GuessingGame.new(501, 1500)
game.play

You have 10 guesses remaining.
Enter a number between 501 and 1500: 104
Invalid guess. Enter a number between 501 and 1500: 1000
Your guess is too low.

You have 9 guesses remaining.
Enter a number between 501 and 1500: 1250
Your guess is too low.

You have 8 guesses remaining.
Enter a number between 501 and 1500: 1375
Your guess is too high.

You have 7 guesses remaining.
Enter a number between 501 and 1500: 80
Invalid guess. Enter a number between 501 and 1500: 1312
Your guess is too low.

You have 6 guesses remaining.
Enter a number between 501 and 1500: 1343
Your guess is too low.

You have 5 guesses remaining.
Enter a number between 501 and 1500: 1359
Your guess is too high.

You have 4 guesses remaining.
Enter a number between 501 and 1500: 1351
Your guess is too high.

You have 3 guesses remaining.
Enter a number between 501 and 1500: 1355
That's the number!

You won!

game.play
You have 10 guesses remaining.
Enter a number between 501 and 1500: 1000
Your guess is too high.

You have 9 guesses remaining.
Enter a number between 501 and 1500: 750
Your guess is too low.

You have 8 guesses remaining.
Enter a number between 501 and 1500: 875
Your guess is too high.

You have 7 guesses remaining.
Enter a number between 501 and 1500: 812
Your guess is too low.

You have 6 guesses remaining.
Enter a number between 501 and 1500: 843
Your guess is too high.

You have 5 guesses remaining.
Enter a number between 501 and 1500: 820
Your guess is too low.

You have 4 guesses remaining.
Enter a number between 501 and 1500: 830
Your guess is too low.

You have 3 guesses remaining.
Enter a number between 501 and 1500: 835
Your guess is too low.

You have 2 guesses remaining.
Enter a number between 501 and 1500: 836
Your guess is too low.

You have 1 guesses remaining.
Enter a number between 501 and 1500: 837
Your guess is too low.

You have no more guesses. You lost!
=end
