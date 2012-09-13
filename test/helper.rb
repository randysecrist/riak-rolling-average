$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
ROOT_DIR = File.join(File.dirname(__FILE__),'..')

ENV['RACK_ENV'] ||= 'test'
ENV['CLIENT'] ||= 'client'

require 'test/unit'
require File.join(ROOT_DIR,'lib','riak_rolling_average')

require 'test/ripple_test_server'
Ripple::TestServer.setup

# clear out all data
Riak.disable_list_keys_warnings = true
CounterDocument.destroy_all
DataPointDocument.destroy_all

# allow sibling documents so that we can calculate statistics in an
# eventually consistent manner
CounterDocument.bucket.allow_mult = true
