# Using DNAnexus to analyze UK Biobank data

## Get access to data

1. Install tools for local access DNAnexus.

2. Prepare files for running HipSTR
* Get files names that stored in DNAnexus, `dx find data --name "<file_name_pattern>" --path "<path_want_to_check>" > filename_list.txt`.
* UKBiobank use reference genome GRCh38 but didn't specify the detailed verion. Based on the header of cram files, pickthis one [GRCh38](ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/reference/GRCh38_reference_genome/GRCh38_full_analysis_set_plus_decoy_hla.fa).
  * Use `dx upload <local_directory> --destination <cloud_pathi>`.\
    The command may not function with large file, can use wdl to download file or use the [Upload Agent](https://documentation.dnanexus.com/user/objects/uploading-and-downloading-files/batch/upload-agent#uploading-a-single-file) recommended by DNAnexus (haven't try this one yet).
    
## Use DNAnexus to run workflow 
1. DNAnexus use AWS for computation job. By default, DNAnexus will use spot instance with small memory.  
2. To compile wdl file to workflow use `java -jar dxCompiler-2.10.4.jar compile <your_wdl_file> -project <ukb_project_id> -folder <directory_to_storage_on_DNAnexus>`. This will output a string "workflow-xxxx" that needed for running workflow. 
* If the `<directory_to_storage_on_DNAnexus>` does not exist, it will create for you. For example, /test/ folder not exist, it will create a /test/ folder under the root of your project and put the "workflow-xxxx" and other files in there.
* Use `dx ls --brief <directory_to_storage_on_DNAnexus>` to check workflow ID if forgot.
* Use `--streamFiles [all, none, perfile(default)]` to mount data instead of download. For `perfile` need `parameter_meta` section in the wdl file.
3. To run workflow use `dx run <workflow-xxxx> -y -f input.json --destination <path_to_storage>`.
* To generate an `input.json` file, use `dx run <workflow-xx>` in an interactive mode and get the template for `input.json`. Alternatively, `java -jar dxCompiler.jar compile <your_wdl_file> -project project-xxxx -folder <directory_to_storage_on_DNAnexus> -inputs input.json` will convert Crowell JSON format input file into DNAnexus format during compiling `input.dx.json`.
  * `awk '{print "{ \n","\"$dnanexus_link:\"",$NF, "},\n"}' random_50_cram.txt| tr '()' '""' | less` to get array of inputs.
* If `--destination` not specified, dx run will output results to root directory by default.
* If `<path_to_storage>` is not exist, it will create for you. To create `<path_to_storage>` manually use `dx mkdir -p <path_to_storage>`.
4. How to check the job status using "Analysis ID: analysis-GGGfFFjJv7B1FFF291FPfFx5" that ouput call dx run.
### Notes on wdl file and docker
1. If the docker image is build on macbook with M1 CPU, use `docker buildx build --platform linux/amd64`. If not, it can't run on DNAnexus.
2. For test run, redirect stdout or stderr to a file is not recommended. DNAnexus wouldn't be able to transfer those error/infor if job failed, which makes the debugging very difficult.**But**, once test run works, it is better to redirect stdout and stderr as a output because the online log sometime wouldn't be fully display. 
3. If tools need other files that not specified in the options, make sure include those file in the `Input`.
 

## Workflow name lookup
* download_ref: workflow-GGJ1pJQJv7B5Jv8J5K8z1G69
* index_reference: workflow-GGJ28b0Jv7BPQ9F67x9KXvBz
* hipstr_multi: workflow-GGJ973jJv7B217G3K0PY5Yky 


## Problems need to solve
1. Efficent way to get input?
2. How to trouble shoot?
  a. The GUI seems have no information about what goes in the command section?
  b. Error message ""

## Usefull git repositories
1. [dxWDL](https://github.com/dnanexus/dxWDL/blob/v1/doc/ExpertOptions.md#setting-a-default-docker-image-for-all-tasks): provide extra information about dxWDL file documentation.
2. [WDL](https://github.com/openwdl/wdl/blob/main/versions/1.1/SPEC.md#file-stdout): provide specification for WDL.
3. [dxCompiler](https://documentation.dnanexus.com/developer/building-and-executing-portable-containers-for-bioinformatics-software/dxcompiler#dxcompiler-setup): provide more documentation about dxCompiler, like `-extras`,`parameter_meta`. See also the [DNAnexus websit] (https://documentation.dnanexus.com/developer/building-and-executing-portable-containers-for-bioinformatics-software/dxcompiler#dxcompiler-setup)
4. Other information from the DNAnexus like [billing](https://documentation.dnanexus.com/admin/org-management), [dx command](https://documentation.dnanexus.com/user/helpstrings-of-sdk-command-line-utilities#category-orgs),[DNAnexus websit](https://documentation.dnanexus.com/user/objects/searching-data-objects). 
