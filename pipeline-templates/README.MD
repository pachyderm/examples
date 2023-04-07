# Pipeline Templates

A collection of jsonnet pipeline templates that provide specific capabilities.

## Template Subdirectories

---
## `split-combine` 
### Description:
can be used to split text files into multiple files every x lines or combine multiple files into a single file.
### Usage
Splitting:
This will take any files in the input repo `myrepo` and split it into seperate files every `1000` lines
```bash
pachctl create pipeline --jsonnet https://raw.githubusercontent.com/pachyderm/examples/master/pipeline-templates/split-combine/splitcombine.jsonnet \
--arg name="mypipeline" --arg mode="split" \
--arg lines=1000 --arg source="myrepo"
```
Combining:
This will combine all the files in the `mypipeline_split` repo and combine them into a single file
```bash
pachctl create pipeline --jsonnet https://raw.githubusercontent.com/pachyderm/examples/master/pipeline-templates/split-combine/splitcombine.jsonnet \
--arg name="mypipeline_2" --arg mode="combine" --arg source="mypipeline_split"
```
---
