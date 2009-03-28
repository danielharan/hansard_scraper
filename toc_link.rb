class TocLink
  # header1 TocObTitle inner_text
  # header2 TocSbTitle inner_text
  # header3 #toc_SOBQualifier
  # anchor  #toc_Intervention
  # ignore everything else
  attr_accessor :header1, :header2, :header3, :anchor
  
  def initialize(header1, header2, header3, anchor)
    self.header1 = header1
    self.header2 = header2
    self.header3 = header3
    self.anchor  = anchor
  end
end