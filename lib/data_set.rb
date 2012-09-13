class StatBucket
  # attributes:  resolution (DAY, WEEK, MONTH)
end

class Triple
  attr_accessor :user, :application, :data
  def initialize(user, application, hash)
    @user = user
    @application = application
    @data = hash
  end
end

class DataSet
  attr_accessor :data

  def initialize(data=[])
    @data = data
    @sum_bytes = 0
    @sum_count = 0
    calculate_stats(@data) if @data != nil && @data.length > 0
  end

  # ----- GENERATOR ----- #

  def self.generate_data_for(user, application, count)
    ds = DataSet.new
    ds.generate_data_for(user,application, count)
  end

  def generate_data_for(user, application, count)
    count.times.map {
      # date variance
      days = 1 + Random.rand(365)
      hours = 1 + Random.rand(24)
      minutes = 1 + Random.rand(60)
      seconds = 1 + Random.rand(60)

      # usage variance
      aprox_avg_value_size = 290
      upper_count = 1 + Random.rand(3000)

      # generate a summation event (bytes) for a count of items
      ts = (days.days + hours.hours + minutes.minutes + seconds.seconds).ago
      hash = {
        'time' => ts,
        'bytes' => 1 + Random.rand((aprox_avg_value_size * 2) * upper_count),
        'count' => upper_count
      }

      # randomize user and app
      app = (application.is_a?(Array)) ? application[Random.rand(application.length)] : application
      usr = (user.is_a?(Array)) ? user[Random.rand(user.length)] : user

      # store
      triple = Triple.new(usr, app, hash)
      @data.push(triple)
    }
    return calculate_stats(@data)
  end

  # ----- SERIALIZATION ----- #

  def self.deserialize(input)
    data = DataSet.parse(input)
    ds = DataSet.new(data)
    return ds
  end

  def deserialize!(input)
    @data = DataSet.parse(input)
    return calculate_stats(@data)
  end

  # ----- PRECALCULATED ----- #

  def sum
    return @sum_bytes
  end

  def count
    return @sum_count
  end

  def average
    return @sum_bytes / @sum_count
  end

  def distribution_by_date
    return @distribution_by_date
  end

  def distribution_by_frequency
    return @distribution_by_frequency
  end

  # ----- CALCULATED ----- #

  def sum_by_application(application, date_range=nil)
    filtered = (date_range == nil) ? @data.select {|i| i.application == application} : @data.select {|i| i.application == application && date_range.cover?(i.data['time'])}
    return calculate_stats(filtered, true)[0]
  end

  def sum_by_user(user)
    filtered = @data.select {|i| i.user == user}
    return calculate_stats(filtered, true)[0]
  end

  def sum_by_period(date_range=nil)
    filtered = @data.select {|i| date_range.cover?(i.data['time'])}
    return calculate_stats(filtered, true)[0]
  end

  private

  def self.parse(input)
    rtnval = []
    input.each do |item|
      user = item['user']
      app = item['application']
      item['data']['time'] = Time.parse(item['data']['time'])
      triple = Triple.new(user, app, item['data'])
      rtnval.push(triple)
    end
    return rtnval
  end

  # precalculate stats for a data set
  def calculate_stats(data, return_stats=false)
    dups = {}

    l_count = 0
    l_bytes = 0

    data.each do |triple|
      ts = triple.data['time']
      date_key = "#{ts.strftime("%Y-%m-%d")}"
      l_bytes += triple.data['bytes']
      l_count += triple.data['count']

      dups.store(date_key, 0) if !dups.has_key?(date_key)
      dups.store(date_key, dups[date_key] += 1)
    end

    # don't mutate state unless needed
    unless (return_stats)
      @sum_count = l_count
      @sum_bytes = l_bytes

      # order by collisions on same day
      @distribution_by_frequency = dups.sort {|x,y| x[1] <=> y[1]}

      # order by date (last 7 days)
      @distribution_by_date = dups.sort {|x,y| x[0] <=> y[0]}
      return data
    end

    return [l_bytes, l_count]

  end

end
