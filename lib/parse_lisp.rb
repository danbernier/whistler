class LispParser
    def tokenize(lisp)
        lisp.scan(/\(|\)|'|[A-z0-9+*\/%=<>-?]+|#t|#f/i)
    end
    def to_ast(tokens)
        stack = []
        cur_list = []
        
        tokens.each do |token|
            if token == '('
                stack.push cur_list
                cur_list = []
            elsif token == ')'
                l = cur_list
                cur_list = stack.pop
                cur_list << l
            else
                cur_list << token_to_atom(token)
            end
        end
        cur_list.first
    end
    def token_to_atom(a)
        # The LSer translates constants & numbers from strings into values 
        # in the evaluator, not the parser, but we'll do it here, because
        # I think it'll be pretty much the same for all evaluators.  We'll see.
        if a == "#t"
            true
        elsif a == "#f"
            false
        elsif a.to_f.to_s == a
            a.to_f
        elsif a.to_i.to_s == a
            a.to_i
        else
            a.to_sym
        end
    end
    def parse(lisp)
        to_ast(tokenize(lisp))
    end
end