require ('pry')

class Artist
  attr_accessor :id, :name

  def initialize(attributes)
    @name = attributes.fetch(:name)
    @id = attributes.fetch(:id)
  end

  def self.all
    returned_artists = DB.exec("SELECT * FROM artists;")
    artists = []
    returned_artists.each() do |artist|
      name = artist.fetch("name")
      id = artist.fetch("id").to_i
      artists.push(Artist.new({:name => name, :id => id}))
    end
    artists
  end

  def save
    result = DB.exec("INSERT INTO artists (name) VALUES ('#{@name}') RETURNING id;") # update
    @id = result.first().fetch("id").to_i
  end

  def ==(artist_to_compare)
    self.name == artist_to_compare.name
  end

  def self.clear
    DB.exec("DELETE FROM artists *;")
  end

  def self.find(id)
    artist = DB.exec("SELECT * FROM artists WHERE id = #{id};").first # update
    name = artist.fetch("name")
    id = artist.fetch("id").to_i
    Artist.new({:name => name, :id => id})
  end

  def update(attributes)
    if (attributes.has_key?(:name)) && (attributes.fetch(:name) != nil)
      @name = attributes.fetch(:name)
      DB.exec("UPDATE artists SET name = '#{@name}' WHERE id = #{@id};")
    elsif (attributes.has_key?(:album_name)) && (attributes.fetch(:album_name) != nil)
      album_name = attributes.fetch(:album_name)
      album = DB.exec("SELECT * FROM albums WHERE lower(name)='#{album_name.downcase}';").first
      joined_result = DB.exec("SELECT * FROM albums_artists WHERE album_id = #{album['id'].to_i} AND artist_id=#{@id};").first
      if (album != nil) && (joined_result == nil)
        DB.exec("INSERT INTO albums_artists (album_id, artist_id) VALUES (#{album['id'].to_i}, #{@id});")
      end
    end
  end

  def delete
    DB.exec("DELETE FROM albums_artists WHERE artist_id = #{@id};")
    DB.exec("DELETE FROM artists WHERE id = #{@id};")
  end

  # def self.sort
  #   array = @@albums.values.sort_by! &:name
  #   @@albums = {}
  #   array.each do |element|
  #     @@albums[element.id] = element
  #   end
  # end

  # def songs
  #   Song.find_by_album(self.id)
  # end

  def albums
    albums = []
    results = DB.exec("SELECT album_id FROM albums_artists WHERE artist_id = #{@id};")
    results.each() do |result|
      album_id = result.fetch("album_id").to_i()
      album = DB.exec("SELECT * FROM albums WHERE id = #{album_id};")
      name = album.first().fetch("name")
      genre = album.first().fetch("genre")
      year = album.first().fetch("year")
      albums.push(Album.new({:name => name, :genre => genre, :year => year, :id => album_id}))
    end
    albums
  end
end