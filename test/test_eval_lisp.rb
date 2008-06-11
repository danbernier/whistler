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
		entry = lw.new_entry([:uno, :dos, :tres], %w[one two three])
		
		assert_equal([:uno, :dos, :tres], entry[0])
		assert_equal(%w[one two three], entry[1])
		
		val = lw.lookup_in_entry(:uno, entry) { |name| }
		assert_equal('one', val)
		val = lw.lookup_in_entry(:dos, entry) { |name| }
		assert_equal('two', val)
		val = lw.lookup_in_entry(:tres, entry) { |name| }
		assert_equal('three', val)
	end
	
	def test_tables
		lw = LittleWhistler.new
		dan_names = [:appetizer, :entree, :dessert]
		dan_vals = %w[samosas dal galub]
		
		table = []
		table = lw.extend_table(lw.new_entry(dan_names, dan_vals), table)
		assert_equal('samosas', lw.lookup_in_table(:appetizer, table) {})
		assert_equal('dal', lw.lookup_in_table(:entree, table) {})
		assert_equal('galub', lw.lookup_in_table(:dessert, table) {})
		
		mary_names = [:appetizer, :entree]
		mary_vals = %w[papadum korma]
		table = lw.extend_table(lw.new_entry(mary_names, mary_vals), table)
		assert_equal('papadum', lw.lookup_in_table(:appetizer, table) {})
		assert_equal('korma', lw.lookup_in_table(:entree, table) {})
		assert_equal('galub', lw.lookup_in_table(:dessert, table) {})
        
        %{
        x->1, y->2
        z->3, x->4
        g->5, f->9, z->7
        
        x=4, y=2, z=7, g=5, f=9
        }
        table = []
        table = lw.extend_table(lw.new_entry([:x, :y], [1, 2]), table)
        table = lw.extend_table(lw.new_entry([:z, :x], [3, 4]), table)
        table = lw.extend_table(lw.new_entry([:g, :f, :z], [5, 9, 7]), table)
		assert_equal(4, lw.lookup_in_table(:x, table) {})
		assert_equal(2, lw.lookup_in_table(:y, table) {})
		assert_equal(7, lw.lookup_in_table(:z, table) {})
		assert_equal(5, lw.lookup_in_table(:g, table) {})
		assert_equal(9, lw.lookup_in_table(:f, table) {})
		assert_equal(nil, lw.lookup_in_table(:bogus, table) {})
        
		assert_equal('fake', lw.lookup_in_table(:bogus, table) {'fake'})  # I don't believe we'll use it quite like this, but...
	end
end
