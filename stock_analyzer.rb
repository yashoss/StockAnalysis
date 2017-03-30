require 'nokogiri'
require 'httparty'
require 'csv'
require 'algorithms'


class SOI
  def initialize(symbol, oc, op, hc, hp, lc, lp, cc, cp)
    @symbol = symbol
    @open_c = oc
    @open_p = op
    @high_c = hc
    @high_p = hp
    @low_c = lc
    @low_p = lp
    @close_c = cc
    @close_p = cp
  end

  def printStock
    print @symbol + "\n"
    print "  Open Difference: #{@open_c} (#{@open_p}%)\n"
    print "  High Difference: #{@high_c} (#{@high_p}%)\n"
    print "  Low Difference: #{@low_c} (#{@low_p}%)\n"
    print "  Close Difference: #{@close_c} (#{@close_p}%)\n"
  end
end
# Read tickers from csv file
symbols = CSV.read("./stocks_flag.csv")
symbols = symbols.flatten.map {|s| s.downcase}
soi = []
symbols.each do |sym|

  # Grab url
  html = HTTParty.get("http://www.nasdaq.com/symbol/#{sym}/historical")

  # Convert to Nokogiri object
  doc = Nokogiri::HTML(html)

  # Put rows in chronological order and remove header
  rows = doc.xpath('//table/tbody/tr')
  rows.shift

  q = Containers::PriorityQueue.new
  # Go through rows and find the lowest value
  # and highest value to determine percent increase
  p "analyzing #{sym}"
  row1 = rows[0]
  row2 = rows[4]
  oc1 = row1.at_xpath("td[2]/text()").to_s.strip.to_f
  oc2 = row2.at_xpath("td[2]/text()").to_s.strip.to_f
  oc = oc1 - oc2
  op = oc / oc2 * 100
  hc1 = row1.at_xpath("td[3]/text()").to_s.strip.to_f
  hc2 = row2.at_xpath("td[3]/text()").to_s.strip.to_f
  hc = hc1 - hc2
  hp = hc / hc2 * 100
  lc1 = row1.at_xpath("td[4]/text()").to_s.strip.to_f
  lc2 = row2.at_xpath("td[4]/text()").to_s.strip.to_f
  lc = lc1 - lc2
  lp = lc / lc2 * 100
  cc1 = row1.at_xpath("td[5]/text()").to_s.strip.to_f
  cc2 = row2.at_xpath("td[5]/text()").to_s.strip.to_f
  cc = cc1 - cc2
  cp = cc / cc2 * 100
  stock = SOI.new(sym, oc, op, hc, hp, lc, lp, cc, cp)
  soi.push(stock)
end
soi.each do |s|
  s.printStock
end
