local _path = ({...})[1]:gsub("%.init", "")

require( _path .. '.middleclass' )
