class RuleExecutorJob < ActiveJob::Base
  queue_as :default

  def perform(ticket)
    Rule.all.each do |rule|
      rule.execute(ticket) if rule.filter(ticket)
    end
  end
end
