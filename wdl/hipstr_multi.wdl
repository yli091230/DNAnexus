version 1.0

workflow run_HipSTR_multi {
    input {
        Array[File] bams 
        File genome 
        File str_ref
        File genome_idx
        Array[File] bam_indexs
        Int? memory_gb
        Int? disk_space
        Int? cpu
        String? HD_type
        String? docker_image
    }

    call hipstr_multi {
        input : 
          bams=bams, 
          genome=genome,
          genome_idx=genome_idx,
          str_ref=str_ref,
          bam_indexs=bam_indexs,
          memory_gb=memory_gb,
          disk_space=disk_space,
          cpu=cpu,
          HD_type=HD_type,
          docker_image=docker_image
    }

    output {
       File outfile = hipstr_multi.outfile
       File stutter_file = hipstr_multi.stutter_file
       File log_file = hipstr_multi.log_file
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
        Array[File] bam_indexs
        Int? memory_gb
        Int? disk_space
        Int? cpu
        String? HD_type
        String? docker_image
    } 

    String vcffile="joint_call"
    command <<<
      echo "Start Job"
      HipSTR \
          --bams ~{sep=',' bams} \
          --fasta ~{genome} \
          --regions ~{str_ref} \
          --str-vcf ~{vcffile}.vcf.gz \
          --stutter-out stutter_models.txt > run.log 2>&1 || echo "Failed run" &
      echo "Finshed"
    >>>
    Int actual_cpu=select([cpu,1])
    Int actual_disk_space=select_first([disk_space,8])
    Int actual_memory_gb=select_first([memory_gb,12]) 
    String acutal_docker_image=select_first([docker_image,"yli091230/hipstr:amd64"])
    String actual_HD_type=select_first([HD_type,'SSD'])
    runtime {
        docker: actual_docker_image
        cpu: "${cpu}"
        memory: "${actual_memory_gb} GB"
        disks: "local-disk ${disk_space} ${actual_HD_type}"
    }

    output {
       File outfile = "${vcffile}.vcf.gz"
       File stutter_file = "stutter_models.txt"
       File log_file = "run.log"
    }

}



