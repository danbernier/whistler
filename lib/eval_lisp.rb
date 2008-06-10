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
    def rest(ary)
        ary[1..-1]
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

end