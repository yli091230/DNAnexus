version 1.0

workflow run_HipSTR_multi {
    input {
        Array[File] bams 
        File genome 
        File str_ref
        File genome_idx
        Int? memory_gb
        Array[File] bam_indexs
    }

    call hipstr_multi {
        input : 
          bams=bams, 
          genome=genome,
          genome_idx=genome_idx,
          str_ref=str_ref,
          memory_gb=memory_gb,
          bam_indexs=bam_indexs
    }

    output {
       File outfile = hipstr_multi.outfile
       File stutter_file = hipstr_multi.stutter_file
    }
    meta {
      description: "This workflow use HipSTR call STRs from multiple sample and output the stutter model file for running single sample"
    }
}

task hipstr_multi {
    input {
        Array[File] bams
        File genome
        File genome_idx
        File str_ref
        Int? memory_gb
        Array[File] bam_indexs
    } 

    String vcffile="joint_call"
    command <<<
      echo "Start Job"
      HipSTR \
          --bams ~{sep=',' bams} \
          --fasta ~{genome} \
          --regions ~{str_ref} \
          --str-vcf ~{vcffile}.vcf.gz \
          --stutter-out stutter_models.txt || echo "Failed run"
    >>>
    Int cpu=1
    Int disk_space=ceil(1.5 * length(bams)*size(bams, "G"))
    Int actual_memory_gb=select_first([memory_gb,32]) 
    runtime {
        docker:"yli091230/hipstr:amd64"
        cpu: "${cpu}"
        memory: "${actual_memory_gb} GB"
        disks: "local-disk ${disk_space} SSD"
    }

    output {
       File outfile = "${vcffile}.vcf.gz"
       File stutter_file = "stutter_models.txt"
    }

}



