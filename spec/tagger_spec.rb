require File.dirname(__FILE__)+'/../tagger'

describe Tagger, "lexicon" do
  it "should be a hash" do
    Tagger.lexicon.should be_kind_of(Hash)
  end

  it "should not be empty" do
    Tagger.lexicon.should_not have(0).items
  end
end

describe String, ".tags" do
  it "should tag a simple noun" do
    "bank".tags.should == ["NN"]
  end

  it "should tag a sentence" do
    "The dog bites the black cat last week.".tags.should ==
      ["DT", "NN", "VBZ", "DT", "JJ", "NN", "JJ", "NN"]
  end

  it "should tag two sentences" do
    "The bank gave Sam a loan last week. He can bank an airplane really well.".tags.should ==
      ["DT", "NN", "VBD", "NNP", "DT", "NN", "JJ", "NN", nil, "PRP", "MD", "NN", "DT", "NN", "RB", "RB"]
  end

  it "should not tag an empty string" do
    "".tags.should == []
  end
end

describe String, ".tokenize" do
  it "should tokenize a sentence" do
    "This is some text.".tokenize.should == ["This", "is", "some", "text"]
  end
end
