class MarkedRecordsController < ApplicationController

  before_filter :requires_selected_project
  before_filter :requires_project_guest, :only => [ :index, :show, :list_columns, :export_records ]
  before_filter :requires_project_updater, :only => [ :create, :update ]

  include AuthenticatedSystem
  #check if the project param is available in the url
  #before_filter :check_record_permission, :except=> [:index, :create, :findchildren, :fetchchildren, :taxondetails]

  def index

  end

  def show
  
  end
  
  def create
    @info = "Error marking record."
    debugger
    if !params[:type_name].nil? && !params[:type_id].nil? #&& checkPresence of both these values
      @mrk_rec = MarkedRecord.new()
      @mrk_rec.type = params[:type_name] #need to check the presence of particular table/class
      @mrk_rec.type_id = params[:type_id]
      @mrk_rec.user_id = @current_user.id
      if(@mrk_rec.save)
        @info = "Saved Marked Record."      
      end
    else
        @info = "Error marking record, could be that the record is illegal."      
    end
  end

 def update
    
 end
 
 def list_columns
   debugger
   @temp = params[:marked_record_type]
   @temp =   @temp.downcase.classify.constantize
   @marked_records = MarkedRecord.find(:all, :conditions=>["type = ? and user_id=?", @temp.to_s, @current_user.id] )
   #render :partial=> "list_model_columns", :object=> @temp
 end
 
 def export_records
      debugger
    @mrk_rec = params[:marked_record]
    selected_rec = @mrk_rec.select {|k,v| v == "1" }  #=> [["b", 200], ["c", 300]]
    column_list = params.select { |k,v| k.to_s == params[:marked_record][:type].to_s }
    if !column_list.nil? && !column_list.empty?
      sel_col_list = column_list[0][1].select{ |k, v| v=="1" }
      sel_rec_ids = selected_rec.collect {|x| x[0]} #this id list of marked records not id of types(taxon, collections etc.)
      sel_col_list = sel_col_list.collect{|x| x[0]}
      sel_rec_type_ids = MarkedRecord.find(sel_rec_ids)
      sel_rec_type_ids = sel_rec_type_ids.collect {|x| x.type_id }
      @export_text = params[:marked_record][:type].constantize.find(sel_rec_type_ids, :select =>  sel_col_list.join(","))
    end
 end
 
end