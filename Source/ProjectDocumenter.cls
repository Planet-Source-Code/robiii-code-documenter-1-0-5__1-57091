VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "ProjectDocumenter"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Public Event ProjectDocumenting(lCurObjectNumber As Long, lTotObjects As Long)
Public Event ProjectStartDocumenting(strFile As String, lTotObjects As Long)
Public Event ProjectDocumentingDone()

Public Event FileDocumenting(lCurObjectNumber As Long, lTotObjects As Long)
Public Event FileStartDocumenting(strFile As String, lTotObjects As Long)
Public Event FileDocumentingDone()

Private WithEvents oFD As FileDocumenter
Attribute oFD.VB_VarHelpID = -1

Public Function DocumentProject(ByVal strPath As String, ByVal strFile As String) As Object
    Dim oXMLDoc As Object
    Dim objRegExp As Object
    Dim colMatches  As Object
    Dim objMatch As Object
    Dim sTmp As String
    Dim oRoot As Object
    Dim oNode As Object
    Dim arrTMP() As String
    Dim arrVal() As String
    Dim lCount As Long
    
    strPath = FixDir(strPath)
    Set oXMLDoc = fCreateObject("MSXML.DomDocument")
    If Not oXMLDoc Is Nothing Then
        oXMLDoc.appendchild oXMLDoc.CreateProcessingInstruction("xml", cXMLVer)
        Set oRoot = oXMLDoc.appendchild(oXMLDoc.createElement("Project"))
        oRoot.setattribute "filename", GetFullPath(strPath, strFile)
        oRoot.setattribute "filelastchange", Format(FileDateTime(strPath & strFile), "yyyymmddThh:nn:ss")
        
        sTmp = LoadFile(strPath, strFile)
        
        Set objRegExp = fCreateObject("VBScript.RegExp")
        If Not objRegExp Is Nothing Then
            objRegExp.IgnoreCase = True
            objRegExp.Global = True
            objRegExp.Pattern = "[\t ]*\b(Type|Reference|Startup|Name|Object|Class|Module|Form|Designer|UserControl|PropertyPage|MajorVer|MinorVer|RevisionVer)+[\t ]*=.*[^\s]"
            Set colMatches = objRegExp.execute(sTmp)
            lCount = 1
            
            RaiseEvent ProjectStartDocumenting(strFile, colMatches.Count)
            For Each objMatch In colMatches
                RaiseEvent ProjectDocumenting(lCount, colMatches.Count)
                arrTMP() = Split(TrimEx(objMatch.Value), "=", 2)
                Select Case LCase(arrTMP(0))
                    Case "type", "startup", "majorver", "minorver", "revisionver", "name":
                        oRoot.setattribute LCase(arrTMP(0)), Replace(arrTMP(1), """", "")
                    Case Else
                        Set oFD = New FileDocumenter
                        Select Case LCase(arrTMP(0))
                            Case "reference"
                                Set oNode = oXMLDoc.createElement(StrConv(arrTMP(0), vbProperCase))
                                oNode.nodetypedvalue = arrTMP(1)
                                oRoot.appendchild oNode
                            Case "object"
                                Set oNode = oXMLDoc.createElement(StrConv(arrTMP(0), vbProperCase))
                                arrVal = Split(arrTMP(1), ";", 2)
                                oNode.setattribute "clsid", TrimEx(arrVal(0))
                                If UBound(arrVal) > 0 Then oNode.nodetypedvalue = GetFullPath(strPath, TrimEx(arrVal(1)))
                                oRoot.appendchild oNode
                            Case "class", "module"
                                arrVal = Split(arrTMP(1), ";", 2)
                                Set oNode = oFD.DocumentFile(strPath, TrimEx(arrVal(1)))
                                If Not oNode Is Nothing Then oRoot.appendchild oNode.childnodes(1)
                            Case "form", "designer", "usercontrol", "propertypage"
                                Set oNode = oFD.DocumentFile(strPath, TrimEx(arrTMP(1)))
                                If Not oNode Is Nothing Then oRoot.appendchild oNode.childnodes(1)
                            Case Else
                        End Select
                        Set oFD = Nothing
                End Select
                lCount = lCount + 1
            Next
            RaiseEvent ProjectDocumentingDone
        End If
        Set DocumentProject = oXMLDoc
    Else
        Set DocumentProject = Nothing
    End If
End Function

Private Sub oFD_FileDocumenting(lCurObjectNumber As Long, lTotObjects As Long)
    RaiseEvent FileDocumenting(lCurObjectNumber, lTotObjects)
End Sub

Private Sub oFD_FileDocumentingDone()
    RaiseEvent FileDocumentingDone
End Sub

Private Sub oFD_FileStartDocumenting(strFile As String, lTotObjects As Long)
    RaiseEvent FileStartDocumenting(strFile, lTotObjects)
End Sub
