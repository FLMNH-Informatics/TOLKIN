module ActiveRecord
  class Base
    after_initialize :sanitize_attributes
    #before_save :sanitize_attributes

    def quoted_attribute att_name
      quote_value(send(att_name), column_for_attribute(att_name))
    end

    def tolkin_url
      write_attribute(:tolkin_url,self.actual_url)
      read_attribute(:tolkin_url)
    end

    def actual_url
      'http://app.tolkin.org/projects/' + self.project.project_id.to_s + '/' + self.class.to_s.downcase.pluralize.gsub(/::/,'/') + '/' + self.id.to_s
    end

    def sanitize_attributes
      self.attributes.each do |att|
        #self[att.first] = self[att.first].gsub(/\<script\>/,'&lt;script&gt;').gsub(/\<script\\\>/,'&lt;/script&gt') if self[att.first].is_a? String
        if self[att.first].is_a? String
          self[att.first] = self[att.first].gsub(/\</,'&lt;').gsub(/>/,'&gt;')
          self[att.first] = self[att.first]
          .gsub('&lt;i&gt;','<i>')
          .gsub('&lt;/i&gt;','</i>')
          .gsub('&lt;i/&gt;', '<i/>')
          .gsub('&lt;I&gt;','<i>')
          .gsub('&lt;/I&gt;','</i>')
          .gsub('&lt;I/&gt;', '<i/>')
          .gsub('&lt;/br&gt;', '</br>')
          .gsub('&lt;/BR&gt;', '</br>')
          .gsub('&lt;/Br&gt;', '</br>')
          .gsub('&lt;/bR&gt;', '</br>')
          .gsub('&lt;br/&gt;', '</br>')
          .gsub('&lt;BR/&gt;', '</br>')
          .gsub('&lt;Br/&gt;', '</br>')
          .gsub('&lt;bR/&gt;', '</br>')
        end
      end
    end
  end
end
