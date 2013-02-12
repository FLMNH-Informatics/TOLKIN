class Restful::Parser
  def parse params, param_type
    case param_type
      when :select     then parse_select(params[:select])
      when :limit      then parse_limit(params[:limit])
      when :include    then parse_include(params[:include])
      when :joins      then parse_joins(params[:joins])
      when :conditions then parse_conditions(params[:conditions])
      when :order      then parse_order(params[:order])
      when :offset     then parse_offset(params[:offset])
      else fail("#{param_type} cannot be parsed")
    end
  end

  private

  def parse_joins input
    case input
    when String
      input.to_sym
    when Array
      input.collect{|j| j.kind_of?(String) && j.match(/^\w+$/) ? j.to_sym : j}
    else
      input
    end
  end

  def parse_select input
    input.kind_of?(String) ?
      (input.blank? ?
        nil :
        input.split(',').collect{ |item| item.strip.match(/^\[?["']?([\w\.\*]+)["']?\]?$/)[1] }
    ) :
      input
  end

  def parse_order input
    input.kind_of?(String) ?
      (input.blank? ? nil : input.match(/^\[?(.+?)\]?$/)[1].gsub(/["']/, '').split(',')) :
      input
  end

  def parse_offset input
    input.to_i
  end

  def parse_limit input
    input.to_i
  end

  # this main parse_conditions function breaks conditions apart on '+' symbol, and parses key, value, and negated flag
  def parse_conditions input
    if input.kind_of? String
      if input.blank?
        nil
      else
        out = nil
        input.split(/(?<=\])\+(?=%)/u).each do |cond|
          next if cond == 'true'
          if cond == 'false'
            out = "false"
            break
          end
          cond.match(/([\w,\-%\\\.\p{L}\+]+)\[([\^\w\.]+)\]/u) # u option forces utf-8
          k, v = $2, $1
          v = nil if v == 'null'
          negated = !!k.sub!('^', '')
          to_add = _parse_conditions(k, v, negated)
          out = out ? (out & to_add) : to_add
        end
        out
      end
    else
      input
    end
  end

  def _parse_conditions(column, value, negated)
    col_split = column.split('.')
    col_part = col_split.shift
    if col_split.empty?
      case
      when value && value.include?('%')
        ( column.to_sym =~ value ) # meta_where for like
      when value && value.include?(',')
        negated ? ( column.to_sym - value.split(',') ) : ( column.to_sym + value.split(',') ) # meta_where for either IN or NOT IN array
      else
        negated ? ( column.to_sym ^ value ) : { column.to_sym => value } # meta_where = or <>
      end
    # takes care of nested association conditions (by association name i think rather than table name?)
    else
      { col_part.to_sym => _parse_conditions(col_split.join('.'), value, negated) }
    end
    
  end

  def parse_include input
    out = input.kind_of?(String) ? _parse_include(input)[1] : input
    # out = _hashify_includes(out) # MetaWhere helps out here - not needed
    out
  end

  #  def _hashify_includes includes, out_includes = {}
  #    # convert hash include into array for processing composite include conditions
  #    if includes
  #      if includes.respond_to?(:each)
  #        includes.each do |k, v = nil|
  #          if(k.respond_to?(:each))
  #            _hashify_includes(k, out_includes)
  #          else out_includes[k] ||= {}
  #            _hashify_includes(v, out_includes[k])
  #          end
  #        end
  #      else
  #        out_includes[includes] ||= {}
  #      end
  #      out_includes
  #    end
  #  end

  def _parse_include input, construct = nil, key = nil
    until input.strip.empty?
      if input =~ /^\s*\{/
        new_construct = {}
        if construct
          key ? construct[key] = new_construct : construct << new_construct
        else
          construct = new_construct
        end
        $' =~ /^\s*["'](\w+)(.outer)?["']\s*:/
        new_key = $2 ? $1.to_sym.outer : $1.to_sym
        input = _parse_include($', new_construct, $1.to_sym)[0]
      elsif input =~ /^\s*\[/
        new_construct = []
        if construct
          key ? construct[key] = new_construct : construct << new_construct
        else
          construct = new_construct
        end
        input = _parse_include($', new_construct)[0]
      elsif input =~ /^\s*["']?([\w]+)(.outer)?["']?,?\s*/
        while input =~/^\s*["']?([\w]+)(.outer)?["']?,?\s*/
          construct ||= []
          key ?
            construct[key] = $2 ? $1.to_sym.outer : $1.to_sym :
            construct << ($2 ? $1.to_sym.outer : $1.to_sym)
          input = $'
        end
      elsif input =~ /^\s*[\]\}],?\s*/
        input = $'
        break
      end
    end
    [input, construct]
  end
end
