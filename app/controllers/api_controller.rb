require 'csv'
require Rails.root.join('app', 'services', 'recommender').to_s


class ApiController < ActionController::Base
  protect_from_forgery with: :exception

  def scenarios
    scenarios = scenario_hash.keys.select { |id| params[id].present? }
    ratings = params.slice(*scenarios).to_h
    version = params[:anxtype] || 1
    render json: Recommender.new(ratings, version, 'exposurerecommender.R').recommendation
  end

  private

  def scenario_hash
    @scenario_hash ||= CSV.read('./config/scenarios&id.csv', encoding: 'ISO-8859-1').to_h
  end
end
