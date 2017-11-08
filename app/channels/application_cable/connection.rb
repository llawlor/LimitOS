module ApplicationCable
  class Connection < ActionCable::Connection::Base
    # identify each connection by the api key attribute
    #identified_by :api_key

    # connect method which will be called by each actioncable connection
    def connect
      # set the api_key attribute
      #self.api_key = "X"
    end
  end
end
