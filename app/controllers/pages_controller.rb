require "google/cloud/speech/v1"
class PagesController < ApplicationController
  def home
  end

  def transcript
    # Read the file from params
    uploaded_file = params["files"]
    audio_file = uploaded_file.read

    # Call private method speech_to_text responsible for transcription
    google_text_obj = speech_to_text(audio_file)

    # Retrieve the text from the response.
    text = google_text_obj.first&.alternatives.first&.transcript
    
    # render it as a json
    render :json => { text: text }
  end

  private

  # You can put this in separate file as a part of module.
  def speech_to_text(audio_file)
    # reading the credentials from credentials.json
    # For the project you want to production, you might want to put it inside .env 
    credentials = JSON.parse(File.read("app/controllers/concerns/credentials.json"))
    
    # Creating a new client with credentials.
    client = ::Google::Cloud::Speech::V1::Speech::Client.new do |config|
      config.credentials = credentials
    end

    # You shouldn't need to manual setup everything since we don't know exact hertz and everything.
    # For more config options and best practices, check https://cloud.google.com/speech-to-text/docs/best-practices
    config = {
      language_code: 'ja-JP',
      enable_separate_recognition_per_channel: true
    }
    audio = { content: audio_file }
    puts "Operation started"
    response = client.recognize config: config, audio: audio
    results = response.results
    return results
  end
end
