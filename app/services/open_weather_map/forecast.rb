require 'httparty'

module OpenWeatherMap
  class Forecast
    BASE_URL = 'https://api.openweathermap.org/data/2.5'
    attr_accessor :list_weather, :latitude, :longitude, :city

    def initialize
      @api_key = Rails.application.credentials.open_weather_map[:api_key]
    end

    def forecast
      make_request('forecast')
    end

    def weather
      make_request('weather')
    end

    def min_max_weather
      list_weather.group_by do |obj|
        obj['dt_txt'].to_date.strftime("%Y-%m-%d")
      end.map do |_, v|
        [ v.max_by{ |obj| obj['main']['temp']},
          v.min_by{ |obj| obj['main']['temp']}]
      end
    end

    private

    def lat
      latitude.present? ? latitude : geocoded_city_response.first['lat']
    end

    def lon
      longitude.present? ? longitude : geocoded_city_response.first['lon']
    end

    def geocoded_city_response
      @geocoded_city_response ||= Geocode.new(@api_key).geocode(city)
      raise StandardError, 'Sorry, we could not find the weather forecast for the specified city.' if @geocoded_city_response.first.nil?
      @geocoded_city_response
    end

    def make_request(path)
      url = "#{BASE_URL}/#{path}?lat=#{lat}&lon=#{lon}&appid=#{@api_key}"
      response = HTTParty.get(url)
      raise StandardError, "OpenWeatherMap API error: #{response.code} - #{response.message}" unless response.success?
      response.parsed_response
    end
  end
end
