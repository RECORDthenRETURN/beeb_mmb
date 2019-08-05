VERSION 5.00
Begin VB.Form Form1 
   Caption         =   "Games Menu by Martin Mather"
   ClientHeight    =   4185
   ClientLeft      =   5295
   ClientTop       =   3585
   ClientWidth     =   4680
   Icon            =   "Form1.frx":0000
   LinkTopic       =   "Form1"
   ScaleHeight     =   4185
   ScaleWidth      =   4680
   Begin VB.TextBox Text1 
      Height          =   1695
      Left            =   120
      Locked          =   -1  'True
      MultiLine       =   -1  'True
      ScrollBars      =   2  'Vertical
      TabIndex        =   4
      Text            =   "Form1.frx":030A
      Top             =   2400
      Width           =   4455
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Create"
      Height          =   615
      Left            =   1320
      TabIndex        =   3
      Top             =   1560
      Width           =   2055
   End
   Begin VB.CheckBox Check1 
      Caption         =   "Create Log File"
      Height          =   255
      Left            =   1440
      TabIndex        =   2
      Top             =   1080
      Width           =   1695
   End
   Begin VB.ComboBox Combo2 
      Height          =   315
      Left            =   1440
      TabIndex        =   1
      Text            =   "Combo2"
      Top             =   600
      Width           =   1095
   End
   Begin VB.ComboBox Combo1 
      Height          =   315
      Left            =   1440
      TabIndex        =   0
      Text            =   "Combo1"
      Top             =   120
      Width           =   3135
   End
   Begin VB.Label Label3 
      Caption         =   "Info:"
      Height          =   255
      Left            =   120
      TabIndex        =   7
      Top             =   2520
      Width           =   1095
   End
   Begin VB.Label Label2 
      Caption         =   "DFS Directory"
      Height          =   255
      Left            =   120
      TabIndex        =   6
      Top             =   600
      Width           =   1095
   End
   Begin VB.Label Label1 
      Caption         =   "Source File"
      Height          =   255
      Left            =   120
      TabIndex        =   5
      Top             =   120
      Width           =   1215
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private Sub Combo1_KeyPress(KeyAscii As Integer)

    KeyAscii = 0

End Sub

Private Sub Combo2_Click()

    If Combo2 = "" Then
    
        Combo2 = "D"
        
    End If
    
    Command1.Caption = "Create " & Combo2 & ".DATA"

End Sub

Private Sub Combo2_KeyPress(KeyAscii As Integer)

    KeyAscii = 0

End Sub

Private Sub Command1_Click()

On Error GoTo err_

    Dim p As String
    
    Text1.Text = ""
    
    gstrDir = Combo2
    gboolLog = Check1 <> 0
    
    If gstrDir = "" Or Combo1 = "" Then
    
        MsgBox "Details missing!"
        
    Else
    
        Me.MousePointer = vbArrowHourglass
    
        p = App.Path & "\" & Combo1
        
        If ImportData(p) Then
        
            DefChrs
            
            If Make Then
            
                WriteFile
                
            End If
            
        End If
        
        Me.MousePointer = vbDefault
    
    End If
    
    Exit Sub
    
err_:
    
    Form1.Info "ERROR : " & Err.Description
    Err.Clear
    
    Me.MousePointer = vbDefault

End Sub

Private Sub Form_Load()

On Error GoTo err_

    Dim p As String
    Dim f As String
    Dim x As Integer
    Dim a As String
    Dim e As String
    
    p = App.Path & "\*.*"
    
    f = Dir(p, vbNormal)
    
    Do While f <> ""
    
        e = UCase(Right(f, 4))
        
        If Left(e, 1) <> "." Or e = ".TXT" Then
    
            Combo1.AddItem f
            
        End If
        
        f = Dir
        
    Loop
    
    ' Command line argument
    
    a = Trim(Command())
    
    If a <> "" Then
    
        ' Strip marks
        
        If Left(a, 1) = """" Then a = Mid(a, 2)
        If Right(a, 1) = """" Then a = Left(a, Len(a) - 1)
        
    End If

    Combo1 = a
    
    For x = Asc("A") To Asc("Z")
    
        Combo2.AddItem Chr(x)
        
    Next

    Combo2 = "D"
    
    Command1.Caption = "Create D.DATA"
    
    Text1.Text = ""
    
    Exit Sub
    
err_:

    MsgBox "ERROR : " & Err.Description
    Err.Clear

End Sub

Public Sub Info(strText As String)

    If Text1.Text = "" Then
    
        Text1.Text = strText
        
    Else

        Text1.Text = Text1.Text & vbNewLine & strText
        
    End If
    
End Sub
