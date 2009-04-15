class Intervention
  attr_accessor :name, :link, :paragraphs
end

class Header
  attr_accessor :title, :sub_headers, :interventions
  
  def initialize(title)
    @title = title
    @sub_headers, @interventions = [], []
  end
end