module PearsonsCorelation
  def self.similarity(a, b)

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

    den.zero? ? 0 : (1-(num/den))
  end
end
