module CarbCalc
  class GelCalculator
    include Dry::Monads[:result]

    # Proportions: maltodextrin : fructose = 1 : 0.8
    MALTODEXTRIN_RATIO = 1.0
    FRUCTOSE_RATIO = 0.8
    RATIO_SUM = MALTODEXTRIN_RATIO + FRUCTOSE_RATIO

    # Water ratio: 300g powders : 200g water
    POWDER_TO_WATER_RATIO = 300.0 / 200.0

    def initialize(params)
      @params = params
    end

    def call
      contract_result = GelInputContract.new.call(@params)
      return Failure(contract_result.errors.to_h) unless contract_result.success?

      validated_params = contract_result.to_h

      if validated_params[:mode] == "carbs_target"
        calculate_from_carbs(validated_params[:total_carbs_g])
      else
        calculate_from_volume(validated_params[:volume_ml])
      end
    end

    private

    def calculate_from_carbs(total_carbs_g)
      maltodextrin_g = (total_carbs_g * MALTODEXTRIN_RATIO / RATIO_SUM).round(1)
      fructose_g = (total_carbs_g * FRUCTOSE_RATIO / RATIO_SUM).round(1)
      total_powder_g = maltodextrin_g + fructose_g
      water_g = (total_powder_g / POWDER_TO_WATER_RATIO).round(1)
      estimated_volume_ml = (water_g + total_powder_g).round(1)

      Success({
        mode: "carbs_target",
        total_carbs_g: total_carbs_g.round(1),
        maltodextrin_g: maltodextrin_g,
        fructose_g: fructose_g,
        water_g: water_g,
        estimated_volume_ml: estimated_volume_ml
      })
    end

    def calculate_from_volume(volume_ml)
      # Assuming 300g powder + 200g water = 500ml
      # Powder ratio: 300/500 = 0.6
      powder_ratio = 0.6
      total_carbs_g = (volume_ml * powder_ratio).round(1)

      maltodextrin_g = (total_carbs_g * MALTODEXTRIN_RATIO / RATIO_SUM).round(1)
      fructose_g = (total_carbs_g * FRUCTOSE_RATIO / RATIO_SUM).round(1)
      total_powder_g = maltodextrin_g + fructose_g
      water_g = (total_powder_g / POWDER_TO_WATER_RATIO).round(1)

      Success({
        mode: "volume_target",
        volume_ml: volume_ml.round(1),
        total_carbs_g: total_carbs_g,
        maltodextrin_g: maltodextrin_g,
        fructose_g: fructose_g,
        water_g: water_g
      })
    end
  end
end
