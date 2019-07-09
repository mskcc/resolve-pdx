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
    type: 'File[]'
  
  sample_id:
    type: string

  lane_id:
    type: string

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
    outputSource: align_to_human/output_bam

  mouse_bam:
    type: File
    outputSource: align_to_mouse/output_bam

steps:
  align_to_human:
    run: cwl-commandlinetools/bwa_mem_0.7.12/bwa_mem_0.7.12.cwl 
    in:
      reference_sequence: human_reference
      read_pair: read_pair
      sample_id: sample_id
      lane_id: lane_id
    out: [ output_bam ]

  align_to_mouse:
    run: cwl-commandlinetools/bwa_mem_0.7.12/bwa_mem_0.7.12.cwl 
    in:
      reference_sequence: mouse_reference
      read_pair: read_pair
      sample_id: sample_id
      lane_id: lane_id
    out: [ output_bam ]
