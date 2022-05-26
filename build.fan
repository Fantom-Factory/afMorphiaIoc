using build::BuildPod

class Build : BuildPod {

	new make() {
		podName = "afMorphiaIoc"
		summary = "IoC Contributions for Mongo and Morphia"
		version = Version("1.0.1")

		meta = [
			"pod.dis"		: "Morphia IoC",
			"repo.tags"		: "database",
			"repo.public"	: "true",
			"afIoc.module"	: "afMorphiaIoc::MorphiaModule",
		]

		depends = [
			"sys          1.0.73 - 1.0", 
			"concurrent   1.0.73 - 1.0",	// for contributing an ActorPool 
			
			// ---- Core ------------------------
			"afConcurrent 1.0.26 - 1.0",
			"afIoc        3.0.0  - 3.0",
			"afIocConfig  1.1.0  - 1.1",

			// ---- Mongo -----------------------
			"afBson       2.0.0 - 2.0",
			"afMongo      2.0.0 - 2.0",
			"afMorphia    2.0.0 - 2.0",
		]
		
		srcDirs = [`fan/`, `test/`]
		resDirs = [`doc/`]
	}
}
