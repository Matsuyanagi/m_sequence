#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
#-----------------------------------------------------------------------------
#	M系列、ビットずらしの数字を求める。探索済みの数値をビットバッファで記録して、力ずくで求める
#	
#	
#	2019-10-26
#		3: 101110010
#		4: 100111101100010100
#		5: 10001111101110011010110000101001000
#		6: 10000111111011110011101011100011011010011001011000001010100010010000
#		7: 1000001111111011111001111010111100011101101110100111001011100001101100110101011010001100100110001011000000101010010100001001000100000
#		8: 1000000111111110111111001111101011111000111101101111010011110010111100001110111011001110101011101000111001101110010011100010111000001101101011011000110101001101001011010000110011001010110010001100010011000010110000000101010100010100100101000001001000010001000000
#
#		3: 101110010
#			は上位から3bitずつ取ると、すべて違うパターンになる
#			101, 011, 111, 110, 100, 001, 010
#			パターン数は 2^3-1 = 7
#		同様に上記の
#		6: 10000111111011110011101011100011011010011001011000001010100010010000
#			は上位から 6bit ずつ取ると、すべて違うパターンになる。
#			パターン数は 2^6-1 = 63
#		8では、8bitずつでパターン数は 2^8-1 = 255。長さは 262bit。
##
#-----------------------------------------------------------------------------
require './using_number_recorder'

Encoding.default_external="utf-8"
#-----------------------------------------------------------------------------
#	
#-----------------------------------------------------------------------------
settings = {
	bit_size: 8,
}

#-----------------------------------------------------------------------------
#	
#-----------------------------------------------------------------------------
def mseq_ff( settings )
	bit_size = settings[ :bit_size ]
	using_number_recoder = UsingNumberRecorder.new( 2 ** bit_size )

	# 0 は使わないので潰して(使用済みとして)おく
	using_number_recoder.clear
	using_number_recoder.set( 0 )

	# 初期値は 10..1
	# now_value = 1 << ( bit_size - 1 )
	# now_value |= 1
	now_value = 0
	now_value |= 1

	mask_bit = ( 1 << bit_size ) -1

	result_array = []
	recursive_depth( result_array, bit_size, using_number_recoder, now_value, mask_bit )

	# pp result_array
	binary_str = result_array.map(&:to_s).join
	puts( binary_str )
	hex_str = binary_str.to_i(2).to_s( 16 )
	puts( "0x" + hex_str )
end

# 再帰で数値が重複しないかチェックしながらビット列を作っていく
# result_array, using_number_recoder を更新していく
def recursive_depth( result_array, bit_size, using_number_recoder, now_value, mask_bit )

	# 最上位ビットを一旦 result_array に入れる
	result_array << ( now_value & ( 1 << ( bit_size-1 ) ) == 0 ? 0 : 1 )
	# now_value は使用済みだと一旦記録する(未使用であることは この関数呼び出し前にチェックしている)
	using_number_recoder.set( now_value )

	if using_number_recoder.fill_all?
		# この数字ですべてのパターンを網羅できた。

		# 残りの now_value の最上位ビット以外のビットを result_array に入れる
		b = 1 << ( bit_size-1-1 )
		while( b > 0 ) do
			result_array << ( ( ( now_value & b ) == 0 ) ? 0 : 1 )
			b >>= 1
		end
		return true
	end
	
	flag_completed = false
	nvalue = now_value << 1
	nvalue &= mask_bit
	# now_value を右シフトしたもの( nvalue )の最下位ビットに 1, 0 を入れて次の数値を試していく
	# ここを [ 1, 0 ], [ 0, 1 ] と代えることで別のビット列ができる。[0,1].shuffle しても違うパターンができるかも
	[ 1, 0 ].each do |last_bit|
		n = nvalue | last_bit
		if ! using_number_recoder.test( n )
			# ここまでにまだ n は出現していない
			flag_completed = recursive_depth( result_array, bit_size, using_number_recoder, n, mask_bit )
			break if flag_completed
		end
	end
	return true if flag_completed
	
	# 状態を戻す
	result_array.pop
	using_number_recoder.reset( now_value )

	return false
end



mseq_ff( settings )