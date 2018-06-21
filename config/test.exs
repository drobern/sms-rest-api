use Mix.Config

config :sms_rest,
  sms_routing: SmsRoutingMock,
  sms_cloudlink_db: SmsCloudlinkDbMock
# We don't run a server during test. If one is required,
# you can enable the server option below.
config :sms_rest, SMSRestWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
