Attribute VB_Name = "modMain"
Option Explicit

Private Declare Function PathFindExtension Lib "shlwapi" Alias "PathFindExtensionA" (ByVal pPath As String) As Long
Private Declare Function PathCanonicalize Lib "shlwapi.dll" Alias "PathCanonicalizeA" (ByVal pszBuf As String, ByVal pszPath As String) As Long
Private Declare Function lstrlenA Lib "kernel32" (ByVal ptr As Any) As Long
Private Declare Function lstrcpyA Lib "kernel32" (ByVal RetVal As String, ByVal ptr As Long) As Long
Private Declare Function PathIsRelative Lib "shlwapi" Alias "PathIsRelativeA" (ByVal pszPath As String) As Long
Private Declare Function PathRemoveFileSpec Lib "shlwapi.dll" Alias "PathRemoveFileSpecA" (ByVal pszPath As String) As Long
Private Declare Function PathFindFileName Lib "shlwapi" Alias "PathFindFileNameA" (ByVal pPath As String) As Long

Private Const MAX_PATH = 260

Public Const cUnknown = "Unknown"
Public Const cXMLVer = "version=""1.0"" encoding=""ISO-8859-1"""

Public Function GetFileType(strFile As String) As String
    Dim strTMP As String
    
    Select Case LCase(GetExtensionPart(strFile))
        Case ".dsr": strTMP = "Designer"
        Case ".ctl": strTMP = "UserControl"
        Case ".pag": strTMP = "PropertyPage"
        Case ".cls": strTMP = "Class"
        Case ".bas": strTMP = "Module"
        Case ".frm": strTMP = "Form"
        Case ".vbp": strTMP = "Project"
        Case ".vbg": strTMP = "Group project"
        Case Else
            strTMP = cUnknown
    End Select
    GetFileType = strTMP
End Function

Private Function GetExtensionPart(ByVal sPath As String) As String
    GetExtensionPart = GetStrFromPtrA(PathFindExtension(sPath))
End Function

Public Function GetStrFromPtrA(ByVal lpszA As Long) As String
    GetStrFromPtrA = String$(lstrlenA(ByVal lpszA), 0)
    Call lstrcpyA(ByVal GetStrFromPtrA, ByVal lpszA)
End Function

Public Function GetFullPath(ByVal sPath As String, sFile As String) As String
    Dim sBuf As String
    
    If IsPathRelative(sPath) Then
        sBuf = String(MAX_PATH, Chr(0))
        Call PathCanonicalize(sBuf, sPath)
    End If
    
    If IsPathRelative(sFile) Then
        sBuf = String(MAX_PATH, Chr(0))
        Call PathCanonicalize(sBuf, FixDir(sPath) & sFile)
    Else
        sBuf = sBuf & sFile
    End If
    GetFullPath = TrimNull(sBuf)
End Function

Public Function RemoveFileSpec(ByVal sPath As String) As String
    Call PathRemoveFileSpec(sPath)
    RemoveFileSpec = TrimNull(sPath)
End Function

Public Function GetFilePart(ByVal sPath As String) As String
    GetFilePart = GetStrFromPtrA(PathFindFileName(sPath))
End Function

Public Function fCreateObject(sObject As String) As Object
    On Error GoTo errCreateObject
    Set fCreateObject = CreateObject(sObject)
    On Error GoTo 0
    Exit Function

errCreateObject:
        MsgBox "Error creating object: '" & sObject & "'", vbCritical + vbApplicationModal + vbOKOnly, App.Title & "Object error"
End Function

Public Function LoadFile(strPath As String, strFile As String) As String
    Dim sTmp As String
    Dim FF As Integer
    
    sTmp = ""
    strPath = FixDir(strPath)
    If Len(Dir(strPath & strFile, 15)) > 0 Then
        FF = FreeFile
        Open strPath & strFile For Binary As #FF
        sTmp = String(LOF(1), Chr(0))
        Get #FF, , sTmp
        Close #FF
    End If
    LoadFile = sTmp
End Function

Public Function FixDir(strPath As String) As String
    If Right(strPath, 1) <> "\" Then FixDir = strPath & "\" Else FixDir = strPath
End Function

Public Function TrimEx(ByVal strVal As String) As String
    While InStr(strVal, "  ") > 0
        strVal = Replace(strVal, "  ", " ")
    Wend
    TrimEx = Replace(Trim(strVal), vbTab, "")
End Function

Private Function TrimNull(sVal As String) As String
    Dim pos As Integer
    pos = InStr(sVal, Chr$(0))
    If pos > 0 Then TrimNull = Left$(sVal, pos - 1) Else TrimNull = sVal
End Function

Private Function IsPathRelative(ByVal sPath As String) As Boolean
    IsPathRelative = PathIsRelative(sPath) = 1
End Function
