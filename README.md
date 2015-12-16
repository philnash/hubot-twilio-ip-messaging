# Hubot Adapter for Twilio IP Messaging

Twilio's [IP Messaging](https://www.twilio.com/ip-messaging) is an SDK you can use in your mobile and web applications to create rich chat experiences. To add to that richness, this adapter let's you harness the power of [Hubot](https://hubot.github.com/) and the hundreds  of [Hubot scripts](http://hubot-script-catalog.herokuapp.com/recent) within your IP Messaging applications.

## Setup

To use Hubot with Twilio IP Messaging you will need:

* A Twilio account (you can sign up for a [Twilio account for free](https://www.twilio.com/try-twilio))
* Node.js

### Config

Before we run Hubot on IP Messaging you will need 3 pieces of config from your Twilio account. If you don't already have these items, you can see how to generate them below too.

| Config value | Description |
| ------------ | ----------- |
| Service Instance Sid | A [service](https://www.twilio.com/docs/api/ip-messaging/rest/services) instance where all the data for our application is stored and scoped. [Generate one in the Twilio console here](https://www.twilio.com/user/account/ip-messaging/services). |
| API Key | Used to authenticate - [generate one in your Twilio dashboard](https://www.twilio.com/user/account/ip-messaging/dev-tools/api-keys). |
| API Secret | Used to authenticate - [generated at the same time as the API Key](https://www.twilio.com/user/account/ip-messaging/dev-tools/api-keys). |

Once you have those config values, you will need to export them as environment variables so that Hubot can use them. In bash, you can run:

```bash
$ export HUBOT_TWILIO_SERVICE_SID=YOUR_SERVICE_SID
$ export HUBOT_TWILIO_API_KEY=YOUR_API_KEY
$ export HUBOT_TWILIO_API_SECRET=YOUR_API_SECRET
```

### Webhooks

Hubot gets incoming messages from Twilio IP Messaging via the use of Webhooks, HTTP requests from the Twilio API to endpoints defined within the Hubot adapter here. We need to set up those endpoints with the IP Messaging system and, if you are hosting this locally, expose your local development Hubot to those webhooks.

First we need to work out what our URLs will be. If you are deploying Hubot to a server somewhere, then you'll know the URL you're using. If you are developing on your Hubot locally, I recommend using [ngrok](http://ngrok.com) to expose the Hubot's local web server to the webhooks. You can download ngrok for any platform and then run it like so:

```bash
$ ./ngrok http 8080
```

We use 8080 in this case as that is the default port that Hubot uses. Once you run that command, ngrok will show you the URL that you now have exposed externally.

Take your URL, ngrok or otherwise, and fill it in to the following couple of lines of bash. This will set up all the webhooks you need.

```bash
$ export HUBOT_URL=http://your-url
$ curl -XPOST https://ip-messaging.twilio.com/v1/Services/$HUBOT_TWILIO_SERVICE_SID \
  -d "Webhooks.OnChannelAdd.Url=$HUBOT_URL/hubot/on_channel_add" \
  -d "Webhooks.OnMessageSend.Url=$HUBOT_URL/hubot/on_message_send" \
  -d "Webhooks.OnMemberAdd.Url=$HUBOT_URL/hubot/on_member_add" \
  -d "Webhooks.OnMemberRemove.Url=$HUBOT_URL/hubot/on_member_remove" \
  -u "$HUBOT_TWILIO_API_KEY:$HUBOT_TWILIO_API_SECRET"
```

Now we're ready to use Hubot with IP Messaging. You can either create a new Hubot, or attach an existing Hubot to IP Messaging.

## Hubot!

### Creating a new Hubot

To create a new Hubot you need to install [Yeoman](http://yeoman.io) and the Hubot generator.

```bash
$ npm install -g yo generator-hubot
```

Now, create a folder for your Hubot, change into that folder and run the generator with the adapter set to `twilio-ip-messaging`.

```bash
$ mkdir hubot
$ cd hubot
$ yo hubot --adapter=twilio-ip-messaging
```

You now have your Hubot and you can run it with the following command.

```bash
$ bin/hubot
```

If you have your IP Messaging application set up then Hubot will join in all the rooms and be available to chat.

### Adding the adapter to an existing Hubot

If you already have a Hubot, you can install the IP Messaging adapter by opening the directory your Hubot is in and running:

```bash
$ npm install hubot-twilio-ip-messaging --save
```

And then run the Hubot with:

```bash
$ bin/hubot -a twilio-ip-messaging
```

#### Happy Hubotting and happy IP Messaging!
