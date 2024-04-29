

require 'logger'
require_relative 'classes'

class Rule
  Match = Struct.new :pattern, :block
  
  def initialize(name, parser)
    @logger = parser.logger
    @name = name
    @parser = parser
    @matches = []
    @lrmatches = []
  end
  
  def match(*pattern, &block)
    match = Match.new(pattern, block)
    if pattern[0] == @name
      pattern.shift
      @lrmatches << match
    else
      @matches << match
    end
  end
  
  def parse
    match_result = try_matches(@matches)
    return nil if match_result.nil?
    loop do
      result = try_matches(@lrmatches, match_result)
      return match_result if result.nil?
      match_result = result
    end
  end

  private
  
  def try_matches(matches, pre_result = nil)
    match_result = nil
    start = @parser.pos
    matches.each do |match|
      result = pre_result.nil? ? [] : [pre_result]
      match.pattern.each_with_index do |token,index|
        if @parser.rules[token]
          result << @parser.rules[token].parse
          if result.last.nil?
            result = nil
            break
          end
          @logger.debug("Matched '#{@name} = #{match.pattern[index..-1].inspect}'")
        else
          nt = @parser.expect(token)
          if nt
            result << nt
            if @lrmatches.include?(match.pattern) then
              pattern = [@name]+match.pattern
            else
              pattern = match.pattern
            end
            @logger.debug("Matched token '#{nt}' as part of rule '#{@name} <= #{pattern.inspect}'")
          else
            result = nil
            break
          end
        end
      end
      if result
        if match.block
          match_result = match.block.call(*result)
        else
          match_result = result[0]
        end
        @logger.debug("'#{@parser.string[start..@parser.pos-1]}' matched '#{@name}' and generated '#{match_result.inspect}'") unless match_result.nil?
        break
      else
        @parser.pos = start
      end
    end
    
    return match_result
  end
end

class Parser
  attr_accessor :pos
  attr_reader :rules, :string, :logger

  class ParseError < RuntimeError
  end

  def initialize(language_name, &block)
    @logger = Logger.new(STDOUT)
    @lex_tokens = []
    @rules = {}
    @start = nil
    @language_name = language_name
    instance_eval(&block)
  end
  
  def tokenize(string)
    @tokens = []
    @string = string.clone
    until string.empty?
      raise ParseError, "unable to lex '#{string}" unless @lex_tokens.any? do |tok|
        match = tok.pattern.match(string)
        if match
          @logger.debug("Token #{match[0]} consumed")
          @tokens << tok.block.call(match.to_s) if tok.block
          string = match.post_match
          true
        else
          false
        end
      end
    end
  end
  
  def parse(string)
    tokenize(string)
    @pos = 0
    @max_pos = 0
    @expected = []
    result = @start.parse
      #  if @pos != @tokens.size ###################
        #  raise ParseError, "Undefined variable for variable: '#{@tokens[@max_pos]}'"
      #  end
    return result
  end
  
  def next_token
    @pos += 1
    return @tokens[@pos - 1]
  end

  def expect(tok)
    return tok if tok == :empty
    t = next_token
    if @pos - 1 > @max_pos
      @max_pos = @pos - 1
      @expected = []
    end
    return t if tok === t
    @expected << tok if @max_pos == @pos - 1 && !@expected.include?(tok)
    return nil
  end
  
  def to_s
    "Parser for #{@language_name}"
  end

  private
  
  LexToken = Struct.new(:pattern, :block)
  
  def token(pattern, &block)
    @lex_tokens << LexToken.new(Regexp.new('\\A' + pattern.source), block)
  end
  
  def start(name, &block)
    rule(name, &block)
    @start = @rules[name]
  end
  
  def rule(name,&block)
    @current_rule = Rule.new(name, self)
    @rules[name] = @current_rule
    instance_eval &block
    @current_rule = nil
  end

  def match(*pattern, &block)
    @current_rule.send(:match, *pattern, &block)
  end
end




class SimLang
  def initialize
    @langParser = Parser.new("SimLang") do
      token(/\/\/.*$/) { puts "-------------test comment-------------"} # a single line comment should start with //
      token(/(<|>|<=|>=|!=|==)/) { |com_op| com_op }
      token(/(and|or|not)/) { |log_op| log_op }
      token(/(\+|\-|\*|\/)/) { |op| op }
      token(/(\(|\)|\{|\})/) { |parens| parens }
      token(/set/) { |key_word| key_word }
      token(/show:/) { |key_word| key_word }
      token(/to/) { |key_word| key_word }
      token(/write:/) { |key_word| key_word }
      token(/if/) { |key_word| key_word }
      token(/then/) { |key_word| key_word }
      token(/else/) { |key_word| key_word }
      token(/while/) { |key_word| key_word }
      token(/[a-zA-Z][a-zA-Z0-9_]*/) { |variable_name| variable_name }
      token(/\s+/)
      token(/\d+\.\d+/) { |digit_sequence| digit_sequence.to_f }
      token(/\d+/) { |digit_sequence| digit_sequence.to_i }
      token(/(true|TRUE)/) { true }
      token(/(false|FALSE)/) { false }
      token(/"(.)"/) { |letter| letter } # token(/"(.*)"/) { |letter| letter }
      token(/./) { |letter| letter }

      start :statements do
        match(:assignment)
        match(:output)
        match(:input)
        match(:if_statement)
        match(:whileloop)
        match(:function)
      end

      rule :expr do 
        match(:comparison)
        match(/(true|TRUE)/) { |t| MyBoolean.new(t) }
        match(/(false|FALSE)/) { |f| MyBoolean.new(f) } 
        match('(', :expr, ')') { |_, expr, _| expr }
        match(/"(.)"/) { |letter| MyCharacter.new(letter) }
      end

      rule :assignment do 
        match('set', '#', :variable, 'to', :value) { |_, _, variable, _, value| Assignment.new(variable, value) }
      end

      rule :output do 
        match('show:', :expr) { |_ , expr| Output.new(expr) }
      end

      rule :input do 
        match('write:', '#', :variable) { |_, _, var| Input.new(var) }
      end

      rule :if_statement do
        match('if', :condition, 'then', :block) { |_, condition, _, iftrue| IfStatement.new(condition, iftrue, nil) }
        match('if', :condition, 'then', :block, 'else', :block) { |_, condition, _, iftrue, _,  iffalse| IfStatement.new(condition, iftrue, iffalse) }
      end     

      rule :condition do
        match('(', :logical_expression, ')') { |_, expression, _| expression }
      end

      rule :block do
        match('{', :statements, '}') { |_, statements, _| Block.new(statements) }
      end

      rule :logical_expression do
        match(:expr)
      end

      rule :whileloop do 
        match('while', '(', :expr, ')', :block) { |_, _, expr, _, block| WhileLoop.new(expr, block) }
      end

      rule :function do 
        # TODO! 
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
        match(:multidiv, '+', :addsub) { |lhs, operator, rhs| Expression.new(lhs, operator, rhs) }
        match(:multidiv, '-', :addsub) { |lhs, operator, rhs| Expression.new(lhs, operator, rhs) }
        match(:multidiv)
      end

      rule :multidiv do
        match(:unaryexpr, '*', :multidiv) { |lhs, operator, rhs| Expression.new(lhs, operator, rhs) }
        match(:unaryexpr, '/', :multidiv) { |lhs, operator, rhs| Expression.new(lhs, operator, rhs) }
        match(:unaryexpr)
      end

      rule :unaryexpr do
        match('-', :unaryexpr) { |_, expr| -expr }
        match(:factor)
      end

      rule :factor do
        match('(', :expr, ')') { |_, expr, _| expr }
        match(:num)
      end
      

      rule :num do
        match(:digit, :num) { |digit, num| digit + num }
        match(:digit) { |digit| digit }
      end


      rule :digit do
        match(Float) { |float| MyFloat.new(float) }
        match(Integer) { |int| MyInteger.new(int) }
        match('#', :variable) { |_, var| MyVariable.new(var) }
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
