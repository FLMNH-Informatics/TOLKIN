#require 'composite_primary_keys'

class Basic::Project < ActiveRecord::Base

  self.table_name = 'projects'
  self.primary_key = :project_id

  has_many :granted_roles, :class_name => 'Basic::GrantedRole'
  has_many :users, :class_name => 'Basic::User' , :through => :granted_roles



  def self.create_project_framework  params
    #perm_pset_rtid = 0 #set on View permission set
    #first make project
    p = params[:label]
    id = self.find_by_sql %{ INSERT INTO projects (label, owner_user_rtid, owner_graph_rtid, owner_record_rtid, owner_permission_set_rtid, creator_rtid, created_at, updater_rtid, updated_at, website)
                 VALUES ('#{p}',10,1,1,1,10,now(),10,now(),'#{params[:website]}') returning project_id }

    t = self.find(id[0]['project_id'].to_i)
    t.owner_graph_rtid = t.rtid
    t.owner_record_rtid = t.rtid
    t.save!
    roles = {}
    psets = {}
    ####
    ['Admin','Manager','Updater','Guest'].each do |role|
      rid = Basic::Role.find_by_sql %{ INSERT INTO roles (owner_user_rtid,owner_record_rtid,owner_graph_rtid,owner_permission_set_rtid,creator_rtid,created_at,updater_rtid,updated_at,label)
                                                                        VALUES (10,1,#{t.rtid},1,10,now(),10,now(),'#{role}') RETURNING role_id }
      arole = Basic::Role.find(rid[0]['role_id'].to_i)
      arole.owner_record_rtid = arole.rtid
      arole.save!
      roles[role] =  arole.rtid
    end

    ['View (manager edit/delete only)', 'Edit (manager delete only)', 'Delete (project members can edit/delete)', nil ].each do |r|

      psid = Basic::PermissionSet.find_by_sql %{ INSERT INTO permission_sets (owner_user_rtid, owner_record_rtid, owner_graph_rtid, owner_permission_set_rtid, creator_rtid, created_at, updater_rtid, updated_at, label)
                            VALUES (10,1,#{t.rtid},1,10,now(),10,now(),'#{r}') RETURNING permission_set_id }

      pset = Basic::PermissionSet.find(psid[0]['permission_set_id'].to_i)
      if r == 'View (manager edit/delete only)'
        #give project View permission set for owner
        t.owner_permission_set_rtid = pset.rtid
        t.save!
      end
      pset.owner_record_rtid = pset.rtid
      pset.owner_permission_set_rtid = pset.rtid
      pset.save!

      psets[r] = pset.rtid
    end

    roleperms = {
        'Manager' =>{:visible => true, :editable => true, :deletable => true, :permissible => true},
        'Updater' =>{:visible => true, :editable => true, :deletable => true, :permissible => false},
        'Guest' =>{:visible => true, :editable => false, :deletable => false, :permissible => false},
        'Admin' =>{:visible => true, :editable => true, :deletable => true, :permissible => true}
    }
    run=0
    roles.each do |role, rid|
      group = roleperms[role]
      psets.each do |set, sid|
        pid = Basic::Permission.find_by_sql %{ INSERT INTO permissions (role_rtid,permission_set_rtid,owner_user_rtid,owner_record_rtid,owner_graph_rtid,owner_permission_set_rtid,
                                                                                        creator_rtid, created_at, updater_rtid, updated_at, visible, editable, deletable, permissible)
                                                                                       VALUES (#{rid},#{sid},10,1,#{t.rtid},#{sid},10,now(),10,now(),#{group[:visible]},#{group[:editable]},#{group[:deletable]},#{group[:permissible]})
                                                                                       RETURNING permission_id }
        perm = Basic::Permission.find(pid[0]['permission_id'])
        perm.owner_record_rtid = perm.rtid
        perm.save!

        if set == 'Delete (project members can edit/delete)'  && run == 0
          self.find_by_sql "INSERT INTO project_default_permission_sets (project_rtid,permission_set_rtid) VALUES (#{t.rtid},#{sid})"
          run=1
        end
      end
    end

  end
end