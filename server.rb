require "sinatra"
require "sinatra/json"
require "json"

CURRENT_FILE_PATH = File.dirname(__FILE__)

def parsed_books_json_data
  data = File.read(CURRENT_FILE_PATH + "/books.json")
  JSON.parse(data)
end

before do
  headers({ "Access-Control-Allow-Origin" => "*" })
end

get "/books.json" do
  status 200
  json parsed_books_json_data
end
