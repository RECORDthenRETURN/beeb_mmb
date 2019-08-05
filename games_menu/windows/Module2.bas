Attribute VB_Name = "Module2"
Option Explicit

' CHARACTER TABLE

Public Const mintMaxChrs As Integer = 64

Public Type chr2_type

    Nibbles As Byte
    LastNibble As Byte
    
End Type

Public gChrs(32 To 127) As chr2_type

Public gbytChrTable_Size As Byte
Public gbytChrTable() As Byte

Private Type chr_type

    Char As Byte
    Count As Integer
    Nibbles As Byte
    LastNibble As Byte
    
End Type

Private mintChrCount(32 To 127) As Integer

Public Function DefChrs() As Boolean

    ' Build 'character table'
    
    Dim x As Integer
    Dim y As Integer
    Dim intCount As Integer
    Dim Chrs(1 To mintMaxChrs) As chr_type
    Dim t As chr_type
    Dim nx As Byte
    Dim ny As Byte
    Dim n As Byte
    
    ' 1) Count character usage in strings
    
    Erase mintChrCount
    
    For x = 1 To gintGameCount
    
        CountString gGames(x).Title
        CountString gGames(x).File
        
    Next
    
    For x = 1 To gintHouseCount
    
        CountString gHouses(x).Name
        
    Next
    
    For x = 1 To gintDiskCount
    
        CountString gDisks(x).Name
        
    Next
    
    ' 2) Copy count to Chrs array and sort
    
    For x = 32 To 127
    
        If mintChrCount(x) > 0 Then
        
            If intCount = mintMaxChrs Then
            
                Form1.Info "Character table full!"
                
                Exit For
                
            End If
        
            intCount = intCount + 1
            
            With Chrs(intCount)
            
                .Char = x
                .Count = mintChrCount(x)
                
            End With
            
        End If
        
    Next
    
    ' Sort
    
    For x = 1 To intCount
    
        For y = 1 To intCount - 1
        
            If Chrs(y + 1).Count > Chrs(y).Count Then
            
                t = Chrs(y)
                Chrs(y) = Chrs(y + 1)
                Chrs(y + 1) = t
                
            End If
            
        Next
        
    Next
    
    ' Calc. nibbles
    
    nx = 1
    ny = 2
    
    For x = 1 To intCount
    
        With Chrs(x)
        
            .Nibbles = nx
            .LastNibble = ny
        
            'Debug.Print x, .Char, Chr(.Char), .Count, .Nibbles, .LastNibble
            
            ny = ny + 1
            
            If ny = 16 Then ny = 1: nx = nx + 1
            
        End With
        
    Next
    
    ' 3) Populate gChrs & gbytChrTable arrays
    
    gbytChrTable_Size = (nx - 1) * 16 + ny
    
    ReDim gbytChrTable(1 To gbytChrTable_Size)
    
    Erase gChrs
    
    For x = 1 To intCount
    
        With Chrs(x)
        
            gChrs(.Char).Nibbles = .Nibbles
            gChrs(.Char).LastNibble = .LastNibble
            
            n = (.Nibbles - 1) * 16 + .LastNibble + 1
            
            gbytChrTable(n) = .Char
                
        End With
    
    Next

End Function

Private Sub CountString(s As String)

    Dim x As Integer
    Dim c As Byte

    s = Trim(UCase(s))
    
    For x = 1 To Len(s)
        
        c = Asc(Mid(s, x, 1))
        c = Mode7Chr(c)

        mintChrCount(c) = mintChrCount(c) + 1
        
    Next

End Sub

Public Function Mode7Chr(c As Byte) As Byte

    If c = 163 Then
    
        c = 35 ' £ - Mode 7
    
    ElseIf c = 35 Then
    
        c = 95 ' # - Mode 7
            
    ElseIf c = 95 Then
        
        c = 96 ' _ - Mode 7
        
    ElseIf c < 32 Or c >= 127 Then
    
        c = 32
        
    End If
        
    Mode7Chr = c

End Function
