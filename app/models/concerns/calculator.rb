class Calculator
    @hash_priorities = {
        "^" => {"precedence"=>4, "associativity"=>"Right"},
        "*" => {"precedence"=>3, "associativity"=>"Left"},
        "/" => {"precedence"=>3, "associativity"=>"Left"},
        "+" => {"precedence"=>2, "associativity"=>"Left"},
        "-" => {"precedence"=>2, "associativity"=>"Left"},
    }
    @@functions="log|ln|exp|e\^|sinh|cosh|tanh|sin|cos|tan"
    @@operands="\+|\-|\*|\^|\/"
    @@parenthesis="\(|\)"
    @@pi="pi|PI"
    @@numeric="\d*[\.|\,]?\d+"
    @@blank_spaces="\s+"
    class Is_function < Calculator
        def self.===(str)
            str[/[#{@@functions}]/] != nil
        end
    end
    class Is_operator < Calculator
        def self.===(str)
            str[/[#{@@operands}]/] != nil
        end
    end
    class Is_numeric < Calculator
        def self.===(str)
            str[/\d*[\.|\,]?\d+/] != nil
        end
    end
    public
    def self.makeStackfromInput(input)
        #expression = input.split(%r{\s+|(\d*\.\d+)|([\+\-\*\/\^\(\)])|(log|ln|exp|e\^|sinh|cosh|tanh|sin|cos|tan)}).reject(&:empty?)
        expression = input.split(/#{@@blank_spaces}|([#{@@numeric}])|(#{@@pi})|([#{@@operands}])|([#{@@parenthesis}])|(#{@@functions})/).reject(&:empty?).map{|x| x[/#{@@pi}/] ? Math::PI.to_s : x }
    	return expression
    end
    def self.shunting_yard(stack)
        output_queue=[]
        operator_stack=[]
        stack.each{|cell|
            case cell
                when Is_numeric
                    output_queue.push(cell)
                when Is_function, "("
                    operator_stack.push(cell)
                when Is_operator
                    while(condition_operator(operator_stack.last, cell)) do output_queue.push(operator_stack.pop) end
                    operator_stack.push(cell)
                when ")"
                    while(operator_stack.any? and operator_stack.last != "(") do output_queue.push(operator_stack.pop) end
                    operator_stack.pop
            end
        }
        while(operator_stack.any?) do output_queue.push(operator_stack.pop) end
        return output_queue
    end
    def self.polish_notation_algorithm(shunting_yard_stack)
        polish_stack=[]
        shunting_yard_stack.each{|cell|
            case cell
                when Is_operator
                    ops = polish_stack.pop(2)
                    polish_stack.push(simple_operation_calculate(ops, cell))
                when Is_function
                    op = polish_stack.pop
                    polish_stack.push(simple_operation_calculate(op, cell))
                when Is_numeric
                   polish_stack.push(cell)
            end
        }
        return polish_stack
    end
    private
    def self.compare_precedence(operator, type)
        return @hash_priorities[operator][type]
    end
    def self.condition_operator(operator, cell)
        #unless (operator.nil? or operator == "(" or operator.empty?) then
            #if (operator[/#{@@functions}/] != nil) or (compare_precedence(operator, "precedence")>compare_precedence(cell, "precedence")) or (compare_precedence(operator, "precedence")==compare_precedence(cell, "precedence") and compare_precedence(operator, "associativity")=="Left") then
            #    return true
            #end
        #end
        #return false
        return (!(operator.nil? or operator == "(" or operator.empty?) and (Is_function.===(operator) or (compare_precedence(operator, "precedence")>compare_precedence(cell, "precedence")) or (compare_precedence(operator, "precedence")==compare_precedence(cell, "precedence") and compare_precedence(operator, "associativity")=="Left")))
    end
    def self.simple_operation_calculate(operands, operator)
        case operator
        when "log"
            return Math::log10(operands.to_f)
        when "ln"
            return Math::log(operands.to_f, Math::E)
        when "exp","e^"
            return Math::exp(operands.to_f)
        when "sin"
            return Math::sin(operands.to_f)
        when "cos"
            return Math::cos(operands.to_f)
        when "tan"
            return Math::tan(operands.to_f)
        when "sinh"
            return Math::sinh(operands.to_f)
        when "cosh"
            return Math::cosh(operands.to_f)
        when "tanh"
            return Math::tanh(operands.to_f)
        end
        return operands[0].to_f.send operator, operands[1].to_f
    end
end
