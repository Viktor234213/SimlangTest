require 'logger'
require_relative 'classes'
require_relative 'rdparse'


class SimLang
  def initialize
    @langParser = Parser.new("SimLang") do
      token(/\/\/.*$/) # a single line comment should start with //
      token(/(<=|>=|<|>|!=|==)/) { |com_op| com_op }
      token(/(and|or)/) { |log_op| log_op }
      token(/(\+|\-|\*|\/)/) { |op| op }
      token(/(\(|\)|\{|\})/) { |parens| parens }
      token(/set/) { |key_word| key_word }
      token(/to/) { |key_word| key_word }
      token(/show:/) { |key_word| key_word }
      token(/write:/) { |key_word| key_word }
      token(/if/) { |key_word| key_word }
      token(/then/) { |key_word| key_word }
      token(/else/) { |key_word| key_word }
      token(/while/) { |key_word| key_word }
      token(/loop/) { |key_word| key_word }
      token(/function/) { |key_word| key_word }
      token(/[a-zA-Z][a-zA-Z0-9_]*/) { |variable_name| variable_name }
      token(/\s+/) # ignore whitespaces
      token(/\d+\.\d+/) { |digit_sequence| digit_sequence.to_f }
      token(/\d+/) { |digit_sequence| digit_sequence.to_i }
      token(/(true|TRUE)/) { true }
      token(/(false|FALSE)/) { false }
      token(/"(.)"/) { |letter| letter }
      token(/./) { |letter| letter }


#-------------------------------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------------------------------


      start :statement do
        match(:assignment)
        match(:output)
        match(:input)
        match(:if_statement)
        match(:while_loop)
        match(:function)
        match(:function_call)
      end

      # allowed variable and function names
      rule :name do
        match(/[a-zA-Z][a-zA-Z0-9_]*/)
      end

      rule :assignment do 
        match('set', '#', :name, 'to', :expr) { |_, _, variable, _, value| Assignment.new(variable, value) }
      end

      rule :output do 
        match('show:', :expr) { |_, expr| Output.new(expr) }
      end

      rule :input do 
        match('write:', '#', :name) { |_, _, variable| Input.new(variable) }
      end


#-------------------------------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------------------------------


      rule :if_statement do
        match('if', :condition, 'then', :block, 'else', :block) { |_, condition, _, iftrue, _,  iffalse| IfStatement.new(condition, iftrue, iffalse) }
        match('if', :condition, 'then', :block) { |_, condition, _, iftrue| IfStatement.new(condition, iftrue, nil) }
      end

      rule :while_loop do 
        match('while', :condition, 'loop', :block) { |_, condition, _, block| WhileLoop.new(condition, block) }
      end

      rule :condition do
        match('(', :logical_expression, ')') { |_, logical_expression, _| logical_expression }
      end

      rule :block do
        match('{', :inner_statements, '}') { |_, inner_statements, _| Block.new(inner_statements) }
      end


#-------------------------------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------------------------------


      rule :function do
        match('function', :name, '(', :parameters, ')', :block) { |_, function_name, _, params, _, block| FunctionDeclaration.new(function_name, params, block) }
      end

      rule :parameters do
        match(:parameters, ',', :name) { |params, _, param| params << param }
        match(:name) { |param| [param] }
        match() { [] }
      end

      rule :function_call do
        match(:name, '(', :function_args, ')') { |function_name, _, args, _| FunctionCall.new(function_name, args) }
      end

      rule :function_args do
        match(:function_args, ',', :expr) { |args, _, arg| args << arg }
        match(:expr) { |arg| [arg] }
        match() { [] }
      end


#-------------------------------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------------------------------


      rule :inner_statements do
        match(:inner_statements, :statement) { |inner_statements, statement| inner_statements.add_stmt(statement) }
        match(:statement) { |statement| Statements.new([statement]) }
      end

      rule :expr do 
        match(:comparison)
        match(:function_call)
        match(:logical_expression)
        match(/(true|TRUE)/) { |t| MyBoolean.new(t) }
        match(/(false|FALSE)/) { |f| MyBoolean.new(f) } 
        match(/"(.)"/) { |letter| MyCharacter.new(letter) }
      end

      rule :logical_expression do
        match(:logical_expression, 'or', :logical_term) { |lhs, _, rhs| LogicalExpression.new(lhs, :or, rhs) }
        match(:logical_term)
      end

      rule :logical_term do
        match(:logical_term, 'and', :logical_factor) { |lhs, _, rhs| LogicalExpression.new(lhs, :and, rhs) }
        match(:logical_factor)
      end

      rule :logical_factor do
        match('(', :logical_expression, ')') { |_, logical_expression, _| logical_expression }
        match(:comparison)
      end

      rule :comparison do
        match(:addsub, '>', :comparison)  { |lhs, operator, rhs| Expression.new(lhs, operator, rhs) }
        match(:addsub, '<', :comparison)  { |lhs, operator, rhs| Expression.new(lhs, operator, rhs) }
        match(:addsub, '<=', :comparison) { |lhs, operator, rhs| Expression.new(lhs, operator, rhs) }
        match(:addsub, '>=', :comparison) { |lhs, operator, rhs| Expression.new(lhs, operator, rhs) }
        match(:addsub, '==', :comparison) { |lhs, operator, rhs| Expression.new(lhs, operator, rhs) }
        match(:addsub, '!=', :comparison) { |lhs, operator, rhs| Expression.new(lhs, operator, rhs) }
        match(:addsub)
      end

      rule :addsub do
        match(:addsub, '+', :multidiv) { |lhs, operator, rhs| Expression.new(lhs, operator, rhs) }
        match(:addsub, '-', :multidiv) { |lhs, operator, rhs| Expression.new(lhs, operator, rhs) }
        match(:multidiv)
      end

      rule :multidiv do
        match(:multidiv, '*', :unaryexpr) { |lhs, operator, rhs| Expression.new(lhs, operator, rhs) }
        match(:multidiv, '/', :unaryexpr) { |lhs, operator, rhs| Expression.new(lhs, operator, rhs) }
        match(:unaryexpr)
      end

      rule :unaryexpr do
        match('-', :unaryexpr) { |_, unaryexpr| Expression.new(MyInteger.new(0), '-', unaryexpr) }
        match(:factor)
      end

      rule :factor do
        match('(', :expr, ')') { |_, expr, _| expr }
        match(:number)
      end

      rule :number do
        match(:value, :number) { |value, numebr| value + number }
        match(:value) { |value| value }
      end

      rule :value do
        match(Float) { |float| MyFloat.new(float) }
        match(Integer) { |int| MyInteger.new(int) }
        match('#', :name) { |_, var| MyVariable.new(var) }
      end
    end
  end
      

   def parse(code)
     @langParser.parse(code)
   end

  def log(state = true)
    if state
      @langParser.logger.level = Logger::DEBUG
    else
      @langParser.logger.level = Logger::WARN
    end
  end
end
