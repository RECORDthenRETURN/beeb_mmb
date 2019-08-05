Attribute VB_Name = "Module4"
Option Explicit

#Const DEBUG_ = False

Public gboolLog As Boolean

Private Type page_type

    House As Long
    Disk As Long
    RunOpt As Byte
    Title As String
    Filename As String

End Type

Private Const mintMaxLines As Integer = 25 - 2
Private Const mintMaxPages As Integer = 200

Private mintLineNo As Integer

Public gintPageNo As Integer
Public glngPages(1 To mintMaxPages) As Long

Private mbytItemCount As Byte
Private mPage(1 To mintMaxLines) As page_type

Public gbytTabData(0 To 255, 0 To 1) As Byte

Private Const mintMaxPgs = &H1F
Public gbytPgs(1 To mintMaxPgs) As Byte
Public gbytPgs_Count As Byte

Private mlngLog As Long

Public Function Make() As Boolean

On Error GoTo err_

    Dim g As game_type
    Dim b As Byte
    Dim p As String
    Dim x As Integer
    Dim y As Integer
    Dim z As Integer
    Dim c1 As String
    Dim c2 As String
    Dim i As Integer
    Dim bytTab As Byte

    Make = True
    
    If gboolLog Then
    
        mlngLog = FreeFile
    
        p = App.Path & "\log.txt"
    
        If Dir(p, vbNormal) <> "" Then
    
            Kill p
        
        End If
    
        Open p For Output As mlngLog
        
    End If
    
    glngDataPtr = 1
    glngDataSize = 1024
    glngDataSize = glngDataSize * 32
    
    ReDim gbytData(0 To glngDataSize - 1)
    
    ' Character table

    For x = 2 To gbytChrTable_Size
    
        #If DEBUG_ Then
        
            Debug.Print ">> "; gbytChrTable(x), _
                Chr(gbytChrTable(x)); " "; Hex$(x - 1)
                
        #End If
            
        AddByte gbytChrTable(x)
            
    Next
    
    ' Disks

    For x = 1 To gintDiskCount
    
        With gDisks(x)
        
            .Location = glngDataPtr
            
            If gboolLog Then
            
                Print #mlngLog, , LogAddr; " Disk "; .Name
                
            End If
            
            AddString .Name
            
        End With
        
    Next

    ' Houses

    For x = 1 To gintHouseCount
    
        With gHouses(x)
        
            .Location = glngDataPtr
            
            If gboolLog Then
            
                Print #mlngLog, , LogAddr; " House "; .Name
                
            End If
            
            AddString .Name
            
        End With
        
    Next

    ' Games
    
    mintLineNo = 1
    gintPageNo = 1
    
    mbytItemCount = 0
    bytTab = 0
    
    For x = 0 To 255
    
        gbytTabData(x, 1) = 255
        
    Next
    
    gbytTabData(32, 0) = 1
    gbytTabData(32, 1) = 0

    glngPages(gintPageNo) = glngDataPtr
    
    For x = 1 To gintGameCount
        
        g = gGames(x)
        g.Title = Left(g.Title, 60 - 8)
        
        z = Len(g.Title) + 5  ' Size incl 4 extra chrs
        z = IIf(z > 20, 2, 1) ' No of lines (max 2)
        
        If z = 2 Then
        
            ' Justify
            
            If Len(g.Title) + 5 > 40 Then
            
                c1 = Mid(g.Title, 40 - 5)
                c2 = Mid(g.Title, 41 - 5)
                
                If c1 <> " " Then
                
                    If c2 = " " Then
                    
                        ' remove space
                        
                        g.Title = Left(g.Title, 40 - 5) & _
                                    Mid(g.Title, 42 - 5)
                        
                    Else
                    
                        ' find last space
                        
                        i = 0
                        
                        For y = 40 - 5 To 1 Step -1
                        
                            If Mid$(g.Title, y, 1) = " " Then
                            
                                i = y
                                Exit For
                                
                            End If
                            
                        Next
                            
                        If i > 0 Then
                        
                             ' insert spaces
                             
                            g.Title = Left(g.Title, i) & _
                                        String(40 - 5 - i, " ") & _
                                        Mid(g.Title, i + 1)
                            
                        End If
                        
                    End If
                
                End If
            
            End If
        
        End If
        
        If (mintLineNo + z - 1) > mintMaxLines Then
                        
            AddPage
           
            gintPageNo = gintPageNo + 1
            mintLineNo = 1
            glngPages(gintPageNo) = glngDataPtr
            mbytItemCount = 0
            
        End If
        
        If Asc(g.Title) > bytTab Then ' New "TAB" character?
        
            bytTab = Asc(g.Title)
            
            If gboolLog Then

                Print #mlngLog, "TAB "; Chr(bytTab); _
                            " AT "; gintPageNo; " "; _
                            Chr$(mbytItemCount + 65)
            
            End If
            
            gbytTabData(bytTab, 0) = CByte(gintPageNo)
            gbytTabData(bytTab, 1) = mbytItemCount
            
        End If
        
        If gboolLog Then
        
            Print #mlngLog, , LogAddr; "   "; _
                        Format(x, "000"); " "; _
                        Chr$(mbytItemCount + 65); " "; _
                        Format(mintLineNo, "00"); " "; z; " "; _
                        Right("0000" & Hex$(gHouses(g.House).Location), 4); _
                        " "; g.Title
                        
        End If
        
        ' Add item to page
        
        mbytItemCount = mbytItemCount + 1
        
        With mPage(mbytItemCount)
        
            .House = gHouses(g.House).Location
            .Title = g.Title
        
            If g.File = Left(g.Title, 7) Then
            
                .Filename = ""
                
            Else
            
                .Filename = g.File
                
            End If
            
            .Disk = gDisks(g.Disk).Location
            
            b = 0
            
            If gDisks(g.Disk).Sides = 2 Then
            
                If g.Side = 1 Then b = &H40
                
            Else
            
                b = &H80
                
            End If
            
            If g.Exec = Exec Then
            
                b = b Or &H20
                
            End If
            
            If g.Exec <> Run Then
            
                b = b Or (GetPg(g.Page) And &H1F)
                
            End If
            
            .RunOpt = b
            
        End With
        
        mintLineNo = mintLineNo + z
        
    Next
                
    gbytTabData(255, 0) = CByte(gintPageNo)
    gbytTabData(255, 1) = mbytItemCount

    AddPage

    glngDataSize = glngDataPtr
    
    ReDim Preserve gbytData(0 To glngDataSize - 1)

exit_:

On Error Resume Next

    Close mlngLog
    
    Exit Function
    
err_:

    Form1.Info "ERROR : " & Err.Description
    Err.Clear
    
    Make = False
    
    Err.Clear
    Resume exit_

End Function

Private Function LogAddr()

    LogAddr = Right("0000" & Hex$(glngDataPtr), 4)
    
End Function

Private Sub AddPage()

    Dim i As Byte
    Dim b As Byte
    Dim t As String
    Dim l As Long
    
    #If DEBUG_ Then
        
        Debug.Print "Page # "; gintPageNo, Hex$(glngPages(gintPageNo)), _
                mbytItemCount
                
    #End If
    
    If gboolLog Then
            
        Print #mlngLog, ""
        Print #mlngLog, "Page # "; gintPageNo, _
                    Hex$(glngPages(gintPageNo)), _
                    mbytItemCount
        Print #mlngLog, ""
        
    End If
    
    ' Add house 'pointers'
    
    For i = 1 To mbytItemCount
    
        l = mPage(i).House
        
        AddByte l Mod 256
        AddByte l \ 256 + IIf(i = mbytItemCount, &H80, 0)
        
    Next
    
    ' Add game titles
    
    For i = 1 To mbytItemCount
    
        AddString mPage(i).Title
        
    Next
    
    ' Add page no. in BCD
    
    AddByte BCD(gintPageNo \ 100)
    AddByte BCD(gintPageNo Mod 100)
    
    ' Add disk 'pointers' & run option
    
    For i = 1 To mbytItemCount
    
        t = mPage(i).Filename
        
        l = mPage(i).Disk
        
        AddByte l \ 256 + IIf(t = "", &H80, 0)
        AddByte l Mod 256
        
        AddByte mPage(i).RunOpt
    
    Next
    
    ' Add filenames
    
    For i = 1 To mbytItemCount
    
        t = mPage(i).Filename
        
        If t <> "" Then
            
            AddString t
            
        End If
        
    Next

End Sub

Private Function GetPg(pg As Byte) As Byte

    ' Get index of / Add BASIC PAGE

    Dim x As Byte
    Dim i As Byte
    
    For i = 1 To gbytPgs_Count
    
        If gbytPgs(i) = pg Then
        
            x = i
            Exit For
            
        End If
        
    Next
    
    If x = 0 Then
    
        If gbytPgs_Count < mintMaxPgs Then
    
            x = gbytPgs_Count + 1
            gbytPgs_Count = x
            gbytPgs(x) = pg
        
        Else
        
            #If DEBUG_ Then

                Debug.Print "Too many page indexes"
                
            #End If
            
            Form1.Info "Too many different BASIC PAGES!"
            Form1.Info "(Maximum is " & mintMaxPgs - 1 & ")"
            
            If gboolLog Then
            
                Print #mlngLog, ""
                Print #mlngLog, "ERROR : Too many BASIC PAGES!"
                Print #mlngLog, ""
                
            End If
        
        End If
        
    End If
    
    GetPg = x
        
End Function
