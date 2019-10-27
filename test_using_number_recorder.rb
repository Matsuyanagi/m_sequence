require 'test/unit'
require './using_number_recorder.rb'



class TestUsingNumberRecorder < Test::Unit::TestCase
	def setup
		@recorder = UsingNumberRecorder.new( 31 )
	end

	def test_size
		assert_equal( 31, @recorder.bit_count() )
	end
	def test_set_test
		@recorder.set( 20 )
		assert_equal( true, @recorder.test(20) )
	end
	def test_set_test_02
		@recorder.set( 0 )
		assert_equal( true, @recorder.test(0) )
	end
	def test_set_test_03
		@recorder.set( 1 )
		assert_equal( false, @recorder.test(0) )
	end
	def test_set_test_04
		@recorder.set( 0 )
		assert_equal( false, @recorder.test(1) )
	end
	def test_set_test_05
		assert_equal( false, @recorder.test(0) )
	end
	def test_set_reset
		@recorder.set( 20 )
		@recorder.reset( 20 )
		assert_equal( false, @recorder.test(20) )
	end
	def test_fill_all_success
		@recorder.bit_count.times{|n|
			@recorder.set( n )
		}
		assert_equal( true, @recorder.fill_all? )
	end
	def test_fill_all_fail
		(@recorder.bit_count-1).times{|n|
			@recorder.set( n )
		}
		assert_equal( false, @recorder.fill_all? )
	end
	
	def test_bit_count_01
		@recorder.set( 1 )
		assert_equal( 1, @recorder.using_bit_count )
	end
	
	def test_bit_count_02
		@recorder.set( 2 )
		@recorder.set( 3 )
		assert_equal( 2, @recorder.using_bit_count )
	end
	def test_bit_count_03
		@recorder.set( @recorder.bit_count-1 )
		assert_equal( 1, @recorder.using_bit_count )
	end
	def test_bit_count_04
		@recorder.set( 1 )
		@recorder.clear
		assert_equal( 0, @recorder.using_bit_count )
	end
	
	
end