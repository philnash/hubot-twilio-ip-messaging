Twilio = require("twilio")
try
  {Robot,Adapter,TextMessage,EnterMessage,LeaveMessage,User} = require("hubot")
catch
  prequire = require("parent-require")
  {Robot,Adapter,TextMessage,EnterMessage,LeaveMessage,User} = prequire("hubot")

class TwilioIP extends Adapter
  constructor: (robot)->
    @robot      = robot
    @apiKey     = process.env.HUBOT_TWILIO_API_KEY
    @apiSecret  = process.env.HUBOT_TWILIO_API_SECRET
    @serviceSid = process.env.HUBOT_TWILIO_SERVICE_SID

    unless @apiKey? and @apiSecret? and @serviceSid?
      @robot.logger.error "Not enough parameters provided.
                           I need an API Key, API Secret and Service SID"
      process.exit(1)

    @ipClient   = new Twilio.IpMessagingClient(@apiKey, @apiSecret)
    @ipService  = @ipClient.services(@serviceSid)
    super

  send: (envelope, strings...) ->
    for string in strings
      @ipService.channels(envelope.message.room).messages.create
        Body: string
        From: @robot.name

  reply: (envelope, strings...) ->
    strings = strings.map (string) -> "#{envelope.user.name}: #{string}"
    @robot.send(envelope, strings)

  emote: (envelope, strings...) ->
    @robot.send(envelope, "** #{str} **" for str in strings)

  run: ->
    @ipService.users.create({identity: @robot.name}, (err, user) =>
      # TODO: decide on being able to join specified rooms or handle paginating
      # rooms here.
      @ipService.channels.list().then((response) =>
        @joinChannel(channel.sid) for channel in response.channels
      ).catch((err) =>
        @robot.logger.error "Failed to retrieve channels"
        @robot.logger.error err
      )
    )

    # Webhook for new channel added
    @robot.router.post "/hubot/on_channel_add", (request, response) =>
      @joinChannel(request.body.ChannelSid)
      # Return 200 empty response
      response.send("<Response/>");

    # Webhook for new message sent
    @robot.router.post "/hubot/on_message_send", (request, response) =>
      user = new User(request.body.From)
      message = new TextMessage(user, request.body.Body)
      message.room = request.body.To
      @robot.receive(message)
      # Return 200 empty response
      response.send("<Response/>");

    # Webhook for member entering channel
    @robot.router.post "/hubot/on_member_add", (request, response) =>
      @robot.logger.info(request.body)
      if request.body.Identity?
        user = new User(request.body.Identity)
        unless user.name == @robot.name
          @robot.receive(new EnterMessage(user, null))
      # Return 200 empty response
      response.send("<Response/>");

    # Webhook for member leaving channel
    @robot.router.post "/hubot/on_member_remove", (request, response) =>
      @robot.logger.info(request.body)
      if request.body.Identity?
        user = new User(request.body.Identity)
        unless user.id == @robot.name
          @robot.receive(new LeaveMessage(user, null))
      # Return 200 empty response
      response.send("<Response/>");

    @emit("connected")

  joinChannel: (channelSid) =>
    @ipService.channels(channelSid).members.create({identity: @robot.name})
      .then((success) =>
        @robot.logger.info("Joined channel: #{success.channelSid}")
      )
      .catch(@robot.logger.error)

exports.use = (robot) ->
  new TwilioIP robot
