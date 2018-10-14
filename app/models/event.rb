class Event < ApplicationRecord
  attribute :kind, :string
  attribute :starts_at, :datetime
  attribute :ends_at, :datetime
  attribute :weekly_recurring, :boolean

  def self.availabilities(date)
    availabilities = []

    (0..6).each do |i|
      availabilities << {
        date: date.to_date,
        slots: Event.availabilities_for_specific_day(date)
      }
      date += 1.day
    end

    return availabilities
  end

  def self.availabilities_for_specific_day(date)
    availabilities = []
    opening_slots = []
    appointment_slots = []

    Event.get_reccuring_openings(date, opening_slots)
    Event.get_non_reccuring_openings(date, opening_slots)

    opening_slots = opening_slots.sort.map { |slot| Event.format_slot(slot) }

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
          # Do not format to allow sorting
          Event.add_event_to_slots(op_start, op_end, opening_slots, false)
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

      # Do not format to allow sorting
      Event.add_event_to_slots(op_start, op_end, opening_slots, false)
    end

    return opening_slots
  end

  def self.get_appointments(date, appointment_slots)
    appointments = Event.where(kind: "appointment", starts_at: date.beginning_of_day..date.end_of_day)
    appointments.each do |appointment|
      at_start = appointment.starts_at.to_datetime
      at_end = appointment.ends_at.to_datetime

      Event.add_event_to_slots(at_start, at_end, appointment_slots, true)
    end

    return appointment_slots
  end

  def self.add_event_to_slots(event_starts_at, event_ends_at, slots, format)
    while event_starts_at < event_ends_at do
      if not slots.include? Event.format_slot(event_starts_at)
        if format == true
          slots << Event.format_slot(event_starts_at)
        else
          slots << event_starts_at
        end
      end
      event_starts_at += 30.minutes
    end

    return slots
  end

  def self.format_slot(slot)
    return slot.strftime("%-k:%M")
  end
end
