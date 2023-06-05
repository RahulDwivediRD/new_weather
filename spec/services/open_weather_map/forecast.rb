# Author RSpec specs for this class
require 'rails_helper'

RSpec.describe OpenWeatherMap::Forecast do
  let(:api_key) { '50252dba5181c81f776a0386add463a7' || Rails.application.credentials.open_weather_map[:api_key] }
  let(:service) { described_class.new(api_key) }
  let(:city) { 'London' }

  describe '#forecast', :vcr do
    before do
      service.city = city
    end

    subject { service.forecast }

    it 'returns a hash with the weather forecast' do
      expect(subject['list']).to be_a(Array)
      expect(subject['list'].first).to eq({
       'dt' => 1685102400,
       'main' => {
          "feels_like"=>288.52, 
          "grnd_level"=>1028, 
          "humidity"=>53, 
          "pressure"=>1031, 
          "sea_level"=>1031, 
          "temp"=>289.45, 
          "temp_kf"=>-1.55, 
          "temp_max"=>291, 
          "temp_min"=>289.45
       },
       'weather' => [
          {
            "description"=>"clear sky",
            "icon"=>"01d",
            "id"=>800,
            "main"=>"Clear"
          }
        ],
       'clouds' => {
         'all' => 4
       },
       'wind' => {
         "deg"=>67, "gust"=>7.07, "speed"=>5.38
       },
       'visibility' => 10_000,
       'pop' => 0,
       'sys' => { 'pod' => 'd' },
       'dt_txt' => '2023-05-26 12:00:00'
     })
    end
  end

  describe '#weather', :vcr do
    before do
      service.city = city
    end

    subject { service.weather }

    it 'returns a hash with the current weather' do
      byebug
      expect(subject).to be_a(Hash)
      expect(subject['main']['temp']).to be_a(Float)
      expect(subject['weather']).to be_an(Array)
      expect(subject['weather'].first['description']).to be_a(String)
    end
  end

  describe '#min_max_weather' do
    let(:list_weather) do
      [
        { 'main' => { 'temp' => 25.6 }, 'dt_txt' => '2023-03-28 12:00:00' },
        { 'main' => { 'temp' => 28.3 }, 'dt_txt' => '2023-03-28 15:00:00' },
        { 'main' => { 'temp' => 22.1 }, 'dt_txt' => '2023-03-29 12:00:00'
         },
        { 'main' => { 'temp' => 19.8 }, 'dt_txt' => '2023-03-29 15:00:00' }
      ]
    end

    before do
      service.list_weather = list_weather
    end

    it 'returns an array with the maximum and minimum temperature for each date' do
      expect(service.min_max_weather).to eq([
        [
          { 'main' => { 'temp' => 28.3 }, 'dt_txt' => '2023-03-28 15:00:00' },
          { 'main' => { 'temp' => 25.6 }, 'dt_txt' => '2023-03-28 12:00:00' }
        ],
        [
          { 'main' => { 'temp' => 22.1 }, 'dt_txt' => '2023-03-29 12:00:00' },
          { 'main' => { 'temp' => 19.8 }, 'dt_txt' => '2023-03-29 15:00:00' }
        ]
      ])
    end
  end
end
