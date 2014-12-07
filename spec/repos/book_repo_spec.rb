require 'spec_helper'

describe Library::BookRepo do
    
  def book_count(db)
    db.exec("SELECT COUNT(*) FROM books")[0]["count"].to_i
  end

  let(:db) { Library.create_db_connection('library_test') }

  before(:each) do
    Library.clear_db(db)
  end
  
  it "gets all books" do
    sql = %q[
      INSERT INTO books (title,author)
      VALUES ($1,$2);
    ]
    db.exec(sql, ["Alice in Wonderland","Lewis Carrol"])
    db.exec(sql, ['1984','George Orwell'])

    books = Library::BookRepo.all(db)
    expect(books).to be_a Array
    expect(books.count).to eq 2

    titles = books.map {|b| b['title'] }
    expect(titles).to include "Alice in Wonderland", "1984"
    authors = books.map {|b| b['author']}
    expect(authors).to include 'Lewis Carrol', 'George Orwell'
  end
  
  it "creates books" do
    expect(book_count(db)).to eq 0

    book = Library::BookRepo.save(db, { 'title' => "Alice in Wonderland", 'author' => 'Lewis Carrol' })
    expect(book['id']).to_not be_nil
    expect(book['title']).to eq "Alice in Wonderland"
    expect(book['author']).to eq 'Lewis Carrol'
    expect(book['status']).to eq 'available'
    expect(book['borrower']).to be_nil

    # Check for persistence
    expect(book_count(db)).to eq 1

    book = db.exec("SELECT * FROM books")[0]
    expect(book['id']).to_not be_nil
    expect(book['title']).to eq "Alice in Wonderland"
    expect(book['author']).to eq 'Lewis Carrol'
    expect(book['status']).to eq 'available'
    expect(book['borrower']).to be_nil
  end
  
end