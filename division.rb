class Division
  attr_accessor :yeas, :nays, :paired
  def initialize(yeas=[], nays=[], paired=[])
    @yeas, @nays, @paired = yeas, nays, paired
  end
end