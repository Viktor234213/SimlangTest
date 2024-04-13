# classes.rb


#Kan vara en basklass fÃ¶r att jobba med SCOPES/HASH
# Modify the Scope class to accept parameters during initialization
class Scope
  attr_accessor :variables

  def initialize()
    @variables = {}
  end

  def add_variable(variable, value)
    @variables[variable] = value
  end

  def find_variable(name)
    @variables[name]
  end
end



class Output
  def initialize(value)
    @value = value
  end
  def eval()
    puts @value
  end
end

class MyInteger
  attr_accessor :value
  def initialize(value)
    @value = value.to_i 
  end

  def eval()
    @value
  end
end


class MyFloat
  attr_accessor :value
  def initialize(value)
    @value = value.to_f
  end

  def eval()
    @value
  end
end


class MyBoolean 
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
  def initialize(value)
    @value = value
  end
  
  def eval()
    @value
  end
end

class Addition 
  def initialize(lh, rh)
    @lh, @rh = lh, rh
  end

  def eval()
    @lh + @rh
  end
end



class Subtraction 
  def initialize(lh, rh)
    @lh, @rh = lh, rh
  end

  def eval()
    @lh - @rh
  end
end


class Multiplication 
  def initialize(lh, rh)
    @lh, @rh = lh, rh
  end

  def eval()
    @lh * @rh
  end
end

class Division 
  def initialize(lh, rh)
    @lh, @rh = lh, rh
  end

  def eval()
    @lh / @rh
  end
end


