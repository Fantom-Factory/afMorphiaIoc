using afIoc
using afIocConfig
using afBson
using afMongo
using afMorphia

class Example {
	
	// Mongo services
	@Inject MongoConnMgr?	connMgr
	@Inject MongoClient?	client
	@Inject MongoDb?		db
	@Inject MongoSeqs?		seqs
	@Inject { type=ExampleUser# }
			MongoColl?		collection
	
	// Morphia services
	@Inject Morphia?		morphia
	@Inject BsonConvs?		bsonConvs
	@Inject { type=ExampleUser# }
			Datastore?		datastore

	Void main() {
		scope := RegistryBuilder()
			.addModulesFromPod("afMorphiaIoc")
			.addModule(ExampleModule#)
			.build
			.rootScope
		scope.inject(this)
		
		echo("Done.")
		
		scope.registry.shutdown
	}
}

@Entity
class ExampleUser {
	@BsonProp ObjectId   _id
	@BsonProp Str        name
	@BsonProp Int        age

	new make(|This|in) { in(this) }
}

const class ExampleModule {
	@Contribute { serviceType=ApplicationDefaults# }
	Void contributeAppDefaults(Configuration config) {
		config["afMorphia.mongoUrl"] = `mongodb://localhost:27017/afMorphiaTest`
	}
}
