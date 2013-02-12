require 'test_helper'

class TaxonomiesControllerTest < ActionController::TestCase

  def test_should_get_index
    get :index, { :project_id => projects(:viridiplantae).id }, { :user_id => users(:updater).id }
    assert_response :success
    assert_not_nil assigns(:parents)
  end

  # TODO turn this test back on once possible to create new taxonomy
  # through interface
#  def test_should_get_new
#    get :new
#    assert_response :success
#  end

  def test_should_create_taxonomy
    assert_difference('Taxonomy.count') do
      post :create, { :taxon => { :name => 'testname',
                                  :recpermission_id => recpermissions(:edit)
                                },
                      :project_id => projects(:viridiplantae),
                      :sop => {}
                    },
                    { :user_id => users(:updater).id }
    end
  end

  def test_should_show_taxonomy
    get :show, { :id => taxonomies(:taxon_one).id, :project_id => projects(:viridiplantae).id }, { :user_id => users(:updater).id }
    assert_response :success
  end

  # simulate the user clicking a taxon name and having the taxon details
  # window pop up
  def test_should_get_xhr_show
    xhr :get, :taxon_details, { :id => taxonomies(:taxon_one).id, :project_id => projects(:viridiplantae).id }, { :user_id => users(:updater).id }
    assert_not_nil assigns(:taxonomy)
    assert_response :success
  end

  def test_should_update_taxonomy
    put :update, { :id => taxonomies(:taxon_one).id, :project_id => projects(:viridiplantae).id, :taxonomy => { :name => 'Agathis' }, :format => :json}, { :user_id => users(:updater).id }
    assert_not_nil assigns(:taxonomy)
  end

  def test_should_destroy_taxonomy
    assert_difference('Taxonomy.count', -1) do
      delete :destroy, { :id => taxonomies(:taxon_one).id, :project_id => projects(:viridiplantae).id }, { :user_id => users(:updater) }
    end
  end
#  def test_should_get_show_add_to_otu
#    get :show_add_to_otu
#    assert_response :success
#  end
end
