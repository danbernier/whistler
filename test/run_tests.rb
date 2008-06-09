puts Dir.pwd
Dir.chdir '..' if Dir.pwd =~ /test$/
Dir.glob('test/test_*.rb') { |t| puts `ruby #{t}` }
puts Dir.pwd