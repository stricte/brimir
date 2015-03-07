class ResetCounters < ActiveRecord::Migration
  def change
    #Labels
    Labeling.all.each do |labeling|
      labeling.send('update_counters')
    end

    #Replies
    Ticket.all.each do |t| Ticket.reset_counters(t, :replies) end
  end
end
