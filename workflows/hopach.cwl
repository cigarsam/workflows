cwlVersion: v1.0
class: Workflow


requirements:
  - class: SubworkflowFeatureRequirement
  - class: StepInputExpressionRequirement
  - class: InlineJavascriptRequirement
  - class: MultipleInputFeatureRequirement


'sd:upstream':
  rnaseq_sample:
    - "rnaseq-se.cwl"
    - "rnaseq-pe.cwl"
    - "rnaseq-se-dutp.cwl"
    - "rnaseq-pe-dutp.cwl"
    - "rnaseq-se-dutp-mitochondrial.cwl"
    - "rnaseq-pe-dutp-mitochondrial.cwl"
    - "trim-rnaseq-pe.cwl"
    - "trim-rnaseq-se.cwl"
    - "trim-rnaseq-pe-dutp.cwl"
    - "trim-rnaseq-se-dutp.cwl"


inputs:

  alias:
    type: string
    label: "Experiment short name/Alias"
    sd:preview:
      position: 1

  expression_files:
    type: File[]
    format: "http://edamontology.org/format_3752"
    label: "Isoform expression files"
    doc: "Isoform expression files"
    'sd:upstreamSource': "rnaseq_sample/rpkm_isoforms"
    'sd:localLabel': true

  expression_aliases:
    type:
      - "null"
      - string[]
    label: "Isoform expression file aliases"
    doc: "Aliases to make the legend for generated plots. Order corresponds to the isoform expression files"
    # 'sd:upstreamSource': "rnaseq_sample/alias"
    # 'sd:localLabel': true

  group_by:
    type:
      - "null"
      - type: enum
        symbols: ["isoforms", "genes", "common tss"]
    default: "genes"
    label: "Group by"
    doc: "Grouping method for features: isoforms, genes or common tss"

  target_column:
    type:
      - "null"
      - type: enum
        symbols: ["Rpkm", "TotalReads"]
    default: "Rpkm"
    label: "Target column"
    doc: "Target column name from expression files to be used by hopach"

  row_min:
    type: float?
    default: 0
    label: "Min value for target column"
    doc: "Min value for target column"

  keep_discarded:
    type: boolean?
    default: false
    label: "Keep discarded rows"
    doc: "Keep discarded by threshold parameter rows at the end of the output file"

  cluster_method:
    type:
      - "null"
      - type: enum
        symbols: ["row", "column", "both"]
    default: "both"
    label: "Cluster method"
    doc: "Cluster method"

  row_dist_metric:
    type:
      - "null"
      - type: enum
        symbols: ["cosangle", "abscosangle", "euclid", "abseuclid", "cor", "abscor"]
    default: "cosangle"
    label: "Distance metric for row clustering"
    doc: "Algorithm to be used for distance matrix calculation before running hopach row clustering"
    'sd:layout':
      advanced: true

  row_logtransform:
    type: boolean?
    default: true
    label: "Log2 row transform"
    doc: "Log2 transform input data to prior running hopach row clustering"
    'sd:layout':
      advanced: true

  row_center:
    type:
      - "null"
      - type: enum
        symbols: ["mean", "median"]
    default: "mean"
    label: "Center row values"
    doc: "Center row values"
    'sd:layout':
      advanced: true

  row_normalize:
    type: boolean?
    default: true
    label: "Normalize row values"
    doc: "Normalize row values"
    'sd:layout':
      advanced: true

  col_dist_metric:
    type:
      - "null"
      - type: enum
        symbols: ["cosangle", "abscosangle", "euclid", "abseuclid", "cor", "abscor"]
    default: "euclid"
    label: "Distance metric for column clustering"
    doc: "Algorithm to be used for distance matrix calculation before running hopach column clustering"
    'sd:layout':
      advanced: true

  col_logtransform:
    type: boolean?
    default: true
    label: "Log2 column transform"
    doc: "Log2 transform input data to prior running hopach column clustering"
    'sd:layout':
      advanced: true

  col_center:
    type:
      - "null"
      - type: enum
        symbols: ["mean", "median"]
    default: "mean"
    label: "Center column values"
    doc: "Center column values"
    'sd:layout':
      advanced: true

  col_normalize:
    type: boolean?
    default: true
    label: "Normalize column values"
    doc: "Normalize column values"
    'sd:layout':
      advanced: true

  palette:
    type:
      - "null"
      - string[]
    default: ["black", "red", "yellow"]
    label: "Custom palette color list"
    doc: "Color list for custom palette"
    'sd:layout':
      advanced: true


outputs:

  clustering_results:
    type: File
    format: "http://edamontology.org/format_3475"
    label: "Combined clustered expression file"
    doc: "Combined by RefseqId, GeneId, Chrom, TxStart, TxEnd and Strand clustered expression file"
    outputSource: hopach/clustering_results
    'sd:visualPlugins':
    - syncfusiongrid:
        tab: 'Hopach Clustering Results'
        Title: 'Combined clustered expression file'

  column_clustering_labels:
    type: File?
    format: "http://edamontology.org/format_3475"
    label: "Column cluster labels"
    doc: "Column cluster labels"
    outputSource: hopach/column_clustering_labels
    'sd:visualPlugins':
    - syncfusiongrid:
        tab: 'Hopach Clustering Results'
        Title: 'Column cluster labels'

  heatmap_png:
    type: File
    label: "Heatmap"
    format: "http://edamontology.org/format_3603"
    doc: "Heatmap plot"
    outputSource: hopach/heatmap_png
    'sd:visualPlugins':
    - image:
        tab: 'Plots'
        Caption: 'Heatmap'

  row_distance_matrix_png:
    type: File?
    label: "Row Distance Matrix"
    format: "http://edamontology.org/format_3603"
    doc: "Row distance matrix plot. Clusters of similar features will appear as blocks on the diagonal of the matrix"
    outputSource: hopach/row_distance_matrix_png
    'sd:visualPlugins':
    - image:
        tab: 'Plots'
        Caption: 'Row Distance Matrix'

  col_distance_matrix_png:
    type: File?
    label: "Column Distance Matrix"
    format: "http://edamontology.org/format_3603"
    doc: "Column distance matrix plot. Clusters of similar features will appear as blocks on the diagonal of the matrix"
    outputSource: hopach/col_distance_matrix_png
    'sd:visualPlugins':
    - image:
        tab: 'Plots'
        Caption: 'Column Distance Matrix'


steps:

  group_isoforms:
    run: ../subworkflows/group-isoforms-batch.cwl
    in:
      isoforms_file: expression_files
    out:
      - genes_file
      - common_tss_file

  hopach:
    run: ../tools/hopach.cwl
    in:
      expression_files:
        source: [group_by, expression_files, group_isoforms/genes_file, group_isoforms/common_tss_file]
        valueFrom: |
          ${
              if (self[0] == "isoforms") {
                return self[1];
              } else if (self[0] == "genes") {
                return self[2];
              } else {
                return self[3];
              }
          }
      expression_aliases: expression_aliases
      target_column: target_column
      cluster_method: cluster_method
      row_dist_metric: row_dist_metric
      col_dist_metric: col_dist_metric
      row_logtransform: row_logtransform
      col_logtransform: col_logtransform
      row_center: row_center
      col_center: col_center
      row_normalize: row_normalize
      col_normalize: col_normalize
      row_min: row_min
      keep_discarded: keep_discarded
      palette: palette
    out:
      - clustering_results
      - column_clustering_labels
      - heatmap_png
      - row_distance_matrix_png
      - col_distance_matrix_png


$namespaces:
  s: http://schema.org/

$schemas:
- http://schema.org/docs/schema_org_rdfa.html

s:name: "HOPACH - Hierarchical Ordered Partitioning and Collapsing Hybrid"
label: "HOPACH - Hierarchical Ordered Partitioning and Collapsing Hybrid"
s:alternateName: "The HOPACH clustering algorithm builds a hierarchical tree of clusters by recursively partitioning a data set"

s:downloadUrl: https://raw.githubusercontent.com/datirium/workflows/master/workflows/hopach.cwl
s:codeRepository: https://github.com/datirium/workflows
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

doc: |
  Hierarchical Ordered Partitioning and Collapsing Hybrid (HOPACH)
  ===============================================================

  The HOPACH clustering algorithm builds a hierarchical tree of clusters by recursively partitioning a data set, while
  ordering and possibly collapsing clusters at each level. The algorithm uses the Mean/Median Split Silhouette (MSS) criteria
  to identify the level of the tree with maximally homogeneous clusters. It also runs the tree down to produce a final
  ordered list of the elements. The non-parametric bootstrap allows one to estimate the probability that each element
  belongs to each cluster (fuzzy clustering).
