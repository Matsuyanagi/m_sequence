#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
#-----------------------------------------------------------------------------
#	M系列、ビットずらしの数字を求める。ビットバッファ用意して、力ずくで求める
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
#		これなら AVX2 の 256bit のパターン検索に使える。
#			任意のビットを抜き出すような引数として
#			0b00000011111111000000 を引数と渡したときに "10011001" が得られたとすると、どこのビット位置から抜き出されたものかわかる。
##
#-----------------------------------------------------------------------------

Encoding.default_external="utf-8"
#-----------------------------------------------------------------------------
#	
#-----------------------------------------------------------------------------
settings = {
	bit_size: 8,
}

# 値のチェック状態を記録しておく
# ビットフィールドでチェック済みかを保持する
class ResultRecoder
	# 3 なら 8bit
	# 4 なら 16bit の配列を確保する
	BUFFER_WORD_BIT_SHIFT_SIZE = 3

	def initialize( bit_count )
		@bit_count = bit_count
		self.clear
	end

	def clear
		# 必要ビット長を1要素のビット数で割ったのが要素数。半端分があればそれように+1加算する。
		# 100bit 必要で、1要素 8bit ごとに区切るなら 100/8 で12要素、4bit あまるので、+1して 13要素。
		element_num = ( @bit_count >> BUFFER_WORD_BIT_SHIFT_SIZE ) + ( @bit_count & ( 1 << BUFFER_WORD_BIT_SHIFT_SIZE - 1 ) == 0 ? 0 : 1 )
		@bitbuffer = Array.new( element_num , 0 )
		nil
	end
	
	def test( n )
		raise RangeError if n >= @bit_count || n < 0
		a, s = address_and_shift( n )
		return ( @bitbuffer[ a ] & ( 1 << s ) ) != 0
	end
	def set( n )
		raise RangeError if n >= @bit_count || n < 0
		a, s = address_and_shift( n )
		@bitbuffer[ a ] |= ( 1 << s )
	end
	def reset( n )
		raise RangeError if n >= @bit_count || n < 0
		a, s = address_and_shift( n )
		@bitbuffer[ a ] &= ~( 1 << s )
	end

	# 配列の何番目かと、何ビット目かを返す
	def address_and_shift( n )
		return n >> BUFFER_WORD_BIT_SHIFT_SIZE, n & ( ( 1 << BUFFER_WORD_BIT_SHIFT_SIZE )-1 )
	end

	# 全部埋まったか
	# ビット数を数えるか、すべての配列を AND してビットが埋まっているか
	# 20bit とか半端な状態が面倒
	def fill_all?
		# 半端ビットの処理が面倒なのでビット数を数えて、初期ビット数と同じなら全部埋まった
		bc = @bitbuffer.inject( 0 ){ |count,b|
			c = 0
			while( b > 0 ) do
				c += 1 if b & 1 != 0
				b >>= 1
			end
			count += c
		}
		return bc == @bit_count
	end

	# 全ビット数
	def bit_count
		@bit_count
	end

	def inspect
		@bitbuffer.inspect
	end

end

#-----------------------------------------------------------------------------
#	
#-----------------------------------------------------------------------------
def mseq_ff( settings )
	bit_size = settings[ :bit_size ]
	result_recoder = ResultRecoder.new( 2 ** bit_size )

=begin	
	pp result_recoder
	result_recoder.set( 20 )
	pp result_recoder
	pp result_recoder.test( 20 )
	result_recoder.reset( 20 )
	pp result_recoder
	pp result_recoder.test( 20 )
	# pp bitbuffer
	
	
	result_recoder.bit_count.times{|n|
		result_recoder.set( n )
	}
	pp result_recoder
	pp result_recoder.fill_all?

	result_recoder.clear
	(result_recoder.bit_count-1).times{|n|
		result_recoder.set( n )
	}
	pp result_recoder
	pp result_recoder.fill_all?
=end

	# 0 は使わないので潰して(使用済みとして)おく
	result_recoder.clear
	result_recoder.set( 0 )

	# 初期値は 10..1
	now_value = 1 << ( bit_size - 1 )
	now_value |= 1

	mask_bit = ( 1 << bit_size ) -1

	result_array = []
	recursive_depth( result_array, bit_size, result_recoder, now_value, mask_bit )

	# pp result_array
	puts( result_array.map(&:to_s).join )
end

# 再帰部分
# result_array, result_recoder を更新していく
def recursive_depth( result_array, bit_size, result_recoder, now_value, mask_bit )

	# 最上位ビットを一旦 result_array に入れる
	result_array << ( now_value & ( 1 << ( bit_size-1 ) ) == 0 ? 0 : 1 )
	# now_value は使用済みだと一旦記録する
	result_recoder.set( now_value )

	if result_recoder.fill_all?
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
	[ 1, 0 ].each do |last_bit|
		n = nvalue | last_bit
		if ! result_recoder.test( n )
			# ここまでにまだ n は出現していない
			flag_completed = recursive_depth( result_array, bit_size, result_recoder, n, mask_bit )
			break if flag_completed
		end
	end
	return true if flag_completed
	
	# 状態を戻す
	result_array.pop
	result_recoder.reset( now_value )

	return false
end



mseq_ff( settings )