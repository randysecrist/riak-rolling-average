$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
ROOT_DIR = File.join(File.dirname(__FILE__),'..')

ENV['RACK_ENV'] ||= 'test'
ENV['CLIENT'] ||= 'client'

require 'test/unit'
require File.join(ROOT_DIR,'lib','riak_rolling_average')

require 'test/ripple_test_server'
Ripple::TestServer.setup
#def run_at_exit
#  at_exit do
#    if $! || Test::Unit.run?
#      Ripple::TestServer.destroy
#    end
#  end
#end
#run_at_exit

# clear out all data
Riak.disable_list_keys_warnings = true
StatisticDocument.destroy_all
DataPointDocument.destroy_all

# allow sibling documents so that we can calculate statistics in an
# eventually consistent manner
StatisticDocument.bucket.allow_mult = true
