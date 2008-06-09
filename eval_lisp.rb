require 'parse_lisp'

class BasicLisp

    def initialize
        @lp = LispParser.new
        
        @funcs = {}
        @funcs['+'] = lambda { |*args|
            args.inject(0) { |s,i| s + i }
        }
    end

    def first(ary)
        ary[0]
    end
    def rest(ary)
        ary[1..-1]
    end

    def eval(lisp)
        eval_list(@lp.parse(lisp))
    end
    
    def eval_list(l)
        func = @funcs[first(l)]
        func[*rest(l).map{|a| eval_atom(a) }]
    end
    def eval_atom(a)
        a =~ /\d+/ ? a.to_i : a
    end

end