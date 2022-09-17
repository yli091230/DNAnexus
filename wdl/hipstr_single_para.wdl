version 1.0

workflow run_HipSTR_single {
    input {
        File bam 
        File genome 
        File str_ref
        File genome_idx
        File stutter_model
        Int? memory_gb
        File bam_indexs
        Int? min_reads
    }

    call hipstr_single {
        input : 
          bam=bam, 
          genome=genome,
          genome_idx=genome_idx,
          stutter_model=stutter_model,
          str_ref=str_ref,
          memory_gb=memory_gb,
          bam_indexs=bam_indexs,
          min_reads=min_reads
    }

    output {
       File outfile = hipstr_single.outfile
       File log_file = hipstr_single.log_file
    }
    meta {
      description: "This workflow use HipSTR call STRs from a single sample using the stutter model from run_HipSTR_multi workflow"
    }
}

task hipstr_single {
    input {
        File bam
        File genome
        File genome_idx
        File str_ref
        File stutter_model
        Int? memory_gb
        File bam_indexs
        Int? min_reads
    } 
    Int actual_min_reads=select_first([min_reads,5])
    String vcffile=basename(bam)
    command <<<
      echo "Start Job"
      echo Memory $(grep MemTotal /proc/meminfo)
      echo CPU number is $(nproc)
      HipSTR \
          --bams ~{bam} \
          --fasta ~{genome} \
          --regions ~{str_ref} \
          --str-vcf ~{vcffile}.vcf.gz \
          --min-reads ~{actual_min_reads} \
          --stutter-in ~{stutter_model} > run.log 2>&1 || echo "Failed run"
      echo "Finshed"
    >>>
    runtime {
        docker:"yli091230/hipstr:amd64"
    }

    output {
       File outfile = "${vcffile}.vcf.gz"
       File log_file = "run.log"
    }

}



