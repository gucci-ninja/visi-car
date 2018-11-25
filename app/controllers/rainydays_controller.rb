# Imports the Google Cloud client library
require "google/cloud/vision"
require 'open-uri'

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
    
end
