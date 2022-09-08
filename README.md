#Using DNAnexus to analyze UK Biobank data

#Get access to data

#Install tools for local access DNAnexus

1. Get files names that stored in DNAnexus, `dx find data --name "<file_name_pattern>" --path "<path_want_to_check>" > filename_list.txt`

2. Workflow management on DNAnexus
  1. To compile wdl file to workflow use `java -jar dxCompiler-2.10.4.jar compile <your_wdl_file> -project <ukb_project_id> -folder <directory_to_storage_on_DNAnexus>`. This will output a string "workflow-xxxx" that needed for running workflow. 
    * If the `<directory_to_storage_on_DNAnexus>` does not exist, it will create for you. For example, /test/ folder not exist, it will create a /test/ folder under the root of your project and put the "workflow-xxxx" and other files in there.
    * Use `dx ls --brief <directory_to_storage_on_DNAnexus>` to check workflow ID if forgot.
  2. To run workflow use `dx run <workflow-xxxx> -y -f input.json --destination <path_to_storage>`.
    * To generate an `input.json` file, use `dx run <workflow-xx>` in an interactive mode and get the template for `input.json`. Alternatively, `java -jar dxCompiler.jar compile <your_wdl_file> -project project-xxxx -folder <directory_to_storage_on_DNAnexus> -inputs input.json` will convert Crowell JSON format input file into DNAnexus format during compiling `input.dx.json`.
    * If `--destination` not specified, dx run will output results to root directory by default.
    * If `<path_to_storage>` is not exist, it will create for you. To create `<path_to_storage>` manually use `dx mkdir -p <path_to_storage>`.
  4. How to check the job status using "Analysis ID: analysis-GGGfFFjJv7B1FFF291FPfFx5" that ouput call dx run
