require 'test_helper'

class Api::V1::TestsControllerTest < ActionDispatch::IntegrationTest
  test "should get teset" do
    get api_v1_tests_teset_url
    assert_response :success
  end

end
