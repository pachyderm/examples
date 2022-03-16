local newPipeline(name, input, transform) = {
	pipeline: {
		name: name,
	},
	transform: transform,
	input: input,	
};
local pachtf(args, secretName="") = {
	image: "pachyderm/pachtf:2.1.0-4134687d870acfa0224f639fcd39d72c11a63d73",
	cmd: ["/app/pachtf"] + args,
	secrets: if secretName != "" then
		[
			{
				name: secretName,
				env_var: "PACHYDERM_SQL_PASSWORD",
				key: "PACHYDERM_SQL_PASSWORD",
			}
		]
	else
		null
	,
};

function (name, url, query, format, cronSpec, secretName)
	local queryPipelineName = name + "_queries";
	[
	newPipeline(
		name=queryPipelineName,
	 	input={
			cron: {
				name: "in",
				spec: cronSpec,
				overwrite: true,
			}
	  },
	  transform=pachtf(["sql-gen-queries", query]),
	),
	newPipeline(
		name=name,
		input={
			pfs: {
				name: "in",
				repo: queryPipelineName,
				glob: "/*",
			},
		},
		transform=pachtf(["sql-ingest", url, format], secretName),
	)
	]
