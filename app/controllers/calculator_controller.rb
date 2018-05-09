class CalculatorController < ApplicationController
    def index
    end

    def operate
        begin
            @input = params[:input]
            @stackInput = Calculator.makeStackfromInput(@input)
            @shunting_yard = Calculator.shunting_yard(@stackInput)
            @polish_notation_algorithm = Calculator.polish_notation_algorithm(@shunting_yard)
            render :index
        rescue StandardError => e
            render :index
        end
    end
end
