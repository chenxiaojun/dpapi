# meta info
json.partial! 'common/meta'
# code & msg
json.partial! 'common/api_result', api_result: ApiResult.success_result
# data
json.data do
  json.id          @info.id
  json.type_id     @info.info_type_id
  json.type        @info.info_type.try(:name).to_s
  json.tag_id      @info.race_tag_id
  json.tag         @info.race_tag.try(:name).to_s
  json.title       @info.title.to_s
  json.date        @info.date
  json.source_type @info.source_type.to_s
  json.source      @info.source.to_s
  json.image       @info.big_image.to_s
  json.image_thumb @info.image_thumb.to_s
  json.top         @info.top
  json.description @info.description.to_s
end