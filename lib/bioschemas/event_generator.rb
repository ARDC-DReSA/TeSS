module Bioschemas
  class EventGenerator < Generator
    def self.type
      'Event'
    end

    def self.bioschemas_profile
      'https://bioschemas.org/profiles/Event/0.2-DRAFT-2019_06_14'
    end

    property :name, :title
    property :alternateName, :subtitle
    property :url, :url
    property :description, :description
    property :keywords, :keywords
    # DReSA (DRESA-66, Nov 2026): Google requires ISO 8601 dates and a location for every event
    # (a VirtualLocation for online events), and recommends attendance mode, status and offers.
    # TeSS stores the event's local clock time and the timezone separately (see Event#start_utc),
    # so write the time with the event's own offset, e.g. 2027-02-08T10:00:00+11:00
    property :startDate, -> (event) { event.start && event.send(:set_to_local, event.start).iso8601 }
    property :endDate, -> (event) { event.end && event.send(:set_to_local, event.end).iso8601 }
    property :organizer, -> (event) { { '@type' => 'Organization', name: event.organizer } if event.organizer.present? }
    property :location, -> (event) {
      place = address(event) if event.venue.present? || event.city.present? || event.county.present? ||
                                event.country.present? || event.postcode.present?
      online = { '@type' => 'VirtualLocation', 'url' => event.url } if event.url.present?
      if event.online? then online
      elsif event.hybrid? then [place, online].compact
      else place
      end
    }
    property :eventAttendanceMode, -> (event) {
      { 'online' => 'https://schema.org/OnlineEventAttendanceMode',
        'onsite' => 'https://schema.org/OfflineEventAttendanceMode',
        'hybrid' => 'https://schema.org/MixedEventAttendanceMode' }[event.presence.to_s]
    }
    property :eventStatus, -> (_event) { 'https://schema.org/EventScheduled' }
    property :offers, -> (event) {
      if event.cost_value.present?
        { '@type' => 'Offer', 'price' => event.cost_value.to_f, 'priceCurrency' => event.cost_currency.presence || 'AUD',
          'url' => event.url }.compact_blank
      elsif event.cost_basis == 'free'
        { '@type' => 'Offer', 'price' => 0, 'priceCurrency' => event.cost_currency.presence || 'AUD', 'url' => event.url }
      end
    }
    property :hostInstitution, :host_institutions
    property :contact, :contact
    property :funder, -> (event) {
      event.sponsors.map { |sponsor| { '@type' => 'Organization', 'name' => sponsor } }
    }
    property :audience, -> (event) {
      event.target_audience.map { |audience| { '@type' => 'Audience', 'audienceType' => audience } }
    }
    property :maximumAttendeeCapacity, :capacity
    property :event_types, :event_types
    property :eligibility, :eligibility
    property :about, -> (event) {
      event.scientific_topics.map { |t| term(t) }
    }
  end
end
