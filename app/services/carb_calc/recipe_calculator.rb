module CarbCalc
  class RecipeCalculator
    POWDER_TO_WATER_RATIO = { powder: 3, water: 2 }.freeze
    RATIOS = {
      "0.8:1" => { fructose: 0.8, maltodextrin: 1.0 },
      "1:2" => { fructose: 1.0, maltodextrin: 2.0 }
    }.freeze

    def initialize(total_carbs:, ratio:)
      @total_carbs = total_carbs.to_f
      @ratio = ratio
    end

    def call
      ratio_config = RATIOS[@ratio]
      return nil unless ratio_config

      ratio_sum = ratio_config[:fructose] + ratio_config[:maltodextrin]
      fructose_g = (@total_carbs * ratio_config[:fructose] / ratio_sum).round(1)
      maltodextrin_g = (@total_carbs * ratio_config[:maltodextrin] / ratio_sum).round(1)

      total_powder = fructose_g + maltodextrin_g
      water_g = (total_powder * POWDER_TO_WATER_RATIO[:water] / POWDER_TO_WATER_RATIO[:powder]).round(1)

      {
        total_carbs: @total_carbs.round,
        ratio: @ratio,
        fructose_g: fructose_g,
        maltodextrin_g: maltodextrin_g,
        total_powder_g: total_powder.round(1),
        water_g: water_g,
        pectin_tsp: 0.5
      }
    end
  end
end
