require 'sinatra'
require 'json'
require 'sinatra/reloader' if development?
require 'dotenv/load' if development?
require 'pry' if development?
require_relative './models/weather_query'

get '/' do
  erb :index
end

get '/city_not_found' do
  @error_message = 'Sorry, weather could not be retrieved for that city + country combination'
  erb :city_not_found
end

post '/query_by_city' do
  city = params[:query].gsub(', ',',')

  begin
    response = JSON.parse(WeatherQuery.query_by_city(city))
  rescue RestClient::ExceptionWithResponse => err
    redirect '/city_not_found'
  end

  temp = "#{response['main']['temp'].round(0)}°F"
  forecast_descr = response['weather'][0]['description']
  wind_speed = "#{response['wind']['speed'].round(0)} mph winds"
  city_and_country = "#{response['name']}, #{response['sys']['country']}"
  @output = {'temp': temp,'forecast_descr': forecast_descr,'wind_speed': wind_speed, 'city_and_country': city_and_country}
  erb :results
end
