ActiveRecord::Schema.define do

  def fix_pkey(table, column)
    change_column table, column, "bigint NOT NULL AUTO_INCREMENT"
  end

  def add_indices(table, *columns)
    columns.each { |c| add_index(table, c) }
  end

  create_table :blocks, force: true do |t|
    t.integer  'ver'
    t.string   'hash',       limit: 64
    t.string   'prev_block', limit: 64
    t.string   'mrkl_root',  limit: 64
    t.integer  'time',       limit: 8
    t.integer  'bits',       limit: 8
    t.integer  'fee',        limit: 8
    t.integer  'nonce',      limit: 8
    t.integer  'n_tx'
    t.boolean  'main_chain'
    t.integer  'height',     limit: 8
    t.integer  'size',       limit: 8
    t.string   'relayed_by', limit: 15
  end

  fix_pkey    :blocks, :id
  add_indices :blocks, :hash, :time, :n_tx, :relayed_by

  create_table :transactions, force: true  do |t|
    t.integer  'block_id',   limit: 8, null: false
    t.integer  'ver'
    t.string   'hash',       limit: 64
    t.integer  'vin_sz'
    t.integer  'vout_sz'
    t.integer  'size',       limit: 8
    t.string   'relayed_by', limit: 15
  end

  fix_pkey    :transactions, :id
  add_indices :transactions, :block_id, :hash, :vin_sz, :vout_sz, :relayed_by

  create_table :outputs, force: true do |t|
    t.integer 'txn_id', limit: 8, null: false
    t.integer 'n'
    t.string  'addr',   limit: 36
    t.integer 'value',  limit: 8
    t.integer 'type',
    t.string  'addr_tag', limit: 255
    t.string  'addr_tag_link', limit: 255
  end

  fix_pkey    :outputs, :id
  add_indices :outputs, :txn_id, :addr, :value, :type, :addr_tag, :addr_tag_link

  create_table :inputs, force: true do |t|
    t.integer 'txn_id', limit: 8, null: false
    t.integer 'n',                null: false
  end

  fix_pkey    :inputs, :id
  add_indices :inputs, :txn_id, :n
end
