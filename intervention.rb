class Intervention
  attr_accessor :name, :link, :paragraphs
end

class Header
  attr_accessor :name, :link, :sub_headers, :interventions
  
  def initialize(name)
    @name = name
  end
end