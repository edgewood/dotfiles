<xsl:stylesheet version = '1.0'
  xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
  xmlns:fn="http://edgewood.to/xmltv/functions"
  exclude-result-prefixes="fn"
  >

<xsl:output method="html" indent="yes"
  doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
  doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" 
  />

<xsl:variable name="xmltvFmt" select="'%Y%m%d%H%M%S %z'"/>
<xsl:variable name="startFmt" select="'%a %m/%d %I:%M %p'"/>
<xsl:variable name="endFmt" select="' - %I:%M'"/>

<xsl:variable name="xmltvPrevFmt" select="'%Y%m%d%H%M%S'"/>
<xsl:variable name="prevFmt" select="'%Y-%m-%d'"/>

<!-- keys -->
<xsl:key name="channel" match="/tv/channel" use="@id"/>
<xsl:key name="programs-by-name" match="programme" use="title[@lang = 'en']"/>

<xsl:template match="tv">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
  <title>Shows on TV</title>
  <meta http-equiv="Content-Type" content="text/html; charset=us-ascii"/>
  <link rel="stylesheet" href="dailylist.css" type="text/css"/>
</head>

<body lang="EN-US">
  <!--
    Use Muenchian Method to select unique programs by title:
    http://www.jenitennison.com/xslt/grouping/muenchian.html
  -->
  <xsl:for-each select="programme[generate-id() = generate-id(key('programs-by-name', title[@lang = 'en'])[1])]">
  <table width="100%">
    <!-- details common to all showings -->
    <tr>
      <td width="75%">
	<xsl:value-of select="title[@lang = 'en']"/>
	<xsl:if test="sub-title[@lang = 'en']">: <xsl:value-of select="sub-title[@lang = 'en']"/></xsl:if>
	<xsl:if test="episode-num[@system = 'onscreen']"> (Ep <xsl:value-of select="episode-num[@system = 'onscreen']"/>)</xsl:if>
      </td>
      <xsl:apply-templates select="previously-shown"/>
    </tr>
    <tr>
      <td colspan="2">
	<xsl:value-of select="desc[@lang = 'en']"/>
      </td>
    </tr>
    <!-- empty line (using &#160; for &nbsp;) -->
    <tr><td>&#160;</td></tr>
      <!-- per-showing details -->
      <xsl:for-each select="key('programs-by-name',title[@lang = 'en'])">
    <tr>
	<xsl:choose>
	  <xsl:when test="position() = 6">
	    <td>...</td>
	  </xsl:when>
	  <xsl:when test="position() > 6" />
	  <xsl:otherwise>
      <td><xsl:apply-templates select="key('channel', @channel)"/></td> 
      <td align="right">
    <!-- change start and end dates to preferred format before printing -->
	<xsl:value-of select="fn:change_format(string(@start), $xmltvFmt, $startFmt)"/>
	<xsl:value-of select="fn:change_format(string(@stop), $xmltvFmt, $endFmt)"/>
      </td>
	  </xsl:otherwise>
	</xsl:choose>
    </tr>
      </xsl:for-each>
      <!-- back to details common to all showings -->
  </table> 
  </xsl:for-each>
</body>
</html>
</xsl:template>

<xsl:template match="channel">
  <xsl:value-of select="display-name[1]"/>
</xsl:template>

<xsl:template match="previously-shown">
  <xsl:if test="string-length(@start) = string-length('YYYYMMDDHHMMSS')">
    <td align="right">
      <xsl:value-of select="fn:change_format(string(@start), $xmltvPrevFmt, $prevFmt)"/>
    </td>
  </xsl:if>
</xsl:template>

</xsl:stylesheet>
