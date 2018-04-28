#!/usr/bin/env ruby
require 'json'
class Calculator
    class Is_function
        def self.===(str)
            str[/log|ln|exp|e\^/] != nil
        end
    end
    class Is_operator
        def self.===(str)
            str[/[\+*\-*\^*\/*\**]+/] != nil
        end
    end
    class Is_numeric
        def self.===(str)
            str[/^-?\d+$/] != nil
        end
    end


    def makeStackfromInput(input)
        return input.split(%r{\s+|(\d*\.\d+)|([\+\-\*\/\^\(\)])|(log|ln|exp|e\^)}).reject(&:empty?)
    end
    def getInfoFromHash(operator, type)
        @hash_priorities = {
            "^" => {"precedence"=>4, "associativity"=>"Right"},
            "*" => {"precedence"=>3, "associativity"=>"Left"},
            "/" => {"precedence"=>3, "associativity"=>"Left"},
            "+" => {"precedence"=>2, "associativity"=>"Left"},
            "-" => {"precedence"=>2, "associativity"=>"Left"},
        }
        return @hash_priorities[operator][type]
    end
    def condition_operator(operator, cell)
        unless operator.nil? or operator == "(" then 
           if (operator[/log|ln|exp|e\^/] != nil) or (getInfoFromHash(operator, "precedence")>getInfoFromHash(cell, "precedence")) or (getInfoFromHash(operator, "precedence")==getInfoFromHash(cell, "precedence") and getInfoFromHash(operator, "associativity")>getInfoFromHash(cell, "associativity")) then return true
            end
        end 
        return false
        #return false
       #return (not operator.nil?) and (operator != "(") and (operator[/log|ln|exp/] != nil) or (getInfoFromHash(operator, "precedence")>getInfoFromHash(cell, "precedence")) or ((getInfoFromHash(operator, "precedence")==getInfoFromHash(cell, "precedence") and getInfoFromHash(operator, "associativity")>getInfoFromHash(cell, "associativity"))) 
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
end

c = Calculator.new()
input = "3*log ( 3)*e^(12  *8+log(3))-    log(5+5)*33+8"
puts input
puts c.makeStackfromInput(input)
puts "Result:"
puts c.shunting_yard(c.makeStackfromInput(input))
