# Injector fallbackProviders

## Summary of the problem

### Missing mappings are usually a mistake...

- It's easy to forget to make a mapping, and developers want non-silent fails in these cases.
- Usage of extensions such as the SignalCommandMap becomes brittle, e.g. if the SCM silently-fails when a parameter isn't passed to the signal correctly.

### But having to map every little thing is tedious...

- If you just want a new instance to fulfil each slot in your dependency tree, it would be nice to be able to use the injector to construct that object tree without having to make numerous mappings.

## Introducing fallbackProviders

A fallbackProvider is where the injector turns for help when it doesn't have a mapping.

- Set through the `injector.fallbackProvider` property (default is `null`).
- Must implement `FallbackDependencyProvider`.
- The given instance will be used for all dependencies.
- Must implement the `prepareNextRequest` method, which returns a boolean saying whether it can or can't provide for this request.

### Order of strategies for checking `satisfies` & fulfilling dependencies

1. Local mappings
2. Parent (and ancestor) mappings
3. Local fallbackProvider
4. Parent (and ancestor) fallbackProviders (unless the `blockParentFallbackProvider` flag is set)
5. Explode with `InjectorMissingMappingError`

### `satisfies` and `getInstance` are consistent

The `satisfies` method now returns a boolean which essentially says whether or not you can `getInstance` for this type (and name).
The `satisfiesDirectly` method says whether you can `getInstance` without referring to ancestors.
If there is a fallbackProvider it will be checked.

### fallbackProvider restrictions and flexibility

- Unnamed injection only.
- Not available for common base types (Array, Boolean, Class, Function, int, Number, Object, String, uint) as these aren't sensible without names.
- Can support injection of interfaces if the fallbackProvider supports this.
- Can support async providers if you return a promise.
- Can be a facade delegating to a number of custom fallbackProviders.
- Setting `blockParentFallbackProvider` flag on the injector prevents the injector from consulting ancestors. This only applies to fallback providers; parent mappings can still be used. Useful for child injectors in extensions.

## `FreshInstanceProvider` fits the most common use case

- Can provide an injector-instantiated instance of any Class.
- Does not support interfaces.

To configure your injector to always allow instantiation of unmapped types requested for injection, just do:

	injector.fallbackProvider = new FreshInstanceProvider();
	
The `FreshInstanceProvider` uses `injector.instantiateUnmapped` internally, so injected types can have nested injections fulfilled too.

## `instantiateUnmapped` always returns a fresh instance

- Regardless of any mappings.
- Ignores any fallbackProvider.
- Can only be used for classes, not interfaces (type must have a constructor).
- Will use mappings / fallbackProvider for the dependency tree.
- In the case where you have relevant mappings but you don't want to use mappings / fallbackProvider for the dependency tree, you have options such as:
	* Make a normal factory.
	* Roll a (non fallback) DependencyProvider that implements this and map the top type to this provider.
	* Roll a fallbackProvider that forwards to a provider like the one in (2).
	* Consider a different architecture, e.g. Entity based, for this part of the system.

## `getOrCreateNewInstance` = `getInstance` (unnamed) or `instantiateUnmapped`

Provides a single point of entry to obtain a mapped instance if one exists, or a new instance if one doesn't, with identical constraints and flexibility to the methods it wraps.

Essentially a sugar method so:

	var instance:SomeType = injector.getOrCreateNewInstance(SomeType);
	
is equivalent to
	
	var instance:SomeType = injector.satisfies(SomeType)
							? injector.getInstance(SomeType)
							: injector.instantiateUnmapped(SomeType);

This method doesn't support names. If you know you need a name then you should always use `getInstance(type, name)`;