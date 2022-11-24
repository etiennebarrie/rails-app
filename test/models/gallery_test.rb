require "test_helper"

class GalleryTest < ActiveSupport::TestCase
  test "purging with deprecation" do
    gallery = Gallery.create!
    File.open("config/application.rb") do |file|
      gallery.photos.attach(io: file, filename: "photo.jpg")
    end
    gallery.photos_attachments.purge
  end
end
