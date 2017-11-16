import React, { Component } from 'react';

class App extends Component {
  constructor(props) {
    super(props);
    this.state = {
      books: []
    };
  }

  componentDidMount() {
    fetch('http://localhost:4567/books.json')
      .then(response => {
        if (response.ok) {
          return response;
        } else {
          let errorMessage = `${response.status} (${response.statusText})`,
              error = new Error(errorMessage);
          throw(error);
        }
      })
      .then(response => response.json())
      .then(body => {
        let nextBooks = body.books;
        this.setState({ books: nextBooks });
      })
      .catch(error => console.error(`Error in fetch: ${error.message}`));
  }

  render() {
    let books = this.state.books.map(book => {
      return <li key={book.id}>{book.name}</li>;
    });

    return (
      <div>
        <h1>Books</h1>
        <ul>
          {books}
        </ul>
      </div>
    );
  }
}

export default App;
