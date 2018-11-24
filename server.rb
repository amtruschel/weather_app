require 'sinatra'
require 'json'
require 'sinatra/reloader' if development?
require 'dotenv/load' if development?
require 'pry' if development?
require_relative './models/weather_query'


get '/' do
  erb :index
end

post '/query_by_city' do
  city = params[:query].gsub(', ',',')
  response = JSON.parse(WeatherQuery.query_by_city(city))
  temp = "#{response['main']['temp'].round(0)}°F"
  forecast_descr = response['weather'][0]['description']
  wind_speed = "#{response['wind']['speed'].round(0)} mph winds"
  @output = {'temp': temp,'forecast_descr': forecast_descr,'wind_speed': wind_speed}
  erb :results
end
