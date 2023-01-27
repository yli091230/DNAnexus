## Run workflow on All of US platform
### Install and initilize [Google Cloud CLI](https://cloud.google.com/sdk/docs)
1. How to install google clould: [instruction](https://cloud.google.com/sdk/docs/install)
2. How to initilize google cloud CLI [here](https://cloud.google.com/sdk/docs/initializing)
  1. Use a different google cloud account (not the AoU email one, **should be the ucsd email**) to loggin the google cloud and [creat a project](https://cloud.google.com/resource-manager/docs/creating-managing-projects) or [select a exist project](https://console.cloud.google.com/projectselector2/home/dashboard?_ga=2.231392601.710925857.1663345404-1626730909.1663177519)
  2. Switch between multiple account and projects: the current project information is `PROJECT_ID: ucsd-medicine-cast  NAME: ucsd-medicine-cast  PROJECT_NUMBER: 167974413636`.
    * For multiple projects or account, need to create separate configuration for each project/account, for details type`gcloud topic configurations`.
    * To create a new configurations, using `gcloud init`(tested, don't know how to change config name) or `gcloud config configurations create <my-config>`. 
    * To activate a configuration, using `gcloud config configurations activate <my-config>`; to display the path of the activate configuration run `gcloud info --format="get(config.paths.active_config_path)`.
    * To view current activate configuration use `gcloud config list`; to view all configurations using `gcloud config configurations list`.
3. Other common use command
  ```bash
  * Parameters of configuration file can change using `gcloud config set`.
  * List available accounts: `gcloud auth list`
  * Switch the active account: `gcloud config set account <account-email>` 
  * List available projects: `gcloud config list project`
  * Switch to project `gcloud config set project <project-id>`
  ```
### [Set up billing](https://aousupporthelp.zendesk.com/hc/en-us/articles/360039539411)
### Set up GCR (based on this [tutorial](https://cloud.google.com/container-registry/docs/access-control)
1. Enable API (may only need to first time use):
  * Use [Google Cloud Console](https://console.cloud.google.com/flows/enableapi?apiid=containerregistry.googleapis.com&_ga=2.127657035.710925857.1663345404-1626730909.1663177519)
  * Use `gcloud` command:
    ```bash
    gcloud services enable containerregistry.googleapis.com
    ````
  * To disable API: go to this [link](https://console.cloud.google.com/apis/library/containerregistry.googleapis.com?_ga=2.236692935.710925857.1663345404-1626730909.1663177519), select the project, click **Manage**, then click **Disable API**.
2. Commands for set up the gcr 
    ```bash
    gcloud auth login
    gcloud config set project PROJECT_ID
    gcloud auth configure-docker
    docker tag <image-name> <gcr-path>
    docker tag yli091230/hipstr:amd64 gcr.io/ucsd-medicine-cast/hipstr:amd64\n
    docker push gcr.io/ucsd-medicine-cast/hipstr:amd64
    ```
3. Role and permissions:
* Recommend to use a service account.
  1. The first push requires [Storage Admin role](https://cloud.google.com/storage/docs/access-control/iam-roles) to create a storage bucket for the registry.
  2. After the initial image push:
    * Stoc

### How to use workbench tools
1. cohort builder --> concept set selector --> Dataset builder --> Jupyter notebook
* Cohort builder:
  * Create review set
* Dataset Builder:
  * Cohorts:Participants, Concept set (for each sample):Rows, Values:Columns
2. Jupyter notebook build directly
3. Docker images must be stored in GCR.
  * Example to push docker image `busybox` to `gcr`:
    `my-project` is the `project ID`.\
    ```bash
    docker pull busybox
    docker tag busybox gcr.io/my-project/busybox
    docker push gcr.io/my-project/busybox
    ```
  * The user need [permission](https://cloud.google.com/container-registry/docs/access-control) to pull and push images.
### Submit job through command line
Check [dsub](https://aousupporthelp.zendesk.com/hc/en-us/articles/4692986669332-Use-dsub-in-the-All-of-Us-Researcher-Workbench-)
### Where to store the data
1. Google cloud bucket and local (workspace bucket)
* **Need to check ggogle cloud bucket and how it works in AoU platform**
* Can we output all of the files to the fix/permenant bucket?
* Do we need to left the notebook run during wdl



## Google clould storage access
**NOTE**, for All of Us project, the `WORKSPACE_BUCKET` can not access through local terminal.
# Cromwell
## Set up the configuration file
For transfer multiple large files to instance, enable the [**Parallel composite uploads**](https://cromwell.readthedocs.io/en/stable/backends/Google/#parallel-composite-uploads) in the cromwell configuration file. 
Example file:
```
backend {
  ...
  providers {
    ...
    PapiV2 {
      actor-factory = "cromwell.backend.google.pipelines.v2beta.PipelinesApiLifecycleActorFactory"
      config {
        ...
        genomics {
          ...
          parallel-composite-upload-threshold = 150M
          ...
        }
        ...
      }
    }
  }
}
```
## Set up optional parameters
List of Google pipelines API workflow [options](https://cromwell.readthedocs.io/en/stable/wf_options/Google/).

1. Run with preemptible instance
This is to run job on a preemptible instance for 1 time, if premptied, then use on-demand device. 
```bash
options_filename = "options.json"
options_content = f'{{\n  "jes_gcs_root": "{output_bucket}",\n  "default_runtime_attributes": {{\n    "preemptible": "1"\n    }}\n}}'
fp = open(options_filename, 'w')
fp.write(options_content)
fp.close()
```
2. Output directory
```bash
{
    "final_workflow_outputs_dir": "/Users/michael_scott/cromwell/outputs",
    "use_relative_output_paths": true,
    "final_workflow_log_dir": "/Users/michael_scott/cromwell/wf_logs",
    "final_call_logs_dir": "/Users/michael_scott/cromwell/call_logs"
}
```
# Questions
1. How to ssh into VM locally
2. Parallel transfer file?
  * Using Parallel Composite Uploads
  * how to use the `enable_fuse` in cromwell for google cloud
3. How to custom configuration files

