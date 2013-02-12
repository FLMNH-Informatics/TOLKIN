class Message::Results
  def initialize controller, action, successful, failed
    @controller, @action, @successful, @failed = controller, action, successful, failed
    @message = 'Results of #{controller} #{action} operation:<br />#{successful_count} successful #{failed_count} failed.'
  end

  def to_json
    { :message => {
        :class      => self.class.to_s,
        :message    => @message,
        :controller => @controller,
        :action     => @action,
        :successful => @successful,
        :failed     => @failed
      }
    }.to_json
  end
end
