require 'nokogiri'
require 'httparty'
require 'csv'
require 'algorithms'

# Open CSV and grab tickers
tickers = CSV.read("./stocks_flag.csv")
tickers = symbols.flatten.map {|s| s.downcase}

# Create csv output file
CSV.open("./values_table.csv", "wb") do |csv|
  csv << ["Ticker", "Open", "Close", "Volume", "d-1 Close", "d-1 Volume",
    "d-2 Close", "d-2 Volume", "d-3 Close", "d-3 Volume", "d-4 Close",
    "d-4 Volume", "d-5 Close", "d-5 Volume"]
end

tickers.each do |sym|

  # Grab url
  html = HTTParty.get("http://www.nasdaq.com/symbol/#{sym}/historical")

  # Convert to Nokogiri object
  doc = Nokogiri::HTML(html)

  # Put rows in chronological order and remove header
  rows = doc.xpath('//table/tbody/tr')
  rows.shift

  # Go through rows and find the lowest value
  # and highest value to determine percent increase
  p "analyzing #{sym}"
  row = rows[1]
  data = []
  opening = row.at_xpath("td[2]/text()").to_s.gsub(",", "").strip.to_f
  closing = row.at_xpath("td[5]/text()").to_s.gsub(",", "").strip.to_f
  volume = row.at_xpath("td[6]/text()").to_s.gsub(",", "").strip.to_f
  data += [sym, opening, closing, volume]

  (2..6).each do |i|
    row = rows[i]
    closing = row.at_xpath("td[5]/text()").to_s.gsub(",", "").strip.to_f
    volume = row.at_xpath("td[6]/text()").to_s.gsub(",", "").strip.to_f
    data += [closing, volume]
  end

  CSV.open("./values_table.csv", "ab") do |csv|
    csv << data
  end

end

# once the ticker is entered, i will need in a column the
#  previous closing, today's opening, today's
# closing price as well as their volumes.
#  Then I need the closing price of the previous 5 days.
