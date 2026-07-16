class GamesController < ApplicationController
  def index
    key = ENV["RAWG_API_KEY"]

    if key.blank?
      return render json: {
        error: "RAWG_API_KEY not found."
      }, status: :internal_server_error
    end

    url = "https://api.rawg.io/api/games?key=#{key}"

    url += "&page=#{params[:page] || 1}"
    url += "&search=#{CGI.escape(params[:search].to_s)}" if params[:search].present?
    url += "&genres=#{params[:genre]}" if params[:genre].present?
    url += "&platforms=#{params[:platform]}" if params[:platform].present?

    begin
      response = HTTParty.get(url, timeout: 15)

      if response.success?
        render json: response.parsed_response
      else
        render json: {
          error: "Error in RAWG",
          status: response.code
        }, status: :bad_gateway
      end
    rescue => e
      render json: { error: "Connection error with RAWG: #{e.message}" }, status: :bad_gateway
    end
  end

  def show
    key = ENV["RAWG_API_KEY"]

    if key.blank?
      return render json: {
        error: "RAWG_API_KEY not found."
      }, status: :internal_server_error
    end

    begin
      response = HTTParty.get(
        "https://api.rawg.io/api/games/#{params[:id]}?key=#{key}",
        timeout: 15
      )

      if response.success?
        render json: response.parsed_response
      else
        render json: {
          error: "Error in RAWG",
          status: response.code
        }, status: :bad_gateway
      end
    rescue => e
      render json: {
        error: "Connection error with RAWG: #{e.message}"
      }, status: :bad_gateway
    end
  end

  def genres
    key = ENV["RAWG_API_KEY"]

    response = HTTParty.get(
      "https://api.rawg.io/api/genres?key=#{key}"
    )

    if response.success?
      render json: response.parsed_response["results"].map { |genre|
        {
          id: genre["id"],
          name: genre["name"],
          slug: genre["slug"]
        }
      }
    else
      render json: { error: "Error in RAWG" }, status: :bad_gateway
    end
  end

  def platforms
    key = ENV["RAWG_API_KEY"]

    response = HTTParty.get(
      "https://api.rawg.io/api/platforms?key=#{key}"
    )

    if response.success?
      render json: response.parsed_response["results"].map { |platform|
        {
          id: platform["id"],
          name: platform["name"]
        }
      }
    else
      render json: { error: "Error in RAWG" }, status: :bad_gateway
    end
  end
end
