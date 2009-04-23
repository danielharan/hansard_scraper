class Header
  attr_accessor :title, :sub_headers, :interventions
  
  def initialize(title)
    @title = title
    @sub_headers, @interventions = [], []
  end
end