require "bundler/setup"
require "active_support"
require "active_support/core_ext"
require "slack-ruby-client"

def lambda_handler(event:, context:)

  # slackのEvent APIの認証用
  if event["body"].present? && JSON.parse(event["body"])["challenge"].present?
    return { statusCode: 200, body: JSON.parse(event["body"])["challenge"] }
  end

  # slack APIのretryの場合は処理をしない
  return { statusCode: 200, body: "No need to resend" } if retry_header?(event["headers"])

  json_body = JSON.parse(event["body"])
  # 対象のslackのbot, channel以外は実行せずalert
  channel_id = json_body.dig("event", "channel")
  api_app_id = json_body.dig("api_app_id")

  # 不正なアクセスはcloudwatchで確認
  # ※チェック不要な場合はここのif文は削除してください。
  if channel_id != ENV["channel_id"] || api_app_id != ENV["api_app_id"]
    puts "event_data:#{event.inspect}"
    notification_to_slack("意図しないchannelまたはユーザから実行されました。")
    return { statusCode: 200, body: "OK" }
  end

  app_user_id = json_body.dig("event", "blocks", 0, "elements", 0, "elements", 0, "user_id")
  user_id = json_body.dig("event", "user")
  text = json_body.dig("event", "text")

  if text.blank?
    return { statusCode: 200, body: "OK" }
  else
    message = text.gsub(/#{app_user_id}/, user_id)
    notification_to_slack(channel_id, message)

    return { statusCode: 200, body: "OK" }
  end
end

def retry_header?(event_headers)
  retry_num = event_headers.fetch("X-Slack-Retry-Num", nil)
  retry_reason = event_headers.fetch("X-Slack-Retry-Reason", nil)
  retry_num.present? && (retry_reason == "http_timeout" || retry_reason == "http_error")
end

def notification_to_slack(channel_id = nil, message)
  channel = channel_id || ENV["channel_id"]
  Slack.configure do |config|
    config.token = ENV["slack_token"]
  end
  client = Slack::Web::Client.new
  client.chat_postMessage(channel: channel, text: message)
end
