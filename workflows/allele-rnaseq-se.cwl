cwlVersion: v1.0
class: Workflow


requirements:
- class: SubworkflowFeatureRequirement
- class: StepInputExpressionRequirement
- class: InlineJavascriptRequirement
- class: MultipleInputFeatureRequirement


'sd:metadata':
  - "../metadata/rnaseq-header.cwl"


inputs:

  star_indices_folder:
    type: Directory
    label: "STAR indices folder for reference genome"
    doc: "Path to STAR generated indices for reference genome"

  insilico_star_indices_folder:
    type: Directory
    label: "STAR indices folder for insilico genome"
    doc: "Path to STAR generated indices for insilico genome"

  chrom_length_file:
    type: File
    label: "Chromosome length file for reference genome"
    format: "http://edamontology.org/format_2330"
    doc: "Chromosome length file for reference genome"

  strain1:
    type: string
    label: "I strain name"
    doc: "First strain name"

  strain2:
    type: string
    label: "II strain name"
    doc: "Second strain name"

  ref_strain:
    type: string
    label: "Reference strain name"
    doc: "Reference strain name to be projected to"

  hal_file:
    type: File
    label: "HAL file"
    format: "http://edamontology.org/format_3590"
    doc: "HAL file that includes strain information"

  threads:
    type: int?
    default: 2
    label: "Number of threads"
    doc: "Number of threads for those steps that support multithreading"

  fastq_file:
    type: File
    label: "FASTQ input file"
    format: "http://edamontology.org/format_1930"
    doc: "Reads data in a FASTQ format"


outputs:

  strain1_bigwig:
    type: File
    format: "http://edamontology.org/format_3006"
    label: "I strain bigWig file"
    doc: "Generated bigWig file for the first strain"
    outputSource: allele_alignreads_se_pe/strain1_bigwig

  strain2_bigwig:
    type: File
    format: "http://edamontology.org/format_3006"
    label: "II strain bigWig file"
    doc: "Generated bigWig file for the second strain"
    outputSource: allele_alignreads_se_pe/strain2_bigwig

  reference_bigwig:
    type: File
    format: "http://edamontology.org/format_3006"
    label: "Reference bigWig file"
    doc: "Generated BigWig file for the reference genome"
    outputSource: allele_alignreads_se_pe/reference_bigwig

  strain1_bambai_pair:
    type: File
    format: "http://edamontology.org/format_2572"
    label: "Strain I coordinate sorted BAM alignment file (+index BAI)"
    doc: "Coordinate sorted BAM file and BAI index file for strain I"
    outputSource: allele_alignreads_se_pe/strain1_bambai_pair

  strain2_bambai_pair:
    type: File
    format: "http://edamontology.org/format_2572"
    label: "Strain II coordinate sorted BAM alignment file (+index BAI)"
    doc: "Coordinate sorted BAM file and BAI index file for strain II"
    outputSource: allele_alignreads_se_pe/strain2_bambai_pair

  reference_bambai_pair:
    type: File
    format: "http://edamontology.org/format_2572"
    label: "Reference coordinate sorted BAM alignment file (+index BAI)"
    doc: "Coordinate sorted BAM file and BAI index file for reference genome"
    outputSource: allele_alignreads_se_pe/reference_bambai_pair

  insilico_star_final_log:
    type: File
    format: "http://edamontology.org/format_2330"
    label: "STAR final log for insilico genome"
    doc: "STAR Log.final.out for insilico genome"
    outputSource: allele_alignreads_se_pe/insilico_star_final_log

  insilico_star_out_log:
    type: File?
    format: "http://edamontology.org/format_2330"
    label: "STAR log out for insilico genome"
    doc: "STAR Log.out for insilico genome"
    outputSource: allele_alignreads_se_pe/insilico_star_out_log

  insilico_star_progress_log:
    type: File?
    format: "http://edamontology.org/format_2330"
    label: "STAR progress log for insilico genome"
    doc: "STAR Log.progress.out for insilico genome"
    outputSource: allele_alignreads_se_pe/insilico_star_progress_log

  insilico_star_stdout_log:
    type: File?
    format: "http://edamontology.org/format_2330"
    label: "STAR stdout log for insilico genome"
    doc: "STAR Log.std.out for insilico genome"
    outputSource: allele_alignreads_se_pe/insilico_star_stdout_log

  reference_star_final_log:
    type: File
    format: "http://edamontology.org/format_2330"
    label: "STAR final log for reference genome"
    doc: "STAR Log.final.out for reference genome"
    outputSource: allele_alignreads_se_pe/reference_star_final_log

  reference_star_out_log:
    type: File?
    format: "http://edamontology.org/format_2330"
    label: "STAR log out for reference genome"
    doc: "STAR Log.out for reference genome"
    outputSource: allele_alignreads_se_pe/reference_star_out_log

  reference_star_progress_log:
    type: File?
    format: "http://edamontology.org/format_2330"
    label: "STAR progress log for reference genome"
    doc: "STAR Log.progress.out for reference genome"
    outputSource: allele_alignreads_se_pe/reference_star_progress_log

  reference_star_stdout_log:
    type: File?
    format: "http://edamontology.org/format_2330"
    label: "STAR stdout log for reference genome"
    doc: "STAR Log.std.out for reference genome"
    outputSource: allele_alignreads_se_pe/reference_star_stdout_log


steps:

  extract_fastq:
    run: ../tools/extract-fastq.cwl
    in:
      compressed_file: fastq_file
    out: [fastq_file]

  allele_alignreads_se_pe:
    run: ../subworkflows/allele-alignreads-se-pe.cwl
    in:
      fastq_files: extract_fastq/fastq_file
      insilico_star_indices_folder: insilico_star_indices_folder
      reference_star_indices_folder: star_indices_folder
      chrom_length_file: chrom_length_file
      strain1: strain1
      strain2: strain2
      ref_strain: ref_strain
      hal_file: hal_file
      threads: threads
    out:
    - strain1_bambai_pair
    - strain2_bambai_pair
    - reference_bambai_pair
    - strain1_bigwig
    - strain2_bigwig
    - reference_bigwig
    - insilico_star_final_log
    - insilico_star_out_log
    - insilico_star_progress_log
    - insilico_star_stdout_log
    - reference_star_final_log
    - reference_star_out_log
    - reference_star_progress_log
    - reference_star_stdout_log

$namespaces:
  s: http://schema.org/

$schemas:
- http://schema.org/docs/schema_org_rdfa.html

s:name: "RNA-seq alelle specific pipeline for single-read data"
label: "RNA-seq alelle specific pipeline for single-read data"
s:alternateName: "Allele specific RNA-Seq single-read workflow"

s:downloadUrl: https://raw.githubusercontent.com/Barski-lab/workflows/master/workflows/allele-rnaseq-se.cwl
s:codeRepository: https://github.com/Barski-lab/workflows
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
        s:email: mailto:misha.kotliar@gmail.com
        s:sameAs:
        - id: http://orcid.org/0000-0002-6486-3898

doc: |
  Allele specific RNA-Seq single-read workflow
