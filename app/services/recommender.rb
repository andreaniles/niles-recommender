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
    parse_result(result)
  end

  private

  def parse_result(r_script_output)
    rows = r_script_output.split("\n")
    result = rows[1..-1].map do |row|
      row.split(/ +/)[-3..-1].map { |e| JSON.parse(e) }
    end
    %w[low medium high].zip(result.transpose).to_h.to_json
  end

  def sess_token
    @sess_token ||= SecureRandom.urlsafe_base64
  end

  def file_name
    @file_name ||= Rails.root.join('tmp', "#{sess_token}.csv")
  end

  def write_ratings_to_temp_file
    CSV.open(file_name, 'w') do |csv|
      csv << %w(id anx avd)
      @ratings.each { |word, rating| csv << [word, *rating.map(&:presence)] }
    end
  end
end
