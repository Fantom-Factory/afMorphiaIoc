# Morphia IoC v1.0.2
---

[![Written in: Fantom](http://img.shields.io/badge/written%20in-Fantom-lightgray.svg)](https://fantom-lang.org/)
[![pod: v1.0.2](http://img.shields.io/badge/pod-v1.0.2-yellow.svg)](http://eggbox.fantomfactory.org/pods/afMorphiaIoc)
[![Licence: ISC](http://img.shields.io/badge/licence-ISC-blue.svg)](https://choosealicense.com/licenses/isc/)

## Overview

Morphia IoC defines IoC services and contributions for the afMorphia and afMongo libraries.

It provides injectable instances of:

For **afMongo:**

* `MongoClient`
* `MongoColl`
* `MongoConnMgr`
* `MongoDb`
* `MongoSeqs`


For **afMorphia:**

* `BsonConvs`
* `Datastore`
* `Morhpia`


All that is required, is an `IocConfig` contribution for `"afMorphia.mongoUrl"`.

## <a name="Install"></a>Install

Install `Morphia IoC` with the Fantom Pod Manager ( [FPM](http://eggbox.fantomfactory.org/pods/afFpm) ):

    C:\> fpm install afMorphiaIoc

Or install `Morphia IoC` with [fanr](https://fantom.org/doc/docFanr/Tool.html#install):

    C:\> fanr install -r http://eggbox.fantomfactory.org/fanr/ afMorphiaIoc

To use in a [Fantom](https://fantom-lang.org/) project, add a dependency to `build.fan`:

    depends = ["sys 1.0", ..., "afMorphiaIoc 1.0"]

## <a name="documentation"></a>Documentation

Full API & fandocs are available on the [Eggbox](http://eggbox.fantomfactory.org/pods/afMorphiaIoc/) - the Fantom Pod Repository.

## <a name="quickStart"></a>Quick Start

Example usage showing injectable fields.

    using afIoc
    using afIocConfig
    using afBson
    using afMongo
    using afMorphia
    
    class Example {
    
        // Mongo services
        @Inject MongoConnMgr?   connMgr
        @Inject MongoClient?    client
        @Inject MongoDb?        db
        @Inject MongoSeqs?      seqs
        @Inject { type=ExampleUser# }
                MongoColl?      collection
    
        // Morphia services
        @Inject Morphia?        morphia
        @Inject BsonConvs?      bsonConvs
        @Inject { type=ExampleUser# }
                Datastore?      datastore
    
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
    

