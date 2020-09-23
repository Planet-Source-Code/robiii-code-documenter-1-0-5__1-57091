VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "FileDocumenter"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Public Event FileDocumenting(lCurObjectNumber As Long, lTotObjects As Long)
Public Event FileStartDocumenting(strFile As String, lTotObjects As Long)
Public Event FileDocumentingDone()

Private Const cTypes = "Const|Property|Function|Sub|Event"
Private Const cScopes = "Private|Public|Friend"

Private m_arrTypes() As String
Private m_arrScopes() As String
Private objRegExp As Object
Private oXMLDoc As Object

Private Sub Class_Initialize()
    Set objRegExp = fCreateObject("VBScript.RegExp")
    Set oXMLDoc = fCreateObject("MSXML.DomDocument")
    m_arrTypes = Split(cTypes, "|")
    m_arrScopes = Split(cScopes, "|")
End Sub

Public Function DocumentFile(ByVal strPath As String, ByVal strFile As String) As Object
    Dim colMatches As Object
    Dim objMatch As Object
    Dim sTmp As String
    Dim oRoot As Object
    Dim oNode As Object
    Dim oTMPNode As Object
    Dim lCount As Long
    Dim arrValues() As String
    Dim T As Long
    
    Debug.Print strFile
    If (objRegExp Is Nothing) Or (oXMLDoc Is Nothing) Then
        Set DocumentFile = Nothing
    Else
        strPath = FixDir(strPath)
        oXMLDoc.appendchild oXMLDoc.CreateProcessingInstruction("xml", cXMLVer)
        Set oRoot = oXMLDoc.appendchild(oXMLDoc.createElement("SourceFile"))
        oRoot.setattribute "filename", GetFullPath(strPath, strFile)
        oRoot.setattribute "filetype", GetFileType(strFile)
        oRoot.setattribute "filelastchange", Format(FileDateTime(strPath & strFile), "yyyymmddThh:nn:ss")
        
        sTmp = LoadFile(strPath, strFile)
        If Len(sTmp) > 0 Then
            objRegExp.IgnoreCase = True
            objRegExp.Global = True
            
            'First handle line wraps _
            ' that are in the file
            objRegExp.Pattern = "(\s.* _\s)+\s.*\n"
            Set colMatches = objRegExp.execute(sTmp)
                            
            objRegExp.Pattern = "(_\s)+\s*"
            For Each objMatch In colMatches
                sTmp = Replace(sTmp, objMatch.Value, objRegExp.Replace(objMatch.Value, ""), , , vbBinaryCompare)
            Next
            
            'Next, get the name attribute if any
            objRegExp.Pattern = "[\t ]*Attribute[\t ]*VB_Name[\t ]*=[\t ]*\"".*\"""
            Set colMatches = objRegExp.execute(sTmp)
            If colMatches.Count > 0 Then oRoot.setattribute "name", Split(colMatches(0).Value, """")(1)
            
            'Here we start the hard work. Extract all interesting data
            objRegExp.Pattern = "[^('|REM)][\t ]*(" & cScopes & ")+[\t ]*(Declare|Static|WithEvents)?[\t ]*(" & cTypes & ")+ .*[^\s]"
            Set colMatches = objRegExp.execute(sTmp)
            
            lCount = 1
            RaiseEvent FileStartDocumenting(strFile, colMatches.Count)
            For Each objMatch In colMatches
                RaiseEvent FileDocumenting(lCount, colMatches.Count)
                Set oNode = oXMLDoc.createElement("Declare")
                oNode.nodetypedvalue = TrimEx(objMatch.Value)
                oNode.setattribute "scope", GetScope(objMatch.Value)
                oNode.setattribute "type", GetType(objMatch.Value)
                oRoot.appendchild oNode
                lCount = lCount + 1
            Next
        End If
        DoEvents
        
        'Get all enums if any
        objRegExp.Pattern = "[\t ]*(" & cScopes & ")+ Enum .*(\s|\S)*?End Enum"
        Set colMatches = objRegExp.execute(sTmp)
        For Each objMatch In colMatches
            Set oNode = oXMLDoc.createElement("Enum")
            arrValues = Split(objMatch.Value, vbCrLf)
            objRegExp.Pattern = "(" & cScopes & ") Enum "
            oNode.setattribute "name", TrimEx(objRegExp.Replace(arrValues(0), ""))
            For T = 1 To UBound(arrValues) - 1
                Set oTMPNode = oXMLDoc.createElement("Def")
                oTMPNode.nodetypedvalue = TrimEx(arrValues(T))
                oNode.appendchild oTMPNode
            Next
            oRoot.appendchild oNode
        Next
        
        'Get all types if any
        objRegExp.Pattern = "[\t ]*(" & cScopes & ")+ Type .*(\s|\S)*?End Type"
        Set colMatches = objRegExp.execute(sTmp)
        For Each objMatch In colMatches
            Set oNode = oXMLDoc.createElement("Type")
            arrValues = Split(objMatch.Value, vbCrLf)
            objRegExp.Pattern = "(" & cScopes & ") Type "
            oNode.setattribute "name", TrimEx(objRegExp.Replace(arrValues(0), ""))
            For T = 1 To UBound(arrValues) - 1
                Set oTMPNode = oXMLDoc.createElement("Def")
                oTMPNode.nodetypedvalue = TrimEx(arrValues(T))
                oNode.appendchild oTMPNode
            Next
            oRoot.appendchild oNode
        Next
        
        'Get all TODO's, BUG's, FIXes and IDEA's if any
        objRegExp.Pattern = "[\t ]*('|REM)[\t ]*(TODO|BUG|FIX|IDEA)+[\t ]*:.*[^\s]"
        Set colMatches = objRegExp.execute(sTmp)
        If colMatches.Count > 0 Then
            Set oNode = oXMLDoc.createElement("Remarks")
            For Each objMatch In colMatches
                arrValues = Split(objMatch.Value, ":")
                Set oTMPNode = oXMLDoc.createElement("Rem")
                oTMPNode.setattribute "type", LCase(TrimEx(arrValues(0)))
                oTMPNode.nodetypedvalue = TrimEx(objMatch.Value)
                oNode.appendchild oTMPNode
            Next
            oRoot.appendchild oNode
        End If
        
        'Remove all empty/comment lines and blocks wich we cannot use...
        objRegExp.Pattern = "(VERSION [0-9]+\.[0-9]+[ a-z]*)|(BEGIN(\s|\S)*?END\r)|(Attribute VB_.*?\r)|(\n[\t ]*((('|REM).*)*\s*))"
        sTmp = objRegExp.Replace(Replace(sTmp, " ", ""), "")
    
        'TODO: This is an approximate... Check stmp for contents..
        ' "Object = {...}" lines (in .frm files) are counted too, and some "End" from "Begin....End" blocks aren't removed
        oRoot.setattribute "codelines", UBound(Split(sTmp, vbCr))
        
        RaiseEvent FileDocumentingDone
        Set DocumentFile = oXMLDoc
    End If
End Function

Private Function GetScope(ByVal strDeclare As String) As String
    Dim T As Long
    Dim strTMP As String
    
    strDeclare = TrimEx(strDeclare)
    strTMP = ""
    For T = 0 To UBound(m_arrScopes)
        If InStr(1, strDeclare, m_arrScopes(T) & " ", vbTextCompare) = 1 Then
            strTMP = m_arrScopes(T)
            Exit For
        End If
    Next
    GetScope = strTMP
End Function

Private Function GetType(ByVal strDeclare As String) As String
    Dim T As Long
    Dim strTMP As String
    
    strTMP = ""
    For T = 0 To UBound(m_arrTypes)
        If InStr(1, strDeclare, m_arrTypes(T) & " ", vbTextCompare) > 0 Then
            strTMP = m_arrTypes(T)
            Exit For
        End If
    Next
    GetType = strTMP
End Function

Private Sub Class_Terminate()
    Set objRegExp = Nothing
    Set oXMLDoc = Nothing
End Sub

'Private Sub Testing123
'End Sub
