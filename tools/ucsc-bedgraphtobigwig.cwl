cwlVersion: v1.0
class: CommandLineTool

requirements:
- class: InlineJavascriptRequirement
  expressionLib:
  - var default_output_filename = function() {
          let basename = inputs.bedgraph_file.location.split('/').slice(-1)[0];
          let root = basename.split('.').slice(0,-1).join('.');
          let ext = ".bigWig";
          return (root == "")?basename+ext:root+ext;
        };

hints:
- class: DockerRequirement
  dockerPull: biowardrobe2/ucscuserapps:v358


inputs:
  bedgraph_file:
    type: File
    inputBinding:
      position: 10
    doc: |
      Four column bedGraph file: <chrom> <start> <end> <value>

  chrom_length_file:
    type: File
    inputBinding:
      position: 11
    doc: |
      Two-column chromosome length file: <chromosome name> <size in bases>

  unc:
    type: boolean?
    inputBinding:
      position: 5
      prefix: "-unc"
    doc: |
      Disable compression

  items_per_slot:
    type: int?
    inputBinding:
      separate: false
      position: 6
      prefix: "-itemsPerSlot="
    doc: |
      Number of data points bundled at lowest level. Default 1024

  block_size:
    type: int?
    inputBinding:
      separate: false
      position: 7
      prefix: "-blockSize="
    doc: |
      Number of items to bundle in r-tree.  Default 256

  output_filename:
    type: string?
    inputBinding:
      position: 12
      valueFrom: |
        ${
            if (self == ""){
              return default_output_filename();
            } else {
              return self;
            }
        }
    default: ""
    doc: |
      If set, writes the output bigWig file to output_filename,
      otherwise generates filename from default_output_filename()

outputs:
  bigwig_file:
    type: File
    outputBinding:
      glob: |
        ${
            if (inputs.output_filename == ""){
              return default_output_filename();
            } else {
              return inputs.output_filename;
            }
        }

baseCommand: ["bedGraphToBigWig"]

$namespaces:
  s: http://schema.org/

$schemas:
- http://schema.org/docs/schema_org_rdfa.html

s:mainEntity:
  $import: ./metadata/ucsc-metadata.yaml

s:name: "ucsc-bedgraphtobigwig"
s:downloadUrl: https://raw.githubusercontent.com/Barski-lab/workflows/master/tools/ucsc-bedgraphtobigwig.cwl
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
        s:name: Andrey Kartashov
        s:email: mailto:Andrey.Kartashov@cchmc.org
        s:sameAs:
        - id: http://orcid.org/0000-0001-9102-5681
      - class: s:Person
        s:name: Michael Kotliar
        s:email: mailto:misha.kotliar@gmail.com
        s:sameAs:
        - id: http://orcid.org/0000-0002-6486-3898
doc: |
  Tool converts bedGraph to bigWig file.

  `default_output_filename` function returns filename for generated bigWig if `output_filename` is not provided.
  Default filename is generated on the base of `bedgraph_file` basename with the updated to `*.bigWig` extension.

s:about: |
  usage:
     bedGraphToBigWig in.bedGraph chrom.sizes out.bw
  where in.bedGraph is a four column file in the format:
        <chrom> <start> <end> <value>
  and chrom.sizes is a two-column file/URL: <chromosome name> <size in bases>
  and out.bw is the output indexed big wig file.
  If the assembly <db> is hosted by UCSC, chrom.sizes can be a URL like
    http://hgdownload.cse.ucsc.edu/goldenPath/<db>/bigZips/<db>.chrom.sizes
  or you may use the script fetchChromSizes to download the chrom.sizes file.
  If not hosted by UCSC, a chrom.sizes file can be generated by running
  twoBitInfo on the assembly .2bit file.
  The input bedGraph file must be sorted, use the unix sort command:
    sort -k1,1 -k2,2n unsorted.bedGraph > sorted.bedGraph
  options:
     -blockSize=N - Number of items to bundle in r-tree.  Default 256
     -itemsPerSlot=N - Number of data points bundled at lowest level. Default 1024
     -unc - If set, do not use compression.
