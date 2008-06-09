require 'test/unit'
require 'eval_lisp'


class BasicLispTest < Test::Unit::TestCase
    def test_smoketest
        bl = BasicLisp.new
        assert_equal(5, bl.eval("(+ 3 2)"))
    end
end