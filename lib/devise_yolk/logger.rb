module DeviseYolk

  class Logger
    def self.send(message, logger = Rails.logger)
      if logger && ::Devise.yolk_logger
        logger.add 0, "\e[36mYOLK:\e[0m #{message}"
      end
    end
  end

end
