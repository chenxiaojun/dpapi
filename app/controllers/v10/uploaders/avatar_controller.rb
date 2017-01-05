module V10
  module Uploaders
    # 上传用户头像
    class AvatarController < ApplicationController
      include UserAccessible
      include Constants::Error::File
      before_action :login_required

      def create
        @current_user.avatar = upload_params[:avatar]
        # 检查文件格式
        if @current_user.avatar.blank? || @current_user.avatar.path.blank?
          return render_api_error(FORMAT_WRONG)
        end
        # 保存图片
        render render_api_error(UPLOAD_FAILED) unless @current_user.save
        # 上传成功 返回数据
        template = 'v10/account/users/base'
        V10::Account::RenderResultHelper.render_user_result(self, template, @current_user)
      end

      private

      def upload_params
        params.permit(:avatar)
      end
    end
  end
end
