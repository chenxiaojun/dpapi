json.id          list.id
json.type_id     list.info_type_id
json.type        list.info_type.try(:name).to_s
json.tag_id      list.race_tag_id
json.tag         list.race_tag.try(:name).to_s
json.title       list.title.to_s
json.date        list.date
json.source_type list.source_type.to_s
json.source      list.source.to_s
json.image       list.big_image.to_s
json.image_thumb list.image_thumb.to_s
json.top         false
json.description list.description.to_s