class Logger

  def initialize(level)
    @level = level
  end

  def log( level, message )
    puts message
  end

end
