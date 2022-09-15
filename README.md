# Using DNAnexus to analyze UK Biobank data

## UKBiobank sample information
The datset  contains WGS sequencing results from 200,025 samples with 2\*151 reads.\
### Selection of UK Biobank samples
1. The strWAS paper:
  * Remove potential DNA contamination.
  * Remove withdrawn participants, indicated by non-positive IDs in the sample file as well as by IDs in email communications.
    * 487,279 individuals remained at this step
  * QC file, subsetted the non-withdrawn individuals (take only White-British populationi)
2. The Nature 150,119 UKBiobank samples [paper](https://www.nature.com/articles/s41586-022-04965-x#MOESM1)
  * 13 individuals were sequenced in <u>duplicated</u>.
  * 11 individuals were <u>withdrew</u> consent from time of sequencing to time of analysis.
  * 135 people don't have microarray data.
  


## Get access to files on DNAnexus

1. Install tools for local access DNAnexus.

2. Prepare files for running HipSTR
* Get files names that stored in DNAnexus, `dx find data --name "<file_name_pattern>" --path "<path_want_to_check>" > filename_list.txt`.
* UKBiobank use reference genome GRCh38 but didn't specify the detailed verion. Based on the header of cram files, pickthis one [GRCh38](http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/reference/GRCh38_reference_genome/GRCh38_full_analysis_set_plus_decoy_hla.fa).
  * Use `dx upload <local_directory> --destination <cloud_pathi>`.\
    The command may not function with large file, can use wdl to download file or use the [Upload Agent](https://documentation.dnanexus.com/user/objects/uploading-and-downloading-files/batch/upload-agent#uploading-a-single-file) recommended by DNAnexus (haven't try this one yet).
    
## Use DNAnexus to run workflow 
1. DNAnexus use AWS for computation job. By default, DNAnexus will use spot instance with small memory.  
2. To compile wdl file to workflow use `java -jar dxCompiler-2.10.4.jar compile <your_wdl_file> -project <ukb_project_id> -folder <directory_to_storage_on_DNAnexus>`. This will output a string "workflow-xxxx" that needed for running workflow. 
* If the `<directory_to_storage_on_DNAnexus>` does not exist, it will create for you. For example, /test/ folder not exist, it will create a /test/ folder under the root of your project and put the "workflow-xxxx" and other files in there.
* Use `dx ls --brief <directory_to_storage_on_DNAnexus>` to check workflow ID if forgot, `--long` flag to diplay full path and file ID.
* Use `--streamFiles [all, none, perfile(default)]` to mount data instead of download. For `perfile` need `parameter_meta` section in the wdl file.
3. To run workflow use `dx run <workflow-xxxx> -y -f input.json --destination <path_to_storage>`.
* To generate an `input.json` file, use `dx run <workflow-xx>` in an interactive mode and get the template for `input.json`. Alternatively, `java -jar dxCompiler.jar compile <your_wdl_file> -project project-xxxx -folder <directory_to_storage_on_DNAnexus> -inputs input.json` will convert Crowell JSON format input file into DNAnexus format during compiling `input.dx.json`.
  * `awk '{print "{ \n","\"$dnanexus_link\":",$NF, "\n},"}' random_100_cram_ab_15G.txt | tr '()' '""' | less` to get array of inputs.
* If `--destination` not specified, dx run will output results to root directory by default.
* If `<path_to_storage>` is not exist, it will create for you. To create `<path_to_storage>` manually use `dx mkdir -p <path_to_storage>`.
4. How to check the job status using "Analysis ID: analysis-GGGfFFjJv7B1FFF291FPfFx5" that ouput call dx run.
### Notes on wdl file and docker
1. If the docker image is build on macbook with M1 CPU, use `docker buildx build --platform linux/amd64`. If not, it can't run on DNAnexus.
2. For test run, redirect stdout or stderr to a file is not recommended. DNAnexus wouldn't be able to transfer those error/infor if job failed, which makes the debugging very difficult. **But**, once test run works, it is better to redirect stdout and stderr as a output because the online log sometime wouldn't be fully display. 
3. If tools need other files that not specified in the options, make sure include those file in the `Input`.
 
## Run DXJupyterLab
1. To launch a JupyerLab session, select `JupyterLab` tab from the `TOOLS` menue and click on the `New JupyterLab` on the top right corner. Specify the project, instance type and other running information then start the session. After the session started, click on the `Open` button to open the JupyterLab in browser.

2. There are two types of notebooks: Local vs DNAnexus
* The main difference between the Local and DNAnexus is files (include ipynb and datas) in DNAnexus notebook will be kept after close of JupyterLab while files in Local notebook will lost. 
* To access data in your project from notebook:
  * For reading the files multiple times,  use `dx download` to download to current instance. 
  * For reading the content file once or only small fraction of file's content, reading the content of iles in `/mnt/project` folder, which dynamically fetches the content from DNAnexus platform. 
* **Notes**, not sure about the difference, but the [documentation](https://documentation.dnanexus.com/user/jupyter-notebooks) mentioned `/mnt/project/` directory involve more api calls.

## Problems need to solve
1. Efficent way to get input?
2. How to trouble shoot?
  a. The GUI seems have no information about what goes in the command section?
  b. Error message ""

## Usefull git repositories
1. [dxWDL](https://github.com/dnanexus/dxWDL/blob/v1/doc/ExpertOptions.md#setting-a-default-docker-image-for-all-tasks): provide extra information about dxWDL file documentation.
2. [WDL](https://github.com/openwdl/wdl/blob/main/versions/1.1/SPEC.md#file-stdout): provide specification for WDL.
3. [dxCompiler](https://documentation.dnanexus.com/developer/building-and-executing-portable-containers-for-bioinformatics-software/dxcompiler#dxcompiler-setup): provide more documentation about dxCompiler, like `-extras`,`parameter_meta`. See also the [DNAnexus websit](https://documentation.dnanexus.com/developer/building-and-executing-portable-containers-for-bioinformatics-software/dxcompiler#dxcompiler-setup)
4. Other information from the DNAnexus like [billing](https://documentation.dnanexus.com/admin/org-management), [dx command](https://documentation.dnanexus.com/user/helpstrings-of-sdk-command-line-utilities#category-orgs),[DNAnexus websit](https://documentation.dnanexus.com/user/objects/searching-data-objects). 
