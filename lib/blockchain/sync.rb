class Blockchain::Sync
  include Blockchain::Utils
  include Blockchain::ORM

  THREAD_COUNT = 15

  BLOCK_START = 1
  BLOCK_END = 1000

  class BlockChainInfo
    include HTTParty
    base_uri 'https://blockchain.info'
    default_params api_code: "LK75FDss"

    def getblock(n); self.class.get("/rawblock/#{n}") end
    def latestblock; self.class.get("/latestblock")   end
  end

  def initialize(options)
    @options = options
    @http = BlockChainInfo.new
    @start_block = get_start_block
    @end_block = get_end_block
    @mutex = Mutex.new
    @errors = 0
  end

  def start
    THREAD_COUNT.times.map {
      Thread.new do
        http = BlockChainInfo.new
        while idx = get_work
          sync_block(http, idx)
        end
      end
    }.each(&:join)
  end

private

  def get_work
    @mutex.synchronize do
      return if @start_block > @end_block
      @start_block.tap { @start_block+=1 }
    end
  end

  def get_start_block
    @options[:start] || Block.last.try(:id).try(:next) || BLOCK_START
  end

  def get_end_block
    @options[:end] || @http.latestblock['block_index'].try(:to_i) || BLOCK_END
  end

  def sync_block(http, n)
    logger.info "Creating block #{n}, Errors: #{@errors}"
    raw_block = http.getblock(n)

    begin
      if raw_block.is_a? Hash
        block_attrs = Block.from_json(raw_block)
        Block.create(block_attrs, without_protection: true)
      else
        logger.info("bad response: #{raw_block.pretty_inspect}")
      end
    rescue Exception => e
      logger.error(e.class.to_s)
      @errors += 1
    end
  end

end
