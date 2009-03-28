class Extractor
  attr_accessor :contents
  def initialize(filename)
    @contents = IO.read(filename)
  end
end