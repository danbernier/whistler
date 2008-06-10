if $0 == __FILE__
	$LOAD_PATH.unshift '../lib'
end

require 'test/unit'
require 'eval_lisp'


class BasicLispTest < Test::Unit::TestCase
    def test_smoketest
        lw = LittleWhistler.new
        #assert_equal(5, lw.eval("(+ 3 2)"))
    end
	
	def test_entries
		lw = LittleWhistler.new
		entry = lw.new_entry(%w[uno dos tres], %w[one two three])
		
		assert_equal(%w[uno dos tres], entry[0])
		assert_equal(%w[one two three], entry[1])
		
		val = lw.lookup_in_entry('uno', entry) { |name| }
		assert_equal('one', val)
		val = lw.lookup_in_entry('dos', entry) { |name| }
		assert_equal('two', val)
		val = lw.lookup_in_entry('tres', entry) { |name| }
		assert_equal('three', val)
	end
	
	def test_tables
		lw = LittleWhistler.new
		dan_names = %w[appetizer entree dessert]
		dan_vals = %w[samosas dal galub]
		
		table = []
		table = lw.extend_table(lw.new_entry(dan_names, dan_vals), table)
		assert_equal('samosas', lw.lookup_in_table('appetizer', table) {})
		assert_equal('dal', lw.lookup_in_table('entree', table) {})
		assert_equal('galub', lw.lookup_in_table('dessert', table) {})
		
		mary_names = %w[appetizer entree]
		mary_vals = %w[papadum korma]
		table = lw.extend_table(lw.new_entry(mary_names, mary_vals), table)
		assert_equal('papadum', lw.lookup_in_table('appetizer', table) {})
		assert_equal('korma', lw.lookup_in_table('entree', table) {})
		assert_equal('galub', lw.lookup_in_table('dessert', table) {})
	end
	
	def list(*l)
		class << l
			include List
		end
	end
end
