require "test_helper"

class GamesControllerTest < ActionDispatch::IntegrationTest
  setup do
    ENV["RAWG_API_KEY"] = "fake_key"
  end

  teardown do
    ENV.delete("RAWG_API_KEY")
  end

  test "should get games index" do
    rawg_response = Minitest::Mock.new
    rawg_response.expect(:success?, true)
    rawg_response.expect(:parsed_response, {
      "results" => [
        { "id" => 1, "name" => "Zelda" }
      ]
    })

    HTTParty.stub(:get, rawg_response) do
      get "/games"
    end

    assert_response :success

    json = JSON.parse(response.body)
    assert_equal "Zelda", json["results"][0]["name"]
  end

  test "should search games" do
    rawg_response = Minitest::Mock.new
    rawg_response.expect(:success?, true)
    rawg_response.expect(:parsed_response, {
      "results" => [
        { "id" => 10, "name" => "Mario Kart" }
      ]
    })

    HTTParty.stub(:get, rawg_response) do
      get "/games", params: { search: "Mario" }
    end

    assert_response :success
  end

  test "should paginate games" do
    rawg_response = Minitest::Mock.new
    rawg_response.expect(:success?, true)
    rawg_response.expect(:parsed_response, {
      "results" => []
    })

    HTTParty.stub(:get, rawg_response) do
      get "/games", params: { page: 2 }
    end

    assert_response :success
  end

  test "should filter by genre" do
    rawg_response = Minitest::Mock.new
    rawg_response.expect(:success?, true)
    rawg_response.expect(:parsed_response, {
      "results" => []
    })

    HTTParty.stub(:get, rawg_response) do
      get "/games", params: { genre: "action" }
    end

    assert_response :success
  end

  test "should filter by platform" do
    rawg_response = Minitest::Mock.new
    rawg_response.expect(:success?, true)
    rawg_response.expect(:parsed_response, {
      "results" => []
    })

    HTTParty.stub(:get, rawg_response) do
      get "/games", params: { platform: "4" }
    end

    assert_response :success
  end

  test "should return internal server error when api key is missing" do
    ENV.delete("RAWG_API_KEY")

    get "/games"

    assert_response :internal_server_error

    json = JSON.parse(response.body)
    assert_equal "RAWG_API_KEY not found.", json["error"]
  end

  test "should return bad gateway when rawg responds with error" do
    rawg_response = Minitest::Mock.new
    rawg_response.expect(:success?, false)
    rawg_response.expect(:code, 500)

    HTTParty.stub(:get, rawg_response) do
      get "/games"
    end

    assert_response :bad_gateway

    json = JSON.parse(response.body)
    assert_equal 500, json["status"]
  end

  test "should return bad gateway when connection fails" do
    HTTParty.stub(:get, proc { raise StandardError, "Connection timeout" }) do
      get "/games"
    end

    assert_response :bad_gateway

    json = JSON.parse(response.body)
    assert_match "Connection timeout", json["error"]
  end

  test "should show game details" do
    rawg_response = Minitest::Mock.new
    rawg_response.expect(:success?, true)
    rawg_response.expect(:parsed_response, {
      "id" => 1,
      "name" => "Zelda"
    })

    HTTParty.stub(:get, rawg_response) do
      get "/games/1"
    end

    assert_response :success

    json = JSON.parse(response.body)
    assert_equal 1, json["id"]
    assert_equal "Zelda", json["name"]
  end

  test "should get genres" do
    rawg_response = Minitest::Mock.new
    rawg_response.expect(:success?, true)
    rawg_response.expect(:parsed_response, {
      "results" => [
        {
          "id" => 4,
          "name" => "Action",
          "slug" => "action"
        }
      ]
    })

    HTTParty.stub(:get, rawg_response) do
      get "/genres"
    end

    assert_response :success

    json = JSON.parse(response.body)

    assert_equal 4, json.first["id"]
    assert_equal "Action", json.first["name"]
    assert_equal "action", json.first["slug"]
  end

  test "should return bad gateway when genres request fails" do
    rawg_response = Minitest::Mock.new
    rawg_response.expect(:success?, false)

    HTTParty.stub(:get, rawg_response) do
      get "/genres"
    end

    assert_response :bad_gateway
  end

  test "should get platforms" do
    rawg_response = Minitest::Mock.new
    rawg_response.expect(:success?, true)
    rawg_response.expect(:parsed_response, {
      "results" => [
        {
          "id" => 1,
          "name" => "PC"
        }
      ]
    })

    HTTParty.stub(:get, rawg_response) do
      get "/platforms"
    end

    assert_response :success

    json = JSON.parse(response.body)

    assert_equal 1, json.first["id"]
    assert_equal "PC", json.first["name"]
  end

  test "should return bad gateway when platforms request fails" do
    rawg_response = Minitest::Mock.new
    rawg_response.expect(:success?, false)

    HTTParty.stub(:get, rawg_response) do
      get "/platforms"
    end

    assert_response :bad_gateway
  end

  test "should return internal server error on show when api key is missing" do
    ENV.delete("RAWG_API_KEY")

    get "/games/1"

    assert_response :internal_server_error

    json = JSON.parse(response.body)
    assert_equal "RAWG_API_KEY not found.", json["error"]
  end

  test "should return bad gateway when show request fails" do
    rawg_response = Minitest::Mock.new
    rawg_response.expect(:success?, false)
    rawg_response.expect(:code, 404)

    HTTParty.stub(:get, rawg_response) do
      get "/games/1"
    end

    assert_response :bad_gateway

    json = JSON.parse(response.body)

    assert_equal 404, json["status"]
  end

  test "should return bad gateway when show connection fails" do
    HTTParty.stub(:get, proc { raise StandardError, "Timeout" }) do
      get "/games/1"
    end

    assert_response :bad_gateway

    json = JSON.parse(response.body)

    assert_match "Timeout", json["error"]
  end
end
