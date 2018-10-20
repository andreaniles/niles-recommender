class Recommender
  def initialize(ratings, version, r_script_file_name)
    @ratings = ratings
    @version = version
    @num_to_rec = 60
    @r_script_file_name = r_script_file_name
  end

  def recommendation
    write_ratings_to_temp_file
    result =
      `Rscript #{Rails.root}/bin/rscripts/#{@r_script_file_name} #{Rails.root} #{file_name} #{@version}`
    puts result
    parse_result(result)
  end

  private

  def parse_result(r_script_output)
    result = r_script_output.
             gsub(/\[\d+|\,|\] /, '').delete('"').split(/[ \n]+/).
             map(&:strip).select(&:present?)
    puts result
    result = result.in_groups_of(2) if @mode == 3
    result[0..-1]
  end

  def sess_token
    @sess_token ||= SecureRandom.urlsafe_base64
  end

  def file_name
    @file_name ||= Rails.root.join('tmp', "#{sess_token}.csv")
  end

  def write_ratings_to_temp_file
    CSV.open(file_name, 'w') do |csv|
      csv << %w(id rating)
      @ratings.each { |word, rating| csv << [word, rating] }
    end
  end
end
