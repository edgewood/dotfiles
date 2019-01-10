<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <!-- Adapted from http://stackoverflow.com/q/6747817 -->
  <xsl:output omit-xml-declaration="no" indent="yes" doctype-system="file:///usr/share/xmltv/xmltv.dtd"/>

  <!-- The identity template copies every node as-is -->
  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>

  <!--
    This template overrides the identity template when the previous programme
    has the same title and start time as the current one.
    An empty template body means that the duplicate programme is discarded.
  <xsl:template match="programme[position() >1]"/>
  -->
  <xsl:template 
    match="programme[title = preceding-sibling::programme[1]/title and @start = preceding-sibling::programme[1]/@start]"
  />

  <!--
    Adding the xmltv.dtd as the system doctype adds all the default values.
    That's not desired, so discard attributes if they have the xmltv.dvd default.
  -->
  <!-- clumpidx default is '0/1' -->
  <xsl:template match="@clumpidx">
    <xsl:if test=". != '0/1'">
      <xsl:copy>
	<xsl:apply-templates select="node()|@*"/>
      </xsl:copy>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
