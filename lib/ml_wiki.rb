require 'ml_wiki/version'
require 'ml_wiki/words'
require 'ml_wiki/excluded_words'
require 'ml_wiki/pearsons_corelation'
require 'ml_wiki/hcluster/hcluster'
require 'ml_wiki/hcluster/bicluster'
require 'open-uri'
require 'nokogiri'
# require 'redis'

module Wiki

  def self.combine(*args)
    word_hash = Hash.new(0)
    combined_name = []

    args.each do |words|
      combined_name << words.name
      words.top_relevant.each do |word, freq|
        word_hash[word] += freq
      end
    end

    word_frequency = word_hash.sort_by{|_key, val| val}.reverse!

    return Words.new(word_frequency, name: combined_name.join('_'))
  end

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

  def self.most_like(person, *others)
    sim = []
    others.map do |other|
      sim << [other.name, PearsonsCorelation.similarity(person, other)]
    end
    sim.sort_by!{ |other| other.last }
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
basketball = Wiki.classify('http://en.wikipedia.org/wiki/Basketball', name: 'basketball')
volleyball = Wiki.classify('http://en.wikipedia.org/wiki/Volleyball', name: 'volleyball')


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
  basketball,
  volleyball
]


def print_cluster(cluster, n: 0)
  puts (n>0 ? '    '*(n-1) : '') + (n>0 ? '+---' : '') + '+' + cluster.name
  return unless cluster.left || cluster.right
  # puts '|   '*n + '|'
  print_cluster(cluster.left, n: n+1)
  print_cluster(cluster.right, n: n+1)
end

print_cluster(Wiki::HCluster.cluster(collection))
