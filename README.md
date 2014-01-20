eac-cpf_transformations
=======================

XSLT scripts and data files for transforming EAC-CPF records. See the EAC-CPF Tag Library Draft (http://www3.iath.virginia.edu/eac/cpf/tagLibrary/cpfTagLibrary.html) for details on the standard.

## Introduction

EAC-CPF (Encoded Archival Context-Corporate Bodies, Persons, Families) is a data exchange format developed by the archives community to encode information about the social and historical context surrounding archival and special collections. EAC-CPF's relation elements allow it to serve as a transitional format between traditional descriptive practices and emerging linked-data standards.

## 1 eac2gml.xsl

The `eac2gml.xsl` stylesheet takes an XML-formatted list of EAC-CPF files (created by `eacFileListGenerator.xsl`) and outputs a GML (Graph Modeling Language)-formatted representation of the graph of relationships among nameEntry and cpfRelation elements across an EAC-CPF dataset.

### 1.1 Requirements

  * XSLT 2.0-compliant transformation engine

### 1.2 Generate a list of EAC-CPF files

   Run `eacFileListGenerator.xsl` on a directory of EAC-CPF files. The stylesheet may be saved in the same directory as the files or in a different directory (if it is saved in a different directory, the `$pDirectory` parameter should be updated accordingly). Save the XML output.
   
### 1.3 Run the transformation

   Run eac2gml.xsl on the XML list of files and save the output with a `.gml` extension. The resulting file may now be opened in graph/visualization software such as Gephi (https://gephi.org/).
