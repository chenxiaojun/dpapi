class RacePhotoUploader < BaseUploader
  version :preview do
    process resize_to_fit: [200, 200]
  end

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end
end
