# Using DNAnexus to analyze UK Biobank data
## [UK Biobank Showcase user Guide](https://biobank.ndph.ox.ac.uk/showcase/ukb/exinfo/ShowcaseUserGuide.pdf)
## Install tools
1. Install Python SDK and Command Line Tools
  ```bash
  pip3 install dxpy
  eval "$(register-python-argcomplete dx|sed 's/-o default//')"
  ```
  * For MacOX with zsh, enable tab completion by running the following command
  ```bash
  autoload -Uz compinit && compinit
  autoload bashcompinit && bashcompinit
  eval "$(register-python-argcomplete dx|sed 's/-o default//')"
  ```
## UKBiobank sample information
The datset  contains WGS sequencing results from 200,025 samples with 2\*151 reads.
* All of the sample meta files can only access by JupyterLab, `dx cat` command is not allowed to view those file at the local termianl. 
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
* UKBiobank use reference genome GRCh38 but didn't specify the detailed verion. Based on the header of cram files, pick this one [GRCh38](http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/reference/GRCh38_reference_genome/GRCh38_full_analysis_set_plus_decoy_hla.fa).
  * Use `dx upload <local_directory> --destination <cloud_pathi>`.\
    The command may not function with large file, can use wdl to download file or use the [Upload Agent](https://documentation.dnanexus.com/user/objects/uploading-and-downloading-files/batch/upload-agent#uploading-a-single-file) recommended by DNAnexus (haven't try this one yet).
    
## Use DNAnexus to run workflow 
1. DNAnexus use AWS for computation job. By default, DNAnexus will use spot instance with small memory (need to confirm, can't find the documentation).  
2. To compile wdl file to workflow use `java -jar dxCompiler-2.10.4.jar compile <your_wdl_file> -project <ukb_project_id> -folder <directory_to_storage_on_DNAnexus>`. This will output a string "workflow-xxxx" that needed for running workflow. 
* If the `<directory_to_storage_on_DNAnexus>` does not exist, it will create for you. For example, /test/ folder not exist, it will create a /test/ folder under the root of your project and put the "workflow-xxxx" and other files in there.
* Use `dx ls --brief <directory_to_storage_on_DNAnexus>` to check workflow ID if forgot, `--long` flag to diplay full path and file ID.
* Use `--streamFiles [all, none, perfile(default)]` to mount data instead of download. For `perfile` need `parameter_meta` section in the wdl file.
3. To run workflow use `dx run <workflow-xxxx> -y -f input.json --destination <path_to_storage>`.
* To generate an `input.json` file, use `dx run <workflow-xx>` in an interactive mode and get the template for `input.json`. Alternatively, `java -jar dxCompiler.jar compile <your_wdl_file> -project project-xxxx -folder <directory_to_storage_on_DNAnexus> -inputs input.json` will convert Crowell JSON format input file into DNAnexus format during compiling `input.dx.json`.
  * `awk '{print "{ \n","\"$dnanexus_link\":",$NF, "\n},"}' random_100_cram_ab_15G.txt | tr '()' '""' | less` to get array of inputs.
* If `--destination` not specified, dx run will output results to root directory by default.
* If `<path_to_storage>` is not exist, it will create for you. To create `<path_to_storage>` manually use `dx mkdir -p <path_to_storage>`.
* Add `--name <job_name>` to specify job name, if not specified, it will use the workflow name as job name.
* Using `--head-job-on-demand` or `--priority` to specify on-demand or spot instance. **Need to double check**
4. How to set up [batch run](https://documentation.dnanexus.com/user/running-apps-and-workflows/running-batch-jobs) 

## [Monitoring executions](https://documentation.dnanexus.com/user/running-apps-and-workflows/monitoring-executions)
1. Executions contains both  analysis and Jobs (maybe wrong):
  * Analyses are executions of workflows and consist of one or more app(let)s
  * `dx find executions` to return 10 most recent executions in the current project.
  * `dx find analyses` to return top-level analyses, not any of the jobs.
1. How to check the job status using "Analysis ID: analysis-GGGfFFjJv7B1FFF291FPfFx5" that ouput call dx run.

### Notes on wdl file and docker
1. If the docker image is build on macbook with M1 CPU, use `docker buildx build --platform linux/amd64`. If not, it can't run on DNAnexus.
2. For test run, redirect stdout or stderr to a file is not recommended. DNAnexus wouldn't be able to transfer those error/infor if job failed, which makes the debugging very difficult. **But**, once test run works, it is better to redirect stdout and stderr as a output because the online log sometime wouldn't be fully display. 
3. If tools need other files that not specified in the options, make sure include those file in the `Input`.
4. To store docker images on DNAnexus, use `dx-docker` command:
* **Issues**:
  * Not sure whether this is the correct command to store images.
  * The command depend on `docker2aci` package, which is achrived and have trouble on installation.

## Run DXJupyterLab
1. To launch a JupyterLab session, select `JupyterLab` tab from the `TOOLS` menue and click on the `New JupyterLab` on the top right corner. Specify the project, instance type and other running information then start the session. After the session started, click on the `Open` button to open the JupyterLab in browser.

2. There are two types of notebooks: Local vs DNAnexus
* The main difference between the Local and DNAnexus is files (include ipynb and datas) in DNAnexus notebook will be kept after close of JupyterLab while files in Local notebook will lost. 
* To access data in your project from notebook:
  * For reading the files multiple times,  use `dx download` to download to current instance. 
  * For reading the content file once or only small fraction of file's content, reading the content of iles in `/mnt/project` folder, which dynamically fetches the content from DNAnexus platform. 
* **Notes**, not sure about the difference, but the [documentation](https://documentation.dnanexus.com/user/jupyter-notebooks) mentioned `/mnt/project/` directory involve more api calls.

## Problems need to solve
1. Efficent way to get input?
2. How to trouble shoot?
3. How to avoid run duplicated jobs?

## Usefull git repositories
1. [dxWDL](https://github.com/dnanexus/dxWDL/blob/v1/doc/ExpertOptions.md#setting-a-default-docker-image-for-all-tasks): provide extra information about dxWDL file documentation.
2. [WDL](https://github.com/openwdl/wdl/blob/main/versions/1.1/SPEC.md#file-stdout): provide specification for WDL.
3. [dxCompiler](https://documentation.dnanexus.com/developer/building-and-executing-portable-containers-for-bioinformatics-software/dxcompiler#dxcompiler-setup): provide more documentation about dxCompiler, like `-extras`,`parameter_meta`. See also the [DNAnexus websit](https://documentation.dnanexus.com/developer/building-and-executing-portable-containers-for-bioinformatics-software/dxcompiler#dxcompiler-setup)
4. Other information from the DNAnexus like [billing](https://documentation.dnanexus.com/admin/org-management), [dx command](https://documentation.dnanexus.com/user/helpstrings-of-sdk-command-line-utilities#category-orgs),[DNAnexus websit](https://documentation.dnanexus.com/user/objects/searching-data-objects). 

## To do
1. Check core numbers in the instance 
2. Where to change execution name using dx run.
3. check [SSH](https://documentation.dnanexus.com/developer/apps/execution-environment/connecting-to-jobs)
