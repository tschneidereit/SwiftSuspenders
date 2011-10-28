# SwiftSuspenders

Attention: This README is just a stub to prevent you from reading the heavily outdated [one for Swiftsuspenders 1.x](https://github.com/tschneidereit/SwiftSuspenders/blob/the-past/README.textile).

That being said, here's a very quick outline of the new version's capabilities and API:

## Features

- injection requests configurable using standardized metadata
- can inject into vars, setters, methods and constructors
- injection requests can be optional
- mapping dependencies by class and, optionally, name
- satisfying dependencies using value, class instance, singleton or custom providers
- chaining multiple injectors to create modular dependency-mapping graphs much like inheritance works in OOP
- defining local and shared scope for mappings, akin to public and private members of a class
- defining soft mappings that only get used if no injector higher up in the inheritance chain can satisfy a dependency
- support object live-cycle management (note: The latter part of that management, i.e. the destruction, is not yet implemented, but will be for 2.0 final)

## API

### Requests

Requests, aka injection points, can be defined using the metadata tag `[Inject]` atop the var, setter or method to inject into. For constructor injection, no metadata is required.

Named injections can be defined using the syntax `[Inject(name="injection name")]`. In this case, constructors have to have their metadata placed atop the class itself, not the constructor. This is a limitation of the Flex compiler.

Optional injection requests can be defined using the syntax `[Inject(optional=true)]`

### Mappings

The API is expressed as a DSL to make very fine-grained configuration of each mapping easy and readable:

	const injector : Injector = new Injector;
	
	//create a basic mapping:
	injector.map(Sprite); //will instantiate a new Sprite for each request for Sprite
	
	//map to another class:
	injector.map(Sprite).toType(BetterSprite); //will instantiate a new BetterSprite for each request for Sprite
	
	//map as a singleton:
	injector.map(EventDispatcher).asSingleton(); //will lazily create an instance and return it for each consecutive request
	
	//map an interface to a singleton:
	injector.map(IEventDispatcher).toSingleton(EventDispatcher);

### Beta

So, that's it for now as far as documentation is concerned. The implementation, on the other hand, is very stable and shouldn't regress anything that used to work in 1.x, as long as the API changes are dealt with, of course.

More documentation will soon come here, in the github wiki and as asdocs.