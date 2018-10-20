require 'csv'

class ApiController < ActionController::Base
  protect_from_forgery with: :exception

  def scenarios
    scenarios = scenario_hash.keys.select { |id| params[id].present? }
    ratings = params.slice(*scenarios)
    
    render json: ratings
  end

  private

  def scenario_hash
    @scenario_hash ||= CSV.read('./config/scenarios&id.csv', encoding: 'ISO-8859-1').to_h
  end
end
