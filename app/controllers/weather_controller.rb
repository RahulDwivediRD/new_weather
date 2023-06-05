# app/controllers/weather_controller.rb
class WeatherController < ApplicationController

  def index
  end

  def forecast
    service = OpenWeatherMap::Forecast.new

    if params[:city].present?
      service.city = params[:city]
    elsif params[:latitude].present? && params[:longitude].present?
      service.latitude = params[:latitude]
      service.longitude = params[:longitude]
    else
      return render :forecast
    end

    forecast = service.forecast
    service.list_weather = forecast['list']
    @forecast = service.min_max_weather
    @current_weather = service.weather

    render :forecast
  rescue StandardError => e
    @error_message = e.message
  end
end

