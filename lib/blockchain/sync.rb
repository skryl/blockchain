class Blockchain::Sync
  include Blockchain::Utils
  include Blockchain::ORM

  THREAD_COUNT = 10

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
    logger.info "Creating block #{n}"
    raw_block = http.getblock(n)

    unless raw_block.is_a? Hash
      logger.error "bad response: #{raw_block}"
    else
      block = fix_fields(raw_block)
      logger.debug block.pretty_inspect
      Block.create(block, without_protection: true)
    end
  end

  def fix_fields(raw_block)
    raw_block['id'] = raw_block.delete('block_index')
    raw_block.delete('received_time')

    raw_block['transactions_attributes'] = \
      raw_block.delete('tx').each do |tx|
        tx['id'] = tx.delete('tx_index')
        tx['block_id'] = raw_block['id']
        tx.delete('time')

        tx['inputs_attributes'] = \
          tx.delete('inputs').each do |input|
            next unless input['prev_out']
            prev_out = input.delete('prev_out')
            input['txn_id'] = prev_out['tx_index']
            input['n'] = prev_out['n']
          end.reject(&:empty?)

        tx['outputs_attributes'] = \
          tx.delete('out').each do |output|
            output['txn_id'] = tx['id']
            output.delete('tx_index')
          end
      end

    raw_block
  end

end
