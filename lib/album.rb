require ('pry')

class Album
  attr_accessor :id, :name, :genre, :year

  def initialize(attributes)
    @name = attributes.fetch(:name)
    @genre = attributes.fetch(:genre)
    @year = attributes.fetch(:year)
    @id = attributes.fetch(:id)
  end

  def self.all
    returned_albums = DB.exec("SELECT * FROM albums;")
    albums = []
    returned_albums.each() do |album|
      name = album.fetch("name")
      genre = album.fetch("genre")
      year = album.fetch("year").to_i
      id = album.fetch("id").to_i
      albums.push(Album.new({:name => name, :genre => genre, :year => year, :id => id}))
    end
    albums
  end

  def save
    result = DB.exec("INSERT INTO albums (name, genre, year) VALUES ('#{@name}', '#{@genre}', #{@year}) RETURNING id;") # update
    @id = result.first().fetch("id").to_i
  end

  def ==(album_to_compare)
    (self.name == album_to_compare.name) && (self.year == album_to_compare.year) && (self.genre == album_to_compare.genre)
  end

  def self.clear
    DB.exec("DELETE FROM albums *;")
  end

  def self.find(id)
    album = DB.exec("SELECT * FROM albums WHERE id = #{id};").first # update
    name = album.fetch("name")
    genre = album.fetch("genre")
    year = album.fetch("year").to_i
    id = album.fetch("id").to_i
    Album.new({:name => name, :genre => genre, :year => year, :id => id})
  end

  def update(name, genre, year) # update for all attributes
    @name = name
    @genre = genre
    @year = year
    DB.exec("UPDATE albums SET name='#{@name}', genre='#{@genre}', year=#{@year} WHERE id = #{@id};")
  end

  def delete # update
    DB.exec("DELETE FROM albums WHERE id = #{@id};")
    DB.exec("DELETE FROM songs WHERE album_id = #{@id};") # new code
  end

  # def self.sort
  #   array = @@albums.values.sort_by! &:name
  #   @@albums = {}
  #   array.each do |element|
  #     @@albums[element.id] = element
  #   end
  # end

  def songs
    Song.find_by_album(self.id)
  end
end