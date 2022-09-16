////
// Template arguments:
//
// name : The name of this pipeline, for disambiguation when 
//          multiple instances are created.
// input : the repo from which this pipeline will read the csv file to which
//       it applies automl.
// target_col : the column of the csv to be used as the target
// args : additional parameters to pass to the automl regressor (e.g. "--random_state 42")
////
function(name='regression', input, target_col, args='')
{
  pipeline: { name: name},
  input: {
    pfs: {
      glob: "/",
      repo: input
    }
  },
  transform: {
    cmd: [ "python","/workdir/automl.py","--input","/pfs/"+input+"/", "--target-col", target_col, "--output","/pfs/out/"]+ std.split(args, ' '),
    image: "jimmywhitaker/automl:dev0.02"
  }
}
