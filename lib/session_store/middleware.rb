require File.expand_path('../accessors', __FILE__)

module SessionStore
  class Middleware
    include Accessors
    BadRequest = Class.new(StandardError)

    def initialize(app)
      @app = app
    end

    def call(env)
      if env["PATH_INFO"] =~ /\/projects\/(\d+)\/session/
        dup._call(env)
      else
        @app.call(env)
      end
    end

    def _call(env)
      @env = env
      case env['PATH_INFO']
      when /\/projects\/(\d+)\/session$/                    then handle_session_request
      when /\/projects\/(\d+)\/session\/interact_mode$/     then handle_interact_mode_request
      when /\/projects\/(\d+)\/session\/current_selection$/ then handle_current_selection
      when /\/projects\/(\d+)\/session\/cart/               then handle_cart_request
      else [404, {"Content-Type" => "text/html", "X-Cascade" => "pass"}, ["Not Found"] ]
      end
    rescue BadRequest => exception
      [400, {"Content-Type" => "text/html"}, [ exception ] ]
    rescue => exception
      [500, {"Content-Type" => "text/html"}, [ exception ] ]
    end

    private

    def handle_session_request

      if request.get?
        [200, {"Content-Type" => "application/json"}, [*session_get(:projects, project_id).try(:to_json)]]
      else fail BadRequest, 'request method not supported'
      end
    end

    def handle_cart_request
  #      session = env['rack.session']
      case @env["PATH_INFO"]
      when /\/projects\/(\d+)\/session\/cart$/
        if request.get?
          [200, {"Content-Type" => "application/json"}, [*session_get(:projects, project_id, :cart).try(:to_json)]]
        elsif request['_method'] == 'delete'
      session_delete(:projects, project_id, :cart_index)
          session_delete(:projects, project_id, :cart)
          [200, {}, []]
        elsif request.post? && request['_method'] == 'put'
          # add entry to cart and cart index - cart index should keep track of cart array location
          cart_loc = session_get(:projects, project_id, :cart_index, params[:type.to_s], params[:id.to_s], :loc)
          session_sub_cart = session_soft_set(:projects, project_id, :cart, params[:type.to_s], [])
          add_to_cart = { :id => params[:id.to_s], :label => params[:label.to_s] }
          cart_loc ? (session_sub_cart[cart_loc] = add_to_cart) : session_sub_cart.push(add_to_cart)
          cart_loc ||= session_sub_cart.size - 1

          session_set(:projects, project_id, :cart_index, params[:type.to_s], params[:id.to_s], { :label => params[:label.to_s], :loc => cart_loc })
          [200, {}, []]
        else fail BadRequest, 'request method not supported'
        end
      when /\/projects\/(\d+)\/session\/cart\/([\w:]+)$/
        if request['_method'] == 'delete'
          session_delete(:projects, project_id, :cart, $2)
          session_delete(:projects, project_id, :cart_index, $2)
          [200, {}, []]
         else fail BadRequest, 'request method not supported'
        end
      when /\/projects\/(\d+)\/session\/cart\/([\w:]+)\/(\d+)$/
        if request['_method'] == 'delete'
          cart_loc = session_get(:projects, project_id, :cart_index, $2, $3, :loc)
          session_set(:projects, project_id, :cart, $2, cart_loc, nil) if cart_loc # can't remove from array as this will invalidate all stored locs
          session_delete(:projects, project_id, :cart_index, $2, $3)
          [200, {}, []]
        else
          fail BadRequest, 'request method not supported'
        end
      end
    end

    def handle_current_selection
      if request.get?
        [200, {"Content-Type" => "application/json"}, [*session_get(:projects, project_id, :current_selection).try(:to_json)] ]
      elsif request['_method'] == 'put' # &&  env["PATH_INFO"] =~ /^\/projects\/(\d+)\/session\/current_selection$/
        case params['group']
        when "true" then
          session_set(:projects, project_id, :current_selection, { :group => true, :type => params['type'], :label => params['label']})
        else
          session_set(:projects, project_id, :current_selection, { :type => params['type'], :id => params['id'], :label => params['label'] })
        end
        [200, {}, []]
      elsif request['_method'] == 'delete' # && env["PATH_INFO"] =~ /^\/projects\/(\d+)\/session\/current_selection$/
        session_set(:projects, project_id, :current_selection, nil)
        [200, {}, []]
      else fail BadRequest, 'request method not supported'
      end
    end

    def handle_interact_mode_request
      if request.get? #&& env["PATH_INFO"] =~ /^\/projects\/(\d+)\/session\/interact_mode$/
        session_soft_set(:projects, project_id, :interact_mode, 'browse')
        [200, {"Content-Type" => "text/html"}, [*session_get(:projects, project_id, :interact_mode).try(:to_json)]]
      elsif request['_method'] == 'put'
        case params['interact_mode']
        when 'browse', 'edit' then session_set(:projects, project_id, :interact_mode, params['interact_mode']) && [200, {}, []]
        else fail BadRequest, "interaction mode can only be set to 'browse' or 'edit'"
        end
      else fail BadRequest, 'request method not supported'
      end
    end

    def request

      Rack::Request.new(@env)
    end

    def project_id
      @project_id ||= @env['PATH_INFO'].match(/projects\/(\d+)/)[1].to_i
    end

    def params
      request.params
    end

    def session
      @env['rack.session']
    end
  end
end
