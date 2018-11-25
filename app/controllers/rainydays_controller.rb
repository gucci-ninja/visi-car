# Imports the Google Cloud client library
require "google/cloud/vision"
require 'open-uri'
# SOAP library
require 'savon'
# REST library
require 'httparty'
# require 'net/http'
# require 'uri'
# require 'json'


class RainydaysController < ApplicationController
    @latlong = [37.3333945,-121.8806499]
    @url_image = "http://www.evolvefish.com/thumbnail.asp?file=assets/images/vinyl%20decals/EF-VDC-00035(black).jpg&maxx=300&maxy=0"
    # This is our index page :)
    def index
        @url_image = "http://www.evolvefish.com/thumbnail.asp?file=assets/images/vinyl%20decals/EF-VDC-00035(black).jpg&maxx=300&maxy=0"
        @latlong = [37.3333945,-121.8806499]
        @vins = Vin.all
    end

    def cloud_vision
        #@url_image = "http://www.evolvefish.com/thumbnail.asp?file=assets/images/vinyl%20decals/EF-VDC-00035(black).jpg&maxx=300&maxy=0"
        img_url = params[:img_url]
        puts img_url

        cars = ["Ford",
            "Toyota",
            "Honda",
            "Chevrolet",
            "Nissan",
            "Hyundai",
            "Ram",
            "GMC",
            "Kia",
            "Dodge"]

        # Your Google Cloud Platform project ID
        project_id = ENV['PROJECT_ID']

        # Instantiates a client
        vision = Google::Cloud::Vision.new project: project_id

        #image  = vision.image "./images/car.jpg"
        auto_strings = Array.new # year, brand, mode
        open(img_url) do |img|

            image = vision.image(img)
            
            # puts image.text

            # annotation = vision.annotate(image, labels: true, text: true)
            # puts annotation
            # Performs label detection on the image file
            labels = vision.image(image).labels

            puts "Labels:"
            labels.each do |label|
                #puts label.description
                lbl = label.description
                # find the right label
                #puts "chcking if label incldes brands in cars"
                cars.each do |car|
                    if lbl.upcase.include?(car.upcase)
                        puts "hey we found a toota"
                        auto_strings[1] = car
                        if lbl.split(" ").length > 1
                            lbl = lbl.downcase.gsub(car.downcase, "")
                            auto_strings[0] = lbl.match(/\d{4}/)
                            if auto_strings[0] == nil
                                auto_strings[0] = "2016"
                            end
                            lbl = lbl.gsub(auto_strings[0], "")
                            auto_strings[2] = lbl.strip
                        else
                            next
                        end
                    end
                end

                #puts brand
                if cars.select{ |str| lbl.include?(str)}
                   # puts "found 1"
                end
            end

            puts "auto string ================================"
            puts auto_strings
            puts "auto string ================================"
            @car = auto_strings.join(" ").upcase
            @big_jsons = best_deals(style_extractor(auto_strings))
            #here_maps(@location)

        end
        @latlong = [37.3333945,-121.8806499]
        @vin = Vin.new
        @vin.brand = auto_strings[1]
        @vin.model = auto_strings[2]
        @vin.save
        @url_image = img_url
        render :index
    end

    def style_extractor(input_string)
        #input_string = ["2016","Tesla","Model S"]

        client = Savon.client(:wsdl => "http://services.chromedata.com/Description/7b?wsdl", :log => false)

        response = client.call(
            :describe_vehicle,
            message: {
                :account_info =>{
                    :@secret => ENV['AUTO_SECRET'],
                    :@number => ENV['AUTO_USER'],
                    :@country => "CA",
                    :@language => "en"
                },
                :model_year => input_string[0],
                :make_name => input_string[1],
                :model_name => input_string[2],
                # :vin => "?",
            }
        ).to_hash
        
        puts response[:vehicle_description][:style][0][:acode]
        return response[:vehicle_description][:style][0][:acode]
        
    end

    def here_maps(location)
    end

    def best_deals(style_extract)
        # location, car id
        raw_url="https://incentives.chromedata.com/BestOffer/offer/latest/%s/%s/offers.json" % ["L6K3S3", style_extract]
        puts raw_url

        auth = { 
            :username  => "317789",
            :password => 'd4297c7dc3d94bf3' 
        }
        
        base_uri = URI.parse(raw_url)
        puts base_uri

        request = HTTParty.get(
            base_uri.to_s,
            :basic_auth => auth
        )
        # do something with it
        puts request.parsed_response
        
    end
end
