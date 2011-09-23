/*
 * Copyright (c) 2009-2011 the original author or authors
 * 
 * Permission is hereby granted to use, modify, and distribute this file 
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders
{
	import flash.system.ApplicationDomain;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;

	import org.swiftsuspenders.injectionpoints.ConstructorInjectionPoint;

	import org.swiftsuspenders.injectionpoints.InjectionPoint;
	import org.swiftsuspenders.injectionpoints.InjectionPointConfig;
	import org.swiftsuspenders.utils.ClassDescriptor;
	import org.swiftsuspenders.utils.SsInternal;
	import org.swiftsuspenders.utils.getConstructor;

	use namespace SsInternal;

	public class Injector
	{
		//----------------------       Private / Protected Properties       ----------------------//
		private static var INJECTION_POINTS_CACHE : Dictionary = new Dictionary(true);

		private var _parentInjector : Injector;
        private var _applicationDomain:ApplicationDomain;
		private var _classDescriptor : ClassDescriptor;
		private var _mappings : Dictionary;
		private var _namedInjectionsManager : NamedInjectionsManager;


		//----------------------               Public Methods               ----------------------//
		public function Injector()
		{
			_mappings = new Dictionary();
			_namedInjectionsManager = new NamedInjectionsManager(this);
			_classDescriptor = new ClassDescriptor(INJECTION_POINTS_CACHE);
			_applicationDomain = ApplicationDomain.currentDomain;
		}

		public function map(dependency : Class) : InjectionRule
		{
			return _mappings[dependency] ||= createRule(dependency);
		}

		public function unmap(dependency : Class) : void
		{
			var rule : InjectionRule = _mappings[dependency];
			if (!rule)
			{
				throw new InjectorError('Error while removing an injector mapping: ' +
						'No rule defined for dependency ' + getQualifiedClassName(dependency));
			}
			rule.setProvider(null);
		}

		/**
		 * Indicates whether the injector can supply a response for the specified dependency either
		 * by using a rule mapped directly on itself or by querying one of its ancestor injectors.
		 *
		 * @param dependency The dependency under query
		 * @return <code>true</code> if the dependency can be satisfied, <code>false</code> if not
		 */
		public function satisfies(dependency : Class) : Boolean
		{
			var rule : InjectionRule = getMapping(dependency);
			return rule && rule.hasProvider();
		}

		/**
		 * Indicates whether the injector can directly supply a response for the specified
		 * dependency
		 *
		 * In contrast to <code>satisfies</code>, <code>satisfiesDirectly</code> only informs
		 * about rules mapped directly on itself, without querying its ancestor injectors.
		 *
		 * @param dependency The dependency under query
		 * @return <code>true</code> if the dependency can be satisfied, <code>false</code> if not
		 */
		public function satisfiesDirectly(dependency : Class) : Boolean
		{
			var rule : InjectionRule = _mappings[dependency];
			return rule && rule.hasProvider();
		}

		/**
		 * Returns the rule mapped to the specified dependency class
		 *
		 * Note that getRule will only return rules mapped in exactly this injector, not ones
		 * mapped in an ancestor injector. To get rules from ancestor injectors, query them using
		 * <code>parentInjector</code>.
		 * This restriction is in place to prevent accidential changing of rules in ancestor
		 * injectors where only the child's response is meant to be altered.
		 * 
		 * @param type The dependency to return the mapped rule for
		 * @return The rule mapped to the specified dependency class
		 * @throws InjectorError when no rule was found for the specified dependency
		 */
		public function getRule(type : Class) : InjectionRule
		{
			var rule : InjectionRule = _mappings[type];
			if (!rule)
			{
				throw new InjectorError('Error while retrieving an injector mapping: ' +
						'No rule defined for dependency ' + getQualifiedClassName(type));
			}
			return rule;
		}

		public function injectInto(target : Object) : void
		{
			var ctorInjectionPoint : InjectionPoint =
					_classDescriptor.getDescription(getConstructor(target));

			applyInjectionPoints(target, ctorInjectionPoint.next);
		}

		public function getInstance(type : Class) : *
		{
			var mapping : InjectionRule = getMapping(type);
			if (mapping && mapping.hasProvider())
			{
				return mapping.apply(this);
			}
			return instantiateUnmapped(type);
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

		public function usingName(name : String) : NamedInjectionsManager
		{
			_namedInjectionsManager.setRequestName(name);
			return _namedInjectionsManager;
		}


		//----------------------             Internal Methods               ----------------------//
		SsInternal static function purgeInjectionPointsCache() : void
		{
			INJECTION_POINTS_CACHE = new Dictionary(true);
		}

		SsInternal function getMapping(requestType : Class) : InjectionRule
		{
			return _mappings[requestType] || getAncestorMapping(requestType);
		}

		SsInternal function getMappingByName(requestTypeName : String) : InjectionRule
		{
			return _mappings[requestTypeName] || getAncestorMappingByName(requestTypeName);
		}

		SsInternal function getAncestorMapping(requestType : Class) : InjectionRule
		{
			if (_parentInjector)
			{
				return _parentInjector.getMapping(requestType);
			}
			return null;
		}

		SsInternal function getAncestorMappingByName(requestTypeName : String) : InjectionRule
		{
			if (_parentInjector)
			{
				return _parentInjector.getMappingByName(requestTypeName);
			}
			return null;
		}

		SsInternal function getRuleForInjectionPointConfig(
				config : InjectionPointConfig) : InjectionRule
		{
			if (config.injectionName)
			{
				var type : Class = Class(applicationDomain.getDefinition(config.typeName));
				return usingName(config.injectionName).getMapping(type);
			}
			return getMappingByName(config.typeName);
		}

		SsInternal function instantiateUnmapped(type : Class) : *
		{
			var ctorInjectionPoint : ConstructorInjectionPoint =
					_classDescriptor.getDescription(type);
			if (!ctorInjectionPoint)
			{
				throw new InjectorError(
						"Can't instantiate interface " + getQualifiedClassName(type));
			}
			var instance : * = ctorInjectionPoint.createInstance(type, this);
			applyInjectionPoints(instance, ctorInjectionPoint.next);
			return instance;
		}


		//----------------------         Private / Protected Methods        ----------------------//
		private function createRule(requestType : Class) : InjectionRule
		{
			const rule : InjectionRule = new InjectionRule(this, requestType);
			_mappings[getQualifiedClassName(requestType)] = rule;
			return rule;
		}

		private function applyInjectionPoints(
				target : Object, injectionPoint : InjectionPoint) : void
		{
			while (injectionPoint)
			{
				injectionPoint.applyInjection(target, this);
				injectionPoint = injectionPoint.next;
			}
		}
	}
}