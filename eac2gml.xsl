<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs xlink" version="2.0">
    <xsl:output method="text" encoding="UTF-8"/>

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
                                    <name uri="{//otherRecordId[.!='']}">
                                        <xsl:value-of select="concat(normalize-space(part),'|',//otherRecordId[.!=''])"/>
                                    </name>
                                </xsl:when>
                                <xsl:when test="count(part)&gt;1">
                                    <name uri="{//otherRecordId[.!='']}">
                                        <xsl:for-each select="part">                   
                                            <xsl:choose>
                                                <xsl:when test="position()!=last()">
                                                    <xsl:value-of select="."/>        
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="concat(normalize-space(.),'|',//otherRecordId[.!=''])"></xsl:value-of>
                                                </xsl:otherwise>
                                            </xsl:choose>                                                                                                                                                                            
                                        </xsl:for-each>
                                    </name>
                                </xsl:when>                                                                      
                            </xsl:choose>                            
                            <xsl:for-each
                                select="../../relations/cpfRelation/relationEntry[.!=''][not(some $creator in ../../resourceRelation/relationEntry satisfies contains(., $creator))]">
                                <relation uri="{normalize-space(../@xlink:href)}">
                                    <xsl:value-of select="concat(normalize-space(.),'|',normalize-space(../@xlink:href),'=',substring-before(following-sibling::descriptiveNote,'.'))"/>
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
                                                    <xsl:choose>
                                                        <xsl:when
                                                            test="substring(normalize-space(.),string-length(normalize-space(.)))!=','">
                                                            <xsl:value-of
                                                                select="concat(normalize-space(.),', ')"/>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:value-of select="."/>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="normalize-space(.)"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:for-each>
                                    </name>
                                </xsl:when>   
                            </xsl:choose>
                            <xsl:for-each
                                select="../../relations/cpfRelation/relationEntry[.!=''][not(some $creator in ../../resourceRelation/relationEntry satisfies contains(., $creator))]">
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
            <xsl:for-each-group select="$elements/entry/child::node()" group-by="if (substring-before(substring-after(.,'|'),'=')[.!='']) then substring-before(substring-after(.,'|'),'=') else ()">
                <xsl:sort select="translate(substring-before(.,'|'),'ÁÉÍÓÚáéíóúÜú','AEIUOaeiouUu')"
                    data-type="text"/>                
                <xsl:choose>
                    <xsl:when test="$URI='true'">
                        <item name="{normalize-space(substring-before(.,'|'))}" uri="{normalize-space(current-grouping-key())}">
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
                            <xsl:variable name="nameUriVal" select="substring-after(.,'|')"/>
                            <xsl:variable name="relationUriVal" select="substring-before(substring-after(current-grouping-key(),'|'),'=')"/>
                            <xsl:variable name="edgeLabel" select="substring-after(current-grouping-key(),'=')"/>
                            <xsl:for-each select="$list">
                                <source name="{key('listKeyUri',$nameUriVal)/@name}" uri="{key('listKeyUri',$nameUriVal)/@uri}"
                                    target="{key('listKeyUri',$relationUriVal)}" edgeLabel="{$edgeLabel}">
                                    <xsl:value-of select="key('listKeyUri',$nameUriVal)"/>
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
            <xsl:text>"</xsl:text>
            <xsl:value-of select="replace(normalize-space(@name),$quot,$apos)"/>
            <xsl:text>"</xsl:text>
            <xsl:text>&#10;</xsl:text>
            <xsl:text>&#09;</xsl:text>
            <xsl:text>]</xsl:text>
            <xsl:text>&#10;</xsl:text>
        </xsl:for-each>
        <xsl:for-each-group select="$links/links/source" group-by="@uri">
            <xsl:for-each select="current-group()/node()">
                <xsl:variable name="targetVal" select="../@target"/>
                <xsl:variable name="edgeVal" select="../@edgeLabel"/>
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
                    <xsl:value-of select="key('listKeyUri',current-grouping-key())"/>
                </xsl:for-each>
                <xsl:text>&#10;</xsl:text>
                <xsl:text>&#09;</xsl:text>
                <xsl:text>&#09;</xsl:text>
                <xsl:text>target </xsl:text>
                <xsl:value-of select="$targetVal"/>
                <xsl:text>&#10;</xsl:text>
                <xsl:text>&#09;</xsl:text>
                <xsl:text>&#09;</xsl:text>
                <xsl:text>label </xsl:text>
                <xsl:text>"</xsl:text>
                <xsl:value-of select="concat(replace(normalize-space($edgeVal),$quot,$apos),'.')"/>
                <xsl:text>" </xsl:text>
                <xsl:text>&#10;</xsl:text>
                <xsl:text>&#09;</xsl:text>
                <xsl:text>&#09;</xsl:text>                
                <xsl:text>value </xsl:text>
                <xsl:for-each select="$list">
                    <xsl:value-of select="count(key('listKeyUri',current-grouping-key()))"/>
                </xsl:for-each>               
                <xsl:text>&#10;</xsl:text>
                <xsl:text>&#09;</xsl:text>
                <xsl:text>]</xsl:text>
                <xsl:text>&#10;</xsl:text>
            </xsl:for-each>
        </xsl:for-each-group>
        <xsl:text>]</xsl:text>        
    </xsl:template>

</xsl:stylesheet>
