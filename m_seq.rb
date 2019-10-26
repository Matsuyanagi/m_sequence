#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

# n ビットの M系列

def mseq( n )
	# 長さ
	# ( ( 2 ** n ) - 1 ) + ( n-1 )
	arr = Array.new( n, 0 )
	arr[ 0 ] = 1			# [ 1, 0, 0, 0, ...., 0 ]
	array_result = arr.clone
	
	((2**n)-1).times{
		# pp arr
		t = arr.shift
		t = ( arr.last ^ t )
		arr << t
		pp arr
		array_result << t
	}
	puts( array_result.map(&:to_s).join() )
end

def mseq2( n )
	# 長さ
	# ( ( 2 ** n ) - 1 ) + ( n-1 )
	arr = Array.new( n-1, 0 )
	arr.unshift( 1 )			# [ 1, 0, 0, 0, .... ]
	array_result = arr.clone
	
	((2**n)-1).times{
		# pp arr
		t = arr.shift
		last_bit = ( arr.last ^ t )
		arr << last_bit
		array_result << last_bit
	}
	puts( array_result.map(&:to_s).join() )
end

mseq( 5 )

