<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:decimal-format name="european" decimal-separator=',' grouping-separator='.'/>
	 <xsl:param name="pScope"/>
	 <xsl:param name="pShowPrjInfo">0</xsl:param>
 	 <xsl:param name="pShowGrpStats">0</xsl:param>
 	 <xsl:param name="pShowPrjStats">0</xsl:param>
 	 <xsl:param name="pShowEnum">1</xsl:param>
 	 <xsl:param name="pShowType">1</xsl:param>
 	 <xsl:param name="pShowRemark">1</xsl:param>
 	 <xsl:param name="pShowReferences">0</xsl:param>
 	 <xsl:param name="pShowObjects">0</xsl:param>
 	 <xsl:param name="pExpand">0</xsl:param>
 	 <xsl:param name="pRemarksOnly">0</xsl:param>

	<xsl:template match="/">
		<html>
			<head>
				<title>Documentation</title>
				<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
				<link rel="stylesheet" type="text/css" href="css/display.css"/>
				<script language="JavaScript" type="text/javascript">
					<xsl:comment>
						<![CDATA[
							function expandObject(sID) {
								var oObj = document.getElementById(sID);
								var oImg = document.getElementById('img' + sID);
								if (oObj) oObj.style.display = (oObj.style.display == 'block') ? 'none' : 'block';
								if (oImg) oImg.src = (oImg.src.indexOf('minus')>0) ? 'img/plus.gif' : 'img/minus.gif';
							}
		
							function positionTools() {
								var oDVT = document.getElementById('dvTools');
								if (oDVT) {
									if (oDVT.style.display!='block') oDVT.style.display='block';
									oDVT.style.left = document.body.clientWidth - oDVT.clientWidth-10;
									oDVT.style.top = document.body.scrollTop + 10;
								}
							}
							
							function ExplorerFix()  {
								for (a in document.links) document.links[a].onfocus = document.links[a].blur;
							}
							if(document.all) document.onmousedown = ExplorerFix; 
							
							function doFilter() {
								expandObject('dvWait');
								frmTool.disabled=true;
								window.setTimeout('execFilter();',10); //give "wait-div" some time (10ms) to display before we go ahead
							}
							
							function execFilter() {
								var oSource = document.XMLDocument;
								var oStyle = document.XSLDocument;
								var oDVContent = document.getElementById('dvXMLContent');
								
								if ((oSource) && (oStyle) && (oDVContent)) {
									setOption('pScope',frmTool.selScope.value);
									setOption('pShowPrjInfo',frmTool.chkShowPrjInfo.checked?1:0);
									setOption('pShowGrpStats',frmTool.chkShowGrpStats.checked?1:0);
									setOption('pShowPrjStats',frmTool.chkShowPrjStats.checked?1:0);
									setOption('pShowEnum',frmTool.chkShowEnum.checked?1:0);
									setOption('pShowType',frmTool.chkShowType.checked?1:0);
									setOption('pShowRemark',frmTool.chkShowRemark.checked?1:0);
									setOption('pRemarksOnly',frmTool.chkRemarksOnly.checked?1:0);

									setOption('pShowReferences',frmTool.chkShowReferences.checked?1:0);
									setOption('pShowObjects',frmTool.chkShowObjects.checked?1:0);

									setOption('pShowObjects',frmTool.chkShowObjects.checked?1:0);

									setOption('pExpand',frmTool.chkExpand.checked?1:0);
									
								 	oDVContent.innerHTML = oSource.documentElement.transformNode(oStyle);
									positionTools();
								}
								expandObject('dvWait');
								frmTool.disabled=false;
							}
							
							function setOption(sName, vVal) {
								var oXSLNode = document.XSLDocument.selectSingleNode('\/\/xsl:param[@name=\'' + sName + '\']');
								if (oXSLNode) oXSLNode.text = vVal
							}
						]]>
					</xsl:comment>
				</script>
			</head>
			
			<body onload="positionTools();" onscroll="positionTools();" onresize="positionTools();">
				<h1>Documentation</h1>
				<div id="dvTools" class="dvTools">
					<div id="dvWait" class="dvWait">Please Wait... Executing.</div>
					<table cellpadding="2" cellspacing="0" border="0" width="100%">
						<tr>
							<td background="img/toolbar.gif"><a href="javascript:expandObject('trToolContent')"><img id="imgtrToolContent" src="img/plus.gif" width="13" height="13" alt="" align="absmiddle"/> <img src="img/Tools.gif" width="16" height="16" alt=""/></a>&#160;<a href="javascript:expandObject('trToolContent')" class="Tools">Tools</a></td>
						</tr>
						<tr id="trToolContent" style="display:none;">
							<td>
								<form name="frmTool">
									<table cellpadding="0" cellspacing="0" border="0" width="100%">
										<tr>
											<td width="20"><img src="img/Scope.gif" width="16" height="16" alt=""/></td>
											<td width="75">Scope</td>
											<td width="10">:</td>
											<td>
												<select name="selScope" class="DropDown">
													<option value="">All</option>
													<option value="Public">Public</option>
													<option value="Private">Private</option>
													<option value="Friend">Friend</option>
												</select>
											</td>
										</tr>
										<tr>
											<td><img src="img/ProjectGroup_small.gif" width="16" height="16" alt=""/></td>
											<td>Project Group</td>
											<td>:</td>
											<td><input name="chkShowGrpStats" type="Checkbox"/> Show group statistics</td>
										</tr>
										<tr>
											<td><img src="img/Project.gif" width="16" height="16" alt=""/></td>
											<td>Project info</td>
											<td>:</td>
											<td>
												<table cellpadding="0" cellspacing="0" border="0" width="100%">
													<tr>
														<td colspan="2"><input name="chkShowPrjInfo" type="Checkbox" onclick="frmTool.chkShowPrjStats.disabled=!this.checked;frmTool.chkShowReferences.disabled=!this.checked;frmTool.chkShowObjects.disabled=!this.checked;"/> Show info per project</td>
													</tr>
													<tr>
														<td width="15">&#160;</td>
														<td><input name="chkShowPrjStats" type="Checkbox" disabled="true"/> Show stats per project</td>
													</tr>
													<tr>
														<td width="15">&#160;</td>
														<td><input name="chkShowReferences" type="Checkbox" disabled="true"/> Show references per project</td>
													</tr>
													<tr>
														<td width="15">&#160;</td>
														<td><input name="chkShowObjects" type="Checkbox" disabled="true"/> Show objects per project</td>
													</tr>
													<tr>
													</tr>
												</table>
											</td>
										</tr>
										<tr>
											<td><img src="img/Options.gif" width="16" height="16" alt=""/></td>
											<td>Options</td>
											<td>:</td>
											<td><input name="chkShowEnum" type="Checkbox" checked="true"/> Show Enums<br/><input name="chkShowType" type="Checkbox" checked="true"/> Show Used defined types<br/><input name="chkShowRemark" type="Checkbox" checked="true"/> Show Remarks <input name="chkRemarksOnly" type="Checkbox" onclick="frmTool.chkShowEnum.disabled=this.checked;frmTool.chkShowType.disabled=this.checked;if(this.checked)frmTool.chkExpand.checked=this.checked;frmTool.selScope.disabled=this.checked;frmTool.chkShowRemark.checked=this.checked;"/> Remarks Only<br/><input name="chkExpand" type="Checkbox"/> Expand all declarations</td>
										</tr>
										<tr>
											<td align="right" colspan="4"><input name="cmdSubmit" type="Button" onclick="doFilter();" value="Go" class="Button"/></td>
										</tr>
									</table>
								</form>
							</td>
						</tr>
					</table>
				</div>
				<div id="dvXMLContent">
					<xsl:apply-templates/> 
				</div>
			</body>
		</html>
	</xsl:template>

	<xsl:template match="ProjectGroup">
		<h2><img src="img/ProjectGroup.gif" width="32" height="32" alt=""/>&#160;<xsl:value-of select="@filename"/></h2>
		<p><xsl:value-of select="count(Project)"/> projects in this group, <xsl:value-of select="count(Project/SourceFile)"/> files total. Last changed: <xsl:value-of select="concat(substring(@filelastchange,7,2),'-',substring(@filelastchange,5,2),'-',substring(@filelastchange,1,4),' ',substring(@filelastchange,10,2),':',substring(@filelastchange,13,2),':',substring(@filelastchange,16,2))"/></p>
		<xsl:if test="$pShowGrpStats!=0">
			<a href="javascript:expandObject('tStats')"><img id="imgtStats" src="img/plus.gif" width="13" height="13" alt="" align="absmiddle"/>Statistics</a>
			<table id="tStats" cellpadding="0" cellspacing="0" border="0" style="display:none;">
				<tr>
					<td width="100">References</td>
					<td width="20">:</td>
					<td width="50" align="right"><xsl:value-of select="count(Project/Reference)"/></td>
				</tr>
				<tr>
					<td>Objects</td>
					<td>:</td>
					<td align="right"><xsl:value-of select="count(Project/Object)"/></td>
				</tr>
				<tr>
					<td>Constants</td>
					<td>:</td>
					<td align="right"><xsl:value-of select="count(Project/SourceFile/Declare[@type='Const'])"/></td>
				</tr>
				<tr>
					<td>Sub routines</td>
					<td>:</td>
					<td align="right"><xsl:value-of select="count(Project/SourceFile/Declare[@type='Sub'])"/></td>
				</tr>
				<tr>
					<td>Functions</td>
					<td>:</td>
					<td align="right"><xsl:value-of select="count(Project/SourceFile/Declare[@type='Function'])"/></td>
				</tr>
				<tr>
					<td>Properties</td>
					<td>:</td>
					<td align="right"><xsl:value-of select="count(Project/SourceFile/Declare[@type='Property'])"/></td>
				</tr>
				<tr>
					<td>Events</td>
					<td>:</td>
					<td align="right"><xsl:value-of select="count(Project/SourceFile/Declare[@type='Event'])"/></td>
				</tr>				
				<tr>
					<td>Enums</td>
					<td>:</td>
					<td align="right"><xsl:value-of select="count(Project/SourceFile/Enum)"/></td>
				</tr>
				<tr>
					<td>Types</td>
					<td>:</td>
					<td align="right"><xsl:value-of select="count(Project/SourceFile/Type)"/></td>
				</tr>
				<tr>
					<td>Code lines</td>
					<td>:</td>
					<td align="right"><xsl:value-of select="sum(Project/SourceFile/@codelines)"/></td>
				</tr>
			</table>
		</xsl:if>
		<xsl:apply-templates select="Project">
			<xsl:sort select="@startupproject" order="descending"/>
			<xsl:sort select="@name"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="Project">
		<xsl:if test="($pRemarksOnly=1 and count(SourceFile/Remarks)&gt;0) or ($pRemarksOnly=0)">
			<h3>
				<img width="32" height="32" alt="" align="absmiddle">
					<xsl:attribute name="src">img/<xsl:value-of select="@type"/>.gif</xsl:attribute>
				</img>&#160;<xsl:value-of select="@name"/>
			</h3>
			<blockquote class="projectinfo">
				<xsl:if test="$pShowPrjInfo!=0">
					<p>
						<a>
							<xsl:attribute name="href">javascript:expandObject('pi_<xsl:value-of select="generate-id(@name)"/>');</xsl:attribute>
							<img src="img/plus.gif" width="13" height="13" alt="" align="absmiddle"><xsl:attribute name="id">imgpi_<xsl:value-of select="generate-id(@name)"/></xsl:attribute></img>Project Info
						</a>
						<div style="display:none;">
							<xsl:attribute name="id">pi_<xsl:value-of select="generate-id(@name)"/></xsl:attribute>
							<table cellpadding="0" cellspacing="0" border="0">
								<tr>
									<td>Files</td>
									<td>:</td>
									<td><xsl:value-of select="count(SourceFile)"/></td>
								</tr>
								<tr>
									<td>Last change</td>
									<td>:</td>
									<td><xsl:value-of select="concat(substring(@filelastchange,7,2),'-',substring(@filelastchange,5,2),'-',substring(@filelastchange,1,4),' ',substring(@filelastchange,10,2),':',substring(@filelastchange,13,2),':',substring(@filelastchange,16,2))"/></td>
								</tr>
								<tr>
									<td width="100">Name</td>
									<td>:</td>
									<td><xsl:value-of select="@name"/><xsl:if test="@startupproject='true'">&#160;(Startup project)</xsl:if></td>
								</tr>
								<tr>
									<td>Filename</td>
									<td>:</td>
									<td><xsl:value-of select="@filename"/></td>
								</tr>
								<tr>
									<td>Type</td>
									<td>:</td>
									<td><xsl:value-of select="@type"/></td>
								</tr>
								<tr>
									<td>Version</td>
									<td>:</td>
									<td>Major: <xsl:value-of select="@majorver"/> Minor: <xsl:value-of select="@minorver"/> Revision: <xsl:value-of select="@revisionver"/></td>
								</tr>
								<tr>
									<td>Startup</td>
									<td>:</td>
									<td><xsl:value-of select="@startup"/></td>
								</tr>
							</table>
						</div>
					</p>
	
					<xsl:if test="$pShowPrjStats!=0">
						<p>
							<a>
								<xsl:attribute name="href">javascript:expandObject('ps_<xsl:value-of select="generate-id(@name)"/>');</xsl:attribute>
								<img src="img/plus.gif" width="13" height="13" alt="" align="absmiddle"><xsl:attribute name="id">imgps_<xsl:value-of select="generate-id(@name)"/></xsl:attribute></img>Statistics
							</a>
							<div style="display:none;">
								<xsl:attribute name="id">ps_<xsl:value-of select="generate-id(@name)"/></xsl:attribute>
								<table cellpadding="0" cellspacing="0" border="0">
									<tr>
										<td width="100">References</td>
										<td width="20">:</td>
										<td width="25" align="right"><xsl:value-of select="count(Reference)"/></td>
									</tr>
									<tr>
										<td>Objects</td>
										<td>:</td>
										<td align="right"><xsl:value-of select="count(Object)"/></td>
									</tr>
									<tr>
										<td>Constants</td>
										<td>:</td>
										<td align="right"><xsl:value-of select="count(SourceFile/Declare[@type='Const'])"/></td>
									</tr>
									<tr>
										<td>Sub routines</td>
										<td>:</td>
										<td align="right"><xsl:value-of select="count(SourceFile/Declare[@type='Sub'])"/></td>
									</tr>
									<tr>
										<td>Functions</td>
										<td>:</td>
										<td align="right"><xsl:value-of select="count(SourceFile/Declare[@type='Function'])"/></td>
									</tr>
									<tr>
										<td>Properties</td>
										<td>:</td>
										<td align="right"><xsl:value-of select="count(SourceFile/Declare[@type='Property'])"/></td>
									</tr>
									<tr>
										<td>Events</td>
										<td>:</td>
										<td align="right"><xsl:value-of select="count(SourceFile/Declare[@type='Event'])"/></td>
									</tr>									
									<tr>
										<td>Enums</td>
										<td>:</td>
										<td align="right"><xsl:value-of select="count(SourceFile/Enum)"/></td>
									</tr>
									<tr>
										<td>Types</td>
										<td>:</td>
										<td align="right"><xsl:value-of select="count(SourceFile/Type)"/></td>
									</tr>
									<tr>
										<td>Code lines</td>
										<td>:</td>
										<td align="right"><xsl:value-of select="sum(SourceFile/@codelines)"/></td>
									</tr>
								</table>
							</div>
						</p>
					</xsl:if>
	
					<xsl:if test="$pShowReferences!=0 and count(Reference)&gt;0">
						<p>
							<a>
								<xsl:attribute name="href">javascript:expandObject('pr_<xsl:value-of select="generate-id(@name)"/>');</xsl:attribute>
								<img src="img/plus.gif" width="13" height="13" alt="" align="absmiddle"><xsl:attribute name="id">imgpr_<xsl:value-of select="generate-id(@name)"/></xsl:attribute></img>References
							</a>
							<div style="display:none;">
								<xsl:attribute name="id">pr_<xsl:value-of select="generate-id(@name)"/></xsl:attribute>
								<h5>References:</h5>
								<xsl:apply-templates select="Reference">
									<xsl:sort select="."/>
								</xsl:apply-templates>
							</div>
						</p>
					</xsl:if>
	
					<xsl:if test="$pShowObjects!=0 and count(Object)&gt;0">
						<p>
							<a>
								<xsl:attribute name="href">javascript:expandObject('po_<xsl:value-of select="generate-id(@name)"/>');</xsl:attribute>
								<img src="img/plus.gif" width="13" height="13" alt="" align="absmiddle"><xsl:attribute name="id">imgpo_<xsl:value-of select="generate-id(@name)"/></xsl:attribute></img>Objects
							</a>
							<div style="display:none;">
								<xsl:attribute name="id">po_<xsl:value-of select="generate-id(@name)"/></xsl:attribute>
								<h5>Objects:</h5>
								<table cellpadding="0" cellspacing="0" border="0">
								<xsl:apply-templates select="Object">
									<xsl:sort select="."/>
								</xsl:apply-templates>
								</table>
							</div>
						</p>
					</xsl:if>				
					<hr/>
				</xsl:if>
				<xsl:if test="count(SourceFile)&gt;0">
					<table cellpadding="0" cellspacing="0" border="0">
						<xsl:apply-templates select="SourceFile">
							<xsl:sort select="@filetype"/>
							<xsl:sort select="@name"/>
						</xsl:apply-templates>
					</table>
				</xsl:if>
			</blockquote>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="SourceFile">
		<xsl:if test="($pRemarksOnly=1 and count(Remarks)&gt;0) or ($pRemarksOnly=0)">
			<tr>
				<td width="13">
					<a>
						<xsl:attribute name="href">javascript:expandObject('sf_<xsl:value-of select="generate-id(@name)"/>');</xsl:attribute>
						<img width="13" height="13" alt="" align="absmiddle"><xsl:attribute name="src">img/<xsl:choose><xsl:when test="$pExpand=0">plus</xsl:when><xsl:otherwise>minus</xsl:otherwise></xsl:choose>.gif</xsl:attribute><xsl:attribute name="id">imgsf_<xsl:value-of select="generate-id(@name)"/></xsl:attribute></img>
					</a>
				</td>
				<td width="16">
					<img width="16" height="16" align=""><xsl:attribute name="src">img/
						<xsl:choose>
							<xsl:when test="@filetype='Class'">Class</xsl:when>
							<xsl:when test="@filetype='Module'">Module</xsl:when>
							<xsl:when test="@filetype='Form'">Form</xsl:when>
							<xsl:when test="@filetype='Designer'">Designer</xsl:when>
							<xsl:when test="@filetype='UserControl'">UserControl</xsl:when>
							<xsl:when test="@filetype='PropertyPage'">PropertyPage</xsl:when>
							<xsl:otherwise>Unknown</xsl:otherwise>
						</xsl:choose>.gif</xsl:attribute>
					</img>				
				</td>
				<td width="571">
					<h4>
						<a>
							<xsl:attribute name="href">javascript:expandObject('sf_<xsl:value-of select="generate-id(@name)"/>');</xsl:attribute>
							<xsl:attribute name="title">Last change: <xsl:value-of select="concat(substring(@filelastchange,7,2),'-',substring(@filelastchange,5,2),'-',substring(@filelastchange,1,4),' ',substring(@filelastchange,10,2),':',substring(@filelastchange,13,2),':',substring(@filelastchange,16,2))"/>, code lines <xsl:value-of select="@codelines"/></xsl:attribute>
							<xsl:value-of select="@name"/>
						</a>
					</h4>
				</td>
			</tr>
			<tr>
				<xsl:attribute name="id">sf_<xsl:value-of select="generate-id(@name)"/></xsl:attribute>
				<xsl:attribute name="style">display:<xsl:choose><xsl:when test="$pExpand=0">none</xsl:when><xsl:otherwise>block</xsl:otherwise></xsl:choose></xsl:attribute>
				<td colspan="2">&#160;</td>
				<td>
					<xsl:if test="$pRemarksOnly=0">
						<xsl:choose>
							<xsl:when test="$pScope=''">
								<xsl:apply-templates select="Declare">
									<xsl:sort select="@type"/>
									<xsl:sort select="@scope"/>
									<xsl:sort select="."/>
								</xsl:apply-templates>
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates select="Declare[@scope=$pScope]">
									<xsl:sort select="@type"/>
									<xsl:sort select="@scope"/>
									<xsl:sort select="."/>
								</xsl:apply-templates>
							</xsl:otherwise>
						</xsl:choose>

						<xsl:if test="$pShowEnum!=0">
							<xsl:apply-templates select="Enum"><xsl:sort select="@name"/></xsl:apply-templates>
						</xsl:if>
				
						<xsl:if test="$pShowType!=0">
							<xsl:apply-templates select="Type"><xsl:sort select="@name"/></xsl:apply-templates>
						</xsl:if>
					</xsl:if>

					<xsl:if test="$pShowRemark!=0 or pRemarksOnly=1">
						<xsl:apply-templates select="Remarks"><xsl:sort select="Rem/@type"/></xsl:apply-templates>
					</xsl:if>
				</td>
			</tr>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="Declare">
		<img width="16" height="16" align=""><xsl:attribute name="src">img/<xsl:choose><xsl:when test="@type!=''"><xsl:value-of select="@type"/></xsl:when><xsl:otherwise>Unknown</xsl:otherwise></xsl:choose>.gif</xsl:attribute></img>&#160;<xsl:value-of select="."/><br/>
	</xsl:template>

	<xsl:template match="Enum">
		<img src="img/Enums.gif" width="16" height="16" align=""/>&#160;<xsl:value-of select="@name"/><br/>
		<blockquote class="Enum">
			<xsl:for-each select="Def">
				<img src="img/Enum.gif" width="16" height="16" align=""/><xsl:value-of select="." /><br/>
			</xsl:for-each>
		</blockquote>
	</xsl:template>

	<xsl:template match="Type">
		<img src="img/Type.gif" width="16" height="16" align=""/>&#160;<xsl:value-of select="@name"/><br/>
		<blockquote class="Type">
			<xsl:for-each select="Def">
				<img src="img/Property.gif" width="16" height="16" align=""/><xsl:value-of select="." /><br/>
			</xsl:for-each>
		</blockquote>
	</xsl:template>

	<xsl:template match="Remarks">
		<hr/>
		<img src="img/Remarks.gif" width="16" height="16" align=""/>&#160;<b>Remarks:</b><br/>
		<blockquote class="Remarks">
			<xsl:for-each select="Rem">
				<img src="img/Remark.gif" width="16" height="16" align=""/><xsl:value-of select="." /><br/>
			</xsl:for-each>
		</blockquote>
	</xsl:template>
	
	<xsl:template match="Reference">
		<xsl:value-of select="."/><br/>
	</xsl:template>

	<xsl:template match="Object">
		<tr>
			<td nowrap="true"><xsl:value-of select="@clsid"/></td>
			<td>:</td>
			<td><xsl:value-of select="."/></td>
		</tr>
	</xsl:template>
</xsl:stylesheet>