require 'rails_helper'

RSpec.describe 'Weather Forecast', type: :system do
  it 'displays the page title' do
    visit root_path
    expect(page).to have_css('h1', text: 'Weather Forecast')
  end

  it 'displays a form to search for a city' do
    visit root_path
    expect(page).to have_css('form[action="/weather/forecast"][method="get"]')
    expect(page).to have_field('city')
    expect(page).to have_button('Search')
  end

  it 'allows the user to search for a city', :vcr do
    visit root_path
    fill_in 'city', with: 'London'
    click_button 'Search'

    expect(page).to have_css('table')
    expect(page).to have_css('thead')
    expect(page).to have_css('tbody')
    expect(page).to have_css('th', text: 'Date')
    expect(page).to have_css('th', text: 'High Temp')
    expect(page).to have_css('th', text: 'Low Temp')
  end

  it 'displays an error message for an invalid city', :vcr do
    visit root_path
    fill_in 'city', with: 'Invalid City'
    click_button 'Search'
    expect(page).to have_content('Sorry, we could not find the weather forecast for the specified city.')
  end
end

