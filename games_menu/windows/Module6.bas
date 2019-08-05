Attribute VB_Name = "Module6"
Option Explicit

Public gstrDir As String
Public Const gstrDataName As String = ".GAMES"

Private Const mintHdrSize As Integer = 16
Private Const mstrInf As String = ".GAMES        0000   0000"

Public Function WriteFile()

On Error GoTo err_

    Dim p As String
    Dim x As Integer
    Dim y As Integer
    Dim o As Long
    Dim l As Long
    Dim b As Byte
    Dim bytTABSize As Byte

    p = App.Path & "\" & gstrDir & gstrDataName
    
    If Dir(p, vbNormal) <> "" Then
    
        Kill p
        
    End If
    
    o = FreeFile
    
    Open p For Binary Access Write As o
    
    l = gintPageNo
    b = l Mod 256
    
   ' Debug.Print "PG "; Hex$(b)
    
    ' No of pages
    
    Put o, , b
    
    ' No of pages in BCD
    
    Put o, , BCD(b \ 100)
    Put o, , BCD(b Mod 100)
    
    ' TAB KEY table size (1 byte)
    
    bytTABSize = 0
    
    For x = 0 To 255
    
        If gbytTabData(x, 1) <> 255 Then bytTABSize = bytTABSize + 1
        
    Next
    
    Put o, , bytTABSize
    
    ' Table offsets
    
    ' Note: Page Table Low byte always at mintHdrSize
    
    l = mintHdrSize
    
    PutW o, l + gintPageNo ' Page Table High byte
    PutW o, l + gintPageNo * 2 ' TAB table 1
    PutW o, l + gintPageNo * 2 + bytTABSize ' TAB table 2
    PutW o, l + gintPageNo * 2 + bytTABSize * 2 ' TAB table 3
    PutW o, l + gintPageNo * 2 + bytTABSize * 3 ' BASIC PAGE table
    PutW o, l + gintPageNo * 2 + bytTABSize * 3 + gbytPgs_Count * 2 ' DATA
    
    ' Page address table,
    ' Pass 1 = low byte , 2 = high byte
    
    For y = 1 To 2
    
        For x = 1 To gintPageNo
    
            l = glngPages(x)
            
            If y = 1 Then b = l Mod 256 Else b = l \ 256
            
            Put o, , b
            
        Next
        
    Next
    
    ' "TAB key" data
    
    ' Pass -1 = KEY , 0 = page , 1 = line
    
    For y = -1 To 1
    
        For x = 0 To 255
    
            If gbytTabData(x, 1) <> 255 Then
            
                If y = -1 Then
                
                    b = CByte(x)
                    
                Else
                
                    b = gbytTabData(x, y)
                    
                End If
                
                Put o, , b
            
            End If
            
        Next
        
    Next
    
    ' BASIC PAGE data (PAGE=&19 ETC) as text
    
    For x = 1 To gbytPgs_Count
    
        b = (gbytPgs(x) \ 16) And 15
        
        If b >= 10 Then b = b + Asc("A") - 10 Else b = b + Asc("0")
        
        Put o, , b
        
        b = gbytPgs(x) And 15
        
        If b >= 10 Then b = b + Asc("A") - 10 Else b = b + Asc("0")
        
        Put o, , b
        
        'Debug.Print "Pg "; Hex$(x); " "; Hex$(gbytPgs(x))
        
    Next
    
   ' Debug.Print " data ptr?="; Hex$(Seek(o) - 1)
    
    Put o, , gbytData ' Main data block
    
    Close o
    
    Form1.Info "File Created!"
    Form1.Info "Size = " & FileLen(p) & " bytes (" _
                & Format(FileLen(p) / 1024, "0.00") & " kb)"
    
    ' Create .inf file
    
    p = p & ".inf"
    
    If Dir(p, vbNormal) <> "" Then
    
        Kill p
        
    End If
    
    Open p For Output As o
    
    Print #o, gstrDir & mstrInf
    
exit_:

On Error Resume Next
    
    Close o
    
    Exit Function
    
err_:

    Form1.Info "ERROR : " & Err.Description
    Err.Clear
    
    Resume exit_

End Function

Private Sub PutW(f As Long, w As Variant)

    ' Write word

    Dim b As Byte
    
    b = w Mod 256
    Put f, , b
    b = w \ 256
    Put f, , b
    
End Sub

