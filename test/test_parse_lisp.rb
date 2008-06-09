require 'test/unit'
require 'parse_lisp'

class ParserTests < Test::Unit::TestCase
    def test_tokenize
        lp = LispParser.new
        
        tests = {}
        tests['(eq? (+ 1 2) 3)'] = %w[( eq? ( + 1 2 ) 3 )]
        tests['()'] = %w[( )]
        tests["(cons 'a '(b c))"] = %w[( cons ' a ' ( b c ) )]
        tests['(< 3 2 569)'] = %w[( < 3 2 569 )]
        tests['3'] = ['3']
        tests['//'] = ['//']
        
        tests.each do |lisp, expected_tokens|
            lp.tokenize(lisp).each { |actual_token| assert_equal(expected_tokens.shift, actual_token) }
        end
    end
    
    def test_to_ast
        lp = LispParser.new
        
        tests = {}
        tests['(+ 2 3)'] = %w[+ 2 3]
        tests['3'] = '3'
        tests['(* (+ 3 2) (/ 4 7))'] = ['*', %w[+ 3 2], %w[/ 4 7]]
        
        tests.each do |lisp, nodes|        
            assert_equal_trees(nodes, lp.to_ast(lp.tokenize(lisp)))
        end
    end
    
    def assert_equal_trees(expected, actual)
        
        def is_ary(a); a.respond_to? :to_ary; end
        
        list = expected.zip actual
        list.each do |exp, act|
            if is_ary(exp) && is_ary(act)
                assert_equal_trees(exp, act)
            elsif !is_ary(exp) && !is_ary(act)
                assert_equal(exp, act)
            elsif is_ary(exp)
                flunk("Expected an array, got: #{act}")
            else
                flunk("Expected #{act}, got an array: #{exp}")
            end
        end
    end
end