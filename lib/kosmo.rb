# frozen_string_literal: true

require_relative "kosmo/version"
require "faraday"
require "faraday/retry"
require "json"

module Kosmo
  class Error < StandardError; end
  class ApiError < Error; end
  class BadRequestError < ApiError; end
  class UnauthorizedError < ApiError; end
  class ForbiddenError < ApiError; end
  class NotFoundError < ApiError; end
  class RateLimitError < ApiError; end
  class ServerError < ApiError; end

  class Client
    BASE_URL = "https://api.kosmo.delivery/v2"

    def initialize(api_key)
      @api_key = api_key
      @connection = Faraday.new(url: BASE_URL) do |faraday|
        faraday.headers["Authorization"] = "Bearer #{api_key}"
        faraday.headers["Content-Type"] = "application/json"
        faraday.headers["Accept"] = "application/json"
      end
    end

    # Quotes
    def create_quotes(params)
      post("quotes", params)
    end

    # Orders
    def create_order(params)
      post("orders", params)
    end

    def list_orders(params = {})
      get("orders", params)
    end

    def get_order(order_id)
      get("orders/#{order_id}")
    end

    private

    def get(path, params = {})
      response = @connection.get(path, params)
      handle_response(response)
    end

    def post(path, body = {})
      response = @connection.post(path, body.to_json)
      handle_response(response)
    end

    def handle_response(response)
      body = parse_response_body(response.body)
      
      # Check for auth-related errors in response body first
      if body.is_a?(Hash) && body["error"]&.include?("unauthorized")
        raise UnauthorizedError, error_message(response)
      end

      case response.status
      when 200..299
        body
      when 400
        raise BadRequestError, response.body
      when 401
        raise UnauthorizedError, error_message(response)
      when 403
        raise ForbiddenError, error_message(response)
      when 404
        raise NotFoundError, error_message(response)
      when 405
        raise ApiError, response.body
      when 429
        raise RateLimitError, error_message(response)
      when 500..599
        raise ServerError, error_message(response)
      else
        raise ApiError, "Unexpected response status #{response.status}: #{response.body}"
      end
    end

    def parse_response_body(body)
      return body if body.is_a?(Hash)
      begin
        JSON.parse(body)
      rescue JSON::ParserError
        # Return nil if parsing fails
      end
    end

    def error_message(response)
      body = parse_response_body(response.body)
      if body.is_a?(Hash)
        if body["error"]
          "#{response.status}: #{body["error"]}"
        elsif body["details"]
          "#{response.status}: #{body["details"].map { |d| d["message"] }.join(", ")}"
        else
          "#{response.status}: #{response.body}"
        end
      else
        "#{response.status}: #{response.reason_phrase}"
      end
    rescue StandardError
      "#{response.status}: #{response.body}"
    end
  end
end
