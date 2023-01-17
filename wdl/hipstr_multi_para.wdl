version 1.0

# This simple workflow validates a VCF file.  There is no real output, but if a shard fails, then we know that the VCF was
#  not validated.
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
       Array[File] outfile = hipstr_multi.outfile
       Array[File] stutter_file = hipstr_multi.stutter_file
       Array[File] log_file = hipstr_multi.log_file
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
      echo $(date '+%Y-%m-%d-%H:%M')
      echo "CPU number is $(nproc)"
      split -n l/$(nproc) ~{str_ref} -d -a 1 split_ref_
      ls
      echo $PWD
      for i in $(seq 0 $(( $(nproc) - 1)) )
      do
      HipSTR           --bams ~{sep=',' bams}           --fasta ~{genome}           --regions split_ref_${i}           --str-vcf ~{vcffile}_${i}.vcf.gz           --min-reads 5           --stutter-out stutter_models_${i}.txt > run_${i}.log 2>&1 || echo "Failed run" &
      echo job $i submitted
      done
      ls
      wait
      echo "Finshed"
      echo $(date '+%Y-%m-%d-%H:%M')
    >>>
    Int cpu=1
    Int disk_space=ceil(50+length(bams)*size(bams[0],"G"))
    Int actual_memory_gb=select_first([memory_gb,16])

    runtime {
        docker:"gcr.io/ucsd-medicine-cast/hipstr:amd64"
        cpu: "${cpu}"
        memory: "${actual_memory_gb} GB"
        disks: "local-disk ${disk_space} HDD"
    }

    output {
       Array[File] outfile = glob("*.vcf.gz")
       Array[File] stutter_file = glob("stutter_models*.txt")
       Array[File] log_file = glob("run*.log")
    }

}
