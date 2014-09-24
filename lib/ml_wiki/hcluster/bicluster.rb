module Wiki
  module HCluster
    class BiCluster
      attr_reader :vec, :left, :right, :distance, :id

      def initialize(vec, left: nil, right: nil, distance: 0.0)
        @vec = vec
        @left = left
        @right = right
        @distance = distance
      end

      def name
        vec.name
      end

      def top_relevant
        vec.top_relevant
      end
    end
  end
end
