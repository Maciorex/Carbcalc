# frozen_string_literal: true

module CarbCalc
  class GelInputContract < Dry::Validation::Contract
    params do
      required(:mode).filled(:string)
      optional(:total_carbs_g).maybe(:float, gt?: 0)
      optional(:volume_ml).maybe(:float, gt?: 0)
    end

    rule(:mode) do
      key.failure("must be one of: carbs_target, volume_target") unless %w[carbs_target volume_target].include?(value)
    end

    rule(:total_carbs_g) do
      if values[:mode] == "carbs_target"
        key.failure("is required when mode is carbs_target") if value.blank?
      end
    end

    rule(:volume_ml) do
      if values[:mode] == "volume_target"
        key.failure("is required when mode is volume_target") if value.blank?
      end
    end
  end
end
