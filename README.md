Database Practice in a React App!

## Starting Code

To get started, let's get our server running and node running.

In one terminal tab:

```no-highlight
bundle
ruby server.rb
```

And in another terminal tab:

```no-highlight
npm install
npm start
```

If we visit [localhost:8080](localhost:8080), we should see our initial app with a list of books.

## Our Mission

Our mission is to set up a database, create instances of books within the database, and use those books for our application instead of the books supplied in the `books.json` file.

We can break this into the following steps:

- Install Postgres
- Create our first database
- Create our first database table
- Add book records to our database
- Define a `schema` to represent our table
- Define a `seeder` to expedite book creation
- Access those book records from our `server.rb` file
- Convert the book records to a json format

## Installing Postgres

[https://learn.launchacademy.com/teams/philadelphia-4/curricula/on-campus-philly-4/lesson_groups/week_5:_databases/lessons/install-postgres-app] Horizon Lesson

## Creating our first Database

From the command line, we can create a database with the following code:

```no-highlight
createdb NAME_OF_YOUR_DATABASE
```

Let's create a database with the name `books`.

## Creating our first Database Table

We can use the following to open our database:

```no-highlight
psql books
```

Once there, we have the ability to use sql code to access and modify our database.

Our books table needs two columns, `id` and `name`.

```
CREATE TABLE books(
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL
);
```

Please note that the semicolon is very important for sql.

`NOT NULL` indicates that the name column can never be blank for a record.

## Add book records to our database

Let's add some books! In our psql server, we can add books one at a time:

```
INSERT INTO books(name)
VALUES ('Snow Crash');
```

We can also add multiple books at once:

```
INSERT INTO books(name)
VALUES ('Redwall'), ('Enders Game');
```

Notice how we do not identify an `id`, because `SERIAL PRIMARY KEY`s are auto-incrementing, unique integers.

Examining our database:

`\d` Shows us the breakdown of our database

`\d books` Shows us the breakdown of our books table

`SELECT * FROM books;` Retrieves all our book records.

`SELECT name FROM books;` Retrieves all our book records only displaying their names.

`\q` Takes us out of the database! We can also get back in with `psql books`.

## Define a `schema` to represent our table

We don't want to manually set up our database for our applications, so we can create a `schema.sql` file. It's sole purpose is store the structure of our database to a file.

We will soon automatically generate schemas, but for now, let's write one ourselves.

```
#schema.sql
CREATE TABLE books(
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL
);
```

For someone to import the schema to their local database, they can run the following in the command line:

```
psql books < schema.sql
```

## Define a `seeder` to expedite book creation

We can use a similar strategy for creating book records.

Let's create a file, `seeds.sql`, and add our book generation sql query there! Feel free to modify the names and the quantity of books!

```
#seeds.sql
INSERT INTO books(name)
VALUES ('Redwall'), ('Enders Game');
```

Finally, to import these books to our database, we can use the following command in our command line:

```
psql books < seeds.sql
```

Now, we have the ability to initialize our database and data using code supplied in our code base!

## Access those book records from our `server.rb` file

First, we need to install the `pg` gem.

Add `gem "pg"` to the Gemfile.

Then, stop your ruby server, `bundle`, then start the ruby server again.

Now that we have the pg gem installed, we can access our database from our `server.rb` file.

At the top of our `server.rb` file, add the following code:

```ruby
require "pg"

def db_connection
  begin
    connection = PG.connect(dbname: "books")
    yield(connection)
  ensure
    connection.close
  end
end
```

The `db_connection` method allows us to connect to a specified database.

We can retrieve all our books using this method.

In the command line, open a `pry` or `irb` session, require the server.rb file using `require './server.rb'`, and then use the following code to retrieve books.

```
books = db_connection { |conn| conn.exec("SELECT * FROM books") }
{
```

With this, we can examine our data in the `books` variable.

## Convert the book records to a json format

Now, let's change our sinatra endpoint to retrieve books from our database instead of `books.json`.

First, in server.rb, write the following method to retrieve our books and set the records to a hash:

```ruby
def books_from_database
  books = db_connection { |conn| conn.exec("SELECT * FROM books") }
  return {
    books: books.map{ |book| book }
  }
end
```

Next, let's use that method in our sinatra endpoint:

```ruby
get "/books.json" do
  status 200
  json books_from_database
end
```

Now, restart the server, open [localhost:8080](localhost:8080), and see the book records from your database display on the page!

And that's how persistence works in the context of a sinatra/react application using postgres.

Final code for `server.rb`:

```ruby
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
```
