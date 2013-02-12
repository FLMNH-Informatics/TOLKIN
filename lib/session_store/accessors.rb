module SessionStore
  module Accessors
    def current_project
      @current_project ||=
        ( project_id = params[:project_id]) ||
          (params[:controller] == 'projects' && (project_id = params[:id])
        ) ?
          Project.find(project_id, bypass_auth: true) :
          Project.tolkin_project
    end

    def session_get *path
      path.inject(session) do |memo, key|
        memo.try(:[], key)
      end
    end

    def session_set *path, value
      last_key = path.pop
      session_init_path(*path)[last_key] = value
    end

    def session_soft_set *path, value
      last_key = path.pop
      session_init_path(*path)[last_key] ||= value
    end

    def session_delete *path
      last_key = path.pop
      inner_hash = path.inject(session) do |memo, key|
        memo.try(:[], key)
      end
      inner_hash.try(:delete, last_key)
    end

    def project_id
      #if its a request to projects controller then project_id is actually id
      if params.has_key?(:controller) && params[:controller] == 'projects' && !params.has_key?(:project_id) && params.has_key?(:id)
        params[:project_id] = params[:id]
      end
      params[:project_id].to_i
    end

    def interact_mode
      @interact_mode ||= session_get(:projects, project_id, :interact_mode)
    end

    def interact_mode= value
      if(value == 'browse' || value == 'edit')
        session_set(:projects, project_id, :interact_mode, value)
      end
    end

    private

    def session_init_path *path
      path.inject(session) do |memo, key|
        memo[key] ||= {}
      end
    end
  end
end
