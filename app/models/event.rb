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
    opening_slots = []
    appointment_slots = []

    Event.get_reccuring_openings(date, opening_slots)
    Event.get_non_reccuring_openings(date, opening_slots)
    Event.get_appointments(date, appointment_slots)

    opening_slots.each do |opening|
      if not appointment_slots.include?(opening)
        availabilities << opening
      end
    end

    return availabilities
  end

  def self.get_reccuring_openings(date, opening_slots)
    openings = Event.where(kind: "opening", weekly_recurring: true)
    openings.each do |opening|
      op_start = opening.starts_at.to_datetime
      op_end = opening.ends_at.to_datetime

      # If opening is set after tested date
      if date >= op_start.beginning_of_day
        days_difference = date.beginning_of_day - op_start.beginning_of_day
        if days_difference % 7 == 0
          #add opening to tab
          Event.add_event_to_slots(op_start, op_end, opening_slots)
        end
      end
    end

    return opening_slots
  end

  def self.get_non_reccuring_openings(date, opening_slots)
    openings = Event.where(kind: "opening", weekly_recurring: false, starts_at: date.beginning_of_day..date.end_of_day)
    openings.each do |opening|
      op_start = opening.starts_at.to_datetime
      op_end = opening.ends_at.to_datetime

      Event.add_event_to_slots(op_start, op_end, opening_slots)
    end

    return opening_slots
  end

  def self.get_appointments(date, appointment_slots)
    appointments = Event.where(kind: "appointment", starts_at: date.beginning_of_day..date.end_of_day)
    appointments.each do |appointment|
      at_start = appointment.starts_at.to_datetime
      at_end = appointment.ends_at.to_datetime

      Event.add_event_to_slots(at_start, at_end, appointment_slots)
    end

    return appointment_slots
  end

  def self.add_event_to_slots(event_starts_at, event_ends_at, slots)
    while event_starts_at < event_ends_at do
      if not slots.include? Event.format_slot(event_starts_at)
        slots << Event.format_slot(event_starts_at)
      end
      event_starts_at += 30.minutes
    end

    return slots
  end

  def self.format_slot(slot)
    return slot.strftime("%H:%M")
  end
end
