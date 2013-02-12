module Restful
  module Formatters
    class JsonFormatter
      def format data, options
        build data, options
      end

      private

      def build data, options, model_class = nil
        if data.nil?
          nil
        elsif data.respond_to?(:each)
          build_collection data, options, model_class || data.klass
        else
          build_entry data, options
        end
      end

      def build_collection collection, options, model_class
        { count: collection.scoped.count,
          limit: collection.scoped.limit_value,
          can_publify: model_class.public_model?,
          model_class.collection_name =>
            collection.collect do |member|
              build_entry member, options
            end
        }
      end

      def build_entry entry, options
        out = {}
        [*(options[:select]||'*')].each do |select|
          if select.to_s == '*'
            out.merge!(entry.attributes)
          elsif select.kind_of?(Hash)
            # only handles except right now
            [*select[:except]].each do |e|
              out.delete(e)
            end
          else
            out[select] = entry.send(select)
          end
        end
		process_include entry, options[:include], out
        out = { entry.class.member_name => out }
      end

      def process_include entry, include, out
        case include
        when Hash, Array
          include.each do |k, v = {}|
            case k
            when Hash
              process_include(entry, k, out)
            else
              out[k] = build(entry.send(k), v, entry.class.reflect_on_association(k.to_sym).klass) # respond_to? check to handle both hash and array
            end
          end
        when nil
        else # when Symbol, String, etc.
          out[include] =
            build(entry.send(include), {}, entry.class.reflect_on_association(include.to_sym).klass)
        end
      end
    end
  end
end
