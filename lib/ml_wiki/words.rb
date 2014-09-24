module Wiki
  class Words
    attr_reader :word_frequency, :name

    def initialize(word_frequency, name: nil)
      @name = name
      @word_frequency = word_frequency
    end

    def top_relevant
      # word_frequency[0..(word_frequency.length * 0.5).ceil]
      word_frequency
      # word_frequency.select{ |w, freq| freq > 4 }
    end
  end
end
