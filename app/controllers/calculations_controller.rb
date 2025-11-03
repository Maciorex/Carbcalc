class CalculationsController < ApplicationController
  def new
    @input = default_inputs

    if params[:calc].present?
      permitted = params.require(:calc).permit(:calculation_mode, :total_min, :z1, :z2, :z3, :z4, :z5, :intensity_level)
      @input.merge!(permitted.to_h.symbolize_keys)
    end

    if @input[:calculation_mode] == "manual"
      @input[:total_min] = sum_zones(@input)
    end
  end

  def create
    params_hash = calc_params.to_h

    if params_hash[:calculation_mode] == "auto"
      params_hash = apply_automatic_distribution(params_hash)
    end

    result = CarbCalc::Calculator.new(params_hash).call

    if result.success?
      @input = result.value![:input]
      @result = result.value![:value]

      respond_to do |format|
        format.turbo_stream
        format.html { render :new }
      end
    else
      @input = calc_params.to_h
      @errors = result.failure
      render :new, alert: "Calculation failed"
    end
  end

  private

  def calc_params
    params.require(:calc).permit(
      :calculation_mode,
      :total_min, :z1, :z2, :z3, :z4, :z5,
      :intensity_level,
      :mass_kg, :scale_by_mass,
      :gut_tolerance, :weather, :altitude,
      :gel_g,
      :bottle_g,
      :bottle_ml,
      :drink_g_per_100ml
    )
  end

  def default_inputs
    {
      calculation_mode: "auto",
      total_min: 180, z1: 30, z2: 60, z3: 60, z4: 20, z5: 10,
      intensity_level: nil,
      mass_kg: 70, scale_by_mass: true,
      gut_tolerance: "medium", weather: "temperate", altitude: "low",
      gel_g: 30,
      bottle_g: 0,
      bottle_ml: 500, drink_g_per_100ml: 6
    }
  end

  def apply_automatic_distribution(params)
    total_min = params[:total_min].to_i

    params.merge(
      z1: (total_min * 0.10).round,
      z2: (total_min * 0.33).round,
      z3: (total_min * 0.33).round,
      z4: (total_min * 0.20).round,
      z5: (total_min * 0.04).round
    )
  end

  def sum_zones(input)
    [:z1, :z2, :z3, :z4, :z5].sum { |zone_key| input[zone_key].to_i }
  end
end
