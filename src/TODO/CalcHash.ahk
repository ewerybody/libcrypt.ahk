﻿LC_CalcAddrHash(addr, length, algid, byref hash = 0, byref hashlength = 0) {
	static h := [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, "a", "b", "c", "d", "e", "f"]
	static b := h.minIndex()
	hProv := hHash := o := ""
	if (DllCall("advapi32\CryptAcquireContext", "Ptr*", hProv, "Ptr", 0, "Ptr", 0, "UInt", 24, "UInt", 0xf0000000))
	{
		if (DllCall("advapi32\CryptCreateHash", "Ptr", hProv, "UInt", algid, "UInt", 0, "UInt", 0, "Ptr*", hHash))
		{
			if (DllCall("advapi32\CryptHashData", "Ptr", hHash, "Ptr", addr, "UInt", length, "UInt", 0))
			{
				if (DllCall("advapi32\CryptGetHashParam", "Ptr", hHash, "UInt", 2, "Ptr", 0, "UInt*", hashlength, "UInt", 0))
				{
					VarSetCapacity(hash, hashlength, 0)
					if (DllCall("advapi32\CryptGetHashParam", "Ptr", hHash, "UInt", 2, "Ptr", &hash, "UInt*", hashlength, "UInt", 0))
					{
						loop % hashlength
						{
							v := NumGet(hash, A_Index - 1, "UChar")
							o .= h[(v >> 4) + b] h[(v & 0xf) + b]
						}
					}
				}
			}
			DllCall("advapi32\CryptDestroyHash", "Ptr", hHash)
		}
		DllCall("advapi32\CryptReleaseContext", "Ptr", hProv, "UInt", 0)
	}
	return o
}
LC_CalcStringHash(string, algid, encoding = "UTF-8", byref hash = 0, byref hashlength = 0) {
	chrlength := (encoding = "CP1200" || encoding = "UTF-16") ? 2 : 1
	length := (StrPut(string, encoding) - 1) * chrlength
	VarSetCapacity(data, length, 0)
	StrPut(string, &data, floor(length / chrlength), encoding)
	return LC_CalcAddrHash(&data, length, algid, hash, hashlength)
}
LC_CalcHexHash(hexstring, algid) {
	length := StrLen(hexstring) // 2
	VarSetCapacity(data, length, 0)
	loop % length
	{
		NumPut("0x" SubStr(hexstring, 2 * A_Index - 1, 2), data, A_Index - 1, "Char")
	}
	return LC_CalcAddrHash(&data, length, algid)
}
LC_CalcFileHash(filename, algid, continue = 0, byref hash = 0, byref hashlength = 0) {
	fpos := ""
	if (!(f := FileOpen(filename, "r")))
	{
		return
	}
	f.pos := 0
	if (!continue && f.length > 0x7fffffff)
	{
		return
	}
	if (!continue)
	{
		VarSetCapacity(data, f.length, 0)
		f.rawRead(&data, f.length)
		f.pos := oldpos
		return LC_CalcAddrHash(&data, f.length, algid, hash, hashlength)
	}
	hashlength := 0
	while (f.pos < f.length)
	{
		readlength := (f.length - fpos > continue) ? continue : f.length - f.pos
		VarSetCapacity(data, hashlength + readlength, 0)
		DllCall("RtlMoveMemory", "Ptr", &data, "Ptr", &hash, "Ptr", hashlength)
		f.rawRead(&data + hashlength, readlength)
		h := LC_CalcAddrHash(&data, hashlength + readlength, algid, hash, hashlength)
	}
	return h
}