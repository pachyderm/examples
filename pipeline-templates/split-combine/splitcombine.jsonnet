

local args(source, mode, lines, output) = 
    local localargs = ["--input", source,"--mode", mode, "--output", output ];
    if std.length(lines) >= 1 then localargs +["--linecount", lines] else localargs;

local glob(mode, sourcepath) =
    if mode == "split" then "/*" else if sourcepath == "/pfs/input/" then "/" else sourcepath;

function (name, source, sourcepath="/pfs/input/", mode, lines="0", output="/pfs/out/")
{
  pipeline: { name: name + "_" + mode },
  description: mode + "data from "+source+" and write to "+output,
  input: {
    pfs: {
      name: "input",
      glob: glob(mode, sourcepath),
      repo: source,
    }
  },
  transform: {
	image: "pachyderm/splitcombine:0.0.2",
	cmd: ["/splitcombine"] + args(sourcepath, mode, lines, output)
  }
}
