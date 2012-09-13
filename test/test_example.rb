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
    puts "Processed data import in #{Time.now - start_time} seconds."
  end

  def test_counter_operations
    counter = CounterDocument.find('data_point_document_statistic')
    expected_count = 5000
    expected_sum = 2172267113.0
    expected_avg = expected_sum / expected_count

    # assertions
    assert_equal expected_count, counter.count
    assert_equal expected_sum, counter.sum
    assert_equal expected_avg, counter.average
  end
end
