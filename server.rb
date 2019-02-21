require 'sinatra'
require 'json'
require 'sinatra/reloader' if development?
require 'dotenv/load' if development?
require 'pry' if development?
require_relative './models/weather_query'

enable :sessions

helpers do
  def clear_session_data
    session[:query_string] = nil
    session[:query_results_forecast] = nil
    session[:query_results_coordinates] = nil
  end
end

get '/' do
  clear_session_data
  @coordinates = nil
  erb :index
end

get '/city_not_found' do
  @error_message = 'Sorry, weather could not be retrieved for that city + country combination'
  erb :city_not_found
end

get '/query_by_city' do
  @coordinates = session[:query_results_coordinates]
  @forecast = session[:query_results_forecast]
  erb :results
end

post '/query_by_city' do
  session[:query_string] = params[:query]
  city = params[:query].gsub(', ',',')

  begin
    weather_response = JSON.parse(WeatherQuery.query_by_city(city))
  rescue RestClient::ExceptionWithResponse
    redirect '/city_not_found'
  end

  session[:query_results_coordinates] = "#{weather_response['coord']['lat']},#{weather_response['coord']['lon']}"

  temp = "#{weather_response['main']['temp'].round(0)}°F"
  forecast_descr = weather_response['weather'][0]['description']
  wind_speed = "#{weather_response['wind']['speed'].round(0)} mph winds"
  city_and_country = "#{weather_response['name']}, #{weather_response['sys']['country']}"

  session[:query_results_forecast] = {'temp': temp,'forecast_descr': forecast_descr,'wind_speed': wind_speed, 'city_and_country': city_and_country}

  redirect "/query_by_city"

  erb :results
end
