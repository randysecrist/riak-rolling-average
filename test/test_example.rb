require File.expand_path('../helper', __FILE__)

class TestExample < Test::Unit::TestCase
  def setup
    pids = []
    start_time = Time.now

    # start some external clients to add values to the Riak server
    5.times do |t|
      pids << fork {
        `bundle exec rake example:create_data_points ROW=#{t} CLIENT=local#{t}`
      }
    end
    pids.each do |pid|
      Process.waitpid(pid)
    end
    #puts "Processed data import in #{Time.now - start_time} seconds."
  end

  def test_counter_operations
    total_expected_count = 5000
    total_expected_sum = 2172267113.0

    # get stats doc for each app
    app_one = CounterDocument.find('dev1-storage-write')
    app_two = CounterDocument.find('dev2-storage-write')
    app_three = CounterDocument.find('dev3-storage-write')
    app_four = CounterDocument.find('dev4-storage-write')
    app_five = CounterDocument.find('dev5-storage-write')

    # assertions
    assert_equal total_expected_count, (
      app_one.count + app_two.count + app_three.count + app_four.count + app_five.count
    )
    assert_equal total_expected_sum, (
      app_one.sum + app_two.sum + app_three.sum + app_four.sum + app_five.sum
    )

    assert_equal 1485860, app_one.batch_size
    assert_equal 1559225, app_two.batch_size
    assert_equal 1555582, app_three.batch_size
    assert_equal 1502721, app_four.batch_size
    assert_equal 1408799, app_five.batch_size

    assert_equal 431338.97025641025, app_one.average
    assert_equal 433609.16826923075, app_two.average
    assert_equal 440314.68186226964, app_three.average
    assert_equal 443169.27125506074, app_four.average
    assert_equal 423335.8229813665, app_five.average

    assert_equal 283.0384396914918, app_one.batch_average
    assert_equal 289.2164601003704, app_two.batch_average
    assert_equal 291.8293198301343, app_three.batch_average
    assert_equal 291.3722773555437, app_four.batch_average
    assert_equal 290.2773248703328, app_five.batch_average
  end
end
