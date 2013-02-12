class Admin::ProjectsController < ApplicationController

  before_filter :requires_admin, :only => [ :create ]
  before_filter :requires_project_manager

  def index
    @projects =  current_user.projects
  end

  def new

  end

  def create
    begin
     Basic::Project.create_project_framework(params)
    rescue => e
      @msg = 'something went wrong: '+ e.message
    end

    redirect_to :action => :index
  end

  def show
    @project = Basic::Project.find(params[:id])
  end

  def update
    @project = Basic::Project.find(params[:id])
    @project.label = params[:label]
    @project.public = params[:public] === 'on' ? true : false
    @project.website = params[:website]
    @project.save!
    redirect_to :action => :index
  end
    #make permissions for each role and permission set combo

=begin      Basic::Project.find_by_sql "INSERT INTO project_default_permission_sets (project_rtid,permission_set_rtid) VALUES (#{t.rtid},345)"
      #add permission sets
      ['Manager','Updater','Guest','Public'].each do |role|


        rid = Basic::Role.find_by_sql %{ INSERT INTO roles (owner_user_rtid,owner_record_rtid,owner_graph_rtid,owner_permission_set_rtid,creator_rtid,created_at,updater_rtid,updated_at,label)
                                    VALUES (10,1,#{t.rtid},345,10,now(),10,now(),'#{role}') RETURNING role_id }
        arole = Basic::Role.find(rid[0]['role_id'].to_i)
        arole.owner_record_rtid = arole.rtid
        arole.save!


      end

      pset = nil
      ['Delete (project members can edit/delete)', 'Edit (manager delete only)', 'View (manager edit/delete only)', nil ].each do |r|

        psid = Basic::PermissionSet.find_by_sql %{ INSERT INTO permission_sets (owner_user_rtid, owner_record_rtid, owner_graph_rtid, owner_permission_set_rtid, creator_rtid, created_at, updater_rtid, updated_at, label)
                     VALUES (10,1,#{t.rtid},1,10,now(),10,now(),'#{r}') RETURNING permission_set_id }

        pset = Basic::PermissionSet.find(psid[0]['permission_set_id'].to_i)
        pset.owner_record_rtid = pset.rtid
        pset.owner_permission_set_rtid = pset.rtid
        pset.save!
        #now make the View permission set for the project the owner permission set of the project
        #and make owner of roles
        if r == 'View (manager edit/delete only)'
          t.owner_permission_set_rtid = pset.rtid
          #perm_pset_rtid = pset.rtid
          t.save!

        end

        if r == 'Delete (project members can edit/delete)'
          Basic::Project.find_by_sql "INSERT INTO project_default_permission_sets (project_rtid,permission_set_rtid) VALUES (#{t.rtid},#{pset.rtid})"
        end

        ['Manager','Updater','Guest','Public'].each do |role|


          rid = Basic::Role.find_by_sql %{ INSERT INTO roles (owner_user_rtid,owner_record_rtid,owner_graph_rtid,owner_permission_set_rtid,creator_rtid,created_at,updater_rtid,updated_at,label)
                              VALUES (10,1,#{t.rtid},#{pset.rtid},10,now(),10,now(),'#{role}') RETURNING role_id }
          arole = Basic::Role.find(rid[0]['role_id'].to_i)
          arole.owner_record_rtid = arole.rtid
          arole.save!

          #make permissions for each role and permission set combo
          [{:visible => true, :editable => true, :deletable => true, :permissible => true},
           {:visible => true, :editable => true, :deletable => true, :permissible => false},
           {:visible => true, :editable => true, :deletable => false, :permissible => false},
           {:visible => true, :editable => false, :deletable => false, :permissible => false}].each do |group|

            pid = Basic::Permission.find_by_sql %{ INSERT INTO permissions (role_rtid,permission_set_rtid,owner_user_rtid,owner_record_rtid,owner_graph_rtid,owner_permission_set_rtid,
                                        creator_rtid, created_at, updater_rtid, updated_at, visible, editable, deletable, permissible)
                                       VALUES (#{arole.rtid},#{pset.rtid},10,1,#{t.rtid},#{pset.rtid},10,now(),10,now(),#{group[:visible]},#{group[:editable]},#{group[:deletable]},#{group[:permissible]})
                                       RETURNING permission_id }

            perm = Basic::Permission.find(pid[0]['permission_id'])
            perm.owner_record_rtid = perm.rtid
            perm.save!
          end

        end
      end


=end



    #end


end