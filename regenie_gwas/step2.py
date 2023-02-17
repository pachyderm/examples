import os
import subprocess
import sys
import yaml

# get the input repositories from the command line arguments
example_repo = sys.argv[1]
step1_repo = sys.argv[2]

# set the output directory to "/pfs/out"
output_dir = "/pfs/out"

# walk the config repository and find all the YAML files
for root, dirs, files in os.walk(sys.argv[3]):
    for file in files:
        if file.endswith(".yaml"):
            # construct the path to the YAML file
            yaml_file = os.path.join(root, file)

            # read the YAML file and parse it into a dictionary
            with open(yaml_file, 'r') as f:
                yaml_dict = yaml.safe_load(f)

            # check if this is step 2
            if 'step2' in yaml_dict:
                # this is step 2
                step = 2
                bgen = os.path.join(example_repo, yaml_dict['step2']['bgen'])
                covarFile = os.path.join(example_repo, yaml_dict['step2']['covarFile'])
                phenoFile = os.path.join(example_repo, yaml_dict['step2']['phenoFile'])
                remove = os.path.join(example_repo, yaml_dict['step2']['remove'])
                bsize = yaml_dict['step2']['bsize']
                bt = "--bt" if yaml_dict['step2']['bt'] else ""
                firth = "--firth" if yaml_dict['step2']['firth'] else ""
                approx = "--approx" if yaml_dict['step2']['approx'] else ""
                pThresh = yaml_dict['step2']['pThresh']
                pred = os.path.join(step1_repo, yaml_dict['step2']['pred'])
                out = os.path.join(output_dir, yaml_dict['step2']['out'])

                # set the command as a list of strings
                command = ["/usr/local/bin/regenie",
                           f"--step {step}",
                           f"--bgen {bgen}",
                           f"--covarFile {covarFile}",
                           f"--phenoFile {phenoFile}",
                           f"--remove {remove}",
                           f"--bsize {bsize}",
                           bt,
                           firth,
                           approx,
                           f"--pThresh {pThresh}",
                           f"--pred {pred}",
                           f"--out {out}"]

                # add any additional optional parameters to the command
                if 'optional_params' in yaml_dict['step2']:
                    for param, value in yaml_dict['step2']['optional_params'].items():
                        command.append(f"--{param} {value}")

                # run the command using subprocess.run()
                result = subprocess.run(' '.join(command), shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

                # print the result
                print(result.stdout)
