class Event < ApplicationRecord
  attribute :kind, :string
  attribute :starts_at, :datetime
  attribute :ends_at, :datetime
  attribute :weekly_recurring, :boolean

  def self.availabilities(date)
    return []
  end

  def self.availabilities_for_specific_day(date)
    availabilities = []

    Event.get_reccuring_openings(date, availabilities)
    Event.get_non_reccuring_openings(date, availabilities)

    return availabilities
  end

  def self.get_reccuring_openings(date, availabilities)
    openings = Event.where(kind: "opening", weekly_recurring: true)
    openings.each do |opening|
      op_start = opening.starts_at.to_datetime
      op_end = opening.ends_at.to_datetime

      # If opening is set after tested date
      if date >= op_start.beginning_of_day
        days_difference = date.beginning_of_day - op_start.beginning_of_day
        if days_difference % 7 == 0
          #add opening to tab
          Event.add_to_availabilities(op_start, op_end, availabilities)
        end
      end
    end

    return availabilities
  end

  def self.get_non_reccuring_openings(date, availabilities)
    openings = Event.where(kind: "opening", weekly_recurring: false, starts_at: date.beginning_of_day..date.end_of_day)
    openings.each do |opening|
      op_start = opening.starts_at.to_datetime
      op_end = opening.ends_at.to_datetime

      Event.add_to_availabilities(op_start, op_end, availabilities)
    end

    return availabilities
  end

  def self.add_to_availabilities(opening_starts_at, opening_ends_at, availabilities)
    while opening_starts_at < opening_ends_at do
      availabilities << opening_starts_at
      opening_starts_at += 30.minutes
    end

    return availabilities
  end
end
