require 'parse_lisp'

lp = LispParser.new
lisp = lp.parse "(+ 3 2)"

Funcs = {}
Funcs['+'] = lambda { |*args|
    args.inject(0) { |s,i| s + i }
}

def first(ary)
    ary[0]
end
def rest(ary)
    ary[1..-1]
end

def eval_list(l)
    func = Funcs[first(l)]
    func[*rest(l).map{|a| eval_atom(a) }]
end
def eval_atom(a)
    a =~ /\d+/ ? a.to_i : a
end

puts eval_list(lp.parse("(+ 3 2)"))