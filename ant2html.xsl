<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="html" indent="no" omit-xml-declaration="yes" encoding="UTF-8"/>

<xsl:param name="frames"/>
<xsl:param name="content"/>

<xsl:template match="/">
  <html>
    <xsl:comment>XSLT stylesheet used to transform this file:  ant2html.xsl</xsl:comment>

    <!--                                                                    -->
    <!-- Generate the JavaScript routines used to produce the content of    -->
    <!-- each frame.                                                        -->
    <!--                                                                    -->
    <script type="text/javascript">
      function loadFrames() {
        processor = getProcessorFromFiles(window.location.pathname, 'ant2html.xsl');
        if (processor) {
          loadFrame(processor, "tocFrame");

          processor.reset();
          processor.addParameter('content', 'targets');
          loadFrame(processor, "navFrame");

          processor.reset();
          loadFrame(processor, "mainFrame");
        }
      }

      function loadNavFrame(content) {
        processor = getProcessorFromFiles(window.location.pathname, 'ant2html.xsl');
        if (processor) {
          processor.addParameter('content', content);
          loadFrame(processor, "navFrame");
        }
      }

      function loadFrame(processor, fname) {
        try {
          processor.addParameter('frames', fname);
          processor.transform();

        } catch (exception) {
          alert('Error transforming XML:\n' + exception.description);
        }

        frame = window.parent.frames[fname];
        frame.document.open();
        frame.document.write(processor.output);
        frame.document.close();
      }

      function explainParseError(error) {
        return error.reason + '[' + error.url + ': line ' + error.line +
               ', col ' + error.linepos + ']';
      }

      function getEmptyDOM() {
        DOM = new ActiveXObject('Msxml2.FreeThreadedDOMDocument');
        DOM.async = false;
        DOM.validateOnParse = false;
        DOM.preserveWhiteSpace = true;

        return DOM;
      }

      function getDOMFromFile(File) {
        DOM = getEmptyDOM();
        DOM.load(File);
        if (DOM.parseError.errorCode != 0) {
          alert('Error parsing file:\n' + explainParseError(DOM.parseError));
        }

        return DOM;
      }

      function getDOMFromXML(XML) {
        DOM = getEmptyDOM();
        DOM.loadXML(XML);
        if (DOM.parseError.errorCode != 0) {
          alert('Error parsing XML:\n' + explainParseError(DOM.parseError));
        }

        return DOM;
      }

      function getProcessorFromDOMs(XMLDOM, XSLTDOM) {
        try {
          template = new ActiveXObject('Msxml2.XSLTemplate');
          template.stylesheet = XSLTDOM;

          processor = template.createProcessor();
          processor.input = XMLDOM;

          return processor;

        } catch (exception) {
          alert('Error creating processor:\n' + exception.description);
          return;
        }
      }

      function getProcessorFromFiles(XMLFile, XSLFile) {
        XMLDOM = getDOMFromFile(XMLFile);
        if (XMLDOM) {
          XSLTDOM = getDOMFromFile(XSLFile);
          if (XSLTDOM) {
            return getProcessorFromDOMs(XMLDOM, XSLTDOM);
          }
        }
      }
    </script>

  <xsl:choose>
  <xsl:when test="$frames=''">
    <!--                                                                    -->
    <!-- Create the set of frames used to navigate the Ant script.          -->
    <!--                                                                    -->
    <head>
    <title>Ant Project Source: <xsl:value-of select="/project/@name"/></title>
    </head>

    <frameset onload="loadFrames()" cols="25%,75%">
      <frameset rows="30%, 70%">
        <frame name="tocFrame"/>
        <frame name="navFrame"/>
      </frameset>
      <frame name="mainFrame"/>
    </frameset>
  </xsl:when>

  <!--                                                                      -->
  <!-- Generate the contents for the navigator frame.                       -->
  <!--                                                                      -->
  <xsl:when test="$frames='tocFrame'">
    <h2><xsl:value-of select="/project/@name"/> Ant Build Project</h2>
    <b><big><a href="#project" target="mainFrame">Attributes</a></big></b><br/>
    <b><big><a href="#properties" target="navFrame" onClick="loadNavFrame('properties')">Properties</a></big></b><br/>
    <b><big><a href="#targets" target="navFrame" onClick="loadNavFrame('targets')">Targets</a></big></b><br/>
  </xsl:when>

  <!--                                                                      -->
  <!-- Generate the contents for the navigator frame.                       -->
  <!--                                                                      -->
  <xsl:when test="$frames='navFrame'">
    <xsl:choose>
      <xsl:when test="$content='properties'">
        <h3><a href="#properties" target="mainFrame">Global properties</a></h3>

        <!-- Generate each property -->
        <xsl:for-each select="/project/property/@name">
          <xsl:sort/>
          <xsl:variable name="propName" select="."/>
          <xsl:text disable-output-escaping="yes">&amp;nbsp;&amp;nbsp;&amp;nbsp;</xsl:text>
          <xsl:element name="a">
            <xsl:attribute name="href">
              <xsl:value-of select="concat('#property-',$propName)"/>
            </xsl:attribute>
            <xsl:attribute name="target">mainFrame</xsl:attribute>
            <xsl:value-of select="$propName"/>
          </xsl:element>
          <br/>
        </xsl:for-each>
      </xsl:when>

      <xsl:when test="$content='targets'">
        <!-- Generate each target -->
        <h3><a href="#targets" target="mainFrame">All targets</a></h3>
        <xsl:for-each select="/project/target">
          <xsl:sort select="@name"/>
          <xsl:variable name="tarName" select="@name"/>
          <xsl:text disable-output-escaping="yes">&amp;nbsp;&amp;nbsp;&amp;nbsp;</xsl:text>
          <xsl:element name="a">
            <xsl:attribute name="href">
              <xsl:value-of select="concat('#target-',$tarName)"/>
            </xsl:attribute>
            <xsl:attribute name="target">mainFrame</xsl:attribute>
            <xsl:value-of select="$tarName"/>
          </xsl:element>
          <br/>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
  </xsl:when>

  <!--                                                                      -->
  <!-- Generate the contents of the main frame.                             -->
  <!--                                                                      -->
  <xsl:when test="$frames='mainFrame'">
    <!-- Begin project data -->
    <table border="0" cellspacing="0" cellpadding="5">
      <tr>
        <td colspan="3">
          <a name="project"/>
          <b><big>Project Attributes</big></b>
        </td>
      </tr>
      <tr>
        <td width="5%"/>
        <td valign="BOTTOM" width="25%">
          <b>Name:</b>
        </td>
        <td valign="BOTTOM" width="70%">
          <xsl:value-of select="/project/@name"/>
        </td>
      </tr>
      <tr>
        <td width="5%"/>
        <td valign="BOTTOM" width="25%">
          <b>Base directory:</b>
        </td>
        <td valign="BOTTOM" width="70%">
          <xsl:choose>
            <xsl:when test="/project/@basedir='.'">
              <i>current-working-directory</i>
            </xsl:when>

            <xsl:otherwise>
              <xsl:value-of select="/project/@basedir"/>
            </xsl:otherwise>
          </xsl:choose>
        </td>
      </tr>
      <tr>
        <td width="5%"/>
        <td valign="BOTTOM" width="25%">
          <b>Default target:</b>
        </td>
        <td valign="BOTTOM" width="70%">
          <xsl:call-template name="formatTargetList">
            <xsl:with-param name="targets" select="/project/@default"/>
          </xsl:call-template>
        </td>
      </tr>
    </table>
    <hr/>

    <!-- Begin property data -->
    <table border="0" cellspacing="0" cellpadding="5">
      <tr>
        <td colspan="3">
          <a name="properties"/>
          <b><big><a href="#toc" target="navFrame">Project Properties</a></big></b>
        </td>
      </tr>

      <xsl:variable name="propertyList" select="/project/property"/>
      <xsl:for-each select="/project/property/@name">
        <xsl:sort/>
        <tr>
          <td width="5%"/>
          <td valign="TOP" width="25%">
            <xsl:element name="a">
              <xsl:attribute name="name">
                <xsl:text>property-</xsl:text><xsl:value-of select="."/>
              </xsl:attribute>
            </xsl:element>
            <b><xsl:value-of select="."/></b>
          </td>

          <td valign="TOP" width="70%">
            <xsl:variable name="value">
              <xsl:choose>
                <xsl:when test="count(../@location) > 0">
                  <xsl:value-of select="../@location"/>
                </xsl:when>

                <xsl:when test="count(../@value) > 0">
                  <xsl:value-of select="../@value"/>
                </xsl:when>
              </xsl:choose>
            </xsl:variable>

            <xsl:value-of select="$value"/>
            <xsl:if test="contains($value, '${')">
              <br/>
              <xsl:element name="ins">
              <xsl:call-template name="expandProperty">
                <xsl:with-param name="list"  select="$propertyList"/>
                <xsl:with-param name="value" select="$value"/>
              </xsl:call-template>
              </xsl:element>
            </xsl:if>
          </td>
        </tr>
      </xsl:for-each>
    </table>
    <hr/>

    <!-- Begin target data -->
    <table border="0" cellspacing="0" cellpadding="5">
      <tr>
        <td colspan="3">
          <a name="targets"/>
          <b><big><a href="#toc" target="navFrame">Targets</a></big></b>
        </td>
      </tr>

      <xsl:for-each select="/project/target">
        <xsl:sort select="@name"/>
        <tr>
          <td width="5%"/>
          <td valign="BOTTOM" width="25%">
            <xsl:element name="a">
              <xsl:attribute name="name">
                <xsl:text>target-</xsl:text><xsl:value-of select="@name"/>
              </xsl:attribute>
            </xsl:element>
            <b>Target:</b>
          </td>
          <td valign="BOTTOM" width="70%">
            <xsl:value-of select="@name"/>
          </td>
        </tr>

        <xsl:if test="count(./@description) > 0">
          <tr>
            <td width="5%"/>
            <td valign="TOP" width="25%">
              <b>Description:</b>
            </td>
            <td valign="TOP" width="70%">
              <xsl:value-of select="@description"/>
            </td>
          </tr>
        </xsl:if>

        <xsl:if test="count(./@depends) > 0">
          <tr>
            <td width="5%"/>
            <td valign="TOP" width="25%">
              <b>Dependencies:</b>
            </td>
            <td valign="TOP" width="70%">
              <xsl:call-template name="formatTargetList">
                <xsl:with-param name="targets" select="@depends"/>
              </xsl:call-template>
            </td>
          </tr>
        </xsl:if>

        <tr>
          <td width="5%"/>
          <td valign="TOP" width="25%">
            <b>Tasks:</b>
          </td>
          <td valign="TOP" width="70%">
            <div style="border: 1px #003366;border-style:dashed;">
            <pre><code>
            <xsl:choose>
              <xsl:when test="count(child::*) > 0">
                <xsl:apply-templates select="child::node()"/>
              </xsl:when>

              <xsl:otherwise>
                <xsl:text>None</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
            </code></pre>
            </div>
          </td>
        </tr>

        <xsl:if test="position() &lt; last()">
          <tr><td colspan="3"><hr/></td></tr>
        </xsl:if>
      </xsl:for-each>
    </table>
  </xsl:when>
  </xsl:choose>
  </html>
</xsl:template>

  <!--
    =========================================================================
      Purpose:  Copy each node and attribute, exactly as found, to the output
                tree.
    =========================================================================
  -->
  <xsl:template match="node()" name="writeTask">
    <xsl:param    name="indent"   select="string('')"/>
    <xsl:variable name="nodeName" select="name(.)"/>

    <xsl:if test="not($nodeName = '')">
<pre><xsl:value-of select="$indent"/>&lt;<xsl:value-of select="$nodeName"/>
      <xsl:if test="count(@*) > 0">
        <xsl:for-each select="@*">
          <xsl:choose>
            <xsl:when test="position() = 1">
              <xsl:value-of select="concat(' ', name(),'=&quot;')"/>
            </xsl:when>

            <xsl:otherwise>
              <xsl:value-of select="'&#10;'"/>
              <xsl:value-of select="concat(translate(name(..), name(..), '                     '),
                   '  ', $indent, name(), '=&quot;')"/>
            </xsl:otherwise>
          </xsl:choose>

          <xsl:call-template name="formatTaskAttributeValue">
            <xsl:with-param name="value" select="."/>
          </xsl:call-template>
          <xsl:value-of select="'&quot;'"/>

          <xsl:if test="position() = last()">
            <xsl:choose>
              <xsl:when test="count(../*) > 0">&gt;</xsl:when>
              <xsl:otherwise>/&gt;</xsl:otherwise>
            </xsl:choose>
          </xsl:if>
        </xsl:for-each>
      </xsl:if>

      <xsl:for-each select="child::node()">
        <xsl:call-template name="writeTask">
          <xsl:with-param name="indent" select="concat($indent, '  ')"/>
        </xsl:call-template>
      </xsl:for-each>

<xsl:value-of select="$indent"/><xsl:if test="count(child::node()) > 0">&lt;/<xsl:value-of select="$nodeName"/>&gt;</xsl:if></pre>

    </xsl:if>
  </xsl:template>

  <!--
    =========================================================================
      Purpose:  Ignore comments imbedded into the text.
    =========================================================================
  -->
  <xsl:template match="comment()"/>

  <!--
    =========================================================================
      Purpose:  Format a list of target names as references.
    =========================================================================
  -->
  <xsl:template name="formatTargetList">
    <xsl:param    name="targets" select="string('')"/>

    <xsl:variable name="list"    select="normalize-space($targets)"/>
    <xsl:variable name="first"   select="normalize-space(substring-before($targets,','))"/>
    <xsl:variable name="rest"    select="normalize-space(substring-after($targets,','))"/>

    <xsl:if test="not($list = '')">
      <xsl:choose>
        <xsl:when test="contains($list, ',')">
          <xsl:element name="a">
            <xsl:attribute name="href">
              <xsl:value-of select="concat('#target-', $first)"/>
            </xsl:attribute>
            <xsl:attribute name="target">mainFrame</xsl:attribute>
            <xsl:value-of select="$first"/>
          </xsl:element>

          <xsl:text>, </xsl:text>

          <xsl:call-template name="formatTargetList">
            <xsl:with-param name="targets" select="$rest"/>
          </xsl:call-template>
        </xsl:when>

        <xsl:otherwise>
          <xsl:element name="a">
            <xsl:attribute name="href">
              <xsl:value-of select="concat('#target-', $list)"/>
            </xsl:attribute>
            <xsl:attribute name="target">mainFrame</xsl:attribute>
            <xsl:value-of select="$list"/>
          </xsl:element>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <!--
    =========================================================================
      Purpose:  Expand an Ant property.
    =========================================================================
  -->
  <xsl:template name="expandProperty">
    <xsl:param    name="list"/>
    <xsl:param    name="value"/>

    <xsl:choose>
      <xsl:when test="contains($value, '${')">
        <xsl:variable name="first" select="normalize-space(substring-before($value,'${'))"/>
        <xsl:variable name="temp"  select="normalize-space(substring-after($value,'${'))"/>
        <xsl:variable name="pname" select="normalize-space(substring-before($temp,'}'))"/>
        <xsl:variable name="rest"  select="normalize-space(substring-after($temp,'}'))"/>

        <xsl:value-of select="$first"/>

        <xsl:if test="not($pname = '')">
          <xsl:variable name="prop" select="$list[@name=$pname]"/>
          <xsl:choose>
            <xsl:when test="$pname='basedir'">
              <xsl:value-of select="/project/@basedir"/>

              <xsl:call-template name="expandProperty">
                <xsl:with-param name="list"  select="$list"/>
                <xsl:with-param name="value" select="$rest"/>
              </xsl:call-template>
            </xsl:when>

            <xsl:when test="count($prop) > 0">
              <xsl:variable name="pvalue">
                <xsl:choose>
                  <xsl:when test="count($prop/@location) > 0">
                    <xsl:value-of select="$prop/@location"/>
                  </xsl:when>

                  <xsl:when test="count($prop/@value) > 0">
                    <xsl:value-of select="$prop/@value"/>
                  </xsl:when>
                </xsl:choose>
              </xsl:variable>

              <xsl:call-template name="expandProperty">
                <xsl:with-param name="list"  select="$list"/>
                <xsl:with-param name="value" select="$pvalue"/>
              </xsl:call-template>
            </xsl:when>

            <xsl:otherwise>
              <xsl:value-of select="concat('${', $pname, '}')"/>
            </xsl:otherwise>
          </xsl:choose>

          <xsl:call-template name="expandProperty">
            <xsl:with-param name="list"  select="$list"/>
            <xsl:with-param name="value" select="$rest"/>
          </xsl:call-template>
        </xsl:if>
      </xsl:when>

      <xsl:otherwise>
        <xsl:value-of select="$value"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    =========================================================================
      Purpose:  Format a task attribute's value.
    =========================================================================
  -->
  <xsl:template name="formatTaskAttributeValue">
    <xsl:param    name="value"/>

    <xsl:variable name="propertyList" select="/project/property"/>

    <xsl:variable name="expandedValue">
      <xsl:call-template name="expandProperty">
        <xsl:with-param name="list"  select="$propertyList"/>
        <xsl:with-param name="value" select="$value"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="contains($value, '${')">
        <xsl:variable name="squote">'</xsl:variable>
        <xsl:element name="ins">
          <xsl:attribute name="onMouseOver">
            javascript:window.status='<xsl:value-of select="$value"/>'
          </xsl:attribute>
          <xsl:value-of select="$expandedValue"/>
        </xsl:element>
      </xsl:when>

      <xsl:otherwise>
        <xsl:value-of select="$expandedValue"/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>
</xsl:stylesheet>
