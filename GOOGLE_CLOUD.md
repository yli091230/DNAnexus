# Google Cloud setup
## Install the gcloud CLI
Based on google clould [instruction](https://cloud.google.com/sdk/docs/install)
## Initialize the gcloud CLI
Check the instruction [here](https://cloud.google.com/sdk/docs/initializing)
`gcloud auth login`
`gcloud config set project PROJECT_ID`
`gcloud auth configure-docker` configurate docker
`docker tag <image-name> <gcr-path>`

### Switch between multiple account and projects
For multiple projects or account, need to create separate configuration for each project/account, for details type`gcloud topic configurations`.
To create a new configurations, using `gcloud init`(tested, don't know how to change config name) or `gcloud config configurations create <my-config>`. 
To activate a configuration, using `gcloud config configurations activate <my-config>`; to display the path of the activate configuration run `gcloud info --format="get(config.paths.active_config_path)`.
To view current activate configuration use `gcloud config list`; to view all configurations using `gcloud config configurations list`.

* Parameters of configuration file can change using `gcloud config set`.
* List available accounts: `gcloud auth list`
* Switch the active account: `gcloud config set account <account-email>` 
* List available projects: `gcloud config list project`
* Switch to project `gcloud config set project <project-id>`

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

