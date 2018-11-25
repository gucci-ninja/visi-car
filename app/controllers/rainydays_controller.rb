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
    end

    def cloud_vision
        img_url = params[:img_url]
        puts img_url
        # Your Google Cloud Platform project ID
        project_id = ENV['PROJECT_ID']

        # Instantiates a client
        vision = Google::Cloud::Vision.new project: project_id

        #image  = vision.image "./images/car.jpg"

        open(img_url) do |img|

            image = vision.image(img)
            # puts image.text

            # annotation = vision.annotate(image, labels: true, text: true)
            # puts annotation
            # Performs label detection on the image file
            labels = vision.image(image).labels

            puts "Labels:"
            labels.each do |label|
                puts label.description
            end
        end
        redirect_to root_path
    end

    def style_extractor
        input_string = ["2016","Chrysler","200"]

        client = Savon.client(:wsdl => "http://services.chromedata.com/Description/7b?wsdl", :log => false)

        response = client.call(
            :describe_vehicle,
            message: {
                :account_info =>{
                    :@number => "317789",
                    :@secret =>  "d4297c7dc3d94bf3",
                    :@country => "CA",
                    :@language => "en"
                },
                :model_year => input_string[0],
                :make_name => input_string[1],
                :model_name => input_string[2],
                # :vin => "?",
            }
        ).to_hash


        return response[:vehicle_description][:style][0][:acode]
        
    end
        # :secret => ENV['AUTO_SECRET'],
        # :number => ENV['AUTO_USER'],

    def best_deals
        # location, car id
        input_path="/%s/%s/" % ["97232", "378067"]
        puts input_path

        headers = { 
            "Username"  => ENV['AUTO_USER'],
            "Password" => ENV['AUTO_SECRET'] 
        }
        base_uri = URI.join("https://incentives.chromedata.com/BestOffer/offer/latest", input_path, "offers.json")
        puts base_uri

        request = HTTParty.get(
            base_uri.to_s, 
            :headers => headers
        )
        # do something with it
        puts request.parsed_response

    end
end
