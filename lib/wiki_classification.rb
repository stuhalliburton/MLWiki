require 'wiki_classification/version'
require 'open-uri'
require 'nokogiri'
require 'redis'

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

  def self.classify_wo_exclusion(url)
    doc = Nokogiri::HTML(open(url))

    word_hash = Hash.new(0)

    doc.xpath('//div[@id="mw-content-text"]/p').each do |tag|
      words = tag.text.downcase.strip.scan(/[a-z'-]+/i)
      words.each do |word|
        word_hash[word] += 1
      end
    end

    word_frequency = word_hash.sort_by{|_key, val| val}.reverse!

    return Words.new(word_frequency)
  end

  def self.combine(*args)
    word_hash = Hash.new(0)

    args.each do |words|
      words.word_frequency.each do |word, freq|
        word_hash[word] += freq
      end
    end

    word_frequency = word_hash.sort_by{|_key, val| val}.reverse!

    return Words.new(word_frequency)
  end


  EXCLUDED_WORDS = %w(the of to in and was that for on as with by had at an it from has is be have which who not said been would also but this before up were then its into when however did while they than them are their or there you where so whether we even went any don't want should could would me do if more all after only like many most can other over under some such these no yes same just use using th very about he she his hers him her my what yet another)

  def self.classify(url, name: nil)
    doc = Nokogiri::HTML(open(url))

    word_hash = Hash.new(0)

    doc.xpath('//div[@id="mw-content-text"]/p').each do |tag|
      words = tag.text.downcase.strip.scan(/[a-z'-]+/i).select{ |word| word.length > 1 }
      words.each do |word|
        word_hash[word] += 1 unless EXCLUDED_WORDS.include?(word)
      end
    end

    word_frequency = word_hash.sort_by{|_key, val| val}.reverse!

    return Words.new(word_frequency, name: name)
  end

  def self.sim_pearsons(a, b)

    common_words = a.top_relevant.map{|w| w[0]} & b.top_relevant.map{|w| w[0]}

    return 0 if common_words.size.zero?

    sum_a = begin
      common_words.map do |word|
        a.top_relevant.detect{ |w| w[0] == word }.last
      end.inject(:+)
    end

    sum_b = begin
      common_words.map do |word|
        b.top_relevant.detect{ |w| w[0] == word }.last
      end.inject(:+)
    end

    sum_a_sq = begin
      common_words.map do |word|
        a.top_relevant.detect{ |w| w[0] == word }.last**2
      end.inject(:+)
    end

    sum_b_sq = begin
      common_words.map do |word|
        b.top_relevant.detect{ |w| w[0] == word }.last**2
      end.inject(:+)
    end

    product_sum = begin
      common_words.map do |word|
        a.top_relevant.detect{ |w| w[0] == word }.last *
        b.top_relevant.detect{ |w| w[0] == word }.last
      end.inject(:+)
    end

    num = product_sum - ((sum_a * sum_b)/common_words.size)

    den = Math.sqrt(
      (sum_a_sq - ((sum_a**2)/common_words.size)) *
      (sum_b_sq - ((sum_b**2)/common_words.size))
    )

    den.zero? ? 0 : (num/den)
  end

  def self.most_like(person, *others)
    sim = []
    others.map do |other|
      sim << [other.name, Wiki.sim_pearsons(person, other)]
    end
    sim.sort_by{ |other| other.last }.reverse!
  end
end

blair = Wiki.classify('http://en.wikipedia.org/wiki/Tony_Blair', name: 'blair')
cameron = Wiki.classify('http://en.wikipedia.org/wiki/David_Cameron', name: 'cameron')
bush = Wiki.classify('http://en.wikipedia.org/wiki/George_W._Bush', name: 'bush')
dylan = Wiki.classify('http://en.wikipedia.org/wiki/Bob_Dylan', name: 'dylan')
sinatra = Wiki.classify('http://en.wikipedia.org/wiki/Frank_Sinatra', name: 'sinatra')
spears = Wiki.classify('http://en.wikipedia.org/wiki/Britney_Spears', name: 'spears')
murray = Wiki.classify('http://en.wikipedia.org/wiki/Bill_Murray', name: 'murray')
spacey = Wiki.classify('http://en.wikipedia.org/wiki/Kevin_Spacey', name: 'spacey')
liu = Wiki.classify('http://en.wikipedia.org/wiki/Lucy_Liu', name: 'liu')
ruby = Wiki.classify('http://en.wikipedia.org/wiki/Ruby_(programming_language)', name: 'ruby')
scala = Wiki.classify('http://en.wikipedia.org/wiki/Scala_(programming_language)', name: 'scala')
javascript = Wiki.classify('http://en.wikipedia.org/wiki/JavaScript', name: 'javascript')
tennis = Wiki.classify('http://en.wikipedia.org/wiki/Tennis', name: 'tennis')
basket_ball = Wiki.classify('http://en.wikipedia.org/wiki/Basketball', name: 'basket_ball')
volley_ball = Wiki.classify('http://en.wikipedia.org/wiki/Volleyball', name: 'volley_ball')


collection = [
  blair,
  cameron,
  bush,
  dylan,
  sinatra,
  spears,
  murray,
  spacey,
  liu,
  ruby,
  scala,
  javascript,
  tennis,
  basket_ball,
  volley_ball
]

collection.each do |item|
  puts item.name
  others = collection - [item]
  puts Wiki.most_like(item, *others).inspect
end

# comb = Wiki.combine(*collection).word_frequency
# puts comb[0..(comb.length*0.02)].map{|w| w[0]}.join(' ')
