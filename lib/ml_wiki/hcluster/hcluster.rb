module Wiki
  module HCluster

    def self.cluster(collection)
      cluster = []
      collection.each do |item|
        cluster << BiCluster.new(item)
      end

      while cluster.length > 1

        closeness = []
        cluster.each do |item|
          puts item.vec.name
          others = cluster - [item]
          sim = Wiki.most_like(item, *others)
          puts sim.inspect
          closeness << [item.name, sim.first]
        end

        closeness.sort_by!{ |name, score| score.last }

        puts ''
        puts '#################################'
        puts '### REDUCED CLUSTER CLOSENESS ###'
        puts closeness.inspect
        puts '#################################'
        puts ''

        distance = closeness[0..1].inject(0){ |total, val| total += val.last.last}/2
        left = cluster.detect{ |c| c.name == closeness[0].first }
        right = cluster.detect{ |c| c.name == closeness[1].first }
        combined = Wiki.combine(left, right)

        cluster << BiCluster.new(combined, left: cluster.delete(left), right: cluster.delete(right), distance: distance)
      end

      cluster.first
    end
  end
end
