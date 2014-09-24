module Wiki
  module KMeansCluster
    def self.cluster(collection, k: 4)
      max_words = 0
      min_words = 1_000_000
      max_freq = 0
      min_freq = 1_000_000

      collection.each do |item|
        count = item.word_frequency.count

        max_words = count if count > max_words
        min_words = count if count < min_words
      end

      collection.each do |item|
        max = item.word_frequency.first[1]
        max_freq = max if max > max_freq
        min = item.word_frequency.last[1]
        min_freq = min if min < min_freq
      end

      combined_data = Wiki.combine(*collection)

      centroids = []
      (1..k).each do |n|
        centroids << Centroid.new(combined_data, min_words: min_words, max_words: max_words, min_freq: min_freq, max_freq: max_freq, id: n)
      end

      100.times do |n|
        puts "Iteration #{n}"

        last_iteration = centroids.map do |c|
          [c.id, c.items.map(&:name)]
        end

        collection.each do |item|
          best_match = centroids.map do |c|
            [c, PearsonsCorelation.similarity(c, item)]
          end.sort_by!{|c, sim| sim }.reverse!.first[0]

          last = centroids.detect{ |c| c.items.include?(item) }
          last.delete(item) if last
          best_match.assign(item)
        end

        current_iteration = centroids.map do |c|
          [c.id, c.items.map(&:name)]
        end

        puts last_iteration.inspect
        puts current_iteration.inspect

        break if last_iteration == current_iteration

        centroids.each do |c|
          c.average_data_set
        end
      end
    end
  end
end
