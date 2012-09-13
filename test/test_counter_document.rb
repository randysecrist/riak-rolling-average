require File.expand_path('../helper', __FILE__)

class TestStatisticDocument < Test::Unit::TestCase
  def test_empty_state
    counter = CounterDocument.new
    assert_equal 0, counter.count
    assert_equal 0, counter.sum
    assert_equal 0, counter.average
  end

  def test_updating_simple_values
    counter = CounterDocument.new
    counter.key = 'test'

    counter.update_with(10)
    assert_equal 1,    counter.count
    assert_equal 10,   counter.sum
    assert_equal 10.0, counter.average

    counter.update_with(5)
    assert_equal 2,   counter.count
    assert_equal 15,  counter.sum
    assert_equal 7.5, counter.average

    counter.update_with(12)
    assert_equal 3,   counter.count
    assert_equal 27,  counter.sum
    assert_equal 9.0, counter.average
  end

  def test_conflict_resolution_of_siblings
    key = 'siblings'
    siblings = []
    siblings[0] = CounterDocument.new
    siblings[0].key = key
    siblings[0].update_with 10

    3.times do
      siblings << CounterDocument.find(key)
    end

    siblings[1].update_with 10
    counter = CounterDocument.find(key)
    assert_equal 2,    counter.count
    assert_equal 20,   counter.sum
    assert_equal 10.0, counter.average

    siblings[2].update_with 7
    counter = CounterDocument.find(key)
    assert_equal 3,   counter.count
    assert_equal 27,  counter.sum
    assert_equal 9.0, counter.average

    siblings[3].update_with 13
    counter = CounterDocument.find(key)
    assert_equal 4,    counter.count
    assert_equal 40,   counter.sum
    assert_equal 10.0, counter.average

    siblings[0].update_with 19
    counter = CounterDocument.find(key)
    assert_equal 5,    counter.count
    assert_equal 59,   counter.sum
    assert_equal 11.8, counter.average

    siblings[0].update_with 13
    counter = CounterDocument.find(key)
    assert_equal 6,    counter.count
    assert_equal 72,   counter.sum
    assert_equal 12.0, counter.average
  end
end
