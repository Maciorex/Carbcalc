module CarbCalc
  class Calculator
    include Dry::Monads[:result]

    # Stałe docelowe g/h dla stref
    ZONE_CARBS_PER_HOUR = { z1: 20, z2: 35, z3: 55, z4: 75, z5: 95 }.freeze

    PRESETS = {
      "easy"     => { z1: 40, z2: 35, z3: 20, z4: 5,  z5: 0  },
      "moderate" => { z1: 20, z2: 40, z3: 30, z4: 8,  z5: 2  },
      "intense"  => { z1: 10, z2: 25, z3: 35, z4: 20, z5: 10 },
      "race"     => { z1: 5,  z2: 20, z3: 35, z4: 25, z5: 15 },
    }.freeze

    def initialize(params)
      @params = params
    end

    def call
      contract_result = InputContract.new.call(@params)
      return Failure(contract_result.errors.to_h) unless contract_result.success?

      validated_params = contract_result.to_h

      calculation_result = if validated_params[:calculation_mode] == "auto"
        auto_calculation(validated_params)
      else
        manual_calculation(validated_params)
      end

      Success(input: validated_params, value: calculation_result)
    end

    private

    attr_reader :params

    def auto_calculation(params)
      intensity_level = params[:intensity_level]
      preset = PRESETS[intensity_level]

      return manual_calculation(params) unless preset

      total_minutes = params[:total_min]
      params_with_zones = params.merge(
        z1: (total_minutes * preset[:z1] / 100.0).round,
        z2: (total_minutes * preset[:z2] / 100.0).round,
        z3: (total_minutes * preset[:z3] / 100.0).round,
        z4: (total_minutes * preset[:z4] / 100.0).round,
        z5: (total_minutes * preset[:z5] / 100.0).round
      )

      manual_calculation(params_with_zones)
    end

    def manual_calculation(params)
      # 1. Oblicz średnią ważoną g/h
      gh = calculate_weighted_average_carbs_per_hour(params)

      # 2. Oblicz całkowite węglowodany
      total_g = calculate_total_carbs(gh, params)

      # 3. Dodaj guardy i pochodne
      {
        carbs_per_hour: gh.round(2),
        carbs_per_hour_rounded: gh.round,
        total_carbs: total_g.round,
        carbs_per_20min: (gh / 3).round(2),
        carbs_per_20min_rounded: (gh / 3).round
      }
    end

    def calculate_weighted_average_carbs_per_hour(params)
      # Pobierz minuty w strefach
      z1, z2, z3, z4, z5 = params.values_at(:z1, :z2, :z3, :z4, :z5)
      # Użyj total_min zamiast sumowania stref
      total_minutes = params[:total_min]
      
      # Jeśli brak czasu, zwróć 0
      return 0.0 if total_minutes == 0
      
      # Średnia ważona: (20*z1 + 35*z2 + 55*z3 + 75*z4 + 95*z5) / total_min
      weighted_sum = (ZONE_CARBS_PER_HOUR[:z1] * z1) +
                     (ZONE_CARBS_PER_HOUR[:z2] * z2) +
                     (ZONE_CARBS_PER_HOUR[:z3] * z3) +
                     (ZONE_CARBS_PER_HOUR[:z4] * z4) +
                     (ZONE_CARBS_PER_HOUR[:z5] * z5)
      
      gh = weighted_sum.to_f / total_minutes
      
      # Guard: przytnij do [0, 120] g/h
      gh.clamp(0, 120)
    end

    def calculate_total_carbs(gh, params)
      # total_g = gh * (total_min / 60)
      total_minutes = params[:total_min]
      gh * (total_minutes / 60.0)
    end
  end
end
