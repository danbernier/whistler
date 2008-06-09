class LispParser
    def tokenize(lisp)
        lisp.scan(/\(|\)|'|[A-z0-9+*\/%=<>-?]+/i)
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
                cur_list << token
            end
        end
        cur_list.first
    end
    def parse(lisp)
        to_ast(tokenize(lisp))
    end
end