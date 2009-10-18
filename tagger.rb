module Tagger
  @lexicon = {}
  file = File.new(File.dirname(__FILE__)+'/lexicon.txt', 'r')
  file.each_line do |line|
    toks=line.split
    @lexicon[toks.shift] = toks
  end

  file.close

  def self.lexicon
    @lexicon
  end
end

class String
  def tokenize
    split(/ |,|\.|\:|\;|\'/) #'
  end

  def tags
    text = dup.tokenize

    ret = []

    text.each do |w|
      ret << (Tagger.lexicon[w] && Tagger.lexicon[w][0]) ||
      (Tagger.lexicon[w.downcase] && words[w.downcase][0]) ||
        'NN'
    end

    ## Now, apply transformational rules:
    text.length.times do |i|

      ## rule 1: DT, {VBD | VBP} --> DT, NN
      if i > 0 then
        if ret[i - 1] == "DT" then
          if ret[i] == "VBD" or ret[i] == "VBP" or ret[i] == "VB" then
            ret[i] = "NN"
          end
        end
      end

      ## rule 2: convert a noun to a number (CD) if "." appears in the word
      if ret[i] =~ /^N/ then
        if text[i] =~ /\./ then
          ret[i] = "CD"
        end
      end

      ## rule 3: convert a noun to a past participle if words[i] ends
      ## with "ed"
      if ret[i] =~ /^N/ && text[i] =~ /ed$/ then
        ret[i] = "VBN"
      end

      ## rule 4: convert any type to adverb if it ends in "ly"
      if text[i] =~ /ly$/ then
        ret[i] = "RB"
      end

      ## rule 5: convert a common noun (NN or NNS) to a adjective if
      ## it ends with "al"
      if ret[i] =~ /^NN/ && text[i] =~ /al$/ then
        ret[i] = "JJ"
      end

      ## rule 6: convert a noun to a verb if the preceeding work is "would"
      if i > 0 then
        if ret[i] =~ /^NN/ then
          if text[i-1].downcase == "would" then
            ret[i] = "VB"
          end
        end
      end

      ## rule 7: if a word has been categorized as a common noun and
      ## it ends with "s", then set its type to plural common noun (NNS)
      if ret[i] == "NN" && text[i] =~ /s$/ then
        ret[i] = "NNS"
      end

      ## rule 8: convert a common noun to a present participle
      ## verb (i.e., a gerand)
      if ret[i] =~ /^NN/ && text[i] =~ /ing$/ then
        ret[i] = "VBG"
      end

      ## rule 9: <noun> <noun 2> --> <noun> <verb> if <noun 2>
      ## can also be a verb
      if i > 0  then
        if ( ( ret[i-1] =~ /^NN/ ) && ( ret[i] =~ /^NN/ ) )  then
          if Tagger.lexicon[text[i]].include?("VBN")  then
            ret[i] = "VBN"
          end
          if Tagger.lexicon[text[i]].include?("VBZ") then
            ret[i] = "VBZ"
          end
        end
      end

   end
   return ret
  end
end
