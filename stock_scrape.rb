require 'nokogiri'
require 'httparty'
require 'csv'
require 'algorithms'


class SOI
  def initialize(symbol, lowest, lowest_date, highest, highest_date, cutoff)
    @symbol = symbol
    @lowest = lowest
    @lowest_date = lowest_date
    @highest = highest
    @highest_date = highest_date
    @cutoff = cutoff
  end

  def printStock
    print @symbol + "\n"
    print "  Lowest Price(#{@lowest_date}): #{@lowest}\n"
    print "  Highest Price(#{@highest_date}): #{@highest}\n"
    print "  Cutoff: #{@cutoff}\n"
  end
end
# Read tickers from csv file
symbols = CSV.read("./stocks_flag.csv")
symbols = symbols.flatten.map {|s| s.downcase}

# Percent increase to look at
P = 0.9
soi = []
symbols.each do |sym|

  # Grab url
  html = HTTParty.get("http://www.nasdaq.com/symbol/#{sym}/historical")

  # Convert to Nokogiri object
  doc = Nokogiri::HTML(html)

  # Put rows in chronological order and remove header
  rows = doc.xpath('//table/tbody/tr')
  rows.shift
  rows = rows.reverse()

  # Default variables to analyze
  lowest = 9999999
  lowest_date = ""
  highest = 0
  highest_date = ""
  cutoff = 9999999
  verified = false
  values = {}
  day = 1
  lowest_day = 0
  q = Containers::PriorityQueue.new
  # Go through rows and find the lowest value
  # and highest value to determine percent increase
  p "analyzing #{sym}"
  rows.each do |row|
    day_lowest = 9999999
    # (2..5).each do |c|
    c = 5
      val = row.at_xpath("td[#{c}]/text()").to_s.strip.to_f
      if (val >= cutoff)
        highest = val
        highest_date = row.at_xpath('td[1]/text()').to_s.strip
        stock = SOI.new(sym, lowest, lowest_date, highest, highest_date, cutoff)
        soi.push(stock)
        verified = true
        break
      elsif (val < lowest)
        lowest_day = day
        lowest = val
        lowest_date = row.at_xpath('td[1]/text()').to_s.strip
        cutoff = val + (val * P)
      end
      if (val < day_lowest)
        day_lowest = val
      end
    # end
    if (verified)
      break
    end
    q.push(day.to_s, 0 - day_lowest)
    values[day] = [day_lowest, row.at_xpath('td[1]/text()').to_s.strip]

    while (day - lowest_day > 40)
      lowest_day = q.pop.to_i
      lowest = values[lowest_day][0]
      lowest_date = values[lowest_day][1]
      cutoff = lowest + (lowest * P)
    end
    day += 1
  end
end
soi.each do |s|
  s.printStock
end
