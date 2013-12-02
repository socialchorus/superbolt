[![Code Climate](https://codeclimate.com/github/socialchorus/superbolt.png)](https://codeclimate.com/github/socialchorus/superbolt)

# Superbolt

Superbolt is an easy intra-app communication system for sending messages
between applications. It is backed by RabbitMQ and under the covers it
uses the Bunny gem.

#### Why not just use those gems?

RabbitMQ is hard. Even though it is a messaging queue, by name, a
developer can't pick up one of these great gems and treat the queue
like a queue. There is great ceremony in the process. In fact, it is
quite easy to pass in the wrong queue arguments, or leave a connection
open.

Superbolt takes the ceremony away and let's developers focus on what is
important: reading and sending messages.

#### How does it make it easier?

Superbolt has two main components: a queue and an app.

The queue object acts like a queue. The queue can push, pop and peek. 
The queue is able to spit out all or a subset of the messages on the 
queue. It can clear itself. In short it makes inline operations doable.

The app on the other hand is an EventMachine process that takes over the
thread. It continually reads from a single queue until it recieves a
signal or message shutting it down. It is smart; it handles exceptions in message
processing by moving those problem messages to a related error queue. It also
listens on a separate quit queue for a graceful shutdown. A graceful
shutdown means no messages are lost.

#### Simple because there are less RabbitMQ capabilities

Superbolt makes intra-app communication easier via reducing
the types of things that can be done in RabbitMQ. While Superbolt was made to
address typical messaging patterns like RPC and work queues, it cuts out
RabbitMQ features like exclusive binding, and uses the library itself,
and conventions to make sure the right application gets the right
message. If all the features of RabbitMQ are needed, then using
Superbolt is not appropriate ... hop along.

#### Conventions

While Superbolt makes it possible to listen on any queue name
as an application, or interact with any queue name as an enumerable-ish queue, it
gets its real power from conventions.

Messages are JSON. Developers can do it differently, but the gains of
ease will be lost.

By convention each application has a name. The name is used along with
the application environment in order to communicate. The environment
means that test and development messages don't get lumped together. The
application name means that each application has to employ some
filtering to figure out what end process should handle the messages.

Per application filtering, is made very easy by Superbolt's message conventions.
A Superbolt message has three keys:

1. origin: the origin application
2. event: some identifier/sort key for the message type, will be 'default' by
   default.
3. arguments: additional data to be passed on to the handling process

Developer's can create a message without having to think to much about
these concerns:

    Superbolt.app_name = 'me'
    Superbolt.message.to('over_there').send!({just: 'do it!'})

    Superbolt.queue('over_there').pop
    => {
      origin: 'me',
      event: 'default',
      arguments: {
        just: 'do it!'
      }
    }

## Usage (more)

###Configuring:

    Superbolt.config = {
      app_name: 'my_app', # no default
      env: 'staging', # looks to env for information
      connection_params: {
        # can use anything RabbitMQ speaks here
        host: 'my-rabbitmq-provider.com'
      } # defaults to what is set in the ENV or localhost
    }

#### Connection Configuration

Out of the box Superbolt will look to the ENV to see if there is a
connection key, RABBITMQ\_URL. Developers can customize the connection
key that is used. Actual connection params that RabbitMQ Bunny/AMQP use
can also be passed in as above. If a connection key is not found in the
ENV, localhost will be used. If the application uses these typical
conventions, then no connection configuration is required.
 
#### App Name

The application name/identifier is an important default to setup in
order to get all the goodness of related to messaging and its
conventions. 

If no app name is set up, a littlem or work is required to send a
message:

    Superbolt.message
      .to('over_there')
      .from('me')
      .send!({just: 'do it!'})

Without the #from call, the message will be sent without an origin. In
our experience it is typical to process messages differently depending
on the sender. Of course, that information can be encoded into the event
name, but it is pretty easy to configure an application name so event
filtering is easier for the consuming application.

    Superbolt.app_name = 'my_great_app'
    # - or -
    Superbolt.config = {
      app_name = 'my_great_app'
    }

### Sending messages

Superbolt doesn't want to developers worrying about exchanges,
durability or connection ceremony. Developers should be able to just
send a message. The ease of that sending depends on whether developers
are sticking with the Superbolt conventions or not. 

#### The easiest way to message

The easiest way is to use the Superbolt level helper for sending a
message:

    Superbolt.message
      .re('dorothy')
      .to('wicked_witch')
      .send!('On yellow brick road; has friends!')

This message can be received on a queue
'wicked\_witch\_staging', given that the environment is
'staging'. When it is popped off it will look like this:

    {
      origin: 'my_configured_app_name',
      event: 'dorothy',
      arguments: 'On yellow brick road; has friends!'
    }
  
#### A more customizable messaging experience

Messages can also be sent via Superbolt::Queue objects. In this case the
message can be anything and the queue name is exactly what is passed in.

    queue = Superbolt::Queue.new('dorothy')
    queue.push({demand: 'Surrender!'})
    queue.pop 
    => {
      'demand' => 'Surrender!'
    }

### Reading messages

Messages can be read inline or via a standalone app. 

#### Reading Inline

Reading messages inline is easy and to the point. The Superbolt::Queue
object tries to act queue-like instead of like a hard to use external
service. 

Popping messages off the queue will remove the message from the queue
immediately. If something goes wrong with eth message processing, it is
the responsibility of the consuming application to figure out what to
do.

    message = queue.pop # This removes the message permanently

Messages can be read in non-destructive ways as well. 

    message = queue.peek
    # Ponder or process message.
    # It is still hanging out at the top of the queue.
    # It can be deleted with a pop, 
    # provided another consumer hasn't already deleted it!

Because of asynchronicity issues with job processing across several apps
or workers, the best usage for non-destructive inline reads is debugging
and information gathering.

    queue.all # return all the messages on the queue

    # remove messages meeting the block criteria
    queue.delete {|m| m['level'] == 'not_important' }

    # peek at messages in a certain range
    queue.slice(2, 4) 

    # get a certain message, non-destructively
    queue[3]

#### Reading via a Standalone App

Reading messages inline is useful, but in general an application wants
to read continuously for the latest and greatest intra-app
communications.

    Superbolt::App.new('dorothy_inbox').run do |message, logger|
      HomewardBound.new(message).perform
    end

Exceptions raised in the processing block will not exit
the Superbolt app. Errors will be logged and the message will be put on
an error queue with information about the exception raised. Those
messages can be seen by accessing the related error queue:

    error_queue = Superbolt::App.new('dorothy_inbox').error_queue
    error_queue.all

The error queue is a Superbolt::Queue and methods like #pop, #delete,
and #[] are available to gather more data about the exceptions being
raised.

The app can be shutdown gracefully by sending a quit message to a
special queue:

    quit_queue = Superbolt::App.new('dorothy_inbox').quit_queue
    quit_queue.push(message: 'for a deploy')

## Installation

Add this line to your application's Gemfile:

    gem 'superbolt'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install superbolt

## TODOs:

* Easy filtering/delegation of messages to classes
* Failed messages are put on another queue so that the app is not
  in a failure loop.
* In code YARD stye documentation
* CodeClimate
* TravisCI continuout integration


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
