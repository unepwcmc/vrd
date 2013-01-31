# Voluntary REDD Database

This app provides a visualisation of the data VRD data, which is provided to us through an atom feed of changes. This atom feed is polled daily to keep the app database up to date.

## Setup

This task will import all the current data from the atom feed and other sources.

    rake vrd:all

You'll need to create a cartodb_config.yml file and place it into config directory:

    host: '<your cartodb host>'
    oauth_key: 'oauthkey'
    oauth_secret: 'oauthsecret'
    username: 'username'
    password: 'password'

## Tests

    bundle exec guard
