cwlVersion: v1.0
class: Workflow

requirements:
  - class: SubworkflowFeatureRequirement
  - class: ScatterFeatureRequirement
  - class: StepInputExpressionRequirement
  - class: InlineJavascriptRequirement

inputs:

  fasta_input_files:
    type: File[]
    label: "FASTA input files"
    format: "http://edamontology.org/format_1929"
    doc: "Reference genome input FASTA file(s)"

outputs:
  indices_folder:
    type: Directory
    label: "Bowtie indices folder"
    doc: "Folder which includes all Bowtie generated indices files"
    outputSource: files_to_folder/folder

steps:
  bowtie_generate_indices:
    run: ../../tools/bowtie-build.cwl
    in:
      reference_in: fasta_input_files
    out: [indices]

  files_to_folder:
    run: ../../expressiontools/files-to-folder.cwl
    in:
      input_files: bowtie_generate_indices/indices
    out: [folder]

$namespaces:
  s: http://schema.org/

$schemas:
- http://schema.org/docs/schema_org_rdfa.html

s:name: "bowtie-index"
s:downloadUrl: https://raw.githubusercontent.com/SciDAP/workflows/master/workflows/scidap/bowtie-index.cwl
s:codeRepository: https://github.com/SciDAP/workflows
s:license: http://www.apache.org/licenses/LICENSE-2.0

s:isPartOf:
  class: s:CreativeWork
  s:name: Common Workflow Language
  s:url: http://commonwl.org/

s:creator:
- class: s:Organization
  s:legalName: "Cincinnati Children's Hospital Medical Center"
  s:location:
  - class: s:PostalAddress
    s:addressCountry: "USA"
    s:addressLocality: "Cincinnati"
    s:addressRegion: "OH"
    s:postalCode: "45229"
    s:streetAddress: "3333 Burnet Ave"
    s:telephone: "+1(513)636-4200"
  s:logo: "https://www.cincinnatichildrens.org/-/media/cincinnati%20childrens/global%20shared/childrens-logo-new.png"
  s:department:
  - class: s:Organization
    s:legalName: "Allergy and Immunology"
    s:department:
    - class: s:Organization
      s:legalName: "Barski Research Lab"
      s:member:
      - class: s:Person
        s:name: Michael Kotliar
        s:email: mailto:michael.kotliar@cchmc.org
        s:sameAs:
        - id: http://orcid.org/0000-0002-6486-3898
      - class: s:Person
        s:name: Andrey Kartashov
        s:email: mailto:Andrey.Kartashov@cchmc.org
        s:sameAs:
        - id: http://orcid.org/0000-0001-9102-5681

s:about: >
  Current workflow should be used to generate BOWTIE genome indices files. It performs the following steps:
  1. Use BOWTIE to generate genome indices files on the base of input FASTA, return results as group of main and secondary files
  2. Transform indices files from the previous step into the Direcotry data type