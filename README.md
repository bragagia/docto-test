# Doctolib-test

This is my project for the Doctolib's technical test.
It consists of a class Event that allow you to get availabilities from a calendar sets with openings and appointments.

Example:

```ruby
Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-04 09:30"), ends_at: DateTime.parse("2014-08-04 12:30"), weekly_recurring: true
Event.create kind: 'appointment', starts_at: DateTime.parse("2014-08-11 10:30"), ends_at: DateTime.parse("2014-08-11 11:30")

Event.availabilities DateTime.parse("2014-08-10")

[
  {:date=>Sun, 10 Aug 2014, :slots=>[]},
  {:date=>Mon, 11 Aug 2014, :slots=>["9:30", "10:00", "11:30", "12:00"]},
  {:date=>Tue, 12 Aug 2014, :slots=>[]},
  {:date=>Wed, 13 Aug 2014, :slots=>[]},
  {:date=>Thu, 14 Aug 2014, :slots=>[]},
  {:date=>Fri, 15 Aug 2014, :slots=>[]},
  {:date=>Sat, 16 Aug 2014, :slots=>[]}
]
```

I made some assumption :
 - Openings and appointments must not exceed a single day
 - Slots are of a fixed size of 30 minutes
 - An recurring opening event starts to be effective only after its actual date

The project uses Ruby 5.1 and is build upon Docker and Docker-Compose.

## Build

```
docker-compose build
docker-compose run doctolib-test rails db:migrate RAILS_ENV=test
```

## Run

```
docker-compose up
```

## Run tests

```
docker-compose run doctolib-test rails test test/models/event_test.rb
```
