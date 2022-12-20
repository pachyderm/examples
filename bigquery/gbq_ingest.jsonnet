function(name='gbp_ingest', inputQuery, outFile, project, cronSpec, credsFile)
{
  pipeline: { name: name},
  input: {
    cron: {
      name: "in",
      spec: cronSpec,
      overwrite: true,
    }
  },
  transform: {
    cmd: [ "python","gbq_ingest.py","-i", inputQuery,  "-o", "/pfs/out/"+outFile, "-p", project, "-c","/kubesecret/"+credsFile],
    image: "jimmywhitaker/gbq_ingest:dev0.01",
    env: {
        "GOOGLE_APPLICATION_CREDENTIALS": "/kubesecret/"+credsFile
    },
    secrets: [ {
				name: "gbqsecret",
				mount_path: "/kubesecret/",
    }],
  }
}
