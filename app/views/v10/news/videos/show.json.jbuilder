# meta info
json.partial! 'common/meta'
# code & msg
json.partial! 'common/api_result', api_result: ApiResult.success_result
# data
json.data do
  json.id          @video.id
  json.type_id     @video.video_type_id
  json.type        @video.video_type.try(:name).to_s
  json.name        @video.name.to_s
  json.title_desc  @video.title_desc.to_s
  json.video_link  @video.video_link
  json.cover_link  @video.cover_link.to_s
  json.top         @video.top
  json.description @video.description.to_s
  json.video_duration @video.video_duration.to_s
end