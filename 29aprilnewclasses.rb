# classes.rb

# class Scope
#   @@variables = {}

#   def self.set_variable(variable_name, value)
#     @@variables[variable_name] = value
#   end

#   def self.find_variable(variable_name)
#     @value = @@variables[variable_name]
#     if @value.nil?
#       abort("Variable '#{variable_name}' not found")
#     else
#       return @value
#     end
#   end
# end



class Output
  attr_accessor :value
  
  def initialize(value)
    @value = value
  end

  def eval
    puts @value.eval
  end
end


class Input
  attr_accessor :value

  def initialize(value)
    @value = value
  end

  def eval
    input = gets.chomp
    Scope.set_variable(@value, input)
  end
end

class Assignment
  attr_accessor :variable, :value

  def initialize(variable, value)
    @variable = variable
    @value = value
  end

  def eval
    Scope.set_variable(@variable, @value.eval)
  end
end

class WhileLoop
  attr_accessor :expr, :block

  def initialize(expr, block)
    @expr = expr
    @block = block
  end

  def eval
    #TODO
  end
end

class IfStatement
  attr_accessor :expr, :block, :block2

  def initialize(expr, block, block2 = nil)
    @expr = expr
    @block = block
    @block2 = block2
  end

  def eval
    if @expr.eval # if expr is true do the block
      @block.eval
    elsif !@block2.nil? #if the expr is not true and there is a block2 (else), do the else block then
      @block2.eval
    end
  end
end

class Condition
  def initialize(condition)
    @condition = condition
  end

  def eval
    if @condition == true
      # puts true
      return true
    elsif @condition == false
      # puts false
      return nil
    end
  end
end

class Block
  def initialize(block)
    @block = block
  end

  def eval
    @block.eval
    # @block.each do |line|
    # if @condition
    #   return @block
    # elsif @condition == false
    #   return @block = nil
    # end
  end
end

class Expression
  attr_accessor :lhs, :rhs, :operator
  def initialize(lhs, operator, rhs )
    @lhs = lhs
    @operator = operator
    @rhs = rhs
  end

  def eval
    case @operator
    when '+' then
      @lhs.eval + @rhs.eval
    when '-' then
      @lhs.eval - @rhs.eval
    when '*' then
      @lhs.eval * @rhs.eval
    when '/' then
      @lhs.eval / @rhs.eval
    when '<'
      @lhs.eval < @rhs.eval
    when '>'
      @lhs.eval > @rhs.eval
    when '<='
      @lhs.eval <= @rhs.eval
    when '>='
      @lhs.eval >= @rhs.eval
    when '=='
      @lhs.eval == @rhs.eval
    when '!='
      @lhs.eval != @rhs.eval
    else
      raise ArgumentError, "Invalid comparison operator: #{@operator}"
    end
  end
end


class MyVariable
  attr_accessor :name

  def initialize(name)
    @name = name
  end

  def eval
    Scope.find_variable(@name)
  end
end


class MyInteger
  attr_accessor :value

  def initialize(value)
    @value = value.to_i 
  end

  def eval()
    return @value
  end
end


class MyFloat
  attr_accessor :value

  def initialize(value)
    @value = value.to_f
  end

  def eval()
    return @value
  end
end


class MyBoolean 
  attr_accessor :value

  def initialize(value)
    @value = value.downcase == 'true'
  end
  
  def eval()
    return @value
  end
end


class MyCharacter
  attr_accessor :value

  def initialize(value)
    @value = value
  end
  
  def eval()
    if @value.length != 3 or @value[0] != '"' or @value[2] != '"'
      abort("\nInvalid input!\nPlease enter a single character between two double quotation marks -> example \"c\"" ) ############
    else
      return @value[1]
    end
  end
end
