hapi-mongoose-handler
=====================
- Easly turn you mongoose models into API endpoint. 
- Converts mongoose validation errors to 401 with an appropriate error message
- Trys to follow hapi's configuration centric stlye


Example
=======

```javascript
var Hapi    = require('hapi');

//fist we need to require this package :P
var Handler = require('hapi-mongoose-handler');

//2) we need a mongoose model
var SomeModel = require('path/to/model');

//3) we create a new generic handler with the prevous model
var SomeHandler = new Handler({
  model: SomeModel
});

//4) create some routes for hapi and use the method provided by the handler we created
var routes = [
  {
    method: "POST",
    path: "/something",
    config: {
      handler: SomeHandler.create(),
      auth: true
    }
  }, {
    //use the param _id to delete by
    method: "DELETE",
    path: "/something/{_id}",
    config: {
      handler: SomeHandler.delete(),
      auth: true
    }
  }, {
    //use the param _id + queryString to find by
    method: "GET",
    path: "/something/{_id}",
    config: {
      handler: SomeHandler.findOne()
    }
  }, {
    //uses the queryString querystring to search
    method: "GET",
    path: "/somethings/",
    config: {
      handler: SomeHandler.find()
    }
  }
];

Hapi.routes(routes);
```

Referance
=========
## new Handler([options])
Create a new instance of hapi-mongoose-handler. 
### options
The following options are valid.

- `model` - the mongoose model we want to create an API for
- `config` - a hash that set some configuation values for mongo
  - `maxLimit` - the max number of results to return
  - `defaultOrder` the order of the results if no `order` is specified in the query
- `fields` - hash of fields that will be saved to the model. Used by `create` and `update` Each field can have the following option
  - `validate` - a function that is given the field value, `params` and  `request` and returns a string if invalid else return null
  - `transform` - a function that is given the field value, `params` and  `request` and returns the new value for the field
  - function - if only a function is given it is use a the `transform` option
- `queries` - the same as fields except used to query mongo. Used by `update`, `delete`, `find` and `findOne`. The values come from the querystring.
- `check` - a function that return a true/false before modifing the model, runs on `update`, `delete`, `create`  
- `omit` - an array of fields to omit
- `before` - a function that runs before anything else. It is given `fields` and the `request` object. You can return a modified `field`.
- `after` - a function that runs after the model as been found or modified. It is given the results of the mongoose query and the `request` object. Whatever you turn will be the response. You can use this to wrap or modify the results from mongo. 

### method
theres are the method attached to handler instance. Each of the function take a options hash with the some option as the contructor. This enables you to overload the option for each individual handler
- `create` create a document using the payload from the request
- `find` find documents using the querystring to search by
- `findOne` find one document using the querystring ORed with request.param as the condition parameter
- `delete` delete one  document using the querystring ORed with request.param as the condition parameter


Examples
========

Lets add some field to transfrom to the first example

```javascript
//3) we create a new generic handler with the prevous model
var SomeHandler = new Handler({
  model: SomeModel,
  fields: {
      //someFieldVal comes from request.params.someField
      someField: function(someFieldVal, params, request){
        //return a new value for the field
        return "Cadaverously Quaint ";
      }
  }
});
```

Here is how you would add some extra validation
```javascript
//3) we create a new generic handler with the prevous model
var SomeHandler = new Handler({
  model: SomeModel,
  fields: {
      //someFieldVal comes from request.params.someField
      someField:{
        transform: function(someFieldVal, params, request){
        //return a new value for the field
        return "Cadaverously Quaint";
        },
        //validation run after traform, so this will also return true
        validate: function(someFieldVal, params, request){
          //if false hapi will return a 401 error with a error message for someField
          return someFieldVal == "Cadaverously Quaint";
        }
      }
  }
});
```

If you want to overload an individual handler.

//3) we create a new generic handler with the prevous model
var SomeHandler = new Handler();

If you want to overload an individual handler.

```javascript
//3) we create a new generic handler with the prevous model
var SomeHandler = new Handler({
  model: someModel
});


var routes = [{
    method: "POST",
    path: "/something",
    config: {
      //create will now act on someThingElse instead of someModel 
      handler: SomeHandler.create({
        model: someThingElse,
     })
    }
}];
```
More Examples
=============
[MetaGeo's event controller](https://github.com/craveprogramminginc/metageo-core/blob/master/controllers/eventController.coffee)

FAQs
====
### So this shit is broken, now what?
please open an [issue](https://github.com/craveprogramminginc/hapi-mongoose-handler/issues).

### uhmm its written in coffeesccript and that not 'what the gods intended'
Diversity is good, stop being a racist.  

### Why am I using mongoose in the first place?
I don't know and thats beyond the scope of this project.
  
