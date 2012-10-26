require "csv"
require "HTTParty"
require "JSON"
require "nokogiri"
require "open-uri"

csv_data = []

CSV.foreach("orig_data.csv", {:headers => true}) do |row|
  # use row here...
  response = HTTParty.get("http://api.iucnredlist.org/index/species/#{row['BINOMIAL'].sub(' ','-')}.json")
  species_summary = JSON.parse response.body
  
  species_id = species_summary[0]["species_id"]
  
  doc = Nokogiri::HTML(open("http://api.iucnredlist.org/details/#{species_id}/0"))
  species_data = [species_id,row['BINOMIAL']]
  doc.css('#red_list_category_code','#red_list_criteria','#modified_year','#range_description','#countries','#population','#population_trend','#habitat','#systems','#major_threats','#conservation_actions').each do |attribute|
    species_data << attribute.content
  end
  
#  puts species_data.flatten
  csv_data << species_data.flatten
  print '.'
end


CSV.open("new_data.csv", "w") do |csv|
  csv_data.each do |species| 
    puts species
    csv << species 
  end
  
end
