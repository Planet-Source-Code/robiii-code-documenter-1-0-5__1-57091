VERSION 5.00
Object = "{F9043C88-F6F2-101A-A3C9-08002B2F49FB}#1.2#0"; "comdlg32.ocx"
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "mscomctl.ocx"
Begin VB.Form frmMain 
   BorderStyle     =   1  'Fixed Single
   Caption         =   "Source Code Documenter"
   ClientHeight    =   3810
   ClientLeft      =   45
   ClientTop       =   330
   ClientWidth     =   5640
   Icon            =   "frmMain.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   3810
   ScaleWidth      =   5640
   StartUpPosition =   2  'CenterScreen
   Begin VB.CommandButton cmdGo 
      Caption         =   "Document"
      Height          =   375
      Left            =   4200
      TabIndex        =   7
      Top             =   960
      Width           =   1335
   End
   Begin VB.CommandButton cmdSelFile 
      Caption         =   "..."
      Height          =   285
      Left            =   5160
      TabIndex        =   6
      Top             =   480
      Width           =   375
   End
   Begin VB.TextBox txtFile 
      Appearance      =   0  'Flat
      Height          =   285
      Left            =   120
      Locked          =   -1  'True
      TabIndex        =   5
      Top             =   480
      Width           =   4935
   End
   Begin MSComDlg.CommonDialog cmDlg 
      Left            =   960
      Top             =   840
      _ExtentX        =   847
      _ExtentY        =   847
      _Version        =   393216
   End
   Begin VB.Frame Frame1 
      Caption         =   "Progress"
      Height          =   2295
      Left            =   120
      TabIndex        =   0
      Top             =   1440
      Width           =   5415
      Begin MSComctlLib.ProgressBar pbProgress 
         Height          =   255
         Index           =   0
         Left            =   240
         TabIndex        =   8
         Top             =   600
         Width           =   4935
         _ExtentX        =   8705
         _ExtentY        =   450
         _Version        =   393216
         BorderStyle     =   1
         Appearance      =   0
         Scrolling       =   1
      End
      Begin MSComctlLib.ProgressBar pbProgress 
         Height          =   255
         Index           =   1
         Left            =   240
         TabIndex        =   9
         Top             =   1200
         Width           =   4935
         _ExtentX        =   8705
         _ExtentY        =   450
         _Version        =   393216
         BorderStyle     =   1
         Appearance      =   0
         Scrolling       =   1
      End
      Begin MSComctlLib.ProgressBar pbProgress 
         Height          =   255
         Index           =   2
         Left            =   240
         TabIndex        =   10
         Top             =   1800
         Width           =   4935
         _ExtentX        =   8705
         _ExtentY        =   450
         _Version        =   393216
         BorderStyle     =   1
         Appearance      =   0
         Scrolling       =   1
      End
      Begin VB.Label lbInfo 
         AutoSize        =   -1  'True
         Caption         =   "-"
         Height          =   195
         Index           =   0
         Left            =   240
         TabIndex        =   3
         Top             =   360
         Width           =   45
      End
      Begin VB.Label lbInfo 
         AutoSize        =   -1  'True
         Caption         =   "-"
         Height          =   195
         Index           =   1
         Left            =   240
         TabIndex        =   2
         Top             =   960
         Width           =   45
      End
      Begin VB.Label lbInfo 
         AutoSize        =   -1  'True
         Caption         =   "-"
         Height          =   195
         Index           =   2
         Left            =   240
         TabIndex        =   1
         Top             =   1560
         Width           =   45
      End
   End
   Begin VB.Label lbInfo 
      AutoSize        =   -1  'True
      Caption         =   "Select a file:"
      Height          =   195
      Index           =   3
      Left            =   120
      TabIndex        =   4
      Top             =   120
      Width           =   870
   End
End
Attribute VB_Name = "frmMain"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private Declare Function lstrlenA Lib "kernel32" (ByVal ptr As Any) As Long
Private Declare Function lstrcpyA Lib "kernel32" (ByVal RetVal As String, ByVal ptr As Long) As Long
Private Declare Function PathRemoveFileSpec Lib "shlwapi.dll" Alias "PathRemoveFileSpecA" (ByVal pszPath As String) As Long
Private Declare Function PathFindFileName Lib "shlwapi" Alias "PathFindFileNameA" (ByVal pPath As String) As Long
Private Declare Function ShellExecute Lib "shell32.dll" Alias "ShellExecuteA" (ByVal hWnd As Long, ByVal lpOperation As String, ByVal lpFile As String, ByVal lpParameters As String, ByVal lpDirectory As String, ByVal nShowCmd As Long) As Long

Private WithEvents oGD As GroupDocumenter
Attribute oGD.VB_VarHelpID = -1
Private WithEvents oPD As ProjectDocumenter
Attribute oPD.VB_VarHelpID = -1

Private Const cDone = "Done"
Private Const cFile = " file: "
Private Const cGroup = "Group"
Private Const cProject = "Project"
Private Const cSourceFile = "Source"

Private Sub cmdGo_Click()
    If Len(txtFile.Text) > 0 Then
        Call DocumentFile
    Else
        MsgBox "Please select a project or project group first!", vbExclamation + vbOKOnly + vbApplicationModal, App.ProductName
    End If
End Sub

Private Sub cmdSelFile_Click()
    On Error GoTo errSelect
    cmDlg.ShowOpen
    txtFile.Text = cmDlg.FileName
    Exit Sub
errSelect:
    'User has cancelled
End Sub

Private Sub DocumentFile()
    Dim oDoc As Object
    
    Me.Enabled = False
    cmdGo.Enabled = False
    cmdSelFile.Enabled = False
    
    If Len(Dir(txtFile.Text)) > 0 Then
        Select Case Right(LCase(txtFile.Text), 4)
            Case ".vbg"
                Set oGD = New GroupDocumenter
                Set oDoc = oGD.DocumentGroup(RemoveFileSpec(txtFile.Text), GetFilePart(txtFile.Text))
                Set oGD = Nothing
            Case ".vbp"
                Set oPD = New ProjectDocumenter
                Set oDoc = oPD.DocumentProject(RemoveFileSpec(txtFile.Text), GetFilePart(txtFile.Text))
                Set oPD = Nothing
        End Select
        If Not oDoc Is Nothing Then
            oDoc.insertBefore oDoc.CreateProcessingInstruction("xml-stylesheet", "type=""text/xsl"" href=""xsl/display.xsl"""), oDoc.childnodes(1)
            oDoc.save App.Path & "\output\output.xml"
            ShellExecute Me.hWnd, vbNullString, """" & App.Path & "\output\output.xml""", vbNullString, vbNullString, 1
        End If
    Else
        MsgBox "Unable to open '" & txtFile.Text & "'", vbCritical + vbOKOnly + vbApplicationModal, App.ProductName
    End If
    
    cmdSelFile.Enabled = True
    cmdGo.Enabled = True
    Me.Enabled = True
End Sub

Private Sub Form_Load()
    With cmDlg
        .CancelError = True
        .Filter = "Visual basic projects (*.vbp;*vbg)|*.vbp;*.vbg"
        .FilterIndex = 1
        .Flags = cdlOFNExplorer Or cdlOFNFileMustExist Or cdlOFNLongNames Or cdlOFNHideReadOnly Or cdlOFNPathMustExist
    End With
End Sub

Private Sub oGD_GroupDocumentingDone()
    lbInfo(0).Caption = cGroup & cFile & cDone
End Sub

Private Sub oGD_ProjectDocumentingDone()
    lbInfo(1).Caption = cProject & cFile & cDone
End Sub

Private Sub oGD_FileDocumentingDone()
    lbInfo(2).Caption = cSourceFile & cFile & cDone
End Sub

Private Sub oGD_GroupDocumenting(lCurObjectNumber As Long, lTotObjects As Long)
    pbProgress(0).Value = lCurObjectNumber
End Sub

Private Sub oGD_ProjectDocumenting(lCurObjectNumber As Long, lTotObjects As Long)
    pbProgress(1).Value = lCurObjectNumber
End Sub

Private Sub oGD_FileDocumenting(lCurObjectNumber As Long, lTotObjects As Long)
    pbProgress(2).Value = lCurObjectNumber
End Sub

Private Sub oGD_GroupStartDocumenting(strFile As String, lTotObjects As Long)
    lbInfo(0).Caption = cGroup & cFile & strFile
    lbInfo(0).Refresh
    pbProgress(0).Max = lTotObjects
End Sub

Private Sub oGD_ProjectStartDocumenting(strFile As String, lTotObjects As Long)
    lbInfo(1).Caption = cProject & cFile & strFile
    lbInfo(1).Refresh
    pbProgress(1).Max = lTotObjects
End Sub

Private Sub oGD_FileStartDocumenting(strFile As String, lTotObjects As Long)
    lbInfo(2).Caption = cSourceFile & cFile & strFile
    lbInfo(2).Refresh
    pbProgress(2).Max = IIf(lTotObjects > 0, lTotObjects, 1)
End Sub

Private Sub oPD_ProjectDocumentingDone()
    lbInfo(1).Caption = cProject & cFile & cDone
End Sub

Private Sub oPD_FileDocumentingDone()
    lbInfo(2).Caption = cSourceFile & cFile & cDone
End Sub

Private Sub oPD_ProjectDocumenting(lCurObjectNumber As Long, lTotObjects As Long)
    pbProgress(1).Value = lCurObjectNumber
End Sub

Private Sub oPD_FileDocumenting(lCurObjectNumber As Long, lTotObjects As Long)
    pbProgress(2).Value = lCurObjectNumber
End Sub

Private Sub oPD_ProjectStartDocumenting(strFile As String, lTotObjects As Long)
    lbInfo(1).Caption = cProject & cFile & strFile
    lbInfo(1).Refresh
    pbProgress(1).Max = lTotObjects
End Sub

Private Sub oPD_FileStartDocumenting(strFile As String, lTotObjects As Long)
    lbInfo(2).Caption = cSourceFile & cFile & strFile
    lbInfo(2).Refresh
    pbProgress(2).Max = IIf(lTotObjects > 0, lTotObjects, 1)
End Sub

'========================================
'File API Helpers
'========================================
Private Function RemoveFileSpec(ByVal sPath As String) As String
    Call PathRemoveFileSpec(sPath)
    RemoveFileSpec = TrimNull(sPath)
End Function

Private Function GetFilePart(ByVal sPath As String) As String
    GetFilePart = GetStrFromPtrA(PathFindFileName(sPath))
End Function

Private Function TrimNull(sVal As String) As String
    Dim pos As Integer
    pos = InStr(sVal, Chr$(0))
    If pos > 0 Then TrimNull = Left$(sVal, pos - 1) Else TrimNull = sVal
End Function

Public Function GetStrFromPtrA(ByVal lpszA As Long) As String
    GetStrFromPtrA = String$(lstrlenA(ByVal lpszA), 0)
    Call lstrcpyA(ByVal GetStrFromPtrA, ByVal lpszA)
End Function
