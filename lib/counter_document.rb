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
      self.client_data.map{|h| h[1]['sum']}.inject(0, :+)

    rescue TypeError
      raise self.client_data.map{|h| h[1]['sum']}.inspect
    end
  end

  def count
    return 0 if self.client_data == nil
    begin
      self.client_data.map{|h| h[1]['count']}.inject(0, :+)

    rescue TypeError
      raise self.client_data.map{|h| h[1]['count']}.inspect
    end
  end

  # --- CRDT State Management --- #

  def update_with(data_point)
    data_point = DataPoint.new(:value => data_point, :time => Time.now) unless data_point.is_a? DataPoint
    self.reload
    self.client_data ||= {}
    counter = self.client_data[Client.id] || {'sum' => 0, 'count' => 0}

    # determine which resolution we are updating
    #  look at how it is created (enum of possible types)
    #  (year (1), month (12), day (365), hours (8760)
    # 219000 hour keys after 25 years; log2(n) = 17.6 ops, days worth of hour data - 422.4 ops of an object in mem (worst case)

    counter['sum'] = (counter['sum'] + data_point.value).to_f
    counter['count'] = (counter['count'] + 1)
    self.client_data[Client.id] = counter
    self.save
  end

  on_conflict do |siblings, c|
    resolved = {}
    siblings.reject!{|s| s.client_data == nil}
    siblings.each do |sibling|
      resolved.merge! sibling.client_data do |client_id, resolved_value, sibling_value|
        resolved_value['count'] > sibling_value['count'] ? resolved_value : sibling_value
      end
    end
    self.client_data = resolved
  end

end

