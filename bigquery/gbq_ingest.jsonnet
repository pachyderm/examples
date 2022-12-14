function(name='gbp_ingest', inputQuery, outFile, project, cronSpec)
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
    cmd: [ "python","gbq_ingest.py","-i", inputQuery,  "-o", "/pfs/out/"+outFile, "-p", project, "-c","/kubesecret/mycreds.json"],
    image: "jimmywhitaker/gbq_ingest:dev0.01",
    env: {
        "GOOGLE_APPLICATION_CREDENTIALS": "/kubesecret/mycreds.json"
    },
    secrets: [ {
				name: "gbqsecret",
				mount_path: "/kubesecret/",
    }],
  }
}
