Attribute VB_Name = "Module5"
Option Explicit

Public Function BCD(n As Byte) As Byte

    BCD = (n Mod 10) + (n \ 10) * 16

End Function
