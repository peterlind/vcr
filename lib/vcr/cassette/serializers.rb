module VCR
  class Cassette
    class Serializers
      autoload :YAML,  'vcr/cassette/serializers/yaml'
      autoload :Syck,  'vcr/cassette/serializers/syck'
      autoload :Psych, 'vcr/cassette/serializers/psych'
      autoload :JSON,  'vcr/cassette/serializers/json'

      def initialize
        @serializers = {}
      end

      def [](name)
        @serializers.fetch(name) do |_|
          @serializers[name] = case name
            when :yaml  then YAML
            when :syck  then Syck
            when :psych then Psych
            when :json  then JSON
            else raise ArgumentError.new("The requested VCR cassette serializer (#{name.inspect}) is not registered.")
          end
        end
      end

      def []=(name, value)
        if @serializers.has_key?(name)
          warn "WARNING: There is already a VCR cassette serializer registered for #{name.inspect}. Overriding it."
        end

        @serializers[name] = value
      end
    end
  end
end

