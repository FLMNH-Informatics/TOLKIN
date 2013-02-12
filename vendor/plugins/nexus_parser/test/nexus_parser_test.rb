require 'test/unit'
require 'rubygems'
require 'ruby-debug'

require File.expand_path(File.join(File.dirname(__FILE__), '../lib/nexus_file'))

class NexusParserTest < Test::Unit::TestCase
  def test_truth
    assert true
  end
end

class Test_NexusFileBuilder < Test::Unit::TestCase
  def test_builder
    b = NexusFileBuilder.new
    assert foo = b.nexus_file
    assert_equal [], foo.taxa
    assert_equal [], foo.characters
    assert_equal [], foo.codings
    assert_equal [], foo.sets
  end
end


class Test_Regex < Test::Unit::TestCase

  def test_begin_taxa
    txt = "  aslkfja\n Begin taxa; BLorf   end; "
    @regexp = Regexp.new(/\s*(Begin\s*taxa\s*;)\s*/i)
    assert txt =~ @regexp
  end

end


class Test_Lexer < Test::Unit::TestCase
  def test_lexer
    lexer = Lexer.new("[ foo ] BEGIN taxa; BLORF end;")
    assert lexer.pop(Tokens::LBracket)
    assert id = lexer.pop(Tokens::ID)
    assert_equal(id.value, "foo")
    assert lexer.pop(Tokens::RBracket)
    assert lexer.pop(Tokens::BeginBlk)
    assert lexer.pop(Tokens::TaxaBlk)
    assert foo = lexer.pop(Tokens::ID)
    assert_equal("BLORF", foo.value) # truncating whitespace
    assert lexer.pop(Tokens::BlkEnd)

    lexer2 = Lexer.new("[ foo ] begin authors; BLORF end; [] ()  some crud here")
    assert lexer2.pop(Tokens::LBracket)
    assert id = lexer2.pop(Tokens::ID)
    assert_equal(id.value, "foo")
    assert lexer2.pop(Tokens::RBracket)
    assert lexer2.pop(Tokens::BeginBlk)
    assert lexer2.pop(Tokens::AuthorsBlk)
    assert foo = lexer2.pop(Tokens::ID)
    assert_equal("BLORF", foo.value)
    assert lexer2.pop(Tokens::BlkEnd)

    lexer3 = Lexer.new("[ foo ] Begin Characters; BLORF end; [] ()  some crud here")
    assert lexer3.pop(Tokens::LBracket)
    assert id = lexer3.pop(Tokens::ID)
    assert_equal(id.value, "foo")
    assert lexer3.pop(Tokens::RBracket)
    assert lexer3.pop(Tokens::BeginBlk)
    assert lexer3.pop(Tokens::ChrsBlk)
    assert foo = lexer3.pop(Tokens::ID)
    assert_equal("BLORF", foo.value) 
    assert lexer3.pop(Tokens::BlkEnd)

    lexer4 = Lexer.new("Begin Characters; 123123123 end; [] ()  some crud here")
    assert lexer4.pop(Tokens::BeginBlk)
    assert lexer4.pop(Tokens::ChrsBlk)
    assert foo = lexer4.pop(Tokens::Number)
    assert_equal(123123123, foo.value) 
    assert lexer4.pop(Tokens::BlkEnd)

    lexer5 = Lexer.new("(0,1)")
    assert lexer5.pop(Tokens::LParen)
    assert foo = lexer5.pop(Tokens::Number)
    assert_equal(0, foo.value) 
    assert lexer5.pop(Tokens::Comma)
    assert foo = lexer5.pop(Tokens::Number)
    assert_equal(1, foo.value) 
    assert lexer5.pop(Tokens::RParen)

    lexer6 =  Lexer.new(" 210(0,1)10A1\n")
    assert foo = lexer6.pop(Tokens::RowVec)
    assert_equal(["2","1","0",["0","1"],"1","0","A","1"], foo.value) 

    lexer7 = Lexer.new("read nothing till Nexus, not that nexus 13243 Block [] ();, this one: #nexus FOO")
    assert foo = lexer7.pop(Tokens::NexusStart)
    assert_equal('#nexus', foo.value) 


    ## we strip comments before parsing now
    # lexer8 = Lexer.new("[ foo ] Begin Characters; BLORF end; [] ()  some crud here")
    # assert foo = lexer8.pop(Tokens::NexusComment)
    # assert_equal "foo", foo.value
    
    # assert lexer.pop(Tokens::Colon)
    # assert num = lexer.pop(Tokens::Number)
    # assert_equal(num.value, 0.0)
    # assert lexer.pop(Tokens::Comma)
    # assert lexer.pop(Tokens::SemiColon)
  end

  def test_punctuation
    lexer = Lexer.new(',/=](\'NOT23\'[);,')
    assert lexer.peek(Tokens::Comma)
    assert lexer.pop(Tokens::Comma)
    assert lexer.pop(Tokens::BckSlash)
    assert lexer.pop(Tokens::Equals)
    assert lexer.pop(Tokens::RBracket)
    assert lexer.pop(Tokens::LParen)
    assert foo = lexer.pop(Tokens::Label)
    assert_equal "NOT23", foo.value
    assert lexer.pop(Tokens::LBracket)
    assert lexer.pop(Tokens::RParen)
    assert lexer.pop(Tokens::SemiColon)
    assert lexer.pop(Tokens::Comma)

  end

  def test_tax_labels
    lexer = Lexer.new("Taxlabels 'foo' bar blorf \"stuff things\" stuff 'and foo';")
    assert foo = lexer.pop(Tokens::Taxlabels)
    assert_equal("Taxlabels ", foo.value) 
  end

  def test_semicolon
    lexer = Lexer.new("; Matrix foo")
    assert lexer.peek(Tokens::SemiColon)
    assert foo = lexer.pop(Tokens::SemiColon)
  end

  def test_label
      lexer = Lexer.new(' \'foo\' bar, blorf; "stuff things" stuff \'and foo\'')
      assert foo = lexer.pop(Tokens::Label)
      assert_equal "foo", foo.value
      assert foo = lexer.pop(Tokens::Label)
      assert_equal "bar", foo.value
      assert lexer.pop(Tokens::Comma)
      assert foo = lexer.pop(Tokens::Label)
      assert_equal "blorf", foo.value
      assert lexer.pop(Tokens::SemiColon)
      assert foo = lexer.pop(Tokens::Label)
      assert_equal "stuff things", foo.value
      assert foo = lexer.pop(Tokens::Label)
      assert_equal "stuff", foo.value
      assert foo = lexer.pop(Tokens::Label)
      assert_equal "and foo", foo.value
  end

  def test_title
    lexer = Lexer.new( "TITLE 'Scharff&Coddington_1997_Araneidae';")
    assert foo = lexer.pop(Tokens::Title)
    assert_equal  "TITLE 'Scharff&Coddington_1997_Araneidae';", foo.value
  end

  def test_dimensions
    input = " DIMENSIONS  NCHAR= 10" 
    lexer = Lexer.new(input)
    assert foo = lexer.pop(Tokens::Dimensions)
    assert_equal  "DIMENSIONS", foo.value
  end

  def test_format
    input = " format  NCHAR= 10" 
    lexer = Lexer.new(input)
    assert foo = lexer.pop(Tokens::Format)
    assert_equal  "format", foo.value
  end

  def test_value_pair

    lexer0 = Lexer.new(' DATATYPE=STANDARD ')
    assert foo = lexer0.pop(Tokens::ValuePair)
    blorf = {:datatype => "STANDARD"}
    assert_equal blorf , foo.value

    lexer = Lexer.new(' DATATYPE = STANDARD ')
    assert foo = lexer.pop(Tokens::ValuePair)
    blorf = {:datatype => "STANDARD"}
    assert_equal blorf , foo.value

    lexer2 = Lexer.new(' DATATYPE ="STANDARD" ')
    assert foo = lexer2.pop(Tokens::ValuePair)
    assert_equal blorf, foo.value

    lexer3 = Lexer.new('DATATYPE= "STANDARD" ')
    assert foo = lexer3.pop(Tokens::ValuePair)
    assert_equal blorf, foo.value

    input= 	"   NCHAR=10 ntaxa =10 nfoo='999' nbar = \" a b c  \" ;  "
    lexer4 = Lexer.new(input)
    assert foo = lexer4.pop(Tokens::ValuePair)
    smorf = {:nchar => '10'}
    assert_equal smorf, foo.value
    assert foo = lexer4.pop(Tokens::ValuePair)
    smorf = {:ntaxa => '10'}
    assert_equal smorf, foo.value
    assert foo = lexer4.pop(Tokens::ValuePair)
    smorf = {:nfoo => '999'}
    assert_equal smorf, foo.value
    assert foo = lexer4.pop(Tokens::ValuePair)
    smorf = {:nbar => 'a b c'}
    assert_equal smorf, foo.value

    lexer5 = Lexer.new(' symbols= " a c b d 1 " ')
    assert foo = lexer5.pop(Tokens::ValuePair)
    smorf = {:symbols => 'a c b d 1'}
    assert_equal smorf, foo.value

    lexer6 = Lexer.new(' missing = - ')
    assert foo = lexer6.pop(Tokens::ValuePair)
    smorf = {:missing => '-'}
    assert_equal smorf, foo.value
  
    lexer7 = Lexer.new("ntaxa =1;\n")
    assert foo = lexer7.pop(Tokens::ValuePair)
    smorf = {:ntaxa => '1'}
    assert_equal smorf, foo.value 
  
    lexer8 = Lexer.new(" ntaxa = 1 ;\n")
    assert foo = lexer8.pop(Tokens::ValuePair)
    smorf = {:ntaxa => '1'}
    assert_equal smorf, foo.value 

    lexer9 = Lexer.new(" TF = (CM 'This is an annotation that haa a hard return in it^n^n^n^nSo there!') ")
    assert foo = lexer9.pop(Tokens::ValuePair)
    smorf = {:tf => "(CM 'This is an annotation that haa a hard return in it^n^n^n^nSo there!')" }
    assert_equal smorf, foo.value 
 
    lexer10 = Lexer.new(" TF = (CM 'This is an value pair that has (parens) within the value, twice! ()') ; some stuff left here ")
    assert foo = lexer10.pop(Tokens::ValuePair)
    smorf = {:tf => "(CM 'This is an value pair that has (parens) within the value, twice! ()')" }
    assert_equal smorf, foo.value 
  end

  def test_MesquiteIDs
    lexer = Lexer.new('IDS JC1191fcddc3b425 JC1191fcddc3b426 JC1191fcddc3b427 JC1191fcddc3b428 JC1191fcddc3b429 JC1191fcddc3b430 JC1191fcddc3b431 JC1191fcddc3b432 JC1191fcddc3b433 JC1191fcddc3b434 ;
      BLOCKID JC1191fcddc0c0;')
    assert lexer.pop(Tokens::MesquiteIDs)
    assert lexer.pop(Tokens::MesquiteBlockID)
  end

  def test_TreesBlk
  lexer = Lexer.new("BEGIN TREES;
      Title Imported_trees;
      LINK Taxa = 'Scharff&Coddington_1997_Araneidae';
      TRANSLATE
        1 Dictyna,
        2 Uloborus,
        3 Deinopis,
        4 Nephila&Herennia,
        5 'Nephilengys_cruentata',
        6 Meta,
        7 Leucauge_venusta,
        8 Pachygnatha,
        9 'Theridiosoma_01',
        10 Tetragnatha;
      TREE 'Imported tree 1+' = (1,((2,3),(((4,5),(6,(7,(8,10)))),9)));
      TREE 'Imported tree 2+' = (1,((2,3),(((4,5),(6,(7,(8,10)))),9)));
      TREE 'Imported tree 3+' = (1,((2,3),(((6,(4,5)),(7,(8,10))),9)));
      TREE 'Imported tree 4+' = (1,((2,3),(((4,5),(6,(7,(8,10)))),9)));
      TREE 'Imported tree 5+' = (1,((2,3),(((6,(4,5)),(7,(8,10))),9)));
      TREE 'Imported tree 6+' = (1,((2,3),(((4,5),(6,(7,(8,10)))),9)));
      TREE 'Imported tree 7+' = (1,((2,3),(((6,(4,5)),(7,(8,10))),9)));
      TREE 'Imported tree 8+' = (1,((2,3),(((6,(4,5)),(7,(8,10))),9)));

    END;


    BEGIN LABELS;
      CHARGROUPLABEL MM_Genitalia COLOR = (RGB 1.0 0.4 0.4) ;
      CHARGROUPLABEL Somatic COLOR = (RGB 0.6 1.0 0.33333333) ;
      CHARGROUPLABEL Spinnerets COLOR = (RGB 0.46666667 0.57254902 1.0) ;
      CHARGROUPLABEL Behavior COLOR = (RGB 1.0 0.46666667 1.0) ;


    END;")
 
    assert lexer.pop(Tokens::BeginBlk)
    assert foo = lexer.pop(Tokens::TreesBlk)
    assert_equal 'TREES', foo.value.slice(0,5)
    assert_equal 'END;', foo.value.slice(-4,4)
    assert lexer.pop(Tokens::BeginBlk)
    assert lexer.pop(Tokens::LabelsBlk)

  end

  def test_NotesBlk
    input = "BEGIN NOTES ;" 
    lexer = Lexer.new(input)
    assert lexer.pop(Tokens::BeginBlk)
    assert foo = lexer.pop(Tokens::NotesBlk)
    assert "NOTES", foo.value
  end

 def test_LabelsBlk
  lexer = Lexer.new("
    LABELS;
      CHARGROUPLABEL MM_Genitalia COLOR = (RGB 1.0 0.4 0.4) ;
      CHARGROUPLABEL Somatic COLOR = (RGB 0.6 1.0 0.33333333) ;
      CHARGROUPLABEL Spinnerets COLOR = (RGB 0.46666667 0.57254902 1.0) ;
      CHARGROUPLABEL Behavior COLOR = (RGB 1.0 0.46666667 1.0) ;


    END;

  BEGIN some other block;")
  
    assert foo = lexer.pop(Tokens::LabelsBlk)
    assert_equal 'LABELS', foo.value.slice(0,6)
    assert_equal 'END;', foo.value.slice(-4,4)
  end

 def test_SetsBlk
  lexer = Lexer.new("
        SETS;
    CHARPARTITION * UNTITLED  =  Somatic :  1 -  2 4, MM_Genitalia :  5 -  8 10;

    END;
  BEGIN some other block;")
  
    assert foo = lexer.pop(Tokens::SetsBlk)
    assert_equal 'SETS', foo.value.slice(0,4)
    assert_equal 'END;', foo.value.slice(-4,4)
  end



  def test_lexer_errors
    lexer = Lexer.new("*&")
    assert_raise(ParseError) {lexer.peek(Tokens::ID)}
  end
end


class Test_Parser < Test::Unit::TestCase
  def setup
    # a Mesquite 2.n or higher file
    @nf = File.read('MX_test_03.nex') # MX_test_01.nex
  end

  def teardown
    @nf = nil
  end

  def test_that_file_might_be_nexus
    begin
      assert !parse_nexus_file("#Nexblux Begin Natrix end;")
    rescue ParseError 
      assert true
    end
  end

  def test_parse_initializes
     foo = parse_nexus_file(@nf)   
  end

  def test_parse_file
    # this is the major loop, all parts should exist
    foo = parse_nexus_file(@nf)

    assert_equal 10, foo.taxa.size
    assert_equal 10, foo.characters.size
    assert_equal 10, foo.codings.size 

    assert_equal 1, foo.taxa[1].notes.size # asserts that notes are parsing
  
  
    assert_equal "norm", foo.characters[0].states["0"].name
    assert_equal "modified", foo.characters[0].states["1"].name

  
  end

  def test_taxa_block
    # we've popped off the header already
    input = 
      "TITLE 'Scharff&Coddington_1997_Araneidae';
        DIMENSIONS NTAX=10;
        TAXLABELS
          Dictyna Uloborus Deinopis Nephila&Herennia 'Nephilengys_cruentata' Meta Leucauge_venusta Pachygnatha 'Theridiosoma_01' Tetragnatha 
        ;
        IDS JC1191fcddc2b128 JC1191fcddc2b129 JC1191fcddc2b130 JC1191fcddc2b131 JC1191fcddc2b132 JC1191fcddc2b133 JC1191fcddc2b134 JC1191fcddc2b135 JC1191fcddc2b137 JC1191fcddc2b136 ;
        BLOCKID JC1191fcddc0c4;
      END;"

    builder = NexusFileBuilder.new
    lexer = Lexer.new(input)
    Parser.new(lexer,builder).parse_taxa_blk
    foo = builder.nexus_file 

    assert_equal 10, foo.taxa.size
    assert_equal "Dictyna", foo.taxa[0].name
    assert_equal "Nephilengys_cruentata", foo.taxa[4].name
    assert_equal "Theridiosoma_01", foo.taxa[8].name
  end

  def test_parse_characters_blk
    input=  "
      TITLE  'Scharff&Coddington_1997_Araneidae';
      DIMENSIONS  NCHAR=10;
      FORMAT DATATYPE = STANDARD GAP = - MISSING = ? SYMBOLS = \"  0 1 2 3 4 5 6 7 8 9 A\";
      CHARSTATELABELS 
        1 Tibia_II /  norm modified, 2 TII_macrosetae /  '= TI' stronger, 3 Femoral_tuber /  abs pres 'm-setae', 5 Cymbium /  dorsal mesal lateral, 6 Paracymbium /  abs pres, 7 Globular_tegulum /  abs pres, 8  /  entire w_lobe, 9 Conductor_wraps_embolus, 10 Median_apophysis /  pres abs; 
      MATRIX
      Dictyna                0?00201001
      Uloborus               0?11000000
      Deinopis               0?01002???
      Nephila&Herennia       0?21010011
      'Nephilengys_cruentata'0?(0,1)1010(0,1,2)11
      Meta                   0?01A10011
      Leucauge_venusta       ???--?-??-
      Pachygnatha            0?210(0,1)0011
      'Theridiosoma_01'      ??????????
      Tetragnatha            0?01011011

    ;
      IDS JC1191fcddc3b425 JC1191fcddc3b426 JC1191fcddc3b427 JC1191fcddc3b428 JC1191fcddc3b429 JC1191fcddc3b430 JC1191fcddc3b431 JC1191fcddc3b432 JC1191fcddc3b433 JC1191fcddc3b434 ;
      BLOCKID JC1191fcddc0c0;

    END;"

    builder = NexusFileBuilder.new
    @lexer = Lexer.new(input)

    # add the taxa, assumes we have them for comparison purposes, though we (shouldn't) ultimately need them
    # foo.taxa = ["Dictyna", "Uloborus", "Deinopis", "Nephila&Herennia", "Nephilenygys_cruentata", "Meta", "Leucauge_venusta", "Pachygnatha", "Theridiosoma_01", "Tetragnatha"]

    # stub the taxa, they would otherwise get added in dimensions or taxa block
    (0..9).each{|i| builder.stub_taxon}

    Parser.new(@lexer,builder).parse_characters_blk
    foo = builder.nexus_file 
    
    assert_equal 10, foo.characters.size
    assert_equal "Tibia_II", foo.characters[0].name 
    assert_equal "TII_macrosetae", foo.characters[1].name

    assert_equal "norm", foo.characters[0].states["0"].name
    assert_equal "modified", foo.characters[0].states["1"].name


    # ?!!?
    # foo.characters[0].states["1"].name
    assert_equal ["", "abs", "pres"], foo.characters[9].states.keys.collect{|s| foo.characters[9].states[s].name}.sort


    assert_equal ["0","1"], foo.codings[7][5].states
    assert_equal ["?"], foo.codings[9][1].states
    assert_equal ["-", "0", "1", "2", "A"], foo.characters[4].state_labels
    
  end

  def test_characters_block_from_file
    foo = parse_nexus_file(@nf)
    assert 10, foo.characters.size
  end

  def test_codings
    foo = parse_nexus_file(@nf)
    assert 100, foo.codings.size  # two multistates count in single cells
  end

  def test_parse_dimensions
    input= 	" DIMENSIONS  NCHAR=10 ntaxa =10 nfoo='999' nbar = \" a b c  \" blorf=2;  " 
    builder = NexusFileBuilder.new
    lexer = Lexer.new(input)

    Parser.new(lexer,builder).parse_dimensions
    foo = builder.nexus_file 

    assert_equal "10", foo.vars[:nchar]
    assert_equal "10", foo.vars[:ntaxa]
    assert_equal "999", foo.vars[:nfoo]
    assert_equal 'a b c', foo.vars[:nbar]
    assert_equal '2', foo.vars[:blorf]
    # add test that nothing is left in lexer
  end

  def test_parse_format
    input= 	"FORMAT DATATYPE = STANDARD GAP = - MISSING = ? SYMBOLS = \"  0 1 2 3 4 5 6 7 8 9 A\";"
    builder = NexusFileBuilder.new
    lexer = Lexer.new(input)

    Parser.new(lexer,builder).parse_format
    foo = builder.nexus_file 

    assert_equal "STANDARD", foo.vars[:datatype]
    assert_equal "-", foo.vars[:gap]
    assert_equal "?", foo.vars[:missing]
    assert_equal '0 1 2 3 4 5 6 7 8 9 A', foo.vars[:symbols]
    # add test that nothing is left in lexer
  end

  def test_parse_chr_state_labels
    input =" CHARSTATELABELS
    1 Tibia_II /  norm modified, 2 TII_macrosetae /  '= TI' stronger, 3 Femoral_tuber /  abs pres 'm-setae', 5 Cymbium /  dorsal mesal lateral, 6 Paracymbium /  abs pres, 7 Globular_tegulum /  abs pres, 8  /  entire w_lobe, 9 Conductor_wraps_embolus, 10 Median_apophysis /  pres abs ;
    MATRIX
    fooo 01 more stuff here that should not be hit"
    
    builder = NexusFileBuilder.new
    lexer = Lexer.new(input)
    
    (0..9).each{builder.stub_chr()}
    
    Parser.new(lexer,builder).parse_chr_state_labels

    foo = builder.nexus_file 
    assert_equal 10, foo.characters.size
    assert_equal "Tibia_II", foo.characters[0].name
    assert_equal "norm", foo.characters[0].states["0"].name
    assert_equal "modified", foo.characters[0].states["1"].name

    assert_equal "TII_macrosetae", foo.characters[1].name
    assert_equal "= TI", foo.characters[1].states["0"].name
    assert_equal "stronger", foo.characters[1].states["1"].name

    assert_equal "Femoral_tuber", foo.characters[2].name
    assert_equal "abs", foo.characters[2].states["0"].name
    assert_equal "pres", foo.characters[2].states["1"].name
    assert_equal "m-setae", foo.characters[2].states["2"].name

    assert_equal "Undefined", foo.characters[3].name
    assert_equal 0, foo.characters[3].states.keys.size

    assert_equal "Cymbium", foo.characters[4].name
    assert_equal "dorsal", foo.characters[4].states["0"].name
    assert_equal "mesal", foo.characters[4].states["1"].name
    assert_equal "lateral", foo.characters[4].states["2"].name
    
    assert_equal "Paracymbium", foo.characters[5].name
    assert_equal "abs", foo.characters[5].states["0"].name
    assert_equal "pres", foo.characters[5].states["1"].name

    assert_equal "Globular_tegulum", foo.characters[6].name
    assert_equal "abs", foo.characters[6].states["0"].name
    assert_equal "pres", foo.characters[6].states["1"].name

    assert_equal "Undefined", foo.characters[7].name
    assert_equal "entire", foo.characters[7].states["0"].name
    assert_equal "w_lobe", foo.characters[7].states["1"].name

    # ...

    assert_equal "Median_apophysis", foo.characters[9].name
    assert_equal "pres", foo.characters[9].states["0"].name
    assert_equal "abs", foo.characters[9].states["1"].name

  end

  def test_parse_notes_blk
   input ="
      TEXT  TAXA = 'Scharff&Coddington_1997_Araneidae' TAXON = 2 TEXT = 'This is a footnote to taxon 2, Uloborus';

      TEXT   TAXON = 4 CHARACTER = 8 TEXT = This_is_a_footnote_to_a_cell.;

      TEXT   CHARACTER = 10 TEXT = This_is_footnote_to_char_10;

      TEXT  FILE TEXT = 'Scharff, N. and J. A. Coddington. 1997. A phylogenetic analysis of the orb-weaving spider family Araneidae (Arachnida, Araneae). Zool. J. Linn. Soc. 120(4): 355?434';

      AN T = 4  A = JC DC = 2008.4.13.20.31.19 DM = 2008.4.13.20.31.38 ID = 01194a57d0161 I = _ TF = (CM 'This is an \"annotation\" to taxon 4') ;

      AN C = 4  A = JC DC = 2008.4.13.20.31.50 DM = 2008.4.13.20.32.10 ID = 01194a584b9f2 I = _ TF = (CM 'This is an annotation to charcter 4, that has no name.') ;

      AN T = 9 C = 3  A = 0 DC = 2008.4.20.17.24.36 DM = 2008.4.20.17.25.4 ID = 01196db963874 I = _ TF = (CM 'This is an annotation to chr 3, taxa 9, coded ?') ;

      AN T = 2 C = 6  A = JC DC = 2008.4.13.20.35.20 DM = 2008.4.13.20.35.36 ID = JC1194a5b7e1a3 I = _ TF = (CM 'This is an annotation that haa a hard return in it^n^n^n^nSo there!') ;

      AN T = 7 C = 10  A = 0 DC = 2008.4.20.17.25.11 DM = 2008.4.20.17.26.1 ID = 01196db9ebd25 I = _ TF = (CM 'this is an annotation^nwith several hard returns^nfor a cell of taxa 6, chr 9 (from zero)^ncoded as -') ; 
    
      AN T = 2 C = 6  A = JC DC = 2008.4.13.20.35.20 DM = 2008.4.13.20.35.36 ID = JC1194a5b7e1a3 I = _ TF = (CM 'This is an annotation that haa a hard return in it^n^n^n^nSo there!') ;

    END; Don't parse this bit, eh?"
        
    # note the second last note note embedds parens in the balue
   
    builder = NexusFileBuilder.new
    lexer = Lexer.new(input)
    
    # stubs
    (0..9).each{builder.stub_chr()}
    (0..9).each{builder.stub_taxon()}
    

    builder.nexus_file.codings[3] = []  # need to use the hash factory here
    builder.nexus_file.codings[3][7] = NexusFile::Coding.new()

    builder.nexus_file.codings[8] = []  # need to use the hash factory here
    builder.nexus_file.codings[8][2] = NexusFile::Coding.new()
 
    builder.nexus_file.codings[1] = []
    builder.nexus_file.codings[1][5] = NexusFile::Coding.new()
    
    builder.nexus_file.codings[6] = []    
    builder.nexus_file.codings[6][9] = NexusFile::Coding.new()

    Parser.new(lexer,builder).parse_notes_blk

    foo = builder.nexus_file 
    
    # make sure stubs 
    assert_equal 10, foo.characters.size
    assert_equal 10, foo.characters.size

    assert_equal 1, foo.taxa[1].notes.size
    assert_equal 1, foo.codings[3][7].notes.size
    assert_equal 'This_is_a_footnote_to_a_cell.', foo.codings[3][7].notes[0].note
    
    assert_equal 1, foo.characters[9].notes.size
    assert_equal 'This_is_footnote_to_char_10', foo.characters[9].notes[0].note

    assert_equal 1, foo.notes.size
    assert_equal 'Scharff, N. and J. A. Coddington. 1997. A phylogenetic analysis of the orb-weaving spider family Araneidae (Arachnida, Araneae). Zool. J. Linn. Soc. 120(4): 355?434', foo.notes[0].note

    assert_equal 1, foo.taxa[3].notes.size
    assert_equal 1, foo.characters[3].notes.size
    assert_equal 1, foo.codings[8][2].notes.size
    assert_equal 1, foo.codings[1][5].notes.size
    assert_equal 1, foo.codings[6][9].notes.size
  end


  def test_parse_trees_block
  end

  def test_parse_labels_block
  end

  def test_parse_sets_block
  end

  def test_parse_assumptions_block
  end

end

