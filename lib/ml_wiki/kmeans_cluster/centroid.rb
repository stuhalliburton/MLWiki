module Wiki
  module KMeansCluster
    class Centroid

      attr_reader :id, :items

      def initialize(data, min_words: , max_words: , min_freq: , max_freq: , id: 0)
        @data = data
        @min_words = min_words
        @max_words = max_words
        @min_freq = min_freq
        @max_freq = max_freq
        @id = id

        @data_set = random_data_set
        @items = []
      end

      def average_data_set
        @data_set = Wiki.combine(*items)
      end

      def assign(item)
        @items << item unless @items.include?(item)
      end

      def delete(item)
        @items.delete(item)
      end

      def top_relevant
        @data_set.top_relevant
      end

    private

      def random_data_set
        sample = @data.word_frequency.sample(rand_word_count)

        sample.map! do |word, freq|
          [word, rand_freq]
        end

        sample.sort_by!{ |_key, val| val }.reverse!

        return Words.new(sample, name: "Centroid #{@id}")
      end

      def rand_word_count
        (@min_words..@max_words).to_a.sample
      end

      def rand_freq
        (@min_freq..@max_freq).to_a.sample
      end
    end
  end
end
