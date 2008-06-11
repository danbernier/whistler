require 'parse_lisp'

class LittleWhistler

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
	def second(ary)
		ary[1]
	end
    def third(ary)
        ary[2]
    end
    def rest(ary)
        ary[1..-1]
    end
    def atom?(x)
        Symbol === x || number?(x)  # implemented in LSer as (and (not (pair? x)) (not (null? x)))))
    end
    def number?(x)
        Fixnum === x || Float === x
    end
    def bool?(x)
        TrueClass === x || FalseClass === x
    end
    def literal?(x)
        number?(x) || bool?(x)   # also strings?
    end

	%{
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
	}
	
	def new_entry(names, vals)
		[names, vals]
	end
	def lookup_in_entry(name, entry, &entry_f)
		def lookup_in_entry_helper(name, names, values, &entry_f_inner)
			if names.empty?
				entry_f_inner[name]
			elsif first(names) == name
				first(values)
			else
				lookup_in_entry_helper(name, rest(names), rest(values), &entry_f_inner)
			end
		end
		
		lookup_in_entry_helper(name, first(entry), second(entry), &entry_f)
	end
	
	# Instead of cons'ing onto the front, we could push onto the end, but let's keep it similar for now.
	def extend_table(new_entry, table)
		table.unshift new_entry
	end
	def lookup_in_table(name, table, &table_f)
		if table.empty?
			table_f[name]
		else
			lookup_in_entry(name, first(table)) do |name|
				lookup_in_table(name, rest(table), &table_f)
			end
		end
	end
    
    
    #----------------------------------------------------
    # Test boundary -- nothing past here is unit tested.
    #----------------------------------------------------
    
    def expression_to_action(e)
        if atom? e
            atom_to_action e
        else
            list_to_action e
        end
    end
    
    @@consts = [true, false, :cons, :car, :cdr, :null?, :eq?, :atom?, :zero?, :add1, :sub1, :number?]  # what about "pair?".to_sym ?
                                # and couldn't many of these be implemented in scheme, anyway?  wouldn't they be identifiers, then?
    def atom_to_action(e)
        if number? e || @@consts.include?(e)
            @@const
        else
            @@identifier
        end
    end
    @@special_forms = [:quote, :lambda, :cond]  # include :define ?  (they say to rely on Y-comb)
    def list_to_action(e)
        if atom? e
            if e == :quote
                @@quote
            elsif e == :lambda
                @@lambda
            elsif e == :cond
                @@cond
            end
        else
            :application  # -> will become a function
        end     
    end
    
    
    def value(e)
        meaning(e, [])  # [] is the empty table
    end
    def meaning(e, table)
        (expression_to_action(e)).call(e, table)
    end
    
    
    #---------------------------------------------------
    # Functions for eval.
    # 
    # Note: these guys are class vars because we want to return them
    # from *_to_action methods.  Once it's running, rubify it.
    
    @@const = lambda do |e, table|
        if literal? e  # bool or number.  Also strings?
            e
        else
            [:primitive, e]
        end
    end
    
    @@quote = lambda do |e, table|
        second(e)  # e should look like: [:quote, e]
    end
    
    @@identifier = lambda do |e, table|
        lookup_in_table(e, table) { |name| @@quote[name] }  # "Let's hope this is never used.  Why?"
    end
    
    @@lambda = lambda do |e, table|
        [:non_primitive, table, rest(e)]  # [:non-primitive, <table>, <formals>, <body>]
    end
    alias :table_of :first
    alias :formals_of :second
    alias :body_of :third
    
    def evcon(lines, table)
        def else?(x)
            atom?(x) && x == :else
        end
        def question_of(ary); first(ary); end
        def answer_of(ary); second(ary); end
        
        q = question_of(first(lines))
        a = answer_of(first(lines))
        if else?(q) || meaning(q, table)
            meaning(a, table)
        else
            evcon(rest(lines), table)
        end 
    end
    
    @@cond = lambda do |e, table|
        evcon(rest(e), table)
    end
end