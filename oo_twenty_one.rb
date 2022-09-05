require 'pry'

class Participant
  attr_accessor :cards, :name, :stay

  def initialize
    @name = nil
    @cards = []
    @stay = false
  end

  def hit(deck)
    random_card = deck.cards.sample
    deck.cards.delete(random_card)
    cards << random_card
  end

  def busted?
    total > 21
  end

  def total # adds card value to total if the card value is not nil
    total = 0
    @cards.each do |card|
      total += card.value if card.value != nil
    end
    total
  end

  def set_name
    puts "#{self.class} please enter name:"
    answer = nil
    loop do
      answer = gets.chomp.strip
      break if !answer.empty? || !nil
    end
    answer
  end

  def has_aces?
    cards.any? do |card|
      card.name.start_with?("Ace")
    end
  end

  def give_ace_value_during_first_dealing
    if cards.any?{|card| card.name.start_with?("Ace")}
      aces = select_aces
      ace_count = aces.size
    end
    case ace_count
    when 2
      aces[0].value = 11
      aces[1].value = 1
    when 1
      aces[0].value = 11
    end
  end

  def select_aces
    cards.select do |card|
      card.name.start_with?("Ace")
    end
  end

  def see_cards
    hide_message
    cards.each_with_index do |card, idx|
      puts "(#{idx + 1}) #{card}"
    end
  end

  def hide_message
    puts "#{self.name} press 2 when you are the only one looking at the screen to see your cards"
    answer = nil
    loop do
      answer = gets.chomp.strip
      break if ['2'].include?(answer)
      puts "Sorry must enter 2 when coast is clear"
    end
  end

  def done_looking_loop
    puts "#{self.name} press 1 when you are done looking at your cards"
    answer = nil
    loop do
      answer = gets.chomp.strip
      break if ['1'].include?(answer)
      puts "Sorry must enter 1 when done seeing cards"
    end
  end

=begin
  - stay means youre no longer taking from the deck
  - this should return true if you are staying
  - this sh
=end

end

class Player < Participant

end

class Dealer < Participant
  def stay
    if total < 17
      puts "Sorry you must hit"
    else
      @stay = true
    end
  end

  def stayed?
    @stay == true
  end

  def show_cards
    hide_message
    cards.each_with_index do |card, idx|
      puts "(#{idx + 1}) #{card}"
    end
    answer = nil
    loop do
      answer = gets.chomp.strip
      break if ['1', '2'].include?(answer)
      puts "Sorry must enter 1 or 2"
    end
    answer
  end

  def cards_dealer_is_showing(answer)
    case answer
    when '1'
      puts "#{self.name} is showing #{cards[0]}"
    when '2' 
      puts "#{self.name} is showing #{cards[1]}"
    end
  end

  def hide_message
    puts "#{self.name}, what card do you want to show?"
    puts "Press 1 when no one else is looking at the screen"
    answer = nil
    loop do
      answer = gets.chomp.strip
      break if ['1'].include?(answer)
      puts "Sorry must enter 1 when coast is clear"
    end
  end

  def hide_message_for_reshow_cards
    puts "#{self.name} press 2 when you are the only one looking at the screen to see your cards"
    answer = nil
    loop do
      answer = gets.chomp.strip
      break if ['2'].include?(answer)
      puts "Sorry must enter 2 when coast is clear"
    end
  end

  def see_cards
    hide_message_for_reshow_cards
    cards.each_with_index do |card, idx|
      puts "(#{idx + 1}) #{card}"
    end
  end
end

class Deck
  attr_reader :cards

  VALUES = [2, 3, 4, 5, 6, 7, 8, 9, 10, "Jack", "Queen", "King", "Ace"]
  SUITS = ["Hearts", "Diamonds", "Clubs", "Spades"]

  NO_VALUE_CARDS = []

  VALUES.each do |value|
    SUITS.each do |suit|
      NO_VALUE_CARDS << "#{value} of #{suit}"
    end
  end

  def initialize
    # obviously, we need some data structure to keep track of cards
    # array, hash, something else?
    @cards = []
    @available_cards = reset_cards
  end

  def reset_cards
    NO_VALUE_CARDS.each do |card|
      @cards << Card.new(card)
    end
  end

  def deal
    random_cards = @cards.sample(2)
    random_cards.each do |random_card|
      @cards.each_with_index do |deck_card, deck_card_idx|
        if random_card == deck_card
          @cards[deck_card_idx] = ""
        end
      end
    end
    @cards.delete("")
    random_cards
  end

end

class Card
  attr_reader :name
  attr_accessor :value

  def initialize(name)
    # what are the "states" of a card?
    values_for_non_ace_cards(name)
    @name = name
  end

  def values_for_non_ace_cards(name)
    number_or_letter = name.split[0]
    if Deck::VALUES[0..8].include?(number_or_letter.to_i)
      @value = number_or_letter.to_i
    elsif Deck::VALUES[9..11].include?(number_or_letter.strip)
      @value = 10
    else
      @value = 1
    end
  end

  def to_s
    @name
  end
end

class Game
  attr_accessor :deck, :player, :dealer

  FIRST_TO_MOVE = @player

  def initialize
    clear
    welcome_message
    @deck = Deck.new
    @player = Player.new
    @player.name = @player.set_name
    @dealer = Dealer.new
    @dealer.name = @dealer.set_name
    @current_marker = FIRST_TO_MOVE
  end

  def start
    clear
    deal_cards
    clear
    show_initial_cards_for_player_and_dealer
    loop do
      player_turn
      if player.busted?
        show_result
        break
      elsif player.stay
        loop do
          dealer_turn
          if dealer.busted? || dealer.stayed?
            show_result
            break
          end
        end
        break
      end
    end
    display_goodbye_message
  end


  def deal_cards
    player.cards = deck.deal
    dealer.cards = deck.deal
    set_ace_values
  end

  def set_ace_values
    player.give_ace_value_during_first_dealing
    dealer.give_ace_value_during_first_dealing
  end

  def player_turn
    answer = asking_for_hit_or_stay(player)
    player_hit_or_stay_case(answer)
  end

  def dealer_turn
    answer = asking_for_hit_or_stay(dealer)
    dealer_hit_or_stay_case(answer)
  end

  def asking_for_hit_or_stay(participant)
    puts "#{participant.name}, do you want to \n(1) HIT!\n(2) STAY!\n(3) See cards"
    puts ""
    puts "Please enter 1, 2 or 3"
    answer = nil
    loop do
      answer = gets.chomp.strip
      break if ['1', '2', '3'].include?(answer)
      puts "Sorry please enter 1, 2 or 3"
    end
    answer
  end

  def player_hit_or_stay_case(answer)
    case answer
    when '1'
      player.hit(deck)
    when '2'
      player.stay = true
    when '3'
      show_player_cards
    end
  end

  def dealer_hit_or_stay_case(answer)
    case answer
    when '1'
      dealer.hit(deck)
    when '2'
      dealer.stay
    when '3'
      show_dealer_cards
    end
  end

  def show_result
    player_total = player.total
    dealer_total = dealer.total
    if player_total > dealer_total && player_total < 21 || dealer.busted?
      clear
      puts "#{player.name} total is #{player.total}\n#{dealer.name} total is #{dealer.total}"
      puts "#{player.name} won!"
    elsif dealer_total > player_total && dealer_total < 21 || player.busted?
      clear
      puts "#{dealer.name} total is #{dealer.total}\n#{player.name} total is #{player.total}"
      puts "#{dealer.name} won!"
    else
      puts "#{dealer.name} total is #{dealer.total}\n#{player.name} total is #{player.total}"
      puts "It's a tie!"
    end
  end

  def show_initial_cards_for_player_and_dealer
    player.see_cards
    player.done_looking_loop
    clear
    dealer_main_card = dealer.show_cards
    clear
    dealer.cards_dealer_is_showing(dealer_main_card)
  end

  def show_player_cards
    clear
    player.see_cards
    player.done_looking_loop
    clear
  end

  def show_dealer_cards
    clear
    dealer.see_cards
    dealer.done_looking_loop
    clear
  end

  def clear
    system "clear"
  end

  def welcome_message
    puts "2----------Welcome to Twenty-One!----------1"
    puts ""
  end

  def end_game
    player.busted? || dealer.busted?
  end

  def display_goodbye_message
    puts ""
    puts "Thanks for playing TWENTY-ONE!"
    puts "Goodbye!"
  end
end

Game.new.start

=begin
  - play again loop
=end
