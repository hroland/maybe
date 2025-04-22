module ExchangeRate::Provided
  extend ActiveSupport::Concern

  class_methods do
    def provider
      registry = Provider::Registry.for_concept(:exchange_rates)
      registry.get_provider(:synth)
    end

    def find_or_fetch_rate(from:, to:, date: Date.current, cache: true)
      # try to find an exact date match first
      rate = find_by(from_currency: from, to_currency: to, date: date)
      return rate if rate.present?

      # no exact match, try to find closest date
      closest_rate = find_closest_rate(from: from, to: to, date: date)
      return closest_rate if closest_rate.present?

      # no existing rate found (exact or closest), try to fetch from provider
      return nil unless provider.present? # No provider configured (some self-hosted apps)

      response = provider.fetch_exchange_rate(from: from, to: to, date: date)

      return nil unless response.success? # Provider error

      rate = response.data
      ExchangeRate.find_or_create_by!(
        from_currency: rate.from,
        to_currency: rate.to,
        date: rate.date,
        rate: rate.rate
      ) if cache
      rate
    end

    def find_closest_rate(from:, to:, date:)
      # Find the closest rate by date (either before or after the requested date)
      closest_rate = where(from_currency: from, to_currency: to)
        .order(Arel.sql("ABS((date - '#{date}'::date))"))
        .first

      return closest_rate if closest_rate.present?

      # If no rate found, try the reverse conversion (1/rate)
      closest_reverse = where(from_currency: to, to_currency: from)
        .order(Arel.sql("ABS((date - '#{date}'::date))"))
        .first

      if closest_reverse.present?
        # create a synthetic rate object with inverted rate
        rate = new(
          from_currency: from, 
          to_currency: to,
          date: closest_reverse.date,
          rate: 1.0 / closest_reverse.rate
        )
        return rate
      end

      nil
    end

    def sync_provider_rates(from:, to:, start_date:, end_date: Date.current)
      unless provider.present?
        Rails.logger.warn("No provider configured for ExchangeRate.sync_provider_rates")
        return 0
      end

      fetched_rates = provider.fetch_exchange_rates(from: from, to: to, start_date: start_date, end_date: end_date)

      unless fetched_rates.success?
        Rails.logger.error("Provider error for ExchangeRate.sync_provider_rates: #{fetched_rates.error}")
        return 0
      end

      rates_data = fetched_rates.data.map do |rate|
        {
          from_currency: rate.from,
          to_currency: rate.to,
          date: rate.date,
          rate: rate.rate
        }
      end

      ExchangeRate.upsert_all(rates_data, unique_by: %i[from_currency to_currency date])
    end
  end
end
