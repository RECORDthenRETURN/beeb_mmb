Attribute VB_Name = "Module1"
Option Explicit

#Const DEBUG_ = False

' Populate arrays with data from text file

Public Const gintMaxGames As Integer = 25 * 256

Public Type house_type

    Name As String
    
    Location As Long
    
End Type

Public gintHouseCount As Integer
Public gHouses(1 To gintMaxGames) As house_type

Public Type disk_type

    Name As String
    Sides As Byte
    
    Location As Long
    
End Type

Public gintDiskCount As Integer
Public gDisks(1 To gintMaxGames) As disk_type

Public Enum exec_types

    Chain = 1
    Run = 2
    Exec = 3
    
End Enum

Public Type game_type

    Title As String
    House As Integer
    File As String
    Disk As Integer
    Side As Byte
    Exec As exec_types
    Page As Byte
    
End Type

Public gintGameCount As Integer
Public gGames(1 To gintMaxGames) As game_type

Private Const mintFieldCount As Integer = 8
Private mstrFields(1 To mintFieldCount) As String

Private Enum flds

    HouseName = 1
    GameTitle = 2
    Filename = 3
    Execution = 4 ' (R=*RUN, E=*EXEC else CHAIN)
    BASICPage = 5 ' (if blank, then &19)
    DiskName = 6
    DiskSide = 7 ' (1 else 0)
    DiskSides = 8 ' (S=Single Sided, else Double Sided)
    
End Enum

Public Function ImportData(strPath As String) As Boolean

    ' Import/Parse text file
    ' Returns true if no errors!

On Error GoTo err_

    Dim f As Long
    Dim s As String
    Dim x As Integer
    Dim y As Integer
    Dim p As Byte
    Dim ht As house_type
    Dim dt As disk_type
    Dim gt As game_type
    Dim c As Integer
    
    ImportData = True
    
    gintHouseCount = 0
    gintDiskCount = 0
    gintGameCount = 0
    
    Erase gHouses
    Erase gDisks
    Erase gGames
    
    f = FreeFile
    
    For p = 1 To 2
        
        c = 0
        
        Open strPath For Input As f
        
        Do While Not EOF(f)
        
            Input #f, s
            
            c = c + 1
            
            If s <> "" Then
            
                ParseData s, p
                
            End If
            
        Loop
        
        Close f
        
        #If DEBUG_ Then
        
            Debug.Print "Pass "; p, " Count="; c
            
        #End If
        
        If p = 1 Then
        
            ' Sort Houses
            
            For x = 1 To gintHouseCount
                
                For y = 1 To gintHouseCount - 1
                
                    If gHouses(y).Name > gHouses(y + 1).Name Then
                
                        ht = gHouses(y)
                        gHouses(y) = gHouses(y + 1)
                        gHouses(y + 1) = ht
                    
                    End If
                    
                Next
            
            Next
            
            ' Sort Disks
            
            For x = 1 To gintDiskCount
                
                For y = 1 To gintDiskCount - 1
                
                    If gDisks(y).Name > gDisks(y + 1).Name Then
                
                        dt = gDisks(y)
                        gDisks(y) = gDisks(y + 1)
                        gDisks(y + 1) = dt
                        
                    End If
                    
                Next
            
            Next
        
        End If
        
    Next
    
    ' Sort games
    
    For x = 1 To gintGameCount
        
        For y = 1 To gintGameCount - 1
        
            If gGames(y).Title > gGames(y + 1).Title Or _
                    (gGames(y).Title = gGames(y + 1).Title And _
                    gGames(y).House > gGames(y + 1).House) Then
                    
                gt = gGames(y)
                gGames(y) = gGames(y + 1)
                gGames(y + 1) = gt
            
            End If
            
        Next
    
    Next
    
    Form1.Info "Houses: " & gintHouseCount
    Form1.Info "Disks : " & gintDiskCount
    Form1.Info "Games : " & gintGameCount
    Form1.Info ""
    
    #If DEBUG_ Then
        
        Close f
    
        Debug.Print "Houses: "; gintHouseCount
        Debug.Print "Disks: "; gintDiskCount
        Debug.Print "Games: "; gintGameCount
        
        s = strPath & ".log"
        
        If Dir(s, vbNormal) <> "" Then
        
            Kill s
            
        End If
        
        Open s For Output As f
        
        Print #f, "HOUSES "; gintHouseCount
        
        For x = 1 To gintHouseCount
            
            Print #f, , x, gHouses(x).Name
            
        Next
        
        Print #f, "DISKS "; gintDiskCount
        
        For x = 1 To gintDiskCount
            
            Print #f, , x, gDisks(x).Name, " ("; gDisks(x).Sides; ")"
            
        Next
        
        Print #f, "GAMES "; gintGameCount
        
        For x = 1 To gintGameCount
            
            With gGames(x)
            
                Print #f, , x, .File, .House, .Disk, .Side, .Exec, .Page, .Title
                
            End With
            
        Next
        
    #End If
    
exit_:

On Error Resume Next

    Close f
    
    If gintGameCount = 0 Or gintDiskCount = 0 Or gintHouseCount = 0 Then
    
        Form1.Info "No Data!"
        
        ImportData = False
    
    End If
    
    Exit Function
    
err_:

    Form1.Info "ERROR : " & Err.Description
    Err.Clear
    
    ImportData = False
    
    Err.Clear
    Resume exit_

End Function

Private Sub ParseData(s As String, p As Byte)

    ' Parse line (record)

    Dim x As Integer
    Dim n As String
    Dim i As Integer
    
    Dim h As Integer
    Dim d As Integer
    
    Erase mstrFields
    
    Do While s <> "" And i < mintFieldCount
    
        x = InStr(s, vbTab)
        
        If x = 0 Then
        
            n = s
            s = ""
            
        Else
        
            n = Left(s, x - 1)
            s = Mid(s, x + 1)
            
        End If
        
        i = i + 1
        
        mstrFields(i) = Trim(UCase(n))
        
    Loop
    
    If mstrFields(flds.GameTitle) <> "" _
        And mstrFields(flds.HouseName) <> "" _
        And mstrFields(flds.Filename) <> "" _
        And mstrFields(flds.DiskName) <> "" Then
        
        h = House(mstrFields(flds.HouseName))
        d = Disk(mstrFields(flds.DiskName), mstrFields(flds.DiskSides))
        
        If p = 2 Then
        
            AddGames h, d
            
        End If
        
    Else
    
        #If DEBUG_ Then
    
            Debug.Print "Not Included : "; mstrFields(flds.GameTitle)
            
        #End If
        
    End If

End Sub

Private Sub AddGames(h As Integer, d As Integer)

    ' Add game

    gintGameCount = gintGameCount + 1
    
    With gGames(gintGameCount)
    
        .House = h
        .Disk = d
        
        .Title = mstrFields(flds.GameTitle)
        .File = mstrFields(flds.Filename)
        
        .Side = IIf(mstrFields(flds.DiskSide) = "1", 1, 0)
        
        Select Case Left(mstrFields(flds.Execution), 1)
        
            Case "R"
            
                .Exec = Run
                
            Case "E"
            
                .Exec = Exec
            
            Case Else
            
                .Exec = Chain
                
        End Select
        
        If .Exec = Chain Or .Exec = Exec Then
        
            .Page = HexOK(mstrFields(flds.BASICPage))
            
            If .Page = 0 Then .Page = 25 ' &19
            
        End If
        
    End With

End Sub

Private Function HexOK(h As String) As Byte

    ' Get hex, ignore errors

On Error Resume Next

    HexOK = Val("&H" & h)
    
End Function

Private Function House(n As String) As Integer

    ' Get/Add House

    Dim x As Integer

    For x = 1 To gintHouseCount
    
        If gHouses(x).Name = n Then
        
            House = x
            Exit Function
            
        End If
    
    Next
    
    gintHouseCount = gintHouseCount + 1
    gHouses(gintHouseCount).Name = n

End Function

Private Function Disk(n As String, s As String) As Integer

    ' Get/Add Disk

    Dim x As Integer

    For x = 1 To gintDiskCount
    
        If gDisks(x).Name = n Then
        
            Disk = x
            Exit Function
            
        End If
    
    Next
    
    gintDiskCount = gintDiskCount + 1
    
    With gDisks(gintDiskCount)
    
        .Name = n
        .Sides = 2
    
        If Left(s, 1) = "S" Then .Sides = 1
        
    End With

End Function

