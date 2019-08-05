Attribute VB_Name = "Module3"
Option Explicit

#Const DEBUG_ = False

Public gbytData() As Byte
Public glngDataPtr As Long
Public glngDataSize As Long

Public Function AddString(s As String) As Integer

    ' Add string to gbytData

    Dim x As Integer
    Dim l As Integer
    Dim n As Byte
    Dim ln As Byte
    Dim c As Byte
    Dim nl As Integer
    Dim nd(0 To 200) As Byte
    Dim b As Byte
    
    l = Len(s)
    
    #If DEBUG_ Then
    
        Debug.Print "L: "; Hex$(l); " @ "; Hex$(glngDataPtr); " > ";
        
    #End If
    
    nl = 0
    
    For x = 1 To l + 1
    
        If x > l Then
        
            n = 0
            ln = 1
            
        Else
        
            c = Asc(Mid(s, x, 1))
            c = Mode7Chr(c)
            
            n = gChrs(c).Nibbles
            ln = gChrs(c).LastNibble
            
        End If
        
        Do While n > 1
        
            nd(nl) = 0
            n = n - 1
            nl = nl + 1
            
        Loop
        
        nd(nl) = ln
        nl = nl + 1
        
    Next
    
    If (nl And 1) > 0 Then
    
        nd(nl) = 0
        nl = nl + 1
        
    End If
    
    For x = 0 To nl - 1 Step 2
    
        b = nd(x) + nd(x + 1) * 16
        
        #If DEBUG_ Then
        
            Debug.Print ; " "; Hex$(b);
            
        #End If
        
        AddByte b
        
    Next
    
    #If DEBUG_ Then
    
        Debug.Print ; "  '"; s; "'"
    
    #End If
    
    AddString = l

End Function

Public Sub AddByte(b As Byte)

    ' Add byte

    gbytData(glngDataPtr) = b
    glngDataPtr = glngDataPtr + 1
    
End Sub

Public Sub AddWord(w As Long)

    ' Add word

    Dim b As Byte
    
    b = w And 255
    AddByte b
    
    b = (w \ 256 And 255)
    AddByte b
    
End Sub
