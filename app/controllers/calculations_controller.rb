class CalculationsController < ApplicationController
  def new
    @input = default_inputs

    if params[:calc].present?
      permitted = params.require(:calc).permit(:calculation_mode, :total_min, :z1, :z2, :z3, :z4, :z5, :intensity_level)
      @input.merge!(permitted.to_h.symbolize_keys)
    end
  end

  def create
    params_hash = calc_params.to_h

    result = CarbCalc::Calculator.new(params_hash).call
    if result.success?
      @input = result.value![:input]
      @result = result.value![:value]
      @input[:total_min] = @result[:total_minutes] if @result[:total_minutes].present?

      respond_to do |format|
        format.turbo_stream
        format.html { render :new }
      end
    else
      @input = calc_params.to_h
      # Normalize errors to ensure values are arrays
      @errors = normalize_validation_errors(result.failure)

      respond_to do |format|
        format.turbo_stream { render "create", status: :unprocessable_entity }
        format.html { render :new, status: :unprocessable_entity }
      end
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

  def normalize_validation_errors(errors)
    errors.transform_values do |messages|
      messages.is_a?(Array) ? messages : [messages]
    end
  end
end
