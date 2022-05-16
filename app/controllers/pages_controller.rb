require "google/cloud/speech/v1"
class PagesController < ApplicationController
  def home
  end

  def transcript
    # Read the file from params
    uploaded_file = params["files"]
    audio_file = uploaded_file.read

    # Call private method speech_to_text doing the transcription
    google_text_obj = speech_to_text(audio_file)

    # Retrieve the text from the response.
    text = google_text_obj.first&.alternatives.first&.transcript
    
    # render it as a json
    render :json => { text: text }
  end

  private

  # You can put this in separate file as a part of module.
  def speech_to_text(audio_file)
    # read the credentials from credentials.json
    # For the project you want deploy to production, you might need put it inside .env 
    credentials = JSON.parse(File.read("app/controllers/concerns/credentials.json"))
    
    # Create a new client with credentials.
    client = ::Google::Cloud::Speech::V1::Speech::Client.new do |config|
      config.credentials = credentials
    end

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
