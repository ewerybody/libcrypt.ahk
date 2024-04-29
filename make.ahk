if A_Args.Length
    Param :=  A_Args[1]
else
    Param := ""

if (Param = "")
{
	Out := 'LC_Version := "' FileOpen("VERSION", "r`r`n").Read() '"`n'
	Loop Files "src\*.ahk"
		Out .= "`n" FileOpen(A_LoopFileFullPath, "r`r`n").Read() "`n"
	DirCreate("build")
	FileOpen("build\libcrypt.ahk", "w`r`n").Write(Out)
}
else if (Param = "install")
	FileCopyCreateDir("build\libcrypt.ahk", A_MyDocuments "\AutoHotkey\Lib\libcrypt.ahk")
else if (Param = "uninstall")
	FileDelete(A_MyDocuments "\AutoHotkey\Lib\libcrypt.ahk")
else
	FileCopyCreateDir("build\libcrypt.ahk", Param)
ExitApp

FileCopyCreateDir(Source, Dest)
{
	SplitPath Dest,, &OutDir
	DirCreate(OutDir)
	FileCopy(Source, Dest)
	return A_LastError
}