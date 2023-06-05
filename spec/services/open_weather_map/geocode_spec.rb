require 'rails_helper'

RSpec.describe OpenWeatherMap::Geocode do
  let(:api_key)   { '50252dba5181c81f776a0386add463a7' || Rails.application.credentials.open_weather_map[:api_key] }
  let(:geocoder)  { OpenWeatherMap::Geocode.new(api_key) }
  let(:city)      { 'London' }

  describe '#geocode', :vcr do
    it 'returns the geocode for a city' do
      response = geocoder.geocode(city)
      expect(response.first['name']).to eq(city)
      expect(response[0]['lat']).to be_a(Float)
      expect(response[0]['lon']).to be_a(Float)
    end

    it 'returns the geocode for a city with spaces' do
      response = geocoder.geocode('New York')
      expect(response.first['name']).to eq('New York County')
      expect(response[0]['lat']).to be_a(Float)
      expect(response[0]['lon']).to be_a(Float)
    end
  end
end

