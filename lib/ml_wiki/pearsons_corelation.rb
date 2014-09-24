module PearsonsCorelation
  def self.similarity(a, b)

    common_words = a.top_relevant.map{|w| w[0]} & b.top_relevant.map{|w| w[0]}

    return 0 if common_words.size.zero?

    sum_a = Thread.new do
      common_words.map do |word|
        a.top_relevant.detect{ |w| w[0] == word }.last
      end.inject(:+)
    end

    sum_b = Thread.new do
      common_words.map do |word|
        b.top_relevant.detect{ |w| w[0] == word }.last
      end.inject(:+)
    end

    sum_a_sq = Thread.new do
      common_words.map do |word|
        a.top_relevant.detect{ |w| w[0] == word }.last**2
      end.inject(:+)
    end

    sum_b_sq = Thread.new do
      common_words.map do |word|
        b.top_relevant.detect{ |w| w[0] == word }.last**2
      end.inject(:+)
    end

    product_sum = Thread.new do
      common_words.map do |word|
        a.top_relevant.detect{ |w| w[0] == word }.last *
        b.top_relevant.detect{ |w| w[0] == word }.last
      end.inject(:+)
    end

    n = common_words.size
    num = product_sum.value - ((sum_a.value * sum_b.value)/n)
    den = Math.sqrt(
      (sum_a_sq.value - ((sum_a.value**2)/n)) *
      (sum_b_sq.value - ((sum_b.value**2)/n))
    )

    begin
      num/den
    rescue ZeroDivisionError
      return 0
    end
  end
end
