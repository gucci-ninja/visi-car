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

    # This is our index page :)
    def index
        @latlong = [37.3333945,-121.8806499]
        best_deals
    end

    def cloud_vision
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

        open(img_url) do |img|

            image = vision.image(img)
            auto_strings = Array.new # year, brand, model
            # puts image.text

            # annotation = vision.annotate(image, labels: true, text: true)
            # puts annotation
            # Performs label detection on the image file
            labels = vision.image(image).labels

            puts "Labels:"
            labels.each do |label|
                puts label.description
                # find the right label
                auto_strings[0] = label.match(/\d{4}/)  
                label = label.gsub(auto_strings[0])

                auto_strings[1] = cars.select{ |str| label.include?(str)}
                label = label.gsub(auto_strings[1])

                auto_strings[2] = label.strip
            end
            @location = best_deals(style_extractor(auto_strings))
            here_maps(@location)
        end
        redirect_to root_path
    end

    def style_extractor
        input_string = ["2016","Tesla","Model S"]

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

    def best_deals
        # location, car id
        raw_url="https://incentives.chromedata.com/BestOffer/offer/latest/%s/%s/offers.json" % ["L6K3S3", style_extractor]
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
