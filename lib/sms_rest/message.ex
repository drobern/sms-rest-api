defmodule SmsRouting.Message do
  @enforce_keys [:id, :to, :from, :body]
  defstruct id: nil,
            to: nil,
            from: nil,
            body: nil,
            options: [],
            metadata: %{}

  @typedoc """
  An SMS message abstracted away from transport details. It can also contain options
  and metadata.

  `id`:       Unique identifier for the message. Will be used in the future for deduplication.
  `to`:       A E164 phone number or a shortcode (post MVP) that represents the destination of the message.
  `from`:     A E164 phone number or a shortcode (post MVP) that represents the source of the message.
  `body`:     A utf-8 string representing a SMS message
  `options`:  A list of keyword parameters with options relating to the message. It can contain
              hints about encoding, priority and other parameters. Unused in MVP.
  `metadata`: Additional information that for one reason or another needs to be passed between senders and routing
              entities. If you use this make an effort not to make anything here mandatory. Also make sure you
              document metadata well where it is produced and used.
              Example keys:
                - correlation_id: Identifier that is used in logging for correlating logs across μ-services
                - account_id:     Cloudlink account id
                - principal_id:   Cloudlink principal_id

              NOTE: You may need to preserve metadata even if the message changes form. In the case of PDU
                    encoding that means you transport the metadata with the PDU while in the system.
  """
  @type t :: %SmsRouting.Message{
          id: String.t(),
          to: String.t(),
          from: String.t(),
          body: String.t(),
          options: keyword(),
          metadata: map()
        }
end
