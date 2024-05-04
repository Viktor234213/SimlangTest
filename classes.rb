class Scope
  
  # an array that holds different scopes. At the beginning it contains only an empty hash which is the global scope.
  @@scopes = [{}]

  # Methods to handle scopes
  def self.global_scope; @@scopes.first end # return the global scope
  def self.create_scope; @@scopes.push({}) end # create a new local scope
  def self.remove_scope; @@scopes.pop end # remove the latest local scope
  def self.current_scope; @@scopes.last end # return the current scope

  def self.set_local(variable_name, value)
    current_scope[variable_name] = value
  end

  def self.set_global(variable_name, value)
    global_scope[variable_name] = value
  end

  def self.find_variable(variable_name)
    @value = current_scope[variable_name]    # try to find the variable in the current scope
    if @value.nil?                           # if the variable is not in current scope
        @value = global_scope[variable_name] # try to find it in the global scope
    end
    if @value.nil?
      abort("Variable '#{variable_name}' not found")
    else
      return @value
    end
  end
end


class Statements
  def initialize(statements)
    @statements = statements
  end

  def add_stmt(stmt)
    Statements.new(@statements + [stmt])
  end

  def eval
    return_value = nil
  
    @statements.each do |stmt|
      return_value = stmt.eval
    end
  
    return_value
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
  
  def eval() # check if the value is only a single character between two double quotation marks
    if @value.length != 3 or @value[0] != '"' or @value[2] != '"'
      abort("\nInvalid input!\nPlease enter a single character between two double quotation marks -> example \"c\"" )
    else
      return @value[1] # return only the character
    end
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


class LogicalExpression
  attr_reader :operation, :operand1, :operand2

  def initialize(operand1, operation, operand2 = nil)
    @operand1 = operand1
    @operation = operation
    @operand2 = operand2
  end

  def eval
    case @operation

    when :and
      @operand1.eval && @operand2.eval
    when :or
      @operand1.eval || @operand2.eval
    end
  end
end


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
  input = $stdin.gets.chomp

    type = if input.match?(/^-?\d+$/) 
            MyInteger.new(input).eval
          elsif input.match?(/^-?\d+\.\d+$/)
            MyFloat.new(input).eval
          elsif ['true', 'false'].include?(input.downcase)
            MyBoolean.new(input).eval
          elsif input.match?(/^"[^"]"$/)
            MyCharacter.new(input).eval
          else
            abort("\nInvalid input!\nPlease enter either a single character between two double quotation marks or a numerical value (integer, float, or boolean).")
          end      
    Scope.set_local(@value, type)
  end
end


class Assignment
  attr_accessor :variable, :value

  def initialize(variable, value)
    @variable = variable
    @value = value
  end

  def eval
    Scope.set_local(@variable, @value.eval)
  end
end


class WhileLoop
  attr_accessor :expr, :block

  def initialize(expr, block)
    @expr = expr
    @block = block
  end

  def eval
    while @expr.eval
      @block.eval
    end
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
    if @expr.eval # if the expression is true, execute block
      @block.eval
    elsif !@block2.nil? # If the expression is false and another block exists, execute block 2
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
      return true
    elsif @condition == false
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
  end
end


class MyFunction
  attr_reader :name, :parameters, :block

  def initialize(name, parameters, block)
    @name = name
    @parameters = parameters
    @block = block
  end

  def call_function(arguments)
    Scope.create_scope 

    @parameters.each_with_index do |param, index|
      Scope.set_local(param, arguments[index])
    end
    
    return_value = @block.eval
    Scope.remove_scope

    return return_value
  end
end


class FunctionDeclaration
  attr_accessor :name, :parameters, :block

  def initialize(name, parameters, block)
    @name = name
    @parameters = parameters
    @block = block
  end

  def eval
    function = MyFunction.new(@name, @parameters, @block)
    Scope.set_global(@name, function)
  end
end


class FunctionCall
  attr_accessor :name, :arguments
  
  def initialize(name, arguments)
    @name = name
    @arguments = arguments
  end
  
  def eval
    function = Scope.find_variable(@name)
    if function.nil? || !function.is_a?(MyFunction)
      abort("Function '#{@name}' not found or not a valid function")
    end
    
    arguments_to_pass = @arguments.map(&:eval)
    function.call_function(arguments_to_pass)
  end
end
