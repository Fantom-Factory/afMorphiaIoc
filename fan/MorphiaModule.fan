using concurrent::ActorPool
using afIoc
using afIocConfig::ConfigSource
using afIocConfig::FactoryDefaults
using afConcurrent::ActorPools
using afMongo::MongoSeqs
using afMongo::MongoColl
using afMongo::MongoClient
using afMongo::MongoConnMgr
using afMongo::MongoConnMgrPool
using afMongo::MongoDb
using afMorphia::BsonConvs
using afMorphia::BsonConv
using afMorphia::Morphia

internal const class MorphiaModule {
	Void defineServices(RegistryBuilder bob) {
		bob.addService(MongoClient#)
		bob.addService(MongoDb#)
	}

	@Contribute { serviceType=FactoryDefaults# }
	static Void contributeFactoryDefaults(Configuration config) {
		config["afMorphia.mongoUrl"] 		= `mongodb://localhost:27017/afMorphia`
		config["afMorphia.seqsCollName"]	= "Seqs"
	}
	
	@Contribute { serviceType=ActorPools# }
	static Void contributeActorPools(Configuration config) {
		config["afMongo.connMgrPool"]		= ActorPool() { it.name = "afMongo.connMgrPool"; it.maxThreads = 5 }
	}
	
	@Build { serviceId="afMongo::MongoConnMgr" }
	MongoConnMgr buildConnectionManager(ConfigSource configSrc, ActorPools actorPools) {
		mongoUrl  := (Uri) configSrc.get("afMorphia.mongoUrl", Uri#)
		actorPool := actorPools.get("afMongo.connMgrPool")
		conMgr	  := MongoConnMgrPool(mongoUrl, null, actorPool)
		// if we startup here, then is saves everyone pissing about trying to order their registry
		// startup contributions to be *after* "afMorphia.conMgrStartup" or similar.
		conMgr.startup
		return conMgr
	}
	
	@Build { serviceId="afMongo::MongoSeqs" }
	MongoSeqs buildMongoSeqs(ConfigSource configSrc, MongoConnMgr connMgr) {
		collName := (Str) configSrc.get("afMorphia.seqsCollName", Str#)
		return MongoSeqs(connMgr, collName)
	}
	
	@Build { serviceId="afMorphia::BsonConvs" }
	BsonConvs buildBsonConvs(Type:BsonConv converters, Registry reg) {
		BsonConvs(converters, [
			"makeEntityFn" : |Type type, Field:Obj? fieldVals->Obj?| {
				reg.activeScope.build(type, null, fieldVals)
			}
		])
	}	

	@Build { serviceId="afMorphia::Morphia" }
	Morphia buildMorphia(MongoConnMgr connMgr, BsonConvs bsonConvs) {
		Morphia(connMgr, bsonConvs)
	}
	
	@Contribute { serviceType=DependencyProviders# }
	Void contributeDependencyProviders(Configuration config) {
		config.set("afMorphia.collection", config.build(CollectionProvider#)).before("afIoc.service")
		config.set("afMorphia.datastore",  config.build( DatastoreProvider#)).before("afIoc.service")
	}
	
	@Contribute { serviceType=BsonConvs# }
	Void contributeBsonConvs(Configuration config) {
		BsonConvs.defConvs.each |conv, type| {
			config[type] = conv
		}
	}

	Void onRegistryShutdown(Configuration config, MongoConnMgr connMgr) {
		config["afMorphia.closeConnections"] = |->| {
			connMgr.shutdown
		}
	}
}
