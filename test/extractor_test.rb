require 'test_helper'
require File.join(File.dirname(__FILE__), '..', 'extractor')
require 'hpricot'

class ExtractorTest < Test::Unit::TestCase
  def setup
    @extractor = Extractor.new(File.join(File.dirname(__FILE__), '..', '/hansards/2009-03-12.html'))
  end
  
  def test_division
    # TODO: (next) add this to what we get out of the TOC:
    # <div class="toc_Division" xmlns:msxsl="urn:schemas-microsoft-com:xslt"><a class="tocLink" href="#Div-28"><b><i>
    
    division = @extractor.division("#Div-28")
    
    yeas = ["Allen (Welland)", "Atamanenko", "Bevington", "Charlton", "Chow", "Christopherson", "Comartin", "Crowder", 
            "Cullen", "Davies (Vancouver East)", "Duncan (Edmonton—Strathcona)", "Godin", "Gravelle", "Hughes", "Julian", 
            "Layton", "Leslie", "Maloway", "Marston", "Martin (Winnipeg Centre)", "Martin (Sault Ste. Marie)", "Masse", 
            "Rafferty", "Savoie", "Siksay", "Stoffer", "Wasylycia-Leis"]
    nays = ["Abbott", "Ablonczy", "Aglukkaq", "Albrecht", "Allen (Tobique—Mactaquac)", "Allison", "Ambrose", "Anderson", "Andrews", 
            "Ashfield", "Bagnell", "Bains", "Beaudin", "Bélanger", "Bennett", "Benoit", "Bernier", "Bezan", "Bigras", "Blackburn", 
            "Blaney", "Block", "Bouchard", "Boucher", "Boughen", "Braid", "Breitkreuz", "Brown (Leeds—Grenville)", "Brown (Newmarket—Aurora)", 
            "Brown (Barrie)", "Bruinooge", "Brunelle", "Byrne", "Cadman", "Calandra", "Calkins", "Cannan (Kelowna—Lake Country)", "Cannis", 
            "Carrie", "Carrier", "Casson", "Chong", "Clarke", "Clement", "Coady", "Coderre", "Cotler", "Cuzner", "D'Amours", "Davidson", "Day", 
            "DeBellefeuille", "Dechert", "Del Mastro", "Demers", "Desnoyers", "Devolin", "Dhaliwal", "Dion", "Dorion", "Dreeshen", "Dufour", 
            "Duncan (Vancouver Island North)", "Duncan (Etobicoke North)", "Dykstra", "Easter", "Eyking", "Faille", "Fast", "Finley", 
            "Fletcher", "Fry", "Galipeau", "Gallant", "Garneau", "Glover", "Goodale", "Goodyear", "Gourde", "Grewal", "Guarnieri", "Guergis", 
            "Guimond (Rimouski-Neigette—Témiscouata—Les Basques)", "Hall Findlay", "Harper", "Harris (Cariboo—Prince George)", "Hawn", "Hiebert", 
            "Hill", "Hoback", "Hoeppner", "Holder", "Jean", "Jennings", "Kamp (Pitt Meadows—Maple Ridge—Mission)", "Kania", "Karygiannis", 
            "Keddy (South Shore—St. Margaret's)", "Kenney (Calgary Southeast)", "Kent", "Kerr", "Komarnicki", "Kramp (Prince Edward—Hastings)", 
            "Laframboise", "Lake", "Lauzon", "Lebel", "Lee", "Lemieux", "Lobb", "Lukiwski", "Lunn", "Lunney", "MacKenzie", "Malhi", "Malo", "Mayes", 
            "McColeman", "McGuinty", "McKay (Scarborough—Guildwood)", "McTeague", "Ménard (Marc-Aurèle-Fortin)", "Mendes", "Menzies", "Merrifield", 
            "Miller", "Minna", "Moore (Fundy Royal)", "Murphy (Charlottetown)", "Murray", "Nicholson", "Norlock", "O'Connor", "O'Neill-Gordon", 
            "Obhrai", "Oda", "Oliphant", "Pacetti", "Paquette", "Paradis", "Patry", "Payne", "Pearson", "Petit", "Poilievre", "Prentice", "Preston", 
            "Proulx", "Raitt", "Rajotte", "Rathgeber", "Regan", "Reid", "Richards", "Richardson", "Rickford", "Rodriguez", "Russell", "Saxton",
            "Scarpaleggia", "Scheer", "Schellenberger", "Shea", "Shipley", "Silva", "Simms", "Simson", "Smith", "Sorenson", "St-Cyr", "Stanton",
            "Storseth", "Strahl", "Sweet", "Szabo", "Thompson", "Tilson", "Toews", "Trost", "Trudeau", "Tweed", "Uppal", "Valeriote", "Van Kesteren",
            "Van Loan", "Vellacott", "Verner", "Vincent", "Wallace", "Warawa", "Warkentin", "Watson", 
            "Weston (West Vancouver—Sunshine Coast—Sea to Sky Country)", "Weston (Saint John)", "Wilfert", "Wong", "Woodworth", "Wrzesnewskyj", 
            "Yelich", "Young", "Zarac"]
    paired = []
    
    assert_equal yeas,   division.yeas
    assert_equal nays,   division.nays
    assert_equal paired, division.paired
  end
  
  def test_division_for_paired
    division = Extractor.new(File.join(File.dirname(__FILE__), '..', '/hansards/2009-03-10.html')).division("#Div-25")
    assert_equal ["Clement", "Ouellet", "Paillé", "Weston (Saint John)"], division.paired
  end
  
  def test_extract_initialize
    assert_not_nil @extractor.contents
    assert @extractor.contents.is_a?(Hpricot::Doc)
  end
  
  def test_extract_toc
    toc = @extractor.toc
        
    assert_equal "#Int-2655585", toc.first.anchor
    assert_equal "Oral Questions--Speaker's Ruling", toc.first.header3
    assert_equal "Points of Order", toc.first.header2
    assert_equal "", toc.first.header1
    
    assert_equal "#Int-2660566", toc.last.anchor
    
    assert_equal 331, toc.length
  end
  
  def test_elements_between
    elems = @extractor.toc_elements
    assert_equal 331, elems.select {|e| e.name == 'div' && e.attributes['class'] == 'toc_Intervention'}.length
  end
  
  def test_extract_tree
    @extractor.extract_tree!
    assert_not_nil @extractor.headers1
    assert_equal 10, @extractor.headers1.length
  end
end