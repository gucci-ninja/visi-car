# Imports the Google Cloud client library
require "google/cloud/vision"
require 'open-uri'
# SOAP library
require 'savon'
# REST library
# require 'net/http'
# require 'uri'
# require 'json'


class RainydaysController < ApplicationController

    # This is our index page :)
    def index
        @latlong = [37.3333945,-121.8806499]
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
        input_string = ""

        client = Savon::Client.new do
            wsdl.document = "http://services.chromedata.com/Description/7b?wsdl"
        end

        response = client.request :urn, "VehicleDescriptionRequest" do
            soap.body = {
                ":urn:accountInfo" => nil, :attributes! => {
                    :number => ENV['SOAP_NUMBER'],
                    :secret => ENV['SOAP_SECRET'],
                    :country => "CA",
                    :language => "en"
                },
                "urn:modelYear" => input_string[0],
                "urn:makeName" => input_string[1],
                "urn:modelName" => input_string[2]
            }
        end

    end

    def here_maps(location)

    end

    # def best_deals
    #     location=""
    #     car_id=""

    #     uri = URI.parse("https://incentives.chromedata.com/BestOffer/offer/latest/")
    #     http = Net::HTTP.new(uri.host, uri.port)


    # end
end
