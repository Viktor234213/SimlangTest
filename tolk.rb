require_relative 'simlang'

class SimLangInterpreter
  def initialize
    @roller = SimLang.new
  end
  
  def readcode(filename)
    $code = File.read(filename)
    interpret($code)
  end
  
  def interpret(code)
    @roller.log(false)
    @roller.parse(code)
  rescue Parser::ParseError => e
    puts "Parse Error: #{e.message}"
  end

  # def readinput
  #   loop do
  #     print "> "
  #     input = gets
  #     interpret(input)
  #   end
  # end
  
end

if __FILE__ == $PROGRAM_NAME
  filename = ARGV[0]
  if filename.nil?
    puts "Enter the file name for SimLang code to interpret."
    exit(1)
  end
  
  unless filename.end_with?('.sim')
    puts "Wrong file format, File should end in .sim"
    exit(1)
  end
  
  interpreter = SimLangInterpreter.new
  interpreter.readcode(filename)
  # if $code.include?("write:")
    # interpreter.readinput
  # end
end
