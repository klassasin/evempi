require 'rubygems'
require 'fastercsv'
require 'net/http'
require 'uri'
require 'pp'

class MineralIndex
	def initialize	
		@url = "http://www.eve-factory.com/thmi/thmi-api.php?region=10000002&system=30000142&pricetype=ask&export=csv"
		@index = Hash.new
		@dates = Array.new
	end

	def loadData
		begin
			s = Net::HTTP::get URI::parse(@url)
			data = FasterCSV::parse(s)
			(1..data.length-1).each { |idx|
		 		@index[data[idx][6]] = data[idx][7].to_f
				@dates << data[idx][3]
			}
		rescue NoMethodError => e
			puts "The Mineral Index Source could not be reached"
			exit
		rescue Net::ProtoRetriableError => detail
    	head = detail.data
  		if head.code == "301"
    		uri = URI.create(head['location'])
    		s = Net::HTTP::get(uri, port)
    		retry
			end
		rescue URI::InvalidURIError => e
			puts "The URI is invalid for the mineral index information"
			puts "\n#{e.message}\n"
			exit
		rescue FasterCSV::MalformedCSVError => e
			puts "The source CSV file for the mineral index is corrupt and could not be parsed."
			puts "\n#{e.message}\n"
			exit 
		end
	end

	def dts
		return @dates.sort!.last
	end

	def display
		puts "--- Mineral Price Index ---\n\n"
		@index.sort{|a,b| a[1]<=>b[1]}.each { |mineral, price| 
			printf "%10s %8.2f\n", mineral, price
		}
		puts "\n--- #{self.dts} ---"			
	end
end
