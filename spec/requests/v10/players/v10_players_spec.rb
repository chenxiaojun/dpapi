require 'rails_helper'

RSpec.describe '/v10/players', :type => :request do
  let(:players) do
    FactoryGirl.create(:player, name: 'poker_1')
    FactoryGirl.create(:player, name: 'poker_2')
    FactoryGirl.create(:player, name: 'poker_3')
    FactoryGirl.create(:player, name: 'poker_4')
    FactoryGirl.create(:player, name: 'poker_5', country: '美国')
  end
  let!(:dpapi_affiliate) { FactoryGirl.create(:affiliate_app) }
  let(:http_headers) do
    {
        ACCEPT: 'application/json',
        HTTP_ACCEPT: 'application/json',
        HTTP_X_DP_CLIENT_IP: 'localhost',
        HTTP_X_DP_APP_KEY: '467109f4b44be6398c17f6c058dfa7ee'
    }
  end

  context '获取牌手列表' do
    it '筛选国内的牌手' do
      players
      params = { region: 'domestic' }
      get v10_players_url,
          headers: http_headers,
          params: params

      expect(response).to have_http_status(200)
      json = JSON.parse(response.body)
      expect(json['data'].size).to eq(4)
    end

    it '筛选2017的牌手' do
      players
      params = { region: 'domestic', begin_year: 2017 }
      get v10_players_url,
          headers: http_headers,
          params: params

      expect(response).to have_http_status(200)
      json = JSON.parse(response.body)
      expect(json['data'].size).to eq(0)
    end

    it '返回空列表' do
      get v10_players_url,
          headers: http_headers
      expect(response).to have_http_status(200)
      json = JSON.parse(response.body)
      expect(json['data']).to eq([])
    end
  end
end