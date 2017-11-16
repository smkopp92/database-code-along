require "sinatra"
require "sinatra/json"
require "json"
require "pg"

def db_connection
  begin
    connection = PG.connect(dbname: "books")
    yield(connection)
  ensure
    connection.close
  end
end

CURRENT_FILE_PATH = File.dirname(__FILE__)

def parsed_books_json_data
  data = File.read(CURRENT_FILE_PATH + "/books.json")
  JSON.parse(data)
end

def books_from_database
  books = db_connection { |conn| conn.exec("SELECT * FROM books") }
  {
    books: books.map{ |book| book }
  }
end

before do
  headers({ "Access-Control-Allow-Origin" => "*" })
end

get "/books.json" do
  status 200
  json books_from_database
end
