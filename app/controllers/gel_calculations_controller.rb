class GelCalculationsController < ApplicationController
  def new
    @gel_calc = { mode: params[:mode] || "carbs_target" }
  end

  def create
    @gel_calc = gel_calc_params.to_h

    result = CarbCalc::GelCalculator.new(@gel_calc).call
    if result.success?
      @result = result.value!
      respond_to do |format|
        format.turbo_stream
        format.html { render :new }
      end
    else
      @errors = normalize_validation_errors(result.failure)
      respond_to do |format|
        format.turbo_stream { render "create", status: :unprocessable_entity }
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  private

  def gel_calc_params
    params.require(:gel_calc).permit(:mode, :total_carbs_g, :volume_ml)
  end

  def normalize_validation_errors(errors)
    errors.transform_values do |messages|
      messages.is_a?(Array) ? messages : [messages]
    end
  end
end

