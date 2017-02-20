require 'rails_helper'

RSpec.describe "/v10/account/users/:user_id/certification", :type => :request do
  let!(:dpapi_affiliate) { FactoryGirl.create(:affiliate_app) }
  let(:http_headers) do
    {
        ACCEPT: "application/json",
        HTTP_ACCEPT: "application/json",
        HTTP_X_DP_CLIENT_IP: "localhost",
        HTTP_X_DP_APP_KEY: "467109f4b44be6398c17f6c058dfa7ee"
    }
  end

  let(:user) { FactoryGirl.create(:user) }
  let(:user_extra) { FactoryGirl.create(:user_extra, {user_id: user.id}) }

  let(:access_token) do
    AppAccessToken.jwt_create('18ca083547bb164b94a0f89a7959548b', user.user_uuid)
  end

  context "获取用户实名信息" do
    context "未登录情况下访问" do
      it "应当返回code: 805" do
        get v10_account_user_certification_index_url(12),
            headers: http_headers
        expect(response).to have_http_status(805)
      end
    end

    context "传递过来的用户id不是当前用户" do
      it "应当返回code: 806" do
        get v10_account_user_certification_index_url(12),
            headers: http_headers.merge({HTTP_X_DP_ACCESS_TOKEN: access_token})
        expect(response).to have_http_status(806)
      end
    end

    context "是当前用户，但是该用户未实名" do
      it "应当返回code: 1100051" do
        get v10_account_user_certification_index_url(user.user_uuid),
            headers: http_headers.merge({HTTP_X_DP_ACCESS_TOKEN: access_token})
        expect(response).to have_http_status(200)
        json = JSON.parse(response.body)
        expect(json['code']).to eq(1100051)
      end
    end

    context "是当前用户，并且该用户已实名过" do
      it "应当返回code: 0" do
        user_extra
        get v10_account_user_certification_index_url(user.user_uuid),
            headers: http_headers.merge({HTTP_X_DP_ACCESS_TOKEN: access_token})
        expect(response).to have_http_status(200)
        json = JSON.parse(response.body)
        expect(json['data']['user_extra']['real_name']).to eq('王石')
        expect(json['data']['user_extra']['cert_no']).to eq('611002199301146811')
      end
    end
  end
end