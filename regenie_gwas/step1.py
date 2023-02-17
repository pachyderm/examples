import os
import sys
import subprocess
import yaml

# get the input repositories from the command line arguments
yaml_repo = sys.argv[1]
example_repo = sys.argv[2]

# set the output directory to "/pfs/out"
output_dir = "/pfs/out"


# walk the YAML repository and find all the YAML files
for root, dirs, files in os.walk(yaml_repo):
    for file in files:
        if file.endswith(".yaml"):
            # construct the path to the YAML file
            yaml_file = os.path.join(root, file)

            # read the YAML file and parse it into a dictionary
            with open(yaml_file, 'r') as f:
                yaml_dict = yaml.safe_load(f)

            # extract the step number from the dictionary
            step = yaml_dict['step1']['step']

            # set the output file name with "/pfs/out" added to the beginning
            output_file = os.path.join(output_dir, yaml_dict['step1']['out'])

            # set the command as a list of strings
            command = ["/usr/local/bin/regenie",
                       "--step 1",
                       f"--bed {os.path.join(example_repo, yaml_dict['step1']['bed'])}",
                       f"--exclude {os.path.join(example_repo, yaml_dict['step1']['exclude'])}",
                       f"--covarFile {os.path.join(example_repo, yaml_dict['step1']['covarFile'])}",
                       f"--phenoFile {os.path.join(example_repo, yaml_dict['step1']['phenoFile'])}",
                       f"--remove {os.path.join(example_repo, yaml_dict['step1']['remove'])}",
                       f"--bsize {yaml_dict['step1']['bsize']}",
                       "--bt" if yaml_dict['step1']['bt'] else "",
                       "--lowmem" if yaml_dict['step1']['lowmem'] else "",
                       f"--lowmem-prefix {yaml_dict['step1']['lowmem-prefix']}",
                       f"--out {output_file}"]

            # add any additional optional parameters to the command
            if 'optional_params' in yaml_dict['step1']:
                for param, value in yaml_dict['step1']['optional_params'].items():
                    command.append(f"--{param} {value}")

            # run the command using subprocess.run()
            result = subprocess.run(' '.join(command), shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

            # print the result
            print(result.stdout)
            
            # open the fit_bin_out_pred.list file for reading
            with open("/pfs/out/fit_bin_out_pred.list", "r") as f:
                # read the contents of the file
                contents = f.read()

            # replace all instances of "/pfs/out" with "/pfs/step1"
            contents = contents.replace("/pfs/out", "/pfs/step1")

            # open the file for writing
            with open("/pfs/out/fit_bin_out_pred.list", "w") as f:
                # write the updated contents to the file
                f.write(contents)
