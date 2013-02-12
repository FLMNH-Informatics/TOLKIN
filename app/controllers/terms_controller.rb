# To change this template, choose Tools | Templates
# and open the template in the editor.

class TermsController < ApplicationController

  include Restful::Responder

  
  def get_qualifier_terms
#    feat_id = Integer(params[:feat_id])
    @qualifiers = []
#    @qualifier_ids = FeatureQualifierRelationship.find(:all, :select => "qualifier_term_id", :conditions => "feature_key_term_id = #{feat_id}")
#    qual_list = '('
#    @qualifier_ids.each do |q|
#      qual_list == '('? qual_list = qual_list + q.qualifier_term_id.to_s : qual_list = [qual_list, q.qualifier_term_id.to_s].join(',')
#    end
#      qual_list += ')'
#    @qualifiers = Term.find(:all, :conditions => "term_id in #{qual_list}")
    respond_to do |format|
      format.json { render :json => {:qualifiers => @qualifiers } }
    end
  end

  def get_features_terms
    feat_id = Ontology.find_by_name('SeqFeature Keys').ontology_id
    @terms = Term.find(:all, :conditions => "ontology_id = #{feat_id}")
    respond_to do |format|
      format.json { render :json => {:terms => @terms } }
    end
  end
end
