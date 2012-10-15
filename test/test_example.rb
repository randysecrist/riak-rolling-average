require File.expand_path('../helper', __FILE__)

class TestExample < Test::Unit::TestCase
  def setup
    CounterDocument.destroy_all
    DataPointDocument.destroy_all

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
    total_expected_sum = 9475678.0
    total_expected_batch_size = -18483

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
    assert_equal total_expected_batch_size, (
      app_one.batch_size + app_two.batch_size + app_three.batch_size + app_four.batch_size + app_five.batch_size
    )

    assert_equal -20450,  app_one.batch_size
    assert_equal 28249,  app_two.batch_size
    assert_equal 21664,  app_three.batch_size
    assert_equal -43700, app_four.batch_size
    assert_equal -4246,  app_five.batch_size

    assert_equal -15503.939637826961, app_one.average
    assert_equal 10376.951771653543, app_two.average
    assert_equal 30027.583072100315, app_three.average
    assert_equal -21851.51921182266, app_four.average
    assert_equal 7648.827111984283, app_five.average

    assert_equal 753.5900244498778,  app_one.batch_average
    assert_equal 373.216149244221,   app_two.batch_average
    assert_equal 1326.4585025849335, app_three.batch_average
    assert_equal 507.5352860411899,  app_four.batch_average
    assert_equal -1833.8450306170514, app_five.batch_average
  end
end
