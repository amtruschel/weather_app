require 'rest-client'

class WeatherQuery
  QUERY_BASE = 'api.openweathermap.org/data/2.5/weather'.freeze

  def self.query_by_city(city)
    RestClient.get(QUERY_BASE, {params: {appid: ENV.fetch('OPENWEATHER_API_KEY'), q: city, units: 'imperial'}})
  end

end
