require 'ripple'

class DataPoint
  include Ripple::EmbeddedDocument
  embedded_in 'DataPointDocument'

  # --- PROPERTIES ---

  # the name of the metric
  property :name, String

  # the value of the metric
  property :value, Integer, :presence => true

  # the unit of the metric
  property :unit, String

  # the time the metric was recorded
  property :time, Time

  # the owning entity of the metric
  property :owner, String

  # the source of the metric
  property :source, String

  # --- END PROPERTIES ---

  # --- INDEX DEFS ---

  index :owner, String do
  	"#{self.owner}"
  end

  index :time, String do
  	"#{self.time.iso8601(6)}"
  end

  index :owner_time, String do
  	"#{self.owner}-#{self.time.iso8601(6)}"
  end

  # --- END INDEX DEFS ---

end
