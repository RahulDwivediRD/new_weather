require 'rails_helper'

RSpec.describe 'Weather API', type: :request do
  describe 'GET /weather/forecast' do
    let(:api_key) { '50252dba5181c81f776a0386add463a7' }
    let(:service) { instance_double(OpenWeatherMap::Forecast) }
    let(:min_max_weather_data) { [[{ 'main' => { 'temp' => 281.39 } }], [{ 'main' => { 'temp' => 280.42 } }]] }
    let(:forecast_data) do
      [
        {
          "dt" => 1685102400,
          "main" => { "temp" => 308.66, "feels_like" => 308.13, "temp_min" => 308.66, "temp_max" => 309.5 },
          "weather" => [{ "id" => 800, "main" => "Clear", "description" => "clear sky", "icon" => "01d" }],
          "clouds" => { "all" => 4 },
          "wind" => { "speed" => 7.67, "deg" => 268, "gust" => 7.8 },
          "visibility" => 10000,
          "pop" => 0,
          "sys" => { "pod" => "d" },
          "dt_txt" => "2023-05-26 12:00:00"
        },
        {
          "dt" => 1685134800,
          "main" => { "temp" => 300.32, "feels_like" => 301.61, "temp_min" => 300.32, "temp_max" => 300.32 },
          "weather" => [{ "id" => 800, "main" => "Clear", "description" => "clear sky", "icon" => "01n" }],
          "clouds" => { "all" => 0 },
          "wind" => { "speed" => 7.37, "deg" => 270, "gust" => 12.68 },
          "visibility" => 10000,
          "pop" => 0,
          "sys" => { "pod" => "n" },
          "dt_txt" => "2023-05-26 21:00:00"
        }
      ]
    end
    let(:current_weather_data) do
      {
        "coord" => { "lon" => 75.8882, "lat" => 22.7378 },
        "weather" => [{ "id" => 800, "main" => "Clear", "description" => "clear sky", "icon" => "01d" }],
        "base" => "stations",
        "main" => { "temp" => 308.24, "feels_like" => 308.17, "temp_min" => 308.24, "temp_max" => 308.24 },
        "visibility" => 7000,
        "wind" => { "speed" => 9.77, "deg" => 260, "gust" => 10.27 },
        "clouds" => { "all" => 0 },
        "dt" => 1685090929,
        "sys" => { "type" => 1, "id" => 9218, "country" => "IN", "sunrise" => 1685071349, "sunset" => 1685119997 },
        "timezone" => 19800,
        "id" => 1277333,
        "name" => "London",
        "cod" => 200
      }
    end

    before do
      allow(OpenWeatherMap::Forecast).to receive(:new).and_return(service)
      allow(service).to receive(:city=)
      allow(service).to receive(:latitude=)
      allow(service).to receive(:longitude=)
      allow(service).to receive(:forecast).and_return(forecast_data)
      allow(service).to receive(:list_weather=)
      allow(service).to receive(:min_max_weather)
      allow(service).to receive(:weather).and_return(current_weather_data)
    end

    context 'with valid city' do
      let(:city) { 'London' }

      before do
        allow(service).to receive(:city=).with(city)
      end

      it 'sets the city on the service' do
        get '/weather/forecast', params: { city: city }
        expect(service).to have_received(:city=).with(city)
      end

      it 'renders the forecast template' do
        get '/weather/forecast', params: { city: city }
        expect(response).to render_template(:forecast)
      end
    end

    context 'with valid latitude and longitude' do
      let(:latitude) { "51.5074" }
      let(:longitude) { "-0.1278" }

      before do
        allow(service).to receive(:latitude=).with(latitude)
        allow(service).to receive(:longitude=).with(longitude)
      end

      it 'sets the latitude and longitude on the service' do
        get '/weather/forecast', params: { latitude: latitude, longitude: longitude }
        expect(service).to have_received(:latitude=).with(latitude)
        expect(service).to have_received(:longitude=).with(longitude)
      end

      it 'renders the forecast template' do
        get '/weather/forecast', params: { latitude: latitude, longitude: longitude }
        expect(response).to render_template(:forecast)
      end
    end

    context 'with missing parameters' do
      it 'renders the forecast template' do
        get '/weather/forecast'
        expect(response).to render_template(:forecast)
      end

      it 'does not assign the forecast data' do
        get '/weather/forecast'
        expect(assigns(:forecast)).to be_nil
      end

      it 'does not assign the current weather data' do
        get '/weather/forecast'
        expect(assigns(:current_weather)).to be_nil
      end
    end

    context 'when an error occurs' do
      let(:error_message) { 'API error' }

      before do
        allow(service).to receive(:forecast).and_raise(StandardError, error_message)
      end

      it 'assigns the error message' do
        get '/weather/forecast', params: { city: 'InvalidCity' }
        expect(assigns(:error_message)).to eq(error_message)
      end

      it 'renders the forecast template' do
        get '/weather/forecast', params: { city: 'InvalidCity' }
        expect(response).to render_template(:forecast)
      end
    end
  end
end
