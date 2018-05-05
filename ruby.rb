#!/usr/bin/env ruby
require 'json'
class Calculator
    class Function_calculator
        def self.===(item)
            accepted_functions=["log","ln","exp","e"]
            accepted_functions.include? item
        end
    end
    class Operator_calculator
        def self.===(item)
            accepted_operators=["^","+","-","*","/"]
            accepted_operators.include? item
        end
    end
    class Is_numeric
        def self.===(str)
            str[/^-?\d+$/] != nil
        end
    end

    @hash_priorities = {
        "^" => {"precedence"=>4, "associativity"=>"Right"},
        "*" => {"precedence"=>3, "associativity"=>"Left"},
        "/" => {"precedence"=>3, "associativity"=>"Left"},
        "+" => {"precedence"=>2, "associativity"=>"Left"},
        "-" => {"precedence"=>2, "associativity"=>"Left"},
    }
    @expression
    def initialize
    end
    def setInput(input)
        @expression = input
    end
    def makeStackInput
        @expression = @expression.split(%r{\s+|(\d*\.\d+)|([\+\-\*\/])|(log|ln|exp|e)}).reject(&:empty?)
    end
    def getInfoFromHash(operator, type)
        return @hash_priorities[operator][type]
    end
    def shunting_yard
        accepted_operators=["^","+","-","*","/"]
        accepted_functions=["log","ln","exp","e"]
        output_queue=[]
        operator_stack=[]
        @expression.each{|cell|
            case cell
                when Is_numeric
                    puts "num"
                    output_queue.push(cell)
                when Function_calculator
                when "("
                    puts "funct or ("
                    operator_stack.push(cell)
                when Operator_calculator
                    puts "Operator"
                    unless operator_stack.last.nil?
                        while(accepted_functions.include? operator_stack.last or getInfoFromHash(operator_stack.last, "precedence")>getInfoFromHash(cell, "precedence") or (getInfoFromHash(operator_stack.last, "precedence")==getInfoFromHash(cell, "precedence") and getInfoFromHash(operator_stack.last, "associativity")>getInfoFromHash(cell, "associativity"))){
                            output_queue.push(operator_stack.pop)
                        }
                    end
                    """
                    operator_stack.each_with_index { |operator, index|
                        puts "in each operate stack"
                        puts operator, index
                        operator_stack[index] = ""
                        break if (accepted_functions.include? operator or getInfoFromHash(operator, "precedence")>getInfoFromHash(cell, "precedence") or (getInfoFromHash(operator, "precedence")==getInfoFromHash(cell, "precedence") and getInfoFromHash(operator, "associativity")>getInfoFromHash(cell, "associativity")))
                        output_queue.push(operator)
                    }
                    """
                    operator_stack.push(cell)
                when ")"
                    puts ")"
                    unless operator_stack.last.nil?
                        while(operator_stack.last != "("){
                            output_queue.push(operator_stack.pop)
                        }
                        if(operator_stack.last == "("){
                            operator_stack.pop
                        }
                    end
                    """
                    operator_stack.each { |operator, index|
                        operator_stack[index] = ""
                        break if operator == "("
                        output_queue.push(operator)
                    }
                    operator_stack.reject(&:empty?)
                    """
            end
        }
        while(operator_stack.any?) {output_queue.push(operator_stack.pop)}
        return output_queue
    end
    def printExpression
        puts @expression
    end
end

c = Calculator.new()
c.setInput("3+3-33+8")
c.makeStackInput

puts "REsult"
puts c.shunting_yard
