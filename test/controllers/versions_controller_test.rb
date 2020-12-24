require 'test_helper'

class VersionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @version = versions(:one)
  end

  test "should get index" do
    get versions_url
    assert_response :success
  end

  test "should get new" do
    get new_version_url
    assert_response :success
  end

  test "should create version" do
    assert_difference('Version.count') do
      post versions_url, params: { version: { key: @version.key, partsstructs: @version.partsstructs, song_id: @version.song_id, songparts: @version.songparts, songstruct: @version.songstruct, title: @version.title, user_id: @version.user_id } }
    end

    assert_redirected_to version_url(Version.last)
  end

  test "should show version" do
    get version_url(@version)
    assert_response :success
  end

  test "should get edit" do
    get edit_version_url(@version)
    assert_response :success
  end

  test "should update version" do
    patch version_url(@version), params: { version: { key: @version.key, partsstructs: @version.partsstructs, song_id: @version.song_id, songparts: @version.songparts, songstruct: @version.songstruct, title: @version.title, user_id: @version.user_id } }
    assert_redirected_to version_url(@version)
  end

  test "should destroy version" do
    assert_difference('Version.count', -1) do
      delete version_url(@version)
    end

    assert_redirected_to versions_url
  end
end
