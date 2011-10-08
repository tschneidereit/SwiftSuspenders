/*
 * Copyright (c) 2009-2011 the original author or authors
 * 
 * Permission is hereby granted to use, modify, and distribute this file 
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders
{
	import flash.events.EventDispatcher;
	import flash.system.ApplicationDomain;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;

	import org.swiftsuspenders.dependencyproviders.DependencyProvider;
	import org.swiftsuspenders.dependencyproviders.LocalOnlyProvider;
	import org.swiftsuspenders.dependencyproviders.SoftDependencyProvider;
	import org.swiftsuspenders.injectionpoints.ConstructorInjectionPoint;
	import org.swiftsuspenders.injectionpoints.InjectionPoint;
	import org.swiftsuspenders.utils.ClassDescriptor;
	import org.swiftsuspenders.utils.SsInternal;
	import org.swiftsuspenders.utils.getConstructor;

	use namespace SsInternal;

	/**
	 * This event is dispatched each time the injector instantiated a class
	 *
	 * At the point where the event is dispatched none of the injection points have been processed.
	 *
	 * The only difference to the <code>PRE_CONSTRUCT</code> event is that
	 * <code>POST_INSTANTIATE</code> is only dispatched for instances that are created in the
	 * injector, whereas <code>PRE_CONSTRUCT</code> is also dispatched for instances the injector
	 * only injects into.
	 *
	 * This event is only dispatched when there are one or more relevant listeners
	 * attached to the dispatching injector.
	 *
	 * @eventType org.swiftsuspenders.InjectorEvent
	 */
	[Event(name='postInstantiate', type='org.swiftsuspenders.InjectorEvent')]
	/**
	 * This event is dispatched each time the injector is about to inject into a class
	 *
	 * At the point where the event is dispatched none of the injection points have been processed.
	 *
	 * The only difference to the <code>POST_INSTANTIATE</code> event is that
	 * <code>PRE_CONSTRUCT</code> is only dispatched for instances that are created in the
	 * injector, whereas <code>POST_INSTANTIATE</code> is also dispatched for instances the
	 * injector only injects into.
	 *
	 * This event is only dispatched when there are one or more relevant listeners
	 * attached to the dispatching injector.
	 *
	 * @eventType org.swiftsuspenders.InjectorEvent
	 */
	[Event(name='preConstruct', type='org.swiftsuspenders.InjectorEvent')]
	/**
	 * This event is dispatched each time the injector created and fully initialized a new instance
	 *
	 * At the point where the event is dispatched all dependencies for the newly created instance
	 * have already been injected. That means that creation-events for leaf nodes of the created
	 * object graph will be dispatched before the creation-events for the branches they are
	 * injected into.
	 *
	 * The newly created instance's [PostConstruct]-annotated methods will also have run already.
	 *
	 * This event is only dispatched when there are one or more relevant listeners
	 * attached to the dispatching injector.
	 *
	 * @eventType org.swiftsuspenders.InjectorEvent
	 */
	[Event(name='postConstruct', type='org.swiftsuspenders.InjectorEvent')]


	public class Injector extends EventDispatcher
	{
		//----------------------       Private / Protected Properties       ----------------------//
		private static var INJECTION_POINTS_CACHE : Dictionary = new Dictionary(true);

		private var _parentInjector : Injector;
        private var _applicationDomain:ApplicationDomain;
		private var _classDescriptor : ClassDescriptor;
		private var _mappings : Dictionary;


		//----------------------            Internal Properties             ----------------------//
		SsInternal const providerMappings : Dictionary = new Dictionary();


		//----------------------               Public Methods               ----------------------//
		public function Injector()
		{
			_mappings = new Dictionary();
			_classDescriptor = new ClassDescriptor(INJECTION_POINTS_CACHE);
			_applicationDomain = ApplicationDomain.currentDomain;
		}

		public function map(type : Class, name : String = '') : InjectionMapping
		{
			const mappingId : String = getQualifiedClassName(type) + '|' + name;
			return _mappings[mappingId] ||= createMapping(type, mappingId);
		}

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
			delete _mappings[mappingId];
			delete providerMappings[mappingId];
		}

		/**
		 * Indicates whether the injector can supply a response for the specified dependency either
		 * by using a mapping of its own or by querying one of its ancestor injectors.
		 *
		 * @param type The dependency under query
		 * @return <code>true</code> if the dependency can be satisfied, <code>false</code> if not
		 */
		public function satisfies(type : Class, name : String = '') : Boolean
		{
			return getProvider(getQualifiedClassName(type) + '|' + name) != null;
		}

		/**
		 * Indicates whether the injector can directly supply a response for the specified
		 * dependency
		 *
		 * In contrast to <code>satisfies</code>, <code>satisfiesDirectly</code> only informs
		 * about mappings on this injector itself, without querying its ancestor injectors.
		 *
		 * @param type The dependency under query
		 * @return <code>true</code> if the dependency can be satisfied, <code>false</code> if not
		 */
		public function satisfiesDirectly(type : Class, name : String = '') : Boolean
		{
			return providerMappings[getQualifiedClassName(type) + '|' + name] != null;
		}

		/**
		 * Returns the mapping for the specified dependency class
		 *
		 * Note that getMapping will only return mappings in exactly this injector, not ones
		 * mapped in an ancestor injector. To get mappings from ancestor injectors, query them 
		 * using <code>parentInjector</code>.
		 * This restriction is in place to prevent accidential changing of mappings in ancestor
		 * injectors where only the child's response is meant to be altered.
		 * 
		 * @param type The dependency to return the mapping for
		 * @return The mapping for the specified dependency class
		 * @throws InjectorError when no mapping was found for the specified dependency
		 */
		public function getMapping(type : Class, name : String = '') : InjectionMapping
		{
			const mappingId : String = getQualifiedClassName(type) + '|' + name;
			var mapping : InjectionMapping = _mappings[mappingId];
			if (!mapping)
			{
				throw new InjectorError('Error while retrieving an injector mapping: ' +
						'No mapping defined for dependency ' + mappingId);
			}
			return mapping;
		}

		public function injectInto(target : Object) : void
		{
			const type : Class = getConstructor(target);
			var ctorInjectionPoint : InjectionPoint = _classDescriptor.getDescription(type);

			applyInjectionPoints(target, type, ctorInjectionPoint.next);
		}

		public function getInstance(type : Class, name : String = '') : *
		{
			const mappingId : String = getQualifiedClassName(type) + '|' + name;
			var result : Object = applyMapping(type, mappingId);
			if (result)
			{
				return result;
			}
			if (name)
			{
				throw new InjectorError('No mapping found for request ' + mappingId
						+ '. getInstance only creates an unmapped instance if no name is given.');
			}
			return instantiateUnmapped(type, type);
		}
		
		public function createChildInjector(applicationDomain : ApplicationDomain = null) : Injector
		{
			var injector : Injector = new Injector();
            injector.applicationDomain = applicationDomain;
			injector.parentInjector = this;
			return injector;
		}

		public function set parentInjector(parentInjector : Injector) : void
		{
			_parentInjector = parentInjector;
		}
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


		//----------------------             Internal Methods               ----------------------//
		SsInternal static function purgeInjectionPointsCache() : void
		{
			INJECTION_POINTS_CACHE = new Dictionary(true);
		}

		SsInternal function instantiateUnmapped(type : Class, targetType : Class) : Object
		{
			var ctorInjectionPoint : ConstructorInjectionPoint =
					_classDescriptor.getDescription(type);
			if (!ctorInjectionPoint)
			{
				throw new InjectorError(
						"Can't instantiate interface " + getQualifiedClassName(type));
			}
			const instance : * = ctorInjectionPoint.createInstance(type, this);
			hasEventListener(InjectorEvent.POST_INSTANTIATE)
				&& dispatchEvent(new InjectorEvent(InjectorEvent.POST_INSTANTIATE, instance, type));
			applyInjectionPoints(instance, type, ctorInjectionPoint.next);
			return instance;
		}

		SsInternal function applyMapping(targetType : Class, mappingId : String) : Object
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
					return provider.apply(targetType, this);
				}
				injector = injector.parentInjector;
			}
			return softProvider && softProvider.apply(targetType, this);
		}


		//----------------------         Private / Protected Methods        ----------------------//
		private function createMapping(type : Class, mappingId : String) : InjectionMapping
		{
			return new InjectionMapping(this, type, mappingId);
		}

		private function applyInjectionPoints(
				target : Object, targetType : Class, injectionPoint : InjectionPoint) : void
		{
			hasEventListener(InjectorEvent.PRE_CONSTRUCT) && dispatchEvent(
					new InjectorEvent(InjectorEvent.PRE_CONSTRUCT, target, targetType));
			while (injectionPoint)
			{
				injectionPoint.applyInjection(target, targetType, this);
				injectionPoint = injectionPoint.next;
			}
			hasEventListener(InjectorEvent.POST_CONSTRUCT) && dispatchEvent(
					new InjectorEvent(InjectorEvent.POST_CONSTRUCT, target, targetType));
		}

		private function getProvider(mappingId : String) : DependencyProvider
		{
			var injector : Injector = this;
			while (injector)
			{
				if (injector.providerMappings[mappingId])
				{
					return injector.providerMappings[mappingId];
				}
				injector = injector.parentInjector;
			}
			return null;
		}
	}
}