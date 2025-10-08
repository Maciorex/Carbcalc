class CalculationsController < ApplicationController
  def new
    @input = default_inputs
  end

  def create
    result = CarbCalc::Calculator.new(calc_params.to_h).call

    if result.success?
      @input = result.value![:input]
      @result = result.value![:value]
    else
      @input = calc_params.to_h
      @errors = result.failure
      render :new, alert: "Calculation failed"
    end
  end

  private

  def calc_params
    params.require(:calc).permit(
      :total_min, :z1, :z2, :z3, :z4, :z5,
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
      total_min: 180, z1: 30, z2: 60, z3: 60, z4: 20, z5: 10,
      mass_kg: 70, scale_by_mass: true,
      gut_tolerance: "medium", weather: "temperate", altitude: "low",
      gel_g: 30,
      bottle_ml: 500, drink_g_per_100ml: 6
    }
  end
end
