VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "GroupDocumenter"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Public Event GroupDocumenting(lCurObjectNumber As Long, lTotObjects As Long)
Public Event GroupStartDocumenting(strFile As String, lTotObjects As Long)
Public Event GroupDocumentingDone()

Public Event ProjectDocumenting(lCurObjectNumber As Long, lTotObjects As Long)
Public Event ProjectStartDocumenting(strFile As String, lTotObjects As Long)
Public Event ProjectDocumentingDone()

Public Event FileDocumenting(lCurObjectNumber As Long, lTotObjects As Long)
Public Event FileStartDocumenting(strFile As String, lTotObjects As Long)
Public Event FileDocumentingDone()

Private WithEvents oPD As ProjectDocumenter
Attribute oPD.VB_VarHelpID = -1

Public Function DocumentGroup(ByVal strPath As String, ByVal strFile As String) As Object
    Dim oXMLDoc As Object
    Dim objRegExp As Object
    Dim colMatches  As Object
    Dim objMatch As Object
    Dim sTmp As String
    Dim oRoot As Object
    Dim oNode As Object
    Dim arrTMP() As String
    Dim lCount As Long
    
    strPath = FixDir(strPath)
    Set oXMLDoc = fCreateObject("MSXML.DomDocument")
    If Not oXMLDoc Is Nothing Then
        oXMLDoc.appendchild oXMLDoc.CreateProcessingInstruction("xml", cXMLVer)
        Set oRoot = oXMLDoc.appendchild(oXMLDoc.createElement("ProjectGroup"))
        oRoot.setattribute "filename", GetFullPath(strPath, strFile)
        oRoot.setattribute "filelastchange", Format(FileDateTime(strPath & strFile), "yyyymmddThh:nn:ss")
        
        sTmp = LoadFile(strPath, strFile)
        
        Set objRegExp = fCreateObject("VBScript.RegExp")
        If Not objRegExp Is Nothing Then
            objRegExp.IgnoreCase = True
            objRegExp.Global = True
            objRegExp.Pattern = "[\t ]*\b(Startup)*Project[\t ]*=.*[^\s]"
            Set colMatches = objRegExp.execute(sTmp)
            lCount = 1
            
            RaiseEvent GroupStartDocumenting(strFile, colMatches.Count)
            For Each objMatch In colMatches
                RaiseEvent GroupDocumenting(lCount, colMatches.Count)
                arrTMP() = Split(TrimEx(objMatch.Value), "=", 2)
                
                Set oPD = New ProjectDocumenter
                Set oNode = oPD.DocumentProject(RemoveFileSpec(strPath & arrTMP(1)), GetFilePart(strPath & arrTMP(1)))
                If Not oNode Is Nothing Then
                    Set oNode = oNode.childnodes(1)
                    oRoot.appendchild oNode
                    oNode.setattribute "startupproject", IIf(InStr(arrTMP(0), "Startup") > 0, "true", "false")
                End If
                Set oPD = Nothing
                
                lCount = lCount + 1
            Next
            RaiseEvent GroupDocumentingDone
        End If
        Set DocumentGroup = oXMLDoc
    Else
        Set DocumentGroup = Nothing
    End If
End Function

Private Sub oPD_FileDocumenting(lCurObjectNumber As Long, lTotObjects As Long)
    RaiseEvent FileDocumenting(lCurObjectNumber, lTotObjects)
End Sub

Private Sub oPD_FileDocumentingDone()
    RaiseEvent FileDocumentingDone
End Sub

Private Sub oPD_FileStartDocumenting(strFile As String, lTotObjects As Long)
    RaiseEvent FileStartDocumenting(strFile, lTotObjects)
End Sub

Private Sub oPD_ProjectDocumenting(lCurObjectNumber As Long, lTotObjects As Long)
    RaiseEvent ProjectDocumenting(lCurObjectNumber, lTotObjects)
End Sub

Private Sub oPD_ProjectDocumentingDone()
    RaiseEvent ProjectDocumentingDone
End Sub

Private Sub oPD_ProjectStartDocumenting(strFile As String, lTotObjects As Long)
    RaiseEvent ProjectStartDocumenting(strFile, lTotObjects)
End Sub
