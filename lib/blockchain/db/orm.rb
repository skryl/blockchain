module Blockchain::ORM

  module BadAttributes
    ATTRS = %w(hash valid type)
    def instance_method_already_implemented?(method_name)
      return true if ATTRS.include?(method_name)
      super
    end
  end


  class Block < ActiveRecord::Base
    extend BadAttributes

    has_many :transactions
    accepts_nested_attributes_for :transactions
  end


  class Blockchain::ORM::Transaction < ActiveRecord::Base
    extend BadAttributes

    has_many :inputs, foreign_key: 'txn_id'
    has_many :outputs, foreign_key: 'txn_id'
    belongs_to :block
    accepts_nested_attributes_for :inputs, :outputs
  end


  class Output < ActiveRecord::Base
    self.inheritance_column = :_type_disabled

    has_many :inputs
    belongs_to :transaction
  end


  class Input < ActiveRecord::Base
    belongs_to :transaction
  end

end
