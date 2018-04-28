#!/usr/bin/env ruby
class Calculator
    @@hash_priorities = {
        "^" => {"precedence"=>4, "associativity"=>"Right"},
        "*" => {"precedence"=>3, "associativity"=>"Left"},
        "/" => {"precedence"=>3, "associativity"=>"Left"},
        "+" => {"precedence"=>2, "associativity"=>"Left"},
        "-" => {"precedence"=>2, "associativity"=>"Left"},
    }
    class Is_function
        def self.===(str)
            str[/[log|ln|exp|e\^]/] != nil
        end
    end
    class Is_operator
        def self.===(str)
            str[/[\+\-\*\/\^]/] != nil
        end
    end
    class Is_numeric
        def self.===(str)
            str[/^[-?\d*\.\d]+$/] != nil
        end
    end
    def makeStackfromInput(input)
        return input.split(%r{\s+|(\d*\.\d+)|([\+\-\*\/\^\(\)])|(log|ln|exp|e\^)}).reject(&:empty?)
    end
    def getInfoFromHash(operator, type)
        return @@hash_priorities[operator][type]
    end
    def condition_operator(operator, cell)
        unless operator.nil? or operator == "(" or operator.empty? then 
            if (operator[/[log|ln|exp|e\^]/] != nil) or (getInfoFromHash(operator, "precedence")>getInfoFromHash(cell, "precedence")) or (getInfoFromHash(operator, "precedence")==getInfoFromHash(cell, "precedence") and getInfoFromHash(operator, "associativity")>getInfoFromHash(cell, "associativity")) then 
                return true
            end
        end 
        return false
    end
    def shunting_yard(stack)
        output_queue=[]
        operator_stack=[]
        stack.each{|cell|
            case cell
                when Is_numeric
                    output_queue.push(cell)
                when Is_function, "("
                    operator_stack.push(cell)
                when Is_operator
                    while(condition_operator(operator_stack.last, cell)) do
                        output_queue.push(operator_stack.pop)
                    end
                    operator_stack.push(cell)
                when ")"
                    unless operator_stack.empty?
                        while(operator_stack.last != "(") do output_queue.push(operator_stack.pop) end
                        operator_stack.pop
                    end
            end
        }
        while(operator_stack.any?) do output_queue.push(operator_stack.pop) end
        return output_queue
    end
    def polish_notation_algorithm(shunting_yard_stack)
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
    def simple_operation_calculate(operands, operator)
        case operator
           when "log" 
             return Math::log10(operands.to_f)
           when "ln" 
             return Math::log(operands.to_f, Math::E)
           when "exp","e^" 
             return Math::exp(operands.to_f)
        end
        return operands[0].to_f.send operator, operands[1].to_f
    end
    def operate(input)
        puts "INPUT:"
        puts input
        a=makeStackfromInput(input)
        puts "STACK FROM INPUT:"
        puts a
        s=shunting_yard(a)
        puts "SHUNTING YARD:"
        puts s
        p = polish_notation_algorithm(s)
        puts "POLISH:"
        puts p
        return p
        #return polish_notation_algorithm(shunting_yard(makeStackfromInput(input)))
    end
end
c = Calculator.new()
input = "3+ln4+3*log(4+5*7) "
puts c.operate(input)
