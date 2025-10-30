# frozen_string_literal: true

module CarbCalc
  class InputContract < Dry::Validation::Contract
    params do
      optional(:calculation_mode).maybe(:string)
      required(:total_min).filled(:integer, gt?: 0)

      optional(:z1).filled(:integer, gteq?: 0)
      optional(:z2).filled(:integer, gteq?: 0)
      optional(:z3).filled(:integer, gteq?: 0)
      optional(:z4).filled(:integer, gteq?: 0)
      optional(:z5).filled(:integer, gteq?: 0)

      required(:mass_kg).filled(:float, gt?: 0)
      required(:scale_by_mass).filled(:bool)

      required(:gut_tolerance).filled(:string)  # "low" | "medium" | "high"
      required(:weather).filled(:string)        # "cold" | "temperate" | "hot"
      required(:altitude) .filled(:string)      # "low"  | "high"

      required(:gel_g).filled(:float, gteq?: 10, lteq?: 40)

      optional(:bottle_g).maybe(:float, gteq?: 0, lteq?: 120)
      optional(:bottle_ml).maybe(:integer, gteq?: 0, lteq?: 1500)
      optional(:drink_g_per_100ml).maybe(:float, gteq?: 0, lteq?: 20) # 0–20 g/100ml
    end

    rule(:gut_tolerance) do
      key.failure("must be one of: low, medium, high") unless %w[low medium high].include?(value)
    end

    rule(:weather) do
      key.failure("must be one of: cold, temperate, hot") unless %w[cold temperate hot].include?(value)
    end

    rule(:altitude) do
      key.failure("must be one of: low, high") unless %w[low high].include?(value)
    end
  end
end
