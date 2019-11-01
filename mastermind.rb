class ComputerSolver
  attr_accessor :max_guesses, :solution

  def initialize(max_guesses, solution)
    
    @max_guesses = max_guesses
    @solution = solution.to_s.split('').map(&:to_i)
    @untested_pairs = {}
    (0...@solution.size).each { |num| @untested_pairs[num] = (1..6).to_a}
    # untested_pairs[guess1-6] = 0-4 index in guess
    @guesses = []
    @solution.size.times {@guesses.push(0)}
    @confirmed_values = {}
    # confirmed_values[guess1-6] = 0-4 index in guess
    @eval_result = []

    puts "max_guesses: #{@max_guesses} solution: #{@solution} empty guesses: #{@guesses}"
    solution_sequence

  end

  def solution_sequence
    i = 1
    while i <= @max_guesses
      reset_guesses
      insert_confirmed_guesses(@guesses)
      random_guesses(@guesses)
      evaluate_guesses(@guesses)
      puts "Guess ##{i}:"
      puts @guesses.join("")
      puts @eval_result.join("")
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
        while validated == false
          guess = @untested_pairs[index][rand(@untested_pairs[index].size)] unless @untested_pairs[index] == nil
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
      elsif @solution.include?(guess)
        @eval_result.push("*")
      else
        @eval_result.push("-")
        @untested_pairs.delete_if { |k, v| v == guess }
      end
    end
    puts( @untested_pairs.map{ |k,v| "#{k} => #{v}" }.sort )
  end

end

ComputerSolver.new(6, 4362)