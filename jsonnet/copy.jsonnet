function(name, output)
{
  pipeline: { name: name+"-pipeline" },
  input: {
    pfs: {
      name: "input",
      glob: "/*",
      repo: "data"
    }
  },
  transform: {
    cmd: [ "/bin/bash" ],
    stdin: [ "cp /pfs/input/* /pfs/out/"+output ]
  }
}

