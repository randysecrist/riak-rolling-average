require 'ripple'

class StatisticDocument
  include Ripple::Document
  property :client_data, Hash, :presence => true

  def update_with(value)
    self.reload
    self.client_data ||= {}
    statistic = self.client_data[Client.id] || {'sum' => 0, 'count' => 0}
    statistic['sum'] = (statistic['sum'] + value).to_f
    statistic['count']   = (statistic['count'] + 1)
    self.client_data[Client.id] = statistic
    self.save
  end

  def sum
    begin
      self.client_data.map{|h| h[1]['sum']}.inject(0, :+)

    rescue TypeError
      raise self.client_data.map{|h| h[1]['sum']}.inspect
    end
  end

  def count
    begin
      self.client_data.map{|h| h[1]['count']}.inject(0, :+)

    rescue TypeError
      raise self.client_data.map{|h| h[1]['count']}.inspect
    end
  end

  def average
    self.sum / self.count
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

