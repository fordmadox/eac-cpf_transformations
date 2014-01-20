<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>

    <!--
        Copyright 2014 Timothy A. Thompson
        EAC-CPF Transformations: https://github.com/Timathom/eac-cpf_transformations
        Licensed under the Educational Community License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://opensource.org/licenses/ECL-2.0 http://www.osedu.org/licenses/ECL-2.0 Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
    -->

    <!--
        eacFileListGenerator.xsl outputs an XML list of EAC-CPF files in a directory. If this stylesheet is saved in a different directory, the value of the $pDirectory parameter may be changed accordingly.                              
    -->

    <xsl:param name="pDirectory">.</xsl:param>

    <xsl:template match="/">
        <eacFiles>
            <xsl:for-each
                select="for $x in collection(concat($pDirectory,'?select=*.xml;recurse=yes;on-error=ignore')) return $x">
                <xsl:sort select="document-uri(.)" data-type="text"/>
                <eacFile filename="{document-uri(.)}"/>                    
            </xsl:for-each>
        </eacFiles>
    </xsl:template>

</xsl:stylesheet>
