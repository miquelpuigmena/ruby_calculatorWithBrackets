
class Calculator
    """
        Hash to define priority among operators.
    """
    @hash_priorities = {
        "^" => {"precedence"=>4, "associativity"=>"Right"},
        "*" => {"precedence"=>3, "associativity"=>"Left"},
        "/" => {"precedence"=>3, "associativity"=>"Left"},
        "+" => {"precedence"=>2, "associativity"=>"Left"},
        "-" => {"precedence"=>2, "associativity"=>"Left"},
    }
    """
        Regex patterns used in several functions.
        Note that all of them are created as Class attributes. Usefull to share them with other classes.
    """
    @@functions="log|ln|exp|e\^|sinh|cosh|tanh|sin|cos|tan"
    @@operands="\+|\\-|\*|\^|\/"
    @@parenthesis="\(|\)"
    @@pi="pi|PI"
    @@numeric="\\d*[\.|\,]?\\d+"
    @@blank_spaces="\s+"
    class Is_function < Calculator
        """
            Inherit Calculator class so Regex patterns are accesible from inside class.

            Checks wether str input is a function. Number could be ['log','ln',...,'cosh',...,'tan']
            Return true if it is a function false otherwise.
        """
        def self.===(str)
            str[/[#{@@functions}]/] != nil
        end
    end
    class Is_operator < Calculator
        """
            Inherit Calculator class so Regex patterns are accesible from inside class.

            Checks wether str input is an operand. Operator could be ['+', '-', '/', '*', '^']
            Return true if it is an operand false otherwise.
        """
        def self.===(str)
            str[/[#{@@operands}]/] != nil
        end
    end
    class Is_numeric < Calculator
        """
            Inherit Calculator class so Regex patterns are accesible from inside class.

            Checks wether str input is a number. Number could be ['1', '1.4', '1,5', '.578', ',99']
            Return true if it is a number false otherwise.
        """
        def self.===(str)
            str[/#{@@numeric}/] != nil
        end
    end
    public
    def self.makeStackfromInput(input)
        """
            Takes any String given from controller method calculator#index as input.

            Returns expression which is a stack of elements where elements could be Functions, operators, numbers.
            Note that .reject(&:empty?) drops any cell with empty string inside stack.
            Note that .map{|x| x[/#{@@pi}/] ? Math::PI.to_s : x } takes any accepted PI statement and replaces it by pi numeric value as a String.
        """
        expression = input.split(/#{@@blank_spaces}|(#{@@numeric})|(#{@@pi})|([#{@@operands}])|([#{@@parenthesis}])|(#{@@functions})/).reject(&:empty?).map{|x| x[/#{@@pi}/] ? Math::PI.to_s : x }
        if expression.first.eql?("-") then expression.unshift("0") end
        return expression
    end
    def self.shunting_yard(stack)
        """
            Takes stack of elements created by makeStackfromInput. This stack is a prefix-notation expression.

            Using Shunting Yard Algorithm, input stack (prefix-notation) is converted to a postfix-notation expression.
            Returns output_queue which is a stack of elements where elements could be Functions, operators, numbers. This stack is a postfix-notation expression.
            Note that condition_operator(operator_stack.last, cell) call it's not needed but achieves a cleaner code.
        """
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
        """
            Takes stack of elements created by shunting_yard. This stack is a postfix-notation expression.
            Using Polish Reverse notation Algorithm, input shunting_yard_stack (postfix-notation) is evaluated and ends as the result.

            Returns polish_stack which contains the final result. If everything worked fine, this polish_stack will be of length 1.
            Note that when you evaluate an operator you need to pop two operands.
            Note that when you evaluate a function you need to pop only one operand.
        """
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
        """
            Takes an operand and type of resource to solicitate.
            Returns associated value from @hash_priorities.
        """
        return @hash_priorities[operator][type]
    end
    def self.condition_operator(operator, cell)
        """
            Return :
            **Pseudo code**
         [(there is a function at the top of the operator stack)
           or (there is an operator at the top of the operator stack with greater precedence)
           or (the operator at the top of the operator stack has equal precedence and is left associative))
          and (the operator at the top of the operator stack is not a left bracket)]
            **Pseudo code**
        """
        return (!(operator.nil? or operator == "(" or operator.empty?) and (Is_function.===(operator) or (compare_precedence(operator, "precedence")>compare_precedence(cell, "precedence")) or (compare_precedence(operator, "precedence")==compare_precedence(cell, "precedence") and compare_precedence(operator, "associativity")=="Left")))
    end
    def self.simple_operation_calculate(operands, operator)
        """
            Takes operands and operator.

            Note that if operand is an accepted function will evaluate using Ruby's Math::function library.
            Note that simple operations such as ['+', '-', '/', '*', '^'] can be evaluated using Float.send. 
        """
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
