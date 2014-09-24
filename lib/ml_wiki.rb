require 'ml_wiki/version'
require 'ml_wiki/words'
require 'ml_wiki/excluded_words'
require 'ml_wiki/pearsons_corelation'
require 'ml_wiki/hcluster/hcluster'
require 'ml_wiki/hcluster/bicluster'
require 'ml_wiki/kmeans_cluster/kmeans_cluster'
require 'ml_wiki/kmeans_cluster/centroid'

require 'temp_pool'
require 'open-uri'
require 'nokogiri'
# require 'redis'
require 'benchmark'

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

  def self.word_count(url, name: nil)
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
    pool = TempPool::Pool.new(4)
    others.each do |other|
      pool.schedule{ [other.name, PearsonsCorelation.similarity(person, other)] }
    end
    pool.value.sort_by!{ |other| other.last }.reverse!
  end
end

blair = Thread.new do
  Wiki.word_count('http://en.wikipedia.org/wiki/Tony_Blair', name: 'blair')
end

cameron = Thread.new do
  Wiki.word_count('http://en.wikipedia.org/wiki/David_Cameron', name: 'cameron')
end

bush = Thread.new do
  Wiki.word_count('http://en.wikipedia.org/wiki/George_W._Bush', name: 'bush')
end

dylan = Thread.new do
  Wiki.word_count('http://en.wikipedia.org/wiki/Bob_Dylan', name: 'dylan')
end

sinatra = Thread.new do
  Wiki.word_count('http://en.wikipedia.org/wiki/Frank_Sinatra', name: 'sinatra')
end

spears = Thread.new do
  Wiki.word_count('http://en.wikipedia.org/wiki/Britney_Spears', name: 'spears')
end

murray = Thread.new do
  Wiki.word_count('http://en.wikipedia.org/wiki/Bill_Murray', name: 'murray')
end

spacey = Thread.new do
  Wiki.word_count('http://en.wikipedia.org/wiki/Kevin_Spacey', name: 'spacey')
end

liu = Thread.new do
  Wiki.word_count('http://en.wikipedia.org/wiki/Lucy_Liu', name: 'liu')
end

ruby = Thread.new do
  Wiki.word_count('http://en.wikipedia.org/wiki/Ruby_(programming_language)', name: 'ruby')
end

scala = Thread.new do
  Wiki.word_count('http://en.wikipedia.org/wiki/Scala_(programming_language)', name: 'scala')
end

javascript = Thread.new do
  Wiki.word_count('http://en.wikipedia.org/wiki/JavaScript', name: 'javascript')
end

tennis = Thread.new do
  Wiki.word_count('http://en.wikipedia.org/wiki/Tennis', name: 'tennis')
end

basketball = Thread.new do
  Wiki.word_count('http://en.wikipedia.org/wiki/Basketball', name: 'basketball')
end

volleyball = Thread.new do
  Wiki.word_count('http://en.wikipedia.org/wiki/Volleyball', name: 'volleyball')
end


collection = [
  blair.value,
  cameron.value,
  bush.value,
  dylan.value,
  sinatra.value,
  spears.value,
  murray.value,
  spacey.value,
  liu.value,
  ruby.value,
  scala.value,
  javascript.value,
  tennis.value,
  basketball.value,
  volleyball.value
]

def print_cluster(cluster, n: 0)
  puts '    '*n + '-' + cluster.name
  return unless cluster.left || cluster.right
  print_cluster(cluster.left, n: n+1)
  print_cluster(cluster.right, n: n+1)
end

# Benchmark.bm do |x|
#   x.report { print_cluster(Wiki::HCluster.cluster(collection)) }
# end

Benchmark.bm do |x|
  x.report { Wiki::KMeansCluster.cluster(collection, k: 5) }
end



exit

