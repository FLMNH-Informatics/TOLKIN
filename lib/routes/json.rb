module Routes
  module JSON
    PATHS_TO_ROUTES =
      Tolkin::Application.routes.named_routes.routes.values.inject({}) { |acc, route|
        loc =
          route.
            path[1..-1].
            sub(/\(\.:format\)$/, '').
#            gsub(/:/, '_'). # js will reject :\w+ as valid key
            split('/').
            #reject_with_index { |part, i| i % 2 == 1 }.
            inject(acc) { |acc2, part| acc2[part] ||= {} }
        loc[:controller] ||= route.defaults[:controller]
        loc[:action]     ||= route.defaults[:action] if ('GET' =~ route.conditions[:request_method])
        acc
      }.to_json

    CONTROLLERS_ACTIONS_TO_ROUTES =
      Tolkin::Application.routes.named_routes.routes.values.inject({}) { |acc, route|
#        if ('GET' =~ route.conditions[:request_method])
          (acc[route.defaults[:controller]] ||= {})[route.defaults[:action]] ||= {
            path: route.path
          }
#        end
        acc
      }.to_json

    PATHNAMES_TO_ROUTES =
      Tolkin::Application.routes.named_routes.routes.values.inject({}) { |hash, route|
        hash[route.name] = route.defaults.merge(path: route.path)
        hash
      }.to_json
  end
end