module SprocketsHelper
  def sprockets_include_tag
    javascript_include_tag("/sprockets.js", concat: true)
  end
end
