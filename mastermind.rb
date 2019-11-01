class String
  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end

  def red
    colorize(31)
  end

  def green
    colorize(32)
  end

  def yellow
    colorize(33)
  end

  def blue
    colorize(34)
  end

  def pink
    colorize(35)
  end

  def light_blue
    colorize(36)
  end
end


class Intro
  def initialize
    start_game  
  end

  def get_name
    puts `clear`
    puts "\nWelcome to Mastermind.  What's your name?"
    @name = gets.chomp
    if (@name.length < 1) or (@name.length > 20)
      puts "\nName must be between one and twenty characters.  Try again."
      get_name
    end
  end

  def get_role
    puts "\nHello, #{@name}."
    puts "Will the human (#{@name}) be guessing the code, or will the computer be guessing the code?"
    puts "  1 = Computer"
    puts "  2 = Human"
    @role = gets.chomp.to_i
    if @role == 1
      puts "\nOK, #{@name}, you have been designated a code maker."
    elsif @role == 2
      puts "\nOK, #{@name}, you have been designated a code cracker."
    else
      puts "\nYou may only enter a single digit: 1 or 2.  Try again, #{@name}."
      get_role
    end
  end

  def get_sol_length
    puts "\nHow many characters is the code you would like to work with?  Enter 4, 5, or 6:"
    @sol_length = gets.chomp.to_i
    if @sol_length.class == Integer && (4..6) === @sol_length
      puts "\nAccepted.  The code solution will be #{@sol_length} characters long."
    else
      puts "\nYou may only enter a single digit: 4, 5 or 6.  Try again, #{@name}."
      get_sol_length 
    end
  end

  def get_max_guesses
    puts "\nHow many guesses will be permitted in one game?  Enter a value between 4 and 12."
    @max_guesses = gets.chomp.to_i
    if @max_guesses.class == Integer && (4..12) === @max_guesses 
      puts "\nAccepted.  The maximum number of guesses will be #{@max_guesses}."
    else
      puts "\nYou may only enter a whole number between 4 and 12.  Try again, #{@name}."
      get_max_guesses
    end
  end

  def get_solution
    puts "\nSelect a solution using digits unique digits from 1 through 6.  Your solution must be 4 to 6 digits long."
    @solution = gets.chomp.to_i
    if @solution.class == Integer && @solution.digits.size == (4 || 5 || 6) && @solution.digits.each { |c| c == (1 || 2 || 3 || 4 || 5 || 6)}
      puts "\nAccepted.  The solution will be #{@solution}."
    else
      puts "\nYou may only enter a number, 4 to 6 digits long, and consisting only of non-repeating numbers 1 through 6.  Try again, #{@name}."
      get_solution
    end
  end

  def replay_prc(&block)
    replay = true
    while replay == true
      puts "Play again?"
      play_again = gets.chomp
      # replay = false
      play_again.upcase == "Y" || "YES" ? replay = true : replay = false
    end
  end

  def start_game
    get_name
    get_role
    get_max_guesses
    if @role == 1
      get_solution
      ComputerSolver.new(@solution, @max_guesses, @name)
    elsif @role == 2
      get_sol_length
      HumanSolver.new(@sol_length, @max_guesses, @name)
    end
  end
end


class HumanSolver
  attr_writer :sol_length, :max_guesses, :name

  def initialize(sol_length, max_guesses, name)
    @sol_length = sol_length
    @max_guesses = max_guesses
    @name = name

    generate_code
    get_guesses_intro
    get_guesses
  end

  def generate_code
    @solution = []
    while @solution.size < @sol_length
      rnum = rand(5) + 1
      if @solution.include?(rnum)
      else
        @solution.push(rnum)
      end
    end
  end

  def get_guesses_intro
    puts %Q(

      Mastermind codes are composed of a sequence of the 
      following numbers:

      #{"1, 2, 3, 4, 5, 6".red}

      In this version of Mastermind, each digit in the
      solution is unique.  In other words, the solution
      will not include the same digit value more than once.

      The solution contains #{@sol_length} digits.
      )
  end

  def compare
    @comp_result = Array.new
    @guess.each_with_index do |c, index|
      if c == @solution[index]
        @comp_result.push("•".green)
      elsif @solution.include?c
        @comp_result.push("•")
      else
        @comp_result.push("•".red)
      end
    end
    puts @comp_result.join("")
    puts @guess.join("")
    if @guess == @solution
      puts "You won!"
      @game_over = true
    end
  end

    
    def get_guesses
      i = 0
      @game_over = false
      while i < @max_guesses && @game_over == false
        valid_input = false
        while valid_input == false
          puts "Enter a guess containing #{@sol_length} digits.  You have #{@max_guesses - i} attempt(s) remaining."
          @guess = gets.chomp.split("").map! { |num| num.to_i }
          if @guess.uniq.size == @sol_length && (([1, 2, 3, 4, 5, 6] - @guess).size == (6 - @sol_length))
            valid_input = true
          else puts "Invalid guess -- try again."
          end
        end
        compare
        i += 1
      end
      replay_question
    end
  
    def replay_question
      puts %Q(
        Would you like to play another round, #{@name}?
        1 = Yes
        2 = No
        )
      answer = gets.chomp.to_i
      if answer == 1
        Intro.new
      elsif answer == 2
        puts "Good game, #{@name}.  See you again soon!"
      end
    end
  

end

class ComputerSolver
  attr_accessor :max_guesses
  attr_writer :solution, :name

  def initialize(solution, max_guesses, name)
    
    @solution = solution.to_s.split('').map(&:to_i)
    @max_guesses = max_guesses
    @name = name
    @untested_pairs = {}
    (0...@solution.size).each { |num| @untested_pairs[num] = (1..6).to_a}

    @guesses = []
    @solution.size.times {@guesses.push(0)}
    @confirmed_values = {}

    @eval_result = []
    @game_active = true

    solution_sequence

  end

  def solution_sequence
    i = 1
    while i <= @max_guesses && @game_active == true
      reset_guesses
      insert_confirmed_guesses(@guesses)
      random_guesses(@guesses)
      evaluate_guesses(@guesses)
      puts "======================================"
      puts ""
      puts "Guess ##{i}:"
      sleep(1)
      puts @guesses.join("")
      puts @eval_result.join("")
      win_or_lose(i)
      puts ""
      i += 1
    end
  end

  def reset_guesses
    @guesses = []
    @solution.size.times {@guesses.push(0)}
  end

  def insert_confirmed_guesses(guesses)
    if @confirmed_values == {}
    else 
      @confirmed_values.each do |key, value|
      @guesses[value] = key
      end 
    end
  end

  def random_guesses(guesses)
    @guesses = guesses
    @guesses.each_with_index do |num, index|
      if num == 0
        validated = false
        i = 0
        while validated == false
          guess = @untested_pairs[index][rand(@untested_pairs[index].size)] unless @untested_pairs[index] == nil
          if i > 5
            break
          end
          i += 1
          if @guesses.include?(guess)
            next
          else
            @guesses[index] = guess
            @untested_pairs[index].delete(guess) unless @untested_pairs[index] == nil
            validated = true
          end
        end
      end
    end
  end

  def evaluate_guesses(guesses)
    @guesses = guesses
    @eval_result = []
    @guesses.each_with_index do |guess, index|
      if guess == @solution[index]
        @eval_result.push("+")
        @confirmed_values[guess] = index
        @untested_pairs.delete(index)
        @untested_pairs.each { |k, v| v.delete(guess) }
      elsif @solution.include?(guess)
        @eval_result.push("*")
      else
        @eval_result.push("-")
        @untested_pairs.each { |k, v| v.delete(guess) }
      end
    end
  end

  def win_or_lose(i)
    if @eval_result.join("") == "+" * @solution.size
      puts "Computer won in #{i} attempts!"
      @game_active = false
    end
  end

end

Intro.new