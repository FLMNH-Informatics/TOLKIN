require 'will_paginate/collection'
class Array
  def all_with_index?
    each_with_index do |elem,i|
      return false unless yield elem,i
    end
    return true
  end

  def paginate(options = {})
    page = options[:page] || 1
    per_page = options[:per_page] || WillPaginate.per_page
    total = options[:total_entries] || self.length

    WillPaginate::Collection.create(page, per_page, total) do |pager|
      pager.replace self[pager.offset, pager.per_page].to_a
    end
  end
end
