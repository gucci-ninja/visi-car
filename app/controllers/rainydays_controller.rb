# Imports the Google Cloud client library
require "google/cloud/vision"
require 'open-uri'
require 'savon'

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
            puts image.text

            annotation = vision.annotate(image, labels: true, text: true)
            puts annotation

          end

    end

    def style_extractor
        input_string = ""
        puts 

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
                }
                "urn:modelYear" => input_string[0]
                "urn:makeName" => input_string[1]
                "urn:modelName" => input_string[2]
            }
        end

    end

end
