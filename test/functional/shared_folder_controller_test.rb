# -*- encoding : utf-8 -*-
require 'test_helper'

class SharedFolderControllerTest < ActionController::TestCase
  test "should get new" do
    get :new
    assert_response :success
  end

  test "should get put" do
    get :put
    assert_response :success
  end

  test "should get show" do
    get :show
    assert_response :success
  end

end
