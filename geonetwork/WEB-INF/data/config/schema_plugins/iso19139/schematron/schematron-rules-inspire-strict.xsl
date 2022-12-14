<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xsl:stylesheet xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:schold="http://www.ascc.net/xml/schematron"
                xmlns:gml="http://www.opengis.net/gml/3.2"
                xmlns:gml320="http://www.opengis.net/gml"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:srv="http://www.isotc211.org/2005/srv"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:geonet="http://www.fao.org/geonetwork"
                xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                version="2.0"><!--Implementers: please note that overriding process-prolog or process-root is
      the preferred method for meta-stylesheets to use where possible.
    -->
<xsl:param name="archiveDirParameter"/>
   <xsl:param name="archiveNameParameter"/>
   <xsl:param name="fileNameParameter"/>
   <xsl:param name="fileDirParameter"/>
   <xsl:variable name="document-uri">
      <xsl:value-of select="document-uri(/)"/>
   </xsl:variable>

   <!--PHASES-->


<!--PROLOG-->
<xsl:output xmlns:svrl="http://purl.oclc.org/dsdl/svrl" method="xml"
               omit-xml-declaration="no"
               standalone="yes"
               indent="yes"/>
   <xsl:include xmlns:svrl="http://purl.oclc.org/dsdl/svrl" href="../../../xsl/utils-fn.xsl"/>
   <xsl:param xmlns:svrl="http://purl.oclc.org/dsdl/svrl" name="lang"/>
   <xsl:param xmlns:svrl="http://purl.oclc.org/dsdl/svrl" name="thesaurusDir"/>
   <xsl:param xmlns:svrl="http://purl.oclc.org/dsdl/svrl" name="rule"/>
   <xsl:variable xmlns:svrl="http://purl.oclc.org/dsdl/svrl" name="loc"
                 select="document(concat('../loc/', $lang, '/', $rule, '.xml'))"/>

   <!--XSD TYPES FOR XSLT2-->


<!--KEYS AND FUNCTIONS-->


<!--DEFAULT RULES-->


<!--MODE: SCHEMATRON-SELECT-FULL-PATH-->
<!--This mode can be used to generate an ugly though full XPath for locators
    -->
<xsl:template match="*" mode="schematron-select-full-path">
      <xsl:apply-templates select="." mode="schematron-get-full-path"/>
   </xsl:template>

   <!--MODE: SCHEMATRON-FULL-PATH-->
<!--This mode can be used to generate an ugly though full XPath for locators
    -->
<xsl:template match="*" mode="schematron-get-full-path">
      <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
      <xsl:text>/</xsl:text>
      <xsl:choose>
         <xsl:when test="namespace-uri()=''">
            <xsl:value-of select="name()"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>*:</xsl:text>
            <xsl:value-of select="local-name()"/>
            <xsl:text>[namespace-uri()='</xsl:text>
            <xsl:value-of select="namespace-uri()"/>
            <xsl:text>']</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="preceding"
                    select="count(preceding-sibling::*[local-name()=local-name(current())                                      and namespace-uri() = namespace-uri(current())])"/>
      <xsl:text>[</xsl:text>
      <xsl:value-of select="1+ $preceding"/>
      <xsl:text>]</xsl:text>
   </xsl:template>
   <xsl:template match="@*" mode="schematron-get-full-path">
      <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
      <xsl:text>/</xsl:text>
      <xsl:choose>
         <xsl:when test="namespace-uri()=''">@
              <xsl:value-of select="name()"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>@*[local-name()='</xsl:text>
            <xsl:value-of select="local-name()"/>
            <xsl:text>' and namespace-uri()='</xsl:text>
            <xsl:value-of select="namespace-uri()"/>
            <xsl:text>']</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <!--MODE: SCHEMATRON-FULL-PATH-2-->
<!--This mode can be used to generate prefixed XPath for humans-->
<xsl:template match="node() | @*" mode="schematron-get-full-path-2">
      <xsl:for-each select="ancestor-or-self::*">
         <xsl:text>/</xsl:text>
         <xsl:value-of select="name(.)"/>
         <xsl:if test="preceding-sibling::*[name(.)=name(current())]">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
            <xsl:text>]</xsl:text>
         </xsl:if>
      </xsl:for-each>
      <xsl:if test="not(self::*)">
         <xsl:text/>/@
        <xsl:value-of select="name(.)"/>
      </xsl:if>
   </xsl:template>
   <!--MODE: SCHEMATRON-FULL-PATH-3-->
<!--This mode can be used to generate prefixed XPath for humans
      (Top-level element has index)
    -->
<xsl:template match="node() | @*" mode="schematron-get-full-path-3">
      <xsl:for-each select="ancestor-or-self::*">
         <xsl:text>/</xsl:text>
         <xsl:value-of select="name(.)"/>
         <xsl:if test="parent::*">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
            <xsl:text>]</xsl:text>
         </xsl:if>
      </xsl:for-each>
      <xsl:if test="not(self::*)">
         <xsl:text/>/@
        <xsl:value-of select="name(.)"/>
      </xsl:if>
   </xsl:template>

   <!--MODE: GENERATE-ID-FROM-PATH-->
<xsl:template match="/" mode="generate-id-from-path"/>
   <xsl:template match="text()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.text-', 1+count(preceding-sibling::text()), '-')"/>
   </xsl:template>
   <xsl:template match="comment()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.comment-', 1+count(preceding-sibling::comment()), '-')"/>
   </xsl:template>
   <xsl:template match="processing-instruction()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.processing-instruction-', 1+count(preceding-sibling::processing-instruction()), '-')"/>
   </xsl:template>
   <xsl:template match="@*" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.@', name())"/>
   </xsl:template>
   <xsl:template match="*" mode="generate-id-from-path" priority="-0.5">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:text>.</xsl:text>
      <xsl:value-of select="concat('.',name(),'-',1+count(preceding-sibling::*[name()=name(current())]),'-')"/>
   </xsl:template>

   <!--MODE: GENERATE-ID-2-->
<xsl:template match="/" mode="generate-id-2">U</xsl:template>
   <xsl:template match="*" mode="generate-id-2" priority="2">
      <xsl:text>U</xsl:text>
      <xsl:number level="multiple" count="*"/>
   </xsl:template>
   <xsl:template match="node()" mode="generate-id-2">
      <xsl:text>U.</xsl:text>
      <xsl:number level="multiple" count="*"/>
      <xsl:text>n</xsl:text>
      <xsl:number count="node()"/>
   </xsl:template>
   <xsl:template match="@*" mode="generate-id-2">
      <xsl:text>U.</xsl:text>
      <xsl:number level="multiple" count="*"/>
      <xsl:text>_</xsl:text>
      <xsl:value-of select="string-length(local-name(.))"/>
      <xsl:text>_</xsl:text>
      <xsl:value-of select="translate(name(),':','.')"/>
   </xsl:template>
   <!--Strip characters--><xsl:template match="text()" priority="-1"/>

   <!--SCHEMA SETUP-->
<xsl:template match="/">
      <svrl:schematron-output xmlns:svrl="http://purl.oclc.org/dsdl/svrl" title="INSPIRE Strict rules"
                              schemaVersion="">
         <xsl:comment>
            <xsl:value-of select="$archiveDirParameter"/>
        ??
        <xsl:value-of select="$archiveNameParameter"/>
        ??
        <xsl:value-of select="$fileNameParameter"/>
        ??
        <xsl:value-of select="$fileDirParameter"/>
         </xsl:comment>
         <svrl:ns-prefix-in-attribute-values uri="http://www.opengis.net/gml/3.2" prefix="gml"/>
         <svrl:ns-prefix-in-attribute-values uri="http://www.opengis.net/gml" prefix="gml320"/>
         <svrl:ns-prefix-in-attribute-values uri="http://www.isotc211.org/2005/gmd" prefix="gmd"/>
         <svrl:ns-prefix-in-attribute-values uri="http://www.isotc211.org/2005/gmx" prefix="gmx"/>
         <svrl:ns-prefix-in-attribute-values uri="http://www.isotc211.org/2005/srv" prefix="srv"/>
         <svrl:ns-prefix-in-attribute-values uri="http://www.isotc211.org/2005/gco" prefix="gco"/>
         <svrl:ns-prefix-in-attribute-values uri="http://www.fao.org/geonetwork" prefix="geonet"/>
         <svrl:ns-prefix-in-attribute-values uri="http://www.w3.org/2004/02/skos/core#" prefix="skos"/>
         <svrl:ns-prefix-in-attribute-values uri="http://www.w3.org/1999/xlink" prefix="xlink"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="name">
               <xsl:value-of select="$loc/strings/conformity"/>
            </xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M10"/>
      </svrl:schematron-output>
   </xsl:template>

   <!--SCHEMATRON PATTERNS-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">INSPIRE Strict rules</svrl:text>

   <!--PATTERN
        $loc/strings/conformity-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
      <xsl:copy-of select="$loc/strings/conformity"/>
   </svrl:text>

  <!--RULE
      -->
<xsl:template match="//gmd:dataQualityInfo/*[name() != 'geonet:element']" priority="1000"
                 mode="M10">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//gmd:dataQualityInfo/*[name() != 'geonet:element']"/>
      <xsl:variable name="lang"
                    select="normalize-space(/*/gmd:language/gco:CharacterString|/*/gmd:language/gmd:LanguageCode/@codeListValue)"/>
      <xsl:variable name="langCodeMap">
                <ger xmlns:sch="http://purl.oclc.org/dsdl/schematron">#DE</ger>
                <eng xmlns:sch="http://purl.oclc.org/dsdl/schematron">#EN</eng>
                <fre xmlns:sch="http://purl.oclc.org/dsdl/schematron">#FR</fre>
                <ita xmlns:sch="http://purl.oclc.org/dsdl/schematron">#IT</ita>
                <spa xmlns:sch="http://purl.oclc.org/dsdl/schematron">#ES</spa>
                <fin xmlns:sch="http://purl.oclc.org/dsdl/schematron">#FI</fin>
                <dut xmlns:sch="http://purl.oclc.org/dsdl/schematron">#NL</dut>
            </xsl:variable>
      <xsl:variable name="langCode" select="normalize-space($langCodeMap//*[name() = $lang])"/>
      <xsl:variable name="specification_title"
                    select="gmd:report/*/gmd:result/*/gmd:specification/*/gmd:title//text()[(string-length(.) &gt; 0) and (../name() = 'gco:CharacterString' or ../@locale = $langCode)]"/>
      <xsl:variable name="has_specification_title" select="count($specification_title) &gt; 0"/>
      <xsl:variable name="allTitles">
                <titles xmlns:sch="http://purl.oclc.org/dsdl/schematron">
                    <ger>verordnung (eg) nr. 1089/2010 der kommission vom 23. november 2010 zur durchf??hrung der richtlinie 2007/2/eg des europ??ischen parlaments und des rates hinsichtlich der interoperabilit??t von geodatens??tzen und -diensten</ger>
                    <eng>commission regulation (eu) no 1089/2010 of 23 november 2010 implementing directive 2007/2/ec of the european parliament and of the council as regards interoperability of spatial data sets and services</eng>
                    <fre>r??glement (ue) n o 1089/2010 de la commission du 23 novembre 2010 portant modalit??s d'application de la directive 2007/2/ce du parlement europ??en et du conseil en ce qui concerne l'interop??rabilit?? des s??ries et des services de donn??es g??ographiques</fre>
                    <ita>regolamento (ue) n . 1089/2010 della commissione del 23 novembre 2010 recante attuazione della direttiva 2007/2/ce del parlamento europeo e del consiglio per quanto riguarda l'interoperabilit?? dei set di dati territoriali e dei servizi di dati territoriali</ita>
                    <spa>reglamento (ue) n o 1089/2010 de la comisi??n de 23 de noviembre de 2010 por el que se aplica la directiva 2007/2/ce del parlamento europeo y del consejo en lo que se refiere a la interoperabilidad de los conjuntos y los servicios de datos espaciales</spa>
                    <fin>komission asetus (eu) n:o 1089/2010, annettu 23 p??iv??n?? marraskuuta 2010 , euroopan parlamentin ja neuvoston direktiivin 2007/2/ey t??yt??nt????npanosta paikkatietoaineistojen ja -palvelujen yhteentoimivuuden osalta</fin>
                    <dut>verordening (eu) n r. 1089/2010 van de commissie van 23 november 2010 ter uitvoering van richtlijn 2007/2/eg van het europees parlement en de raad betreffende de interoperabiliteit van verzamelingen ruimtelijke gegevens en van diensten met betrekking tot ruimtelijke gegevens</dut>
                </titles>
            </xsl:variable>
      <xsl:variable name="isDeMetadata" select="$lang = 'ger'"/>
      <xsl:variable name="isEnMetadata" select="$lang = 'eng'"/>
      <xsl:variable name="isFrMetadata" select="$lang = 'fre'"/>
      <xsl:variable name="isItMetadata" select="$lang = 'ita'"/>
      <xsl:variable name="isEsMetadata" select="$lang = 'spa'"/>
      <xsl:variable name="isFiMetadata" select="$lang = 'fin'"/>
      <xsl:variable name="isNlMetadata" select="$lang = 'dut'"/>
      <xsl:variable name="specification_inspire"
                    select="gmd:report/*/gmd:result/*/gmd:specification[                 ($isDeMetadata and (lower-case(normalize-space(*/gmd:title//text()[(string-length(.) &gt; 0) and (../name() = 'gco:CharacterString')]))  = $allTitles//ger/text()) or (lower-case(normalize-space(*/gmd:title//text()[(string-length(.) &gt; 0) and (../@locale = $langCode)]))  = $allTitles//ger/text())) or                 ($isEnMetadata and (lower-case(normalize-space(*/gmd:title//text()[(string-length(.) &gt; 0) and (../name() = 'gco:CharacterString')]))  = $allTitles//eng/text()) or (lower-case(normalize-space(*/gmd:title//text()[(string-length(.) &gt; 0) and (../@locale = $langCode)]))  = $allTitles//eng/text())) or                 ($isFrMetadata and (lower-case(normalize-space(*/gmd:title//text()[(string-length(.) &gt; 0) and (../name() = 'gco:CharacterString')]))  = $allTitles//fre/text()) or (lower-case(normalize-space(*/gmd:title//text()[(string-length(.) &gt; 0) and (../@locale = $langCode)]))  = $allTitles//fre/text())) or                 ($isItMetadata and (lower-case(normalize-space(*/gmd:title//text()[(string-length(.) &gt; 0) and (../name() = 'gco:CharacterString')]))  = $allTitles//ita/text()) or (lower-case(normalize-space(*/gmd:title//text()[(string-length(.) &gt; 0) and (../@locale = $langCode)]))  = $allTitles//ita/text())) or                 ($isEsMetadata and (lower-case(normalize-space(*/gmd:title//text()[(string-length(.) &gt; 0) and (../name() = 'gco:CharacterString')]))  = $allTitles//spa/text()) or (lower-case(normalize-space(*/gmd:title//text()[(string-length(.) &gt; 0) and (../@locale = $langCode)]))  = $allTitles//spa/text())) or                 ($isFiMetadata and (lower-case(normalize-space(*/gmd:title//text()[(string-length(.) &gt; 0) and (../name() = 'gco:CharacterString')]))  = $allTitles//fin/text()) or (lower-case(normalize-space(*/gmd:title//text()[(string-length(.) &gt; 0) and (../@locale = $langCode)]))  = $allTitles//fin/text())) or                 ($isNlMetadata and (lower-case(normalize-space(*/gmd:title//text()[(string-length(.) &gt; 0) and (../name() = 'gco:CharacterString')]))  = $allTitles//dut/text()) or (lower-case(normalize-space(*/gmd:title//text()[(string-length(.) &gt; 0) and (../@locale = $langCode)]))  = $allTitles//dut/text()))                 ]"/>
      <xsl:variable name="degree" select="$specification_inspire/../gmd:pass/*/text()"/>
      <xsl:variable name="correctTitle" select="$allTitles//*[name() = $lang]/text()"/>

      <!--ASSERT
      -->
<xsl:choose>
         <xsl:when test="count($specification_inspire) &gt; 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="count($specification_inspire) &gt; 0">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:copy-of select="$loc/strings/assert.M44.conformityActual/div"/>
                  <xsl:text/>

                  <xsl:text/>
                  <xsl:copy-of select="concat('''', normalize-space($specification_title[1]), '''')"/>
                  <xsl:text/>

                  <xsl:text/>
                  <xsl:copy-of select="$loc/strings/assert.M44.conformityExpected/div"/>
                  <xsl:text/>

                  <xsl:text/>
                  <xsl:copy-of select="concat('''', $correctTitle, '''')"/>
                  <xsl:text/>

               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

      <!--ASSERT
      -->
<xsl:choose>
         <xsl:when test="$has_specification_title"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="$has_specification_title">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:copy-of select="$loc/strings/assert.M44.title/div"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="specification_date"
                    select="$specification_inspire/*/gmd:date/*/gmd:date/*/text()[string-length(.) &gt; 0]"/>
      <xsl:variable name="specification_dateType"
                    select="normalize-space($specification_inspire/*/gmd:date/*/gmd:dateType/*/@codeListValue)"/>

      <!--ASSERT
      -->
<xsl:choose>
         <xsl:when test="not($specification_inspire) or ($specification_date and $specification_dateType)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="not($specification_inspire) or ($specification_date and $specification_dateType)">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:copy-of select="$loc/strings/assert.M44.date/div"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

      <!--REPORT
      -->
<xsl:if test="$has_specification_title">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 test="$has_specification_title">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                <xsl:text/>
               <xsl:copy-of select="$loc/strings/report.M44.spec/div"/>
               <xsl:text/>
                <xsl:text/>
               <xsl:copy-of select="$has_specification_title"/>
               <xsl:text/>, (<xsl:text/>
               <xsl:copy-of select="$specification_date"/>
               <xsl:text/>, <xsl:text/>
               <xsl:copy-of select="$specification_dateType"/>
               <xsl:text/>)
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

      <!--REPORT
      -->
<xsl:if test="$degree">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 test="$degree">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                <xsl:text/>
               <xsl:copy-of select="$loc/strings/report.M44.degree/div"/>
               <xsl:text/>
                <xsl:text/>
               <xsl:copy-of select="$degree"/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M10"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M10"/>
   <xsl:template match="@*|node()" priority="-2" mode="M10">
      <xsl:apply-templates select="*" mode="M10"/>
   </xsl:template>
</xsl:stylesheet>