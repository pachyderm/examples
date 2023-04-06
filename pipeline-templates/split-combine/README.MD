# Split-Combine

This pipeline either splits or combines text files

## How to use

The template needs a few arguments:
- `name` is the name of the pipeline. We add the mode to the end of it so `name=foo` creates a pipeline called `foo_split`
- `mode` is the mode (`split` or `combine`)
- `source` is the source repo name
- `output` is the output directory. defaults to `/pfs/out` if you're doing a `combine` it should be the full path to the combined output file.
- `lines` is required in `split` mode. How many lines shoud be in each output file
- `sourcepath` is the path in the repo to the files or files you want to split/combine. it defaults to `/pfs/input`

## Some examples:

### To split file
```bash
pachctl create pipeline --jsonnet <url or path to splitcombine.jsonnet> \
  --arg name="mypipeline" --arg source="datafiles" \
  --arg mode="split" --arg lines=1000
```

### How to combine files

```bash
pachctl create pipeline --jsonnet <url or path to splitcombine.jsonnet> \
  --arg name="mypipeline" --arg source="datafiles" \
  --arg mode="combine" --arg output="/pfs/out/mycsv.csv"
```
