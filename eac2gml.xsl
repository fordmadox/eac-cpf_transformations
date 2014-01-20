<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs xlink" version="2.0">
    <xsl:output method="xml" encoding="UTF-8"/>

    <!--
        Copyright 2014 Timothy A. Thompson        
        EAC-CPF Transformations: https://github.com/Timathom/eac-cpf_transformations
        Licensed under the Educational Community License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://opensource.org/licenses/ECL-2.0 http://www.osedu.org/licenses/ECL-2.0 Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
    -->

    <!--
        eac2gml.xsl takes an XML list of EAC-CPF (Encoded Archival Context-Corporate Bodies, Persons, Familes) files and outputs a GML (Graph Modeling Language)-formatted representation of the graph of relationships among <nameEntry> and <cpfRelation> elements across the dataset.                                                   
    -->

    <xsl:strip-space elements="*"/>

    <xsl:variable name="apos">'</xsl:variable>
    <xsl:variable name="quot">"</xsl:variable>
    
    <xsl:param name="URI">true</xsl:param>

    <xsl:key name="listKey" match="item" use="@name"/>
    <xsl:key name="listKeyUri" match="item" use="@uri"/>

    <xsl:variable name="elements">
        <xsl:for-each select="eacFiles/eacFile">
            <xsl:for-each select="document(@filename)/eac-cpf//nameEntry[1]"
                xpath-default-namespace="urn:isbn:1-931666-33-4">
                <entry>
                    <xsl:choose>
                        <xsl:when test="$URI='true'">
                            <xsl:choose>
                                <xsl:when test="count(part)=1">
                                    <name>
                                        <xsl:value-of select="concat(normalize-space(part),'|',//otherRecordId[.!=''])"/>
                                    </name>
                                </xsl:when>
                                <xsl:when test="count(part)&gt;1">
                                    <name uri="{//recordId[.!='']}">                                        
                                        <xsl:for-each select="part">                                            
                                            <xsl:choose>
                                                <xsl:when test="position()!=last()">
                                                    <xsl:value-of select="."/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="concat(normalize-space(.),'|',//otherRecordId[.!=''])"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:for-each>
                                    </name>
                                </xsl:when>        
                            </xsl:choose>                            
                            <xsl:for-each select="//cpfRelation/relationEntry[.!='']">
                                <relation>
                                    <xsl:value-of select="concat(normalize-space(.),'|',normalize-space(../@xlink:href))"/>
                                </relation>
                            </xsl:for-each>
                        </xsl:when>                        
                        <xsl:otherwise>
                            <xsl:choose>
                                <xsl:when test="count(part)=1">
                                    <name>
                                        <xsl:value-of select="normalize-space(part)"/>
                                    </name>
                                </xsl:when>
                                <xsl:when test="count(part)&gt;1">
                                    <name>                                        
                                        <xsl:for-each select="part">                                            
                                            <xsl:choose>
                                                <xsl:when test="position()!=last()">
                                                    <xsl:value-of select="."/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="normalize-space(.)"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:for-each>
                                    </name>
                                </xsl:when>        
                            </xsl:choose>
                            <xsl:for-each select="//cpfRelation/relationEntry[.!='']">
                                <relation>
                                    <xsl:value-of select="normalize-space(.)"/>                                    
                                </relation>
                            </xsl:for-each>
                        </xsl:otherwise>                                                
                    </xsl:choose>                    
                </entry>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="list">
        <list>
            <xsl:for-each-group select="$elements/entry" group-by="child::node()">
                <xsl:sort select="translate(current-grouping-key(),'ÁÉÍÓÚáéíóúÜú','AEIUOaeiouUu')"
                    data-type="text"/>                
                <xsl:choose>
                    <xsl:when test="$URI='true'">
                        <item name="{substring-before(current-grouping-key(),'|')}" uri="{substring-after(current-grouping-key(),'|')}">
                            <xsl:value-of select="position()-1"/>
                        </item>        
                    </xsl:when>
                    <xsl:otherwise>
                        <item name="{current-grouping-key()}">
                            <xsl:value-of select="position()-1"/>
                        </item>
                    </xsl:otherwise>
                </xsl:choose>                
            </xsl:for-each-group>
        </list>
    </xsl:variable>

    <xsl:variable name="links">
        <links>
            <xsl:for-each-group select="$elements/entry/name" group-by="following-sibling::relation">
                <xsl:variable name="posCount" select="position()-1"/>
                <xsl:choose>
                    <xsl:when test="$URI='true'">
                        <xsl:for-each select="current-group()/node()">
                            <xsl:variable name="nameVal" select="substring-before(.,'|')"/>
                            <xsl:variable name="uriVal">
                                <xsl:choose>
                                    <xsl:when test=".">
                                        <xsl:value-of select="substring-after(.,'|')"/>
                                    </xsl:when>
                                    <xsl:when test="current-grouping-key()">
                                        <xsl:value-of select="substring-after(.,'|')"/>
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:variable>
                            <xsl:variable name="relationVal" select="substring-before(current-grouping-key(),'|')"/>
                            <xsl:for-each select="$list">
                                <source name="{key('listKey',$nameVal)/@name}"
                                    target="{key('listKeyUri',$uriVal)}">
                                    <xsl:value-of select="$posCount"/>
                                </source>
                            </xsl:for-each>
                        </xsl:for-each>        
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:for-each select="current-group()/node()">
                            <xsl:variable name="nameVal" select="."/>
                            <xsl:variable name="relationVal" select="current-grouping-key()"/>
                            <xsl:for-each select="$list">
                                <source name="{key('listKey',$nameVal)/@name}"
                                    target="{key('listKey',$relationVal)}">
                                    <xsl:value-of select="$posCount"/>
                                </source>
                            </xsl:for-each>
                        </xsl:for-each>
                    </xsl:otherwise>
                </xsl:choose>                                
            </xsl:for-each-group>
        </links>
    </xsl:variable>

    <xsl:template match="/">
        <!--
        <xsl:text>graph</xsl:text>
        <xsl:text>&#10;</xsl:text>
        <xsl:text>[</xsl:text>
        <xsl:text>&#10;</xsl:text>
        <xsl:text>&#09;</xsl:text>
        <xsl:text>directed 1</xsl:text>
        <xsl:text>&#10;</xsl:text>
        <xsl:for-each select="$list/list/item">
            <xsl:text>&#09;</xsl:text>
            <xsl:text>node</xsl:text>
            <xsl:text>&#09;</xsl:text>
            <xsl:text>&#10;</xsl:text>
            <xsl:text>&#09;</xsl:text>
            <xsl:text>[</xsl:text>
            <xsl:text>&#10;</xsl:text>
            <xsl:text>&#09;</xsl:text>
            <xsl:text>&#09;</xsl:text>
            <xsl:text>id </xsl:text>
            <xsl:value-of select="."/>
            <xsl:text>&#10;</xsl:text>
            <xsl:text>&#09;</xsl:text>
            <xsl:text>&#09;</xsl:text>
            <xsl:text>label </xsl:text>
            <xsl:text> "</xsl:text>
            <xsl:value-of select="replace(normalize-space(@name),$quot,$apos)"/>
            <xsl:text>"</xsl:text>
            <xsl:text>&#10;</xsl:text>
            <xsl:text>&#09;</xsl:text>
            <xsl:text>]</xsl:text>
            <xsl:text>&#10;</xsl:text>
        </xsl:for-each>
        <xsl:for-each-group select="$links/links/source" group-by="@name">
            <xsl:for-each select="current-group()/node()">
                <xsl:variable name="targetVal" select="../@target"/>
                <xsl:text>&#09;</xsl:text>
                <xsl:text>edge</xsl:text>
                <xsl:text>&#09;</xsl:text>
                <xsl:text>&#10;</xsl:text>
                <xsl:text>&#09;</xsl:text>
                <xsl:text>[</xsl:text>
                <xsl:text>&#10;</xsl:text>
                <xsl:text>&#09;</xsl:text>
                <xsl:text>&#09;</xsl:text>
                <xsl:text>source </xsl:text>
                <xsl:for-each select="$list">
                    <xsl:value-of select="key('listKey',current-grouping-key())"/>
                </xsl:for-each>
                <xsl:text>&#10;</xsl:text>
                <xsl:text>&#09;</xsl:text>
                <xsl:text>&#09;</xsl:text>
                <xsl:text>target </xsl:text>
                <xsl:value-of select="$targetVal"/>
                <xsl:text>&#10;</xsl:text>
                <xsl:text>&#09;</xsl:text>
                <xsl:text>&#09;</xsl:text>
                <xsl:text>value </xsl:text>
                <xsl:for-each select="$list">
                    <xsl:value-of select="count(key('listKey',current-grouping-key()))"/>
                </xsl:for-each>
                <xsl:text>&#10;</xsl:text>
                <xsl:text>&#09;</xsl:text>
                <xsl:text>]</xsl:text>
                <xsl:text>&#10;</xsl:text>
            </xsl:for-each>
        </xsl:for-each-group>
        <xsl:text>]</xsl:text>
        -->
        <root>
        <xsl:copy-of select="$list"></xsl:copy-of>
        <xsl:copy-of select="$links"></xsl:copy-of>
        </root>
    </xsl:template>

</xsl:stylesheet>
