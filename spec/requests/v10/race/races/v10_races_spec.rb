require 'rails_helper'

RSpec.describe '/v10/u/:u_id/races', :type => :request do

  let!(:dpapi_affiliate) { FactoryGirl.create(:affiliate_app) }
  let(:http_headers) do
    {
        ACCEPT: 'application/json',
        HTTP_ACCEPT: 'application/json',
        HTTP_X_DP_CLIENT_IP: 'localhost',
        HTTP_X_DP_APP_KEY: '467109f4b44be6398c17f6c058dfa7ee'
    }
  end
  let(:user) { FactoryGirl.create(:user) }
  let(:init_races) do
    20.times { FactoryGirl.create(:race) }
  end

  context '当不传参数进行访问时' do
    it '应回参数有误' do
      get v10_u_races_url(0),
          headers: http_headers,
          params: { }

      expect(response).to have_http_status(200)
      json = JSON.parse(response.body)
      expect(json['code']).to eq(1100004)
    end
  end

  context '给定不存在赛事列表，当获取赛事时' do
    it '应当返回空数组' do
      get v10_u_races_url(0),
          headers: http_headers,
          params: { page_size: 20, operator: :forward, begin_date: Time.now }

      expect(response).to have_http_status(200)
      json = JSON.parse(response.body)
      expect(json['code']).to eq(0)

      races = json['data']['items']
      expect(races.class).to      eq(Array)
      expect(races.size.zero?).to be_truthy
    end
  end

  context '给定存在20条赛事，当获取10条赛事时' do
    it '应当返回10条赛事，数据格式应正常' do
      init_races
      get v10_u_races_url(0),
          headers: http_headers,
          params: { page_size: 10,
                    operator: :forward,
                    begin_date: Time.now.strftime('%Y-%m-%d') }


      expect(response).to have_http_status(200)
      json = JSON.parse(response.body)
      expect(json['code']).to eq(0)
      races = json['data']['items']
      expect(races.class).to      eq(Array)
      expect(races.size).to       eq(10)
      races.each do |race|
        expect(race['name'].class).to       eq(String)
        expect(race['logo'].class).to       eq(String)
        expect(race['prize'].class).to      eq(String)
        expect(race['location'].class).to   eq(String)
        expect(race['begin_date'].class).to eq(String)
        expect(race['end_date'].class).to   eq(String)
        expect(race['status'].class).to     eq(String)
        expect(race['ticket_status'].class).to eq(String)
        expect(race['ticket_sellable']).to eq(true)
        expect(race['describable']).to     eq(true)
        expect(race.key?('seq_id')).to      be_truthy
        expect( %w(true false) ).to    include(race['followed'].to_s)
        expect( %w(true false) ).to    include(race['ordered'].to_s)
      end
    end
  end

  context '存在一条赛事' do
    it '返回的logo路径应正确' do
      race = FactoryGirl.create(:race)
      get v10_u_races_url(0),
          headers: http_headers,
          params: { page_size: 10,
                    operator: :forward,
                    begin_date: Time.now.strftime('%Y-%m-%d') }

      json = JSON.parse(response.body)
      expect(json['code']).to eq(0)
      races = json['data']['items']
      expect(races[0]['logo']).to eq(race.preview_logo)
      expect(races[0]['big_logo']).to eq(race.big_logo)
    end
  end

  context '给定存在20条赛事，当以日期为当天并以down操作获取赛事时' do
    it '排序应为开始日期的正序，开始日期与结束日期都是大于或等于当天的' do
      init_races
      get v10_u_races_url(0),
          headers: http_headers,
          params: { page_size: 10,
                    operator: :forward,
                    begin_date: Time.now.strftime('%Y-%m-%d') }

      expect(response).to have_http_status(200)
      json = JSON.parse(response.body)
      expect(json['code']).to eq(0)
      races = json['data']['items']
      expect(races.class).to      eq(Array)
      expect(races.size).to       eq(10)
      races.each_with_index do |race, index|
        expect(Time.parse(race['begin_date']) >= Time.now.beginning_of_day).to be_truthy
        expect(Time.parse(race['end_date']) >= Time.now.beginning_of_day).to be_truthy
        next if index.zero?

        first_begin_date = Time.parse(races[index - 1]['begin_date'])
        second_begin_date = Time.parse(race['begin_date'])
        expect(second_begin_date >= first_begin_date).to be_truthy
      end
    end
  end

  context '给定存在20条赛事，当以seq_id并以up操作获取赛事时' do
    it '那么应race的seq_id都是小于参数的seq_id' do
      init_races
      seq_id = Race.last.seq_id
      get v10_u_races_url(0),
          headers: http_headers,
          params: { page_size: 10,
                    operator: :backward,
                    seq_id: seq_id }

      expect(response).to have_http_status(200)
      json = JSON.parse(response.body)
      expect(json['code']).to eq(0)
      races = json['data']['items']
      expect(races.class).to      eq(Array)
      races.each do |race|
        expect(race['seq_id'] < seq_id).to be_truthy
      end
    end
  end

  context '给定存在20条赛事，当以seq_id并以down操作获取赛事时' do
    it '那么应race的seq_id都是大于参数的seq_id' do
      init_races
      seq_id = Race.first.seq_id
      get v10_u_races_url(0),
          headers: http_headers,
          params: { page_size: 10,
                    operator: :forward,
                    seq_id: seq_id }

      expect(response).to have_http_status(200)
      json = JSON.parse(response.body)
      expect(json['code']).to eq(0)
      races = json['data']['items']
      expect(races.class).to      eq(Array)
      races.each do |race|
        expect(race['seq_id'] > seq_id).to be_truthy
      end
    end
  end
end