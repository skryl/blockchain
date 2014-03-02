module Blockchain::Utils

  def logger
    Blockchain::Utils.logger
  end

  def self.logger
    @logger ||= BufferedLogger.new(STDOUT, :debug,
               { info:  "$green INFO: $white %s",
                 debug: "$yellow DEBUG: $white %s",
                 error: "$red ERROR: $white %s" })
  end

end
