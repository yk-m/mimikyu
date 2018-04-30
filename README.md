# Mimikyu

HTTP Server

## Usage
* echoサーバーを起動する:

        $ bundle exec bin/mimikyu echo --host 0.0.0.0 --port 8080

* echoサーバー（マルチスレッド）を起動する:

        $ bundle exec bin/mimikyu echo_multi_thread --host 0.0.0.0 --port 8080

* HTTPサーバーを起動する

        $ bundle exec bin/mimikyu http --host 0.0.0.0 --port 8080

* CGIサーバー（????）を起動する

        $ bundle exec bin/mimikyu cgi --host 0.0.0.0 --port 8080

* help

        $ bundle exec bin/mimikyu help

## Install

    $ bundle install

## Code Status
[![Build Status](https://travis-ci.org/yk-m/mimikyu.svg?branch=master)](https://travis-ci.org/yk-m/mimikyu)
