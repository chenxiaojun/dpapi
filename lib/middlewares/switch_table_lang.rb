module DpAPI
  SUPPORT_HEADER_LANG = %w(cn en).freeze
  SWITCH_MODEL_LIST = %w(Info InfoType Race Ticket Video VideoType).freeze

  class SwitchTableLang
    def initialize(app)
      @app = app
    end

    def call(env)
      lang = (env['HTTP_X_DP_LANG'] || 'cn').strip
      return wrong_header_lang unless SUPPORT_HEADER_LANG.include?(lang)
      switch_lang lang
      @app.call(env)
    end

    private

    def switch_lang(lang)
      lang.eql?('cn') ? switch_table_cn : switch_table_ln(lang)
    end

    def switch_table_cn
      origin_table
    end

    def switch_table_ln(lang)
      target_table lang
    end

    def origin_table
      SWITCH_MODEL_LIST.collect do |t|
        t.safe_constantize.table_name = t.underscore.pluralize
      end
    end

    def target_table(lang)
      SWITCH_MODEL_LIST.collect do |t|
        t.safe_constantize.table_name = "#{t.underscore}_#{lang.pluralize}"
      end
    end

    def wrong_header_lang
      status = Constants::Error::Http::HTTP_INVALID_HEADER
      headers = {
        'Content-Type' => 'application/json',
        'x-dp-code' => status,
        'x_dp_msg' => '不支持的请求头.'
      }
      [status, headers, []]
    end
  end
end