#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

# n ビットの M系列の長さ
=begin
  2 : 4
  3 : 9
  4 : 18
  5 : 35
  6 : 68
  7 : 133
  8 : 262
  9 : 519
 10 : 1032
=end

def f( n )
	( ( 2 ** n ) - 1 ) + ( n-1 )
end

( 2 .. 10 ).each{|a|
	puts( %Q!#{"%3d"%a} : #{f(a)}! )
}







