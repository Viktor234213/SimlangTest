# classes.rb

class Scope
  attr_accessor :variables

  @@variables = {}
  
  def self.add_variable(variable_name, value)
    @@variables[variable_name] = value
  end

  def self.find_variable(variable_name)
    @value = @@variables[variable_name]
    if @value.nil?
      abort("Variable '#{variable_name}' not found")
    else
      return @value
    end
  end

  def handle_input(variable)
    print "Enter a value for variable '#{variable}': "
    value = gets.chomp

    if value.to_i.to_s == value
      @variables[variable] = value.to_i
    elsif value.to_f.to_s == value
      @variables[variable] = value.to_f
    elsif value.downcase == 'true'
      @variables[variable] = true
    elsif value.downcase == 'false'
      @variables[variable] = false
    elsif value.length == 1
      @variables[variable] = value
    else
      abort("Invalid input. Please enter a single character, true, false, integer, or float.")
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
    @value = value.downcase
  end
  
  def eval()
    if @value == "true"
      @value = true
    else
      @value = false
    end
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


class Expression
  attr_accessor :lhs, :rhs, :operator
  def initialize(lhs, operator, rhs)
    @lhs = lhs
    @operator = operator
    @rhs = rhs
  end

  def eval
    case @operator
    when '+' then
      @lhs + @rhs
    when '-' then
      @lhs - @rhs
    when '*' then
      @lhs * @rhs
    when '/' then
      @lhs / @rhs
    when '<'
      @lhs < @rhs
    when '>'
      @lhs > @rhs
    when '<='
      @lhs <= @rhs
    when '>='
      @lhs >= @rhs
    when '=='
      @lhs == @rhs
    when '!='
      @lhs != @rhs
    else
      raise ArgumentError, "Invalid comparison operator: #{@operator}"
    end
  end
end


class LogicalExpression
  attr_reader :lhs, :operator, :rhs

  def initialize(lhs, operator, rhs = nil)
    @lhs = lhs
    @operator = operator
    @rhs = rhs
  end

  def eval
    case @operator
    when :and
      @lhs && @rhs
    when :or
      @lhs || @rhs
    when :not
      !@rhs
    end
  end
end


class Output
  attr_accessor :value
  def initialize(value)
    @value = value
  end
  def eval
    puts @value
  end
end


class IfStatement
  attr_accessor :condition, :block, :else_block

  def initialize(condition, block, else_block = nil)
    @condition = condition
    @block = block
    @else_block = else_block
    puts "hello its initialize"
  end

  def eval
    if else_block
      if condition
        return block
      else
        return else_block
      end
    elsif condition
      puts "its condition"
      return block
    else
      puts "its nil"
      return nil
    end
  end 
end


class Condition
  def initialize(condition)
    @condition = condition
  end

  def eval
    if @condition == true
      puts true
      return true
    elsif @condition == false
      puts false
      return nil
    end
  end
end


class Block
  def initialize(block)
    @block = block
  end

  def eval
    if @condition
      return @block
    elsif @condition == false
      return @block = nil
    end
  end
end


class WhileLoop
  def initialize(condition, block)
    @condition = condition
    @block = block
  end

  def eval
    while @condition == true
      @block.each do |block| @block
      end
    end
  end
end
