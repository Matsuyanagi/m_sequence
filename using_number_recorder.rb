#!/usr/bin/env ruby
# -*- coding: utf-8 -*-


# 指定の数値が使われていることを記録しておく。
# 内部的にはビットフィールドで使用済みかを保持する。
class UsingNumberRecorder
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
		return self.using_bit_count == @bit_count
	end

	# 全ビット数
	def bit_count
		@bit_count
	end

	# 立っているビット数
	# 半端ビットの処理が面倒なのでビット数を数えて、初期ビット数と同じなら全部埋まった
	def using_bit_count
		@bitbuffer.inject( 0 ){ |count,b|
			c = 0
			while( b > 0 ) do
				c += 1 if b & 1 != 0
				b >>= 1
			end
			count += c
		}
	end

	def inspect
		@bitbuffer.inspect
	end

end

