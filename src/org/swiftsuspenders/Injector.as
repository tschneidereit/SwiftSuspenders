/*
 * Copyright (c) 2012 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file 
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders
{
	import avmplus.DescribeTypeJSON;

	import flash.events.EventDispatcher;
	import flash.system.ApplicationDomain;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	import org.swiftsuspenders.dependencyproviders.DependencyProvider;
	import org.swiftsuspenders.dependencyproviders.FallbackDependencyProvider;
	import org.swiftsuspenders.dependencyproviders.LocalOnlyProvider;
	import org.swiftsuspenders.dependencyproviders.SoftDependencyProvider;
	import org.swiftsuspenders.errors.InjectorError;
	import org.swiftsuspenders.errors.InjectorInterfaceConstructionError;
	import org.swiftsuspenders.errors.InjectorMissingMappingError;
	import org.swiftsuspenders.mapping.InjectionMapping;
	import org.swiftsuspenders.mapping.MappingEvent;
	import org.swiftsuspenders.reflection.DescribeTypeJSONReflector;
	import org.swiftsuspenders.reflection.DescribeTypeReflector;
	import org.swiftsuspenders.reflection.Reflector;
	import org.swiftsuspenders.typedescriptions.ConstructorInjectionPoint;
	import org.swiftsuspenders.typedescriptions.InjectionPoint;
	import org.swiftsuspenders.typedescriptions.PreDestroyInjectionPoint;
	import org.swiftsuspenders.typedescriptions.TypeDescription;
	import org.swiftsuspenders.utils.SsInternal;
	import org.swiftsuspenders.utils.TypeDescriptor;

	use namespace SsInternal;

	/**
	 * This event is dispatched each time the injector instantiated a class
	 *
	 * <p>At the point where the event is dispatched none of the injection points have been processed.</p>
	 *
	 * <p>The only difference to the <code>PRE_CONSTRUCT</code> event is that
	 * <code>POST_INSTANTIATE</code> is only dispatched for instances that are created in the
	 * injector, whereas <code>PRE_CONSTRUCT</code> is also dispatched for instances the injector
	 * only injects into.</p>
	 *
	 * <p>This event is only dispatched if there are one or more relevant listeners attached to
	 * the dispatching injector.</p>
	 *
	 * @eventType org.swiftsuspenders.InjectionEvent.POST_INSTANTIATE
	 */
	[Event(name='postInstantiate', type='org.swiftsuspenders.InjectionEvent')]
	/**
	 * This event is dispatched each time the injector is about to inject into a class
	 *
	 * <p>At the point where the event is dispatched none of the injection points have been processed.</p>
	 *
	 * <p>The only difference to the <code>POST_INSTANTIATE</code> event is that
	 * <code>PRE_CONSTRUCT</code> is only dispatched for instances that are created in the
	 * injector, whereas <code>POST_INSTANTIATE</code> is also dispatched for instances the
	 * injector only injects into.</p>
	 *
	 * <p>This event is only dispatched if there are one or more relevant listeners attached to
	 * the dispatching injector.</p>
	 *
	 * @eventType org.swiftsuspenders.InjectionEvent.PRE_CONSTRUCT
	 */
	[Event(name='preConstruct', type='org.swiftsuspenders.InjectionEvent')]
	/**
	 * This event is dispatched each time the injector created and fully initialized a new instance
	 *
	 * <p>At the point where the event is dispatched all dependencies for the newly created instance
	 * have already been injected. That means that creation-events for leaf nodes of the created
	 * object graph will be dispatched before the creation-events for the branches they are
	 * injected into.</p>
	 *
	 * <p>The newly created instance's [PostConstruct]-annotated methods will also have run already.</p>
	 *
	 * <p>This event is only dispatched if there are one or more relevant listeners attached to
	 * the dispatching injector.</p>
	 *
	 * @eventType org.swiftsuspenders.InjectionEvent.POST_CONSTRUCT
	 */
	[Event(name='postConstruct', type='org.swiftsuspenders.InjectionEvent')]

	/**
	 * This event is dispatched each time the injector creates a new mapping for a type/ name
	 * combination, right before the mapping is created
	 *
	 * <p>At the point where the event is dispatched the mapping hasn't yet been created. Thus, the
	 * respective field in the event is null.</p>
	 *
	 * <p>This event is only dispatched if there are one or more relevant listeners attached to
	 * the dispatching injector.</p>
	 *
	 * @eventType org.swiftsuspenders.MappingEvent.PRE_MAPPING_CREATE
	 */
	[Event(name='preMappingCreate', type='org.swiftsuspenders.mapping.MappingEvent')]
	/**
	 * This event is dispatched each time the injector creates a new mapping for a type/ name
	 * combination, right after the mapping was created
	 *
	 * <p>At the point where the event is dispatched the mapping has already been created and stored
	 * in the injector's lookup table.</p>
	 *
	 * <p>This event is only dispatched if there are one or more relevant listeners attached to
	 * the dispatching injector.</p>
	 *
	 * @eventType org.swiftsuspenders.MappingEvent.POST_MAPPING_CREATE
	 */
	[Event(name='postMappingCreate', type='org.swiftsuspenders.mapping.MappingEvent')]
	/**
	 * This event is dispatched each time an injector mapping is changed in any way, right before
	 * the change is applied.
	 *
	 * <p>At the point where the event is dispatched the changes haven't yet been applied, meaning the
	 * mapping stored in the event can be queried for its pre-change state.</p>
	 *
	 * <p>This event is only dispatched if there are one or more relevant listeners attached to 
	 * the dispatching injector.</p>
	 *
	 * @eventType org.swiftsuspenders.MappingEvent.PRE_MAPPING_CHANGE
	 */
	[Event(name='preMappingChange', type='org.swiftsuspenders.mapping.MappingEvent')]
	/**
	 * This event is dispatched each time an injector mapping is changed in any way, right after
	 * the change is applied.
	 *
	 * <p>At the point where the event is dispatched the changes have already been applied, meaning
	 * the mapping stored in the event can be queried for its post-change state</p>
	 *
	 * <p>This event is only dispatched if there are one or more relevant listeners attached to 
	 * the dispatching injector.</p>
	 *
	 * @eventType org.swiftsuspenders.MappingEvent.POST_MAPPING_CHANGE
	 */
	[Event(name='postMappingChange', type='org.swiftsuspenders.mapping.MappingEvent')]
	/**
	 * This event is dispatched each time an injector mapping is removed, right after
	 * the mapping is deleted from the configuration.
	 *
	 * <p>At the point where the event is dispatched the changes have already been applied, meaning
	 * the mapping is lost to the injector and can't be queried anymore.</p>
	 *
	 * <p>This event is only dispatched if there are one or more relevant listeners attached to 
	 * the dispatching injector.</p>
	 *
	 * @eventType org.swiftsuspenders.MappingEvent.POST_MAPPING_REMOVE
	 */
	[Event(name='postMappingRemove', type='org.swiftsuspenders.mapping.MappingEvent')]
	/**
	 * This event is dispatched if an existing mapping is overridden without first unmapping it.
	 *
	 * <p>The reason for dispatching an event (and tracing a warning) is that in most cases,
	 * overriding existing mappings is a sign of bugs in the application. Deliberate mapping
	 * changes should be done by first removing the existing mapping.</p>
	 *
	 * <p>This event is only dispatched if there are one or more relevant listeners attached to 
	 * the dispatching injector.</p>
	 *
	 * @eventType org.swiftsuspenders.MappingEvent.POST_MAPPING_REMOVE
	 */
	[Event(name='mappingOverride', type='org.swiftsuspenders.mapping.MappingEvent')]

	/**
	 * The <code>Injector</code> manages the mappings and acts as the central hub from which all
	 * injections are started.
	 */
	public class Injector extends EventDispatcher
	{
		//----------------------       Private / Protected Properties       ----------------------//
		private static var INJECTION_POINTS_CACHE : Dictionary = new Dictionary(true);

		private var _parentInjector : Injector;
        private var _applicationDomain:ApplicationDomain;
		private var _classDescriptor : TypeDescriptor;
		private var _mappings : Dictionary;
		private var _mappingsInProcess : Dictionary;
		private var _managedObjects : Dictionary;
		private var _reflector : Reflector;
		private var _fallbackProvider : FallbackDependencyProvider;
		private var _blockParentFallbackProvider : Boolean = false;

		private static const _baseTypes:Array = initBaseTypeMappingIds(
				[Object, Array, Class, Function, Boolean, Number, int, uint, String]);

		private static function initBaseTypeMappingIds(types : Array) : Array
		{
			return types.map(function(type : Class, index : uint, list : Array) : String
				{
					return getQualifiedClassName(type) + '|';
				});
		}


		//----------------------            Internal Properties             ----------------------//
		SsInternal const providerMappings : Dictionary = new Dictionary();


		//----------------------               Public Methods               ----------------------//
		public function Injector()
		{
			_mappings = new Dictionary();
			_mappingsInProcess = new Dictionary();
			_managedObjects = new Dictionary();
			try
			{
				_reflector = DescribeTypeJSON.available
					? new DescribeTypeJSONReflector()
					: new DescribeTypeReflector();
			}
			catch (e:Error)
			{
				_reflector = new DescribeTypeReflector();
			}
			_classDescriptor = new TypeDescriptor(_reflector, INJECTION_POINTS_CACHE);
			_applicationDomain = ApplicationDomain.currentDomain;
		}

		/**
		 * Maps a request description, consisting of the <code>type</code> and, optionally, the
		 * <code>name</code>.
		 *
		 * <p>The returned mapping is created if it didn't exist yet or simply returned otherwise.</p>
		 *
		 * <p>Named mappings should be used as sparingly as possible as they increase the likelyhood
		 * of typing errors to cause hard to debug errors at runtime.</p>
		 *
		 * @param type The <code>class</code> describing the mapping
		 * @param name The name, as a case-sensitive string, to further describe the mapping
		 *
		 * @return The <code>InjectionMapping</code> for the given request description
		 *
		 * @see #unmap()
		 * @see org.swiftsuspenders.mapping.InjectionMapping
		 */
		public function map(type : Class, name : String = '') : InjectionMapping
		{
			const mappingId : String = getQualifiedClassName(type) + '|' + name;
			return _mappings[mappingId] || createMapping(type, name, mappingId);
		}

		/**
		 *  Removes the mapping described by the given <code>type</code> and <code>name</code>.
		 *
		 * @param type The <code>class</code> describing the mapping
		 * @param name The name, as a case-sensitive string, to further describe the mapping
		 *
		 * @throws org.swiftsuspenders.errors.InjectorError Descriptions that are not mapped can't be unmapped
		 * @throws org.swiftsuspenders.errors.InjectorError Sealed mappings have to be unsealed before unmapping them
		 *
		 * @see #map()
		 * @see org.swiftsuspenders.mapping.InjectionMapping
		 * @see org.swiftsuspenders.mapping.InjectionMapping#unseal()
		 */
		public function unmap(type : Class, name : String = '') : void
		{
			const mappingId : String = getQualifiedClassName(type) + '|' + name;
			var mapping : InjectionMapping = _mappings[mappingId];
			if (mapping && mapping.isSealed)
			{
				throw new InjectorError('Can\'t unmap a sealed mapping');
			}
			if (!mapping)
			{
				throw new InjectorError('Error while removing an injector mapping: ' +
						'No mapping defined for dependency ' + mappingId);
			}
			mapping.getProvider().destroy();
			delete _mappings[mappingId];
			delete providerMappings[mappingId];
			hasEventListener(MappingEvent.POST_MAPPING_REMOVE) && dispatchEvent(
				new MappingEvent(MappingEvent.POST_MAPPING_REMOVE, type, name, null));
		}

		/**
		 * Indicates whether the injector can supply a response for the specified dependency either
		 * by using a mapping of its own or by querying one of its ancestor injectors.
		 *
		 * @param type The type of the dependency under query
		 * @param name The name of the dependency under query
		 *
		 * @return <code>true</code> if the dependency can be satisfied, <code>false</code> if not
		 */
		public function satisfies(type : Class, name : String = '') : Boolean
		{
			const mappingId : String = getQualifiedClassName(type) + '|' + name;
			return getProvider(mappingId, true) != null;
		}

		/**
		 * Indicates whether the injector can directly supply a response for the specified
		 * dependency.
		 *
		 * <p>In contrast to <code>#satisfies()</code>, <code>satisfiesDirectly</code> only informs
		 * about mappings on this injector itself, without querying its ancestor injectors.</p>
		 *
		 * @param type The type of the dependency under query
		 * @param name The name of the dependency under query
		 *
		 * @return <code>true</code> if the dependency can be satisfied, <code>false</code> if not
		 */
		public function satisfiesDirectly(type : Class, name : String = '') : Boolean
		{
			return hasDirectMapping(type, name)
				|| getDefaultProvider(getQualifiedClassName(type) + '|' + name, false) != null;
		}

		/**
		 * Returns the mapping for the specified dependency class
		 *
		 * <p>Note that getMapping will only return mappings in exactly this injector, not ones
		 * mapped in an ancestor injector. To get mappings from ancestor injectors, query them 
		 * using <code>parentInjector</code>.
		 * This restriction is in place to prevent accidential changing of mappings in ancestor
		 * injectors where only the child's response is meant to be altered.</p>
		 * 
		 * @param type The type of the dependency to return the mapping for
		 * @param name The name of the dependency to return the mapping for
		 *
		 * @return The mapping for the specified dependency class
		 * 
		 * @throws org.swiftsuspenders.errors.InjectorMissingMappingError when no mapping was found
		 * for the specified dependency
		 */
		public function getMapping(type : Class, name : String = '') : InjectionMapping
		{
			const mappingId : String = getQualifiedClassName(type) + '|' + name;
			var mapping : InjectionMapping = _mappings[mappingId];
			if (!mapping)
			{
				throw new InjectorMissingMappingError('Error while retrieving an injector mapping: '
						+ 'No mapping defined for dependency ' + mappingId);
			}
			return mapping;
		}

		/**
		 * Inspects the given object and injects into all injection points configured for its class.
		 *
		 * @param target The instance to inject into
		 *
		 * @throws org.swiftsuspenders.errors.InjectorError The <code>Injector</code> must have mappings
		 * for all injection points
		 *
		 * @see #map()
		 */
		public function injectInto(target : Object) : void
		{
			const type : Class = _reflector.getClass(target);
			applyInjectionPoints(target, type, _classDescriptor.getDescription(type));
		}

		/**
		 * Instantiates the class identified by the given <code>type</code> and <code>name</code>.
		 *
		 * <p>The parameter <code>targetType</code> is only useful if the
		 * <code>InjectionMapping</code> used to satisfy the request might vary its result based on
		 * that <code>targetType</code>. An Example of that would be a provider returning a logger
		 * instance pre-configured for the instance it is used in.</p>
		 *
		 * @param type The <code>class</code> describing the mapping
		 * @param name The name, as a case-sensitive string, to use for mapping resolution
		 * @param targetType The type of the instance that is dependent on the returned value
		 *
		 * @return The mapped or created instance
		 *
		 * @throws org.swiftsuspenders.errors.InjectorMissingMappingError if no mapping was found
		 * for the specified dependency and no <code>fallbackProvider</code> is set.
		 */
		public function getInstance(type : Class, name : String = '', targetType : Class = null) : *
		{
			const mappingId : String = getQualifiedClassName(type) + '|' + name;
			const provider : DependencyProvider =
					getProvider(mappingId) || getDefaultProvider(mappingId, true);
			if(provider)
			{
				const ctor : ConstructorInjectionPoint = _classDescriptor.getDescription(type).ctor;
				return provider.apply(targetType, this, ctor ? ctor.injectParameters : null);
			}

			var fallbackMessage:String = _fallbackProvider
				? "the fallbackProvider, '" + _fallbackProvider + "', was unable to fulfill this request."
				: "the injector has no fallbackProvider.";
			
			throw new InjectorMissingMappingError('No mapping found for request ' + mappingId
					+ ' and ' + fallbackMessage);
		}

		/**
		 * Returns an instance of the given type. If the Injector has a mapping for the type, that
		 * is used for getting the instance. If not, a new instance of the class is created and
		 * injected into.
		 *
		 * @param type The type to get an instance of
		 * @return The instance that was created or retrieved from the mapped provider
		 *
		 * @throws org.swiftsuspenders.errors.InjectorMissingMappingError if no mapping is found
		 * for one of the type's dependencies and no <code>fallbackProvider</code> is set
		 * @throws org.swiftsuspenders.errors.InjectorInterfaceConstructionError if the given type
		 * is an interface and no mapping was found
		 */
		public function getOrCreateNewInstance(type : Class) : *
		{
			return satisfies(type) && getInstance(type) || instantiateUnmapped(type);
		}

		/**
		 * Creates an instance of the given type and injects into it.
		 *
		 * @param type The type to instantiate
		 * @return The new instance, with all of its dependencies fulfilled
		 *
		 * @throws org.swiftsuspenders.errors.InjectorMissingMappingError if no mapping is found
		 * for one of the type's dependencies and no <code>fallbackProvider</code> is set
		 */
		public function instantiateUnmapped(type : Class) : *
		{
			if(!canBeInstantiated(type))
			{
				throw new InjectorInterfaceConstructionError(
					"Can't instantiate interface " + getQualifiedClassName(type));
			}
			const description : TypeDescription = _classDescriptor.getDescription(type);
			const instance : * = description.ctor.createInstance(type, this);
			hasEventListener(InjectionEvent.POST_INSTANTIATE) && dispatchEvent(
				new InjectionEvent(InjectionEvent.POST_INSTANTIATE, instance, type));
			applyInjectionPoints(instance, type, description);
			return instance;
		}

		/**
		 * Uses the <code>TypeDescription</code> the injector associates with the given instance's
		 * type to iterate over all <code>[PreDestroy]</code> methods in the instance, supporting
		 * automated destruction.
		 *
		 * @param instance The instance to destroy
		 */
		public function destroyInstance(instance : Object) : void
		{
			if (!instance)
			{
				return;
			}
			const type : Class = _reflector.getClass(instance);
			const typeDescription : TypeDescription = getTypeDescription(type);
			for (var preDestroyHook : PreDestroyInjectionPoint = typeDescription.preDestroyMethods;
			     preDestroyHook; preDestroyHook = PreDestroyInjectionPoint(preDestroyHook.next))
			{
				preDestroyHook.applyInjection(instance, type, this);
			}
		}

		/**
		 * Destroys the injector by cleaning up all instances it manages.
		 *
		 * Cleanup in this context means iterating over all mapped dependency providers and invoking
		 * their <code>destroy</code> methods and calling preDestroy methods on all objects the
		 * injector created or injected into.
		 *
		 * Of note, the <link>SingletonProvider</link>'s implementation of <code>destroy</code>
		 * invokes all preDestroy methods on the managed singleton to guarantee its orderly
		 * destruction. Implementers of custom implementations of <link>DependencyProviders</link>
		 * are encouraged to do likewise.
		 */
		public function teardown() : void
		{
			for each (var mapping : InjectionMapping in _mappings)
			{
				mapping.getProvider().destroy();
			}
			for each (var instance : Object in _managedObjects)
			{
				destroyInstance(instance);
			}
			_mappings = new Dictionary();
			_mappingsInProcess = new Dictionary();
			_managedObjects = new Dictionary();
			_fallbackProvider = null;
			_blockParentFallbackProvider = false;
		}

		/**
		 * Creates a new <code>Injector</code> and sets itself as that new <code>Injector</code>'s
		 * <code>parentInjector</code>.
		 *
		 * @param applicationDomain The optional domain to use in the new Injector.
		 * If not given, the creating injector's domain is set on the new Injector as well.
		 * @return The newly created <code>Injector</code> instance
		 *
		 * @see #parentInjector
		 */
		public function createChildInjector(applicationDomain : ApplicationDomain = null) : Injector
		{
			var injector : Injector = new Injector();
            injector.applicationDomain = applicationDomain || this.applicationDomain;
			injector.parentInjector = this;
			return injector;
		}

		/**
		 * Sets the <code>Injector</code> to ask in case the current <code>Injector</code> doesn't
		 * have a mapping for a dependency.
		 *
		 * <p>Parent Injectors can be nested in arbitrary depths with very little overhead,
		 * enabling very modular setups for the managed object graphs.</p>
		 *
		 * @param parentInjector The <code>Injector</code> to use for dependencies the current
		 * <code>Injector</code> can't supply
		 */
		public function set parentInjector(parentInjector : Injector) : void
		{
			_parentInjector = parentInjector;
		}

		/**
		 * Returns the <code>Injector</code> used for dependencies the current
		 * <code>Injector</code> can't supply
		 */
		public function get parentInjector() : Injector
		{
			return _parentInjector;
		}

		public function set applicationDomain(applicationDomain : ApplicationDomain) : void
		{
			_applicationDomain = applicationDomain || ApplicationDomain.currentDomain;
		}
		public function get applicationDomain() : ApplicationDomain
		{
			return _applicationDomain;
		}

		/**
		 * Instructs the injector to use the description for the given type when constructing or
		 * destroying instances.
		 *
		 * The description consists details for the constructor, all properties and methods to
		 * inject into during construction and all methods to invoke during destruction.
		 *
		 * @param type
		 * @param description
		 */
		public function addTypeDescription(type : Class, description : TypeDescription) : void
		{
			_classDescriptor.addDescription(type, description);
		}

		/**
		 * Returns a description of the given type containing its constructor, injection points
		 * and post construct and pre destroy hooks
		 *
		 * @param type The type to describe
		 * @return The TypeDescription containing all information the injector has about the type
		 */
		public function getTypeDescription(type : Class) : TypeDescription
		{
			return _reflector.describeInjections(type);
		}
		
		public function hasMapping(type : Class, name : String = '') : Boolean
		{
			return getProvider(getQualifiedClassName(type) + '|' + name) != null;
		}
		
		public function hasDirectMapping(type : Class, name : String = '') : Boolean
		{
			return _mappings[getQualifiedClassName(type) + '|' + name] != null;
		}

		public function get fallbackProvider() : FallbackDependencyProvider
		{
			return _fallbackProvider;
		}

		public function set fallbackProvider(provider : FallbackDependencyProvider) : void
		{
			_fallbackProvider = provider;
		}

		public function get blockParentFallbackProvider() : Boolean
		{
			return _blockParentFallbackProvider;
		}

		public function set blockParentFallbackProvider(value : Boolean) : void
		{
			_blockParentFallbackProvider = value;
		}

		//----------------------             Internal Methods               ----------------------//
		SsInternal static function purgeInjectionPointsCache() : void
		{
			INJECTION_POINTS_CACHE = new Dictionary(true);
		}
				
		SsInternal function canBeInstantiated(type : Class) : Boolean
		{
			const description : TypeDescription = _classDescriptor.getDescription(type);
			return description.ctor != null;
		}

		SsInternal function getProvider(
			mappingId : String, fallbackToDefault : Boolean = true) : DependencyProvider
		{
			var softProvider : DependencyProvider;
			var injector : Injector = this;
			while (injector)
			{
				var provider : DependencyProvider =
						injector.SsInternal::providerMappings[mappingId];
				if (provider)
				{
					if (provider is SoftDependencyProvider)
					{
						softProvider = provider;
						injector = injector.parentInjector;
						continue;
					}
					if (provider is LocalOnlyProvider && injector !== this)
					{
						injector = injector.parentInjector;
						continue;
					}
					return provider;
				}
				injector = injector.parentInjector;
			}
			if (softProvider)
			{
				return softProvider;
			}
			return fallbackToDefault ? getDefaultProvider(mappingId, true) : null;
		}

		SsInternal function getDefaultProvider(
			mappingId : String, consultParents : Boolean) : DependencyProvider
		{
			//No meaningful way to automatically create base types without names
			if (_baseTypes.indexOf(mappingId) > -1)
			{
				return null;
			}

			if (_fallbackProvider && _fallbackProvider.prepareNextRequest(mappingId))
			{
				return _fallbackProvider;
			}
			if (consultParents && !_blockParentFallbackProvider && _parentInjector)
			{
				return _parentInjector.getDefaultProvider(mappingId,  consultParents);
			}
			return null;
		}


		//----------------------         Private / Protected Methods        ----------------------//
		private function createMapping(
			type : Class, name: String, mappingId : String) : InjectionMapping
		{
			if (_mappingsInProcess[mappingId])
			{
				throw new InjectorError(
					'Can\'t change a mapping from inside a listener to it\'s creation event');
			}
			_mappingsInProcess[mappingId] = true;
			
			hasEventListener(MappingEvent.PRE_MAPPING_CREATE) && dispatchEvent(
				new MappingEvent(MappingEvent.PRE_MAPPING_CREATE, type, name, null));

			const mapping : InjectionMapping = new InjectionMapping(this, type, name, mappingId);
			_mappings[mappingId] = mapping;

			const sealKey : Object = mapping.seal();
			hasEventListener(MappingEvent.POST_MAPPING_CREATE) && dispatchEvent(
				new MappingEvent(MappingEvent.POST_MAPPING_CREATE, type, name, mapping));
			delete _mappingsInProcess[mappingId];
			mapping.unseal(sealKey);
			return mapping;
		}

		private function applyInjectionPoints(
				target : Object, targetType : Class, description : TypeDescription) : void
		{
			var injectionPoint : InjectionPoint = description.injectionPoints;
			hasEventListener(InjectionEvent.PRE_CONSTRUCT) && dispatchEvent(
					new InjectionEvent(InjectionEvent.PRE_CONSTRUCT, target, targetType));
			while (injectionPoint)
			{
				injectionPoint.applyInjection(target, targetType, this);
				injectionPoint = injectionPoint.next;
			}
			if (description.preDestroyMethods)
			{
				_managedObjects[target] = target;
			}
			hasEventListener(InjectionEvent.POST_CONSTRUCT) && dispatchEvent(
					new InjectionEvent(InjectionEvent.POST_CONSTRUCT, target, targetType));
		}
	}
}