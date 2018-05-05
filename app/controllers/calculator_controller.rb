class CalculatorController < ApplicationController
    def index
    end

    def operate
        @input = params[:input]
        @stackInput = Calculator.makeStackfromInput(@input)
        @shunting_yard = Calculator.shunting_yard(@stackInput)
        @polish_notation_algorithm = Calculator.polish_notation_algorithm(@shunting_yard)
        render :index
    end
end
