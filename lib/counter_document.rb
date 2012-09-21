require 'ripple'

class CounterDocument
  include Ripple::Document
  property :client_data, Hash, :presence => true

  def average
    return self.sum / self.count unless self.count == 0
    return 0
  end

  # a precalculated running total of a data point's value
  def sum(range = nil)
    return 0 if self.client_data == nil
    begin
      return self.client_data.map{|h| h[1]['total']['sum']}.inject(0, :+)
    rescue TypeError
      raise self.client_data.map{|h| h[1]['total']['sum']}.inspect
    end if range == nil

    return self.client_data.map do |h|
      daily_keys = h[1]['daily'].keys.select do |k|
        t = Time.parse(k)
        range.cover?(t)
      end
      daily_keys.inject(0) {|sum,i| sum + h[1]['daily'][i]['sum']}
    end[0]
  end

  # a precalculated running total of the number of data points
  def count
    return 0 if self.client_data == nil
    begin
      self.client_data.map{|h| h[1]['total']['count']}.inject(0, :+)

    rescue TypeError
      raise self.client_data.map{|h| h[1]['total']['count']}.inspect
    end
  end

  def batch_average
    return self.sum / self.batch_size unless self.batch_size == 0
    return 0
  end

  # a precalculated running total of a data point's batch size
  def batch_size
    return 0 if self.client_data == nil
    begin
      self.client_data.map{|h| h[1]['total']['batch_size']}.inject(0, :+)

    rescue TypeError
      raise self.client_data.map{|h| h[1]['total']['batch_size']}.inspect
    end
  end

  # --- CRDT State Management --- #

  def update_with(data_point)
    data_point = DataPoint.new(
      :value => data_point,
      :time => Time.now,
      :batch_size => 1
    ) unless data_point.is_a? DataPoint

    self.reload
    self.client_data ||= {}

    counter = self.client_data[Client.id] || {
      'daily' => {}, 'monthly' => {}, 'total' => { 'sum' => 0, 'count' => 0, 'batch_size' => 0 }
    }

    # update daily
    day_key = "#{data_point.time.strftime("%Y%m%d")}"
    day_stats = counter['daily'][day_key] || { 'sum' => 0, 'count' => 0, 'batch_size' => 0 }
    day_stats['sum'] = (day_stats['sum'] + data_point.value).to_f
    day_stats['batch_size'] = (day_stats['batch_size'] + data_point.batch_size)
    day_stats['count'] = (day_stats['count'] + 1)
    counter['daily'][day_key] = day_stats

    # update monthly
    month_key = "#{data_point.time.strftime("%Y%m")}"
    month_stats = counter['monthly'][month_key] || { 'sum' => 0, 'count' => 0, 'batch_size' => 0 }
    month_stats['sum'] = (month_stats['sum'] + data_point.value).to_f
    month_stats['batch_size'] = (month_stats['batch_size'] + data_point.batch_size)
    month_stats['count'] = (month_stats['count'] + 1)
    counter['monthly'][month_key] = month_stats

    # update total
    total_stats = counter['total']
    total_stats['sum'] = (total_stats['sum'] + data_point.value).to_f
    total_stats['batch_size'] = (total_stats['batch_size'] + data_point.batch_size)
    total_stats['count'] = (total_stats['count'] + 1)

    # update doc & save
    self.client_data[Client.id] = counter
    self.save
  end

  on_conflict do |siblings, c|
    resolved = {}
    siblings.reject!{|s| s.client_data == nil}
    siblings.each do |sibling|
      resolved.merge! sibling.client_data do |client_id, resolved_value, sibling_value|
        resolved_value['total']['count'] > sibling_value['total']['count'] ? resolved_value : sibling_value
      end
    end
    self.client_data = resolved
  end

end

