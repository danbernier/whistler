$LOAD_PATH.unshift './lib'
Dir.glob('test/test_*.rb') do |t|
	puts t
	load t
end