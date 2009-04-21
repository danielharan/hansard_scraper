require 'test_helper'
require '../extractor'
require 'hpricot'

class ExtractorTest < Test::Unit::TestCase
  def setup
    @extractor = Extractor.new('../hansards/2009-03-12.html')
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
    division = Extractor.new('../hansards/2009-03-10.html').division("#Div-25")
    assert_equal ["Clement", "Ouellet", "Paillé", "Weston (Saint John)"], division.paired
  end
  
  def test_extract_initialize
    assert_not_nil @extractor.contents
    assert @extractor.contents.is_a?(Hpricot::Doc)
  end
  
  def test_intervention
    intervention = @extractor.intervention('#Int-2655693')
    assert_not_nil intervention
    expected_link = "/HousePublications/GetWebOptionsCallBack.aspx?SourceSystem=PRISM&ResourceType=Affiliation&ResourceID=128173&language=1&DisplayMode=2"
    assert_equal expected_link, intervention.link
    assert_equal "Mr. Michel Guimond (Montmorency—Charlevoix—Haute-Côte-Nord, BQ)", intervention.name
    assert_equal 2, intervention.paragraphs.length
    
    first = "Mr. Speaker, I cannot appeal your ruling, nor do I wish to, but I did ask for corrective action. With all due respect, it seems to me that you have not made it clear enough whether you want the minister to withdraw her offensive statements."
    second = "You have distinguished between remarks directed to an individual and remarks directed to a party. Depending on your response, and with your permission, I might have a statement to make, but we do not understand what sanction, if any, you have imposed by your ruling."
    
    assert_equal first, intervention.paragraphs.first
    assert_equal second, intervention.paragraphs.last
  end
  
  def test_intervention_with_multiple_paragraphs
    intervention = @extractor.intervention('#Int-2655773')
    assert_not_nil intervention
    assert_equal 5, intervention.paragraphs.length
  end
  
  def test_intervention_contains_procedural_text
    intervention = @extractor.intervention('#Int-2656184')
    assert_not_nil intervention
    expected = "moved for leave to introduce Bill C-19, An Act to amend the Criminal Code (investigative hearing and recognizance with conditions)."
    assert_equal expected, intervention.paragraphs.first
    assert_equal "<div class='procedural_text'>(Motions deemed adopted, bill read the first time and printed)</div>", intervention.paragraphs.last
  end
  
  def test_intervention_with_bracketed_notes_between_paragrahs
    intervention = @extractor.intervention('#Int-2655585')
    
    assert_match /^I am now prepared to rule/, intervention.paragraphs.first
    assert_equal "The hon. whip of the Bloc Québécois on a point of order.", intervention.paragraphs[-2]
    assert_equal "<div class='timestamp'>(1010)</div>", intervention.paragraphs.last
  end
  
  def test_intervention_with_timestamp_between_paragraphs
    intervention = @extractor.intervention('#Int-2656407')
    
    assert_equal "<div class='timestamp'>(1050)</div>", intervention.paragraphs[21]
    assert_equal "Omar Khadr's repatriation is long overdue. The bottom line is we must bring Omar Khadr home.", intervention.paragraphs.last
  end
  
  def test_timestamp_after_a_paragraph_gets_picked_up
    intervention = @extractor.intervention('#Int-2655875')
    assert_equal 6, intervention.paragraphs.length
    assert_equal "<div class='timestamp'>(1020)</div>", intervention.paragraphs.last
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