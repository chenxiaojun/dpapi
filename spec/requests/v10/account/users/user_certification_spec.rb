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

  let!(:user) { FactoryGirl.create(:user) }
  let!(:user2) { FactoryGirl.create(:user) }
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
      it "应当返回code: 1100033" do
        get v10_account_user_certification_index_url(user2.user_uuid),
            headers: http_headers.merge({HTTP_X_DP_ACCESS_TOKEN: access_token})
        expect(response).to have_http_status(200)
        json = JSON.parse(response.body)
        expect(json['code']).to eq(1100033)
      end
    end

    context "是当前用户，并且该用户已实名过" do
      it "应当返回code: 0" do
        get v10_account_user_certification_index_url(user.user_uuid),
            headers: http_headers.merge({HTTP_X_DP_ACCESS_TOKEN: access_token})
        expect(response).to have_http_status(200)
        json = JSON.parse(response.body)
        expect(json['data']['real_name']).to eq('测试用户')
        expect(json['data']['cert_type']).to eq('chinese_id')
        expect(json['data']['cert_no']).to eq('0802022017021611200101')
        expect(json['data']['memo']).to eq('身份证')
      end
    end
  end

  context "添加用户实名信息" do
    extra_params = { real_name: '小白', cert_no: '232721198605227410' }
    context "未登录情况下访问" do
      it "应当返回code: 805" do
        post v10_account_user_certification_index_url(12),
            headers: http_headers,
             params: extra_params
        expect(response).to have_http_status(805)
      end
    end

    context "传递过来的用户id不是当前用户" do
      it "应当返回code: 806" do
        post v10_account_user_certification_index_url(12),
            headers: http_headers.merge({HTTP_X_DP_ACCESS_TOKEN: access_token}),
             params: extra_params
        expect(response).to have_http_status(806)
      end
    end

    context "用户已实名过" do
      it "应当返回code: 1100034" do
        post v10_account_user_certification_index_url(user.user_uuid),
             headers: http_headers.merge({HTTP_X_DP_ACCESS_TOKEN: access_token}),
             params: extra_params
        expect(response).to have_http_status(200)
        json = JSON.parse(response.body)
        expect(json['code']).to eq(1100034)
      end
    end

    context "用户未实名过" do
      context "传入不正确的姓名格式" do
        it "应当返回code: 1100036" do
          post v10_account_user_certification_index_url(user2.user_uuid),
               headers: http_headers.merge({HTTP_X_DP_ACCESS_TOKEN: access_token}),
               params: { real_name: '111111', cert_no: '232721198605227410' }
          expect(response).to have_http_status(200)
          json = JSON.parse(response.body)
          expect(json['code']).to eq(1100036)
        end

        it "应当返回code: 1100036" do
          post v10_account_user_certification_index_url(user2.user_uuid),
               headers: http_headers.merge({HTTP_X_DP_ACCESS_TOKEN: access_token}),
               params: { real_name: '王shi', cert_no: '232721198605227410' }
          expect(response).to have_http_status(200)
          json = JSON.parse(response.body)
          expect(json['code']).to eq(1100036)
        end
      end

      context "传入不正确的身份证号码" do
        it "应当返回code: 1100035" do
          post v10_account_user_certification_index_url(user2.user_uuid),
               headers: http_headers.merge({HTTP_X_DP_ACCESS_TOKEN: access_token}),
               params: { real_name: '王小五', cert_no: 'test123' }
          expect(response).to have_http_status(200)
          json = JSON.parse(response.body)
          expect(json['code']).to eq(1100035)
        end
      end

      context "身份证号码已存在" do
        it "应当返回code: 1100037" do
          user_extra
          post v10_account_user_certification_index_url(user2.user_uuid),
               headers: http_headers.merge({HTTP_X_DP_ACCESS_TOKEN: access_token}),
               params: { real_name: '王小五', cert_no: '611002199301146811' }
          expect(response).to have_http_status(200)
          json = JSON.parse(response.body)
          expect(json['code']).to eq(1100037)
        end
      end

      context "实名认证成功" do
        it "应当返回code: 0" do
          post v10_account_user_certification_index_url(user2.user_uuid),
               headers: http_headers.merge({HTTP_X_DP_ACCESS_TOKEN: access_token}),
               params: { real_name: '王小五', cert_no: '232721198605227410' }
          expect(response).to have_http_status(200)
          json = JSON.parse(response.body)
          expect(json['code']).to eq(0)
        end
      end
    end
  end
end