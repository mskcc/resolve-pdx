#!/usr/bin/env cwl-runner

$namespaces:
  dct: http://purl.org/dc/terms/
  foaf: http://xmlns.com/foaf/0.1/
  doap: http://usefulinc.com/ns/doap#

cwlVersion: v1.0

class: Workflow
id: resolve-pdx
requirements:
  StepInputExpressionRequirement: {} 
  MultipleInputFeatureRequirement: {}
  ScatterFeatureRequirement: {}
  SubworkflowFeatureRequirement: {}
  InlineJavascriptRequirement: {}

inputs:
  read_pair:
    type: 
      type: array
      items:
        type: array
        items: File 
  
  sample_id:
    type: string

  lane_id:
    type: 'string[]' 

  mouse_reference:
    type: File
    secondaryFiles: 
      - .amb
      - .ann
      - .bwt
      - .pac
      - .sa
      - .fai
    
  human_reference:
    type: File
    secondaryFiles:
      - .amb
      - .ann
      - .bwt
      - .pac
      - .sa
      - .fai

outputs:
  human_bam: 
    type: File
    outputSource: align_to_human/output_md_bam

  mouse_bam:
    type: File
    outputSource: align_to_mouse/output_md_bam

  disambiguate_output_dir:
    type: Directory
    outputSource: run_disambiguate/output

steps:
  align_to_human:
    run: align_sample/align_sample.cwl 
    in:
      prefix: sample_id
      reference_sequence: human_reference
      read_pair: read_pair
      sample_id:
        valueFrom: ${ return inputs.prefix + "_human"; }
      lane_id: lane_id
    out: [ output_md_bam ]

  align_to_mouse:
    run: align_sample/align_sample.cwl 
    in:
      prefix: sample_id
      reference_sequence: mouse_reference
      read_pair: read_pair
      sample_id: 
        valueFrom: ${ return inputs.prefix + "_mouse"; }
      lane_id: lane_id
    out: [ output_md_bam ]

  run_disambiguate:
    run: cwl-commandlinetools/disambiguate_1.0.0/disambiguate_1.0.0.cwl
    in:
      prefix: sample_id
      aligner: 
        valueFrom: ${ return "bwa"; }
      output_dir:
        valueFrom: ${ return inputs.prefix + "_disambiguated"; }
      species_a_bam: align_to_human/output_md_bam
      species_b_bam: align_to_mouse/output_md_bam
    out: [ output ]
