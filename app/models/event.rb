class Event < ApplicationRecord
  attribute :kind, :string
  attribute :starts_at, :datetime
  attribute :ends_at, :datetime
  attribute :weekly_recurring, :boolean

  def self.availabilities(date)
    return []
  end

  def self.availabilities_for_specific_day(date)
    openings = Event.where(kind: "opening")
    openings.each do |opening|
      op_start = opening.starts_at.to_datetime
      op_end = opening.ends_at.to_datetime
      if opening.weekly_recurring && date >= op_start.beginning_of_day
        # Substract week difference, check for the sooner week date after the opening's start datetime
        days_difference = date.beginning_of_day - op_start.beginning_of_day
        days_difference_modseven = (days_difference - (days_difference % 7)).day
        if Event.date_matches?(op_start + days_difference_modseven, op_end + days_difference_modseven, date)
          #add opening to tab
          puts "match" #TODO
        end
      else
        if Event.date_matches?(op_start, op_end, date)
          #add opening to tab
          puts "match" #TODO
        end
      end
    end
  end

  def self.date_matches?(opening_starts_at, opening_ends_at, date)
    if date >= opening_starts_at.beginning_of_day && date <= opening_ends_at.end_of_day
      return true
    end
    return false
  end
end
