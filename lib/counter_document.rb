require 'ripple'

class CounterDocument
  include Ripple::Document
  property :client_data, Hash, :presence => true

  def average
    return self.sum / self.count unless self.count == 0
    return 0
  end

  def sum
    return 0 if self.client_data == nil
    begin
      self.client_data.map{|h| h[1]['total']['sum']}.inject(0, :+)

    rescue TypeError
      raise self.client_data.map{|h| h[1]['total']['sum']}.inspect
    end
  end

  def count
    return 0 if self.client_data == nil
    begin
      self.client_data.map{|h| h[1]['total']['count']}.inject(0, :+)

    rescue TypeError
      raise self.client_data.map{|h| h[1]['total']['count']}.inspect
    end
  end

  # --- CRDT State Management --- #

  def update_with(data_point)
    data_point = DataPoint.new(:value => data_point, :time => Time.now) unless data_point.is_a? DataPoint
    self.reload
    self.client_data ||= {}

    counter = self.client_data[Client.id] || { 'daily' => {}, 'monthly' => {}, 'total' => { 'sum' => 0, 'count' => 0 } }

    # update daily
    day_key = "#{data_point.time.strftime("%Y%m%d")}"
    day_stats = counter['daily'][day_key] || { 'sum' => 0, 'count' => 0 }
    day_stats['sum'] = (day_stats['sum'] + data_point.value).to_f
    day_stats['count'] = (day_stats['count'] + 1)
    counter['daily'][day_key] = day_stats

    # update monthly
    month_key = "#{data_point.time.strftime("%Y%m")}"
    month_stats = counter['monthly'][month_key] || { 'sum' => 0, 'count' => 0 }
    month_stats['sum'] = (month_stats['sum'] + data_point.value).to_f
    month_stats['count'] = (month_stats['count'] + 1)
    counter['monthly'][month_key] = month_stats

    # update total
    total_stats = counter['total']
    total_stats['sum'] = (total_stats['sum'] + data_point.value).to_f
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

