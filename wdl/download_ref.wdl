version 1.0

workflow get_reference {
    input {
        String download_link="ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/reference/GRCh38_reference_genome/GRCh38_full_analysis_set_plus_decoy_hla.fa"
    }

    call download_reference {
        input : download_link = download_link
    }
    
    output {
        File outfile = download_reference.grch38
    }
}

task download_reference {
    input {
        String download_link
    }
    
    String reference_name=basename(download_link)
    
    command <<<
        wget ~{download_link}
    >>>
    
    runtime {
        docker: "yli091230/hipstr:latest"
    }
  
    output {
        File grch38="${reference_name}"
    }
}



