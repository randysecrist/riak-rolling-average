require 'ripple'

class DataPoint
  include Ripple::EmbeddedDocument
  embedded_in 'DataPointDocument'

  property :value, Integer, :presence => true

  property :unit, String
  property :owner, String
  property :name, String
  property :time, Time

  index :owner, String do
  	"#{self.owner}"
  end

  index :time, String do
  	"#{self.time.iso8601(6)}"
  end

  index :owner_time, String do
  	"#{self.owner}-#{self.time.iso8601(6)}"
  end

end
