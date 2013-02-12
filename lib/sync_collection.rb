class SyncCollection
  include Restful::Mixins::ParamsForCollection

  attr_reader :type, :entries, :params, :size, :limit

  delegate :map, :to => :entries

  def initialize options
    @type = options[:type] || fail('no type given')
    @collection = options[:collection] || fail('no collection given')
  end

  #### START - used just for people list (anything using will_paginate)
  def total_pages
    @size/@limit
  end

  def current_page
    (@offset/@limit) + 1
  end

  def previous_page
    current_page - 1
  end

  def next_page
    current_page + 1
  end
  #### END

  def load params = {}
 
    @params = params.clone
    @limit = params[:limit]
#    if(@params[:page])
#      @entries = @collection.paginate(@params)
#    else
    if(@limit)
#      @collection = @collection.search(params[:search]) if params[:search]
      options = collection_initial_options @type
      relation =
        @collection.
          joins(  options[:joins]).
          select( options[:select]).
          order(  options[:order]).
          where(  options[:conditions])
      results = type.connection.select_values(relation.debug_sql).uniq
       #results = @collection.all_ids(collection_initial_options @type).uniq
      @size = results.size
      offset = params[:offset] || 0
      ids = results[offset,@limit] || [-1]
    else
      ids = nil
    end
    options = collection_limited_options(@type, ids)
    @entries =
      @collection.
        joins(  options[:joins]).
        select( options[:select]).
        order(  options[:order]).
        where(  options[:conditions]).
        all
      #all(collection_limited_options(@type, ids))
    @size ||= @entries.size # if size hasn't been set so far then set it
#    end
    self
  end

  def each &block
    @entries.each &block
  end

  def to_csv cols
     csv = CsvExporter::Export.export_to_csv(@entries, cols)
  end

  def to_json options
    if(options[:controller])
      Restful::JsonFormatter.new.format(self, options)
    else
      @entries.to_json(options)
    end
  end

#  def size
#    if @entries.respond_to?(:total_entries)
#      @entries.total_entries
#    else
#      @entries.size
#    end
#  end

  def empty?
    @size == 0
  end

  #private

  def parse_finder_params params
    params[:select] = params[:only] if params[:only]
    params[:page] = 1 unless params[:page]
    [ :conditions, :limit, :offset, :select, :include, :order ].each do |option| # run validator
      Restful::Option.new(params, option, @type) if params[option]
   end
    formatter = Restful::Finder::OptionFormatter.new(model_class: @type, collection: @collection)
    parsed, @collection = formatter.format(params)
    parsed
  end
end