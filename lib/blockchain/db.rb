class Blockchain::Db

  def initialize(options)
    @options = options
  end

  def db_spec
    { adapter:   @options[:db_type] || 'mysql2',
      host:      @options[:db_host] || '127.0.0.1',
      username:  @options[:db_user] || 'root',
      password:  @options[:db_pass] || '',
      database:  @options[:db_name] || 'blockchain',
      pool: 10 }
  end

  def connect!
    ActiveRecord::Base.establish_connection(db_spec)
    load_orm
  end

  def prepare!
    connect!
    drop!
    create!
    connect!
    load_schema
  end

private

  def drop!
    ActiveRecord::Base.connection.drop_database db_spec[:database] rescue nil
  end

  def create!
    ActiveRecord::Base.connection.create_database db_spec[:database]
  end

  def load_orm
    load 'blockchain/db/orm.rb'
  end

  def load_schema
    load 'blockchain/db/schema.rb'
  end

end
