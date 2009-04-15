class Intervention
  attr_accessor :name, :link, :paragraphs
end

class Header
  attr_accessor :name, :sub_headers, :interventions
  
  def initialize(name)
    @name = name
    @sub_headers, @interventions = [], []
  end
end