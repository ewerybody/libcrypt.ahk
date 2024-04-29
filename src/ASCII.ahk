LC_ASCII2Bin(s,pretty:=0) {
	r:=""
	Loop l:=StrLen(s)
	{
		z:=Ord(SubStr(s,A_Index,1)),y:="",p:=1
		Loop 8
			b:=!!(z&p),y:=b y,p:=p<<1
		r.=y
		if (pretty && (A_Index<l))
			r.=" "
	}
	return r
}

LC_Ascii2Bin2(Ascii) {
	for each, Char in StrSplit(Ascii)
	Loop 8
		Out .= !!(Ord(Char) & 1 << 8-A_Index)
	return Out
}

LC_Bin2Ascii(Bin) {
	Bin := RegExReplace(Bin, "[^10]")
    Asc := ""
	Loop StrLen(Bin) / 8
	{
		for each, Bit in StrSplit(SubStr(Bin, A_Index*8-7, 8))
			Asc .= Bit
		Out .= Chr(Asc), Asc := 0
	}
	return Out
}

LC_BinStr_EncodeText(Text, Pretty:=False, Encoding:="UTF-8") {
	VarSetStrCapacity(&Bin, StrPut(Text, Encoding))
	LC_BinStr_Encode(&BinStr, &Bin, StrPut(Text, Bin, Encoding)-1, Pretty)
	return BinStr
}

LC_BinStr_DecodeText(Text, Encoding:="UTF-8") {
	Len := LC_BinStr_Decode(Bin, Text)
	return StrGet(&Bin, Len, Encoding)
}

LC_BinStr_Encode(&Out, &Inn, InLen, Pretty:=False) {
	Loop InLen
	{
		Byte := NumGet(Inn, A_Index-1, "UChar")
		Loop 8
			Out .= Byte>>(8-A_Index) & 1
		if Pretty ; Perhaps a regex at the end instead of a check in every loop would be better
			Out .= " "
	}
	; Out := RegExReplace(Out, "(\d{8})", "$1 ") ; For example, this
}

LC_BinStr_Decode(&Out, &Inn) {
	ByteCount := StrLen(Inn)/8
	VarSetStrCapacity(Out, ByteCount)
	BitIndex := 1
	Loop ByteCount
	{
		Byte := 0
		Loop 8
			Byte := Byte<<1 | SubStr(Inn, BitIndex++, 1)
		NumPut(Byte, Out, A_Index-1, "UChar")
	}
}
