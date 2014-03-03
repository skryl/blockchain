module Blockchain::ORM
  ActiveSupport::Deprecation.silenced = true

  module Trasformable
    BAD_ATTRS = %w(hash valid type)
    def instance_method_already_implemented?(method_name)
      return true if BAD_ATTRS.include?(method_name)
      super
    end

    def from_json(data)
      transforms.each do |t|
        case t
        when Hash
          t.each { |k,v| data[v] = data[k] }
        when Proc
          t.call(data)
        end
      end; data
    end

    def trim_attrs(attrs)
      (attrs.keys.reject {|a| a.include?('_attributes')} - self.column_names)
        .each { |a| attrs.delete(a) }
    end
  end

  class Block < ActiveRecord::Base
    extend Trasformable

    has_many :transactions
    accepts_nested_attributes_for :transactions

    def self.transforms
      [  lambda { |b| b['tx'].map! { |t| Transaction.from_json(t) }
                      b['tx'].each { |t| t['block_id'] = b['id']  }},
         { 'tx'          => 'transactions_attributes',
           'block_index' => 'id' },
         lambda { |b| Block.trim_attrs(b) } ]
    end
  end


  class Blockchain::ORM::Transaction < ActiveRecord::Base
    extend Trasformable

    has_many :inputs, foreign_key: 'txn_id'
    has_many :outputs, foreign_key: 'txn_id'
    belongs_to :block
    accepts_nested_attributes_for :inputs, :outputs

    def self.transforms
      [  lambda { |t| t['inputs'].map!  { |i| i['prev_out'] }.compact!
                      t['inputs'].map!  { |i| Input.from_json(i)  }
                      t['out'].map!     { |o| Output.from_json(o) }},
         { 'inputs'   => 'inputs_attributes',
           'out'      => 'outputs_attributes',
           'tx_index' => 'id' },
         lambda { |t| Transaction.trim_attrs(t) } ]
    end
  end


  class Output < ActiveRecord::Base
    extend Trasformable
    self.inheritance_column = :_type_disabled

    has_many :inputs
    belongs_to :transaction

    def self.transforms
      [  { 'tx_index' => 'txn_id' },
         lambda { |i| Output.trim_attrs(i) } ]
    end
  end


  class Input < ActiveRecord::Base
    extend Trasformable

    belongs_to :transaction

    def self.transforms
      [  { 'tx_index' => 'txn_id' },
         lambda { |o| Input.trim_attrs(o) } ]
    end
  end

end
