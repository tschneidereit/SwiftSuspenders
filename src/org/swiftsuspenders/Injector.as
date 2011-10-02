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


		//----------------------               Public Methods               ----------------------//
		public function Injector()
		{
			_mappings = new Dictionary();
			_classDescriptor = new ClassDescriptor(INJECTION_POINTS_CACHE);
			_applicationDomain = ApplicationDomain.currentDomain;
		}

		public function map(type : Class, name : String = '') : InjectionRule
		{
			const mappingId : String = getQualifiedClassName(type) + '|' + name;
			return _mappings[mappingId] ||= createRule(type, mappingId);
		}

		public function unmap(type : Class, name : String = '') : void
		{
			const mappingId : String = getQualifiedClassName(type) + '|' + name;
			var rule : InjectionRule = _mappings[mappingId];
			if (!rule)
			{
				throw new InjectorError('Error while removing an injector mapping: ' +
						'No rule defined for dependency ' + mappingId);
			}
			rule.setProvider(null);
		}

		/**
		 * Indicates whether the injector can supply a response for the specified dependency either
		 * by using a rule mapped directly on itself or by querying one of its ancestor injectors.
		 *
		 * @param type The dependency under query
		 * @return <code>true</code> if the dependency can be satisfied, <code>false</code> if not
		 */
		public function satisfies(type : Class, name : String = '') : Boolean
		{
			const  rule : InjectionRule = getMapping(getQualifiedClassName(type) + '|' + name);
			return rule && rule.hasProvider();
		}

		/**
		 * Indicates whether the injector can directly supply a response for the specified
		 * dependency
		 *
		 * In contrast to <code>satisfies</code>, <code>satisfiesDirectly</code> only informs
		 * about rules mapped directly on itself, without querying its ancestor injectors.
		 *
		 * @param type The dependency under query
		 * @return <code>true</code> if the dependency can be satisfied, <code>false</code> if not
		 */
		public function satisfiesDirectly(type : Class, name : String = '') : Boolean
		{
			const rule : InjectionRule = _mappings[getQualifiedClassName(type) + '|' + name];
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
		public function getRule(type : Class, name : String = '') : InjectionRule
		{
			const mappingId : String = getQualifiedClassName(type) + '|' + name;
			var rule : InjectionRule = _mappings[mappingId];
			if (!rule)
			{
				throw new InjectorError('Error while retrieving an injector mapping: ' +
						'No rule defined for dependency ' + mappingId);
			}
			return rule;
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
			var mapping : InjectionRule = getMapping(mappingId);
			if (mapping && mapping.hasProvider())
			{
				return mapping.apply(type, this);
			}
			if (name)
			{
				throw new InjectorError('No mapping found for request ' + mappingId
						+ '. getInstance only creates an unmapped instance if no name is given.');
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


		//----------------------             Internal Methods               ----------------------//
		SsInternal static function purgeInjectionPointsCache() : void
		{
			INJECTION_POINTS_CACHE = new Dictionary(true);
		}

		SsInternal function getAncestorMapping(mappingId : String) : InjectionRule
		{
			return _parentInjector ? _parentInjector.getMapping(mappingId) : null;
		}

		SsInternal function getMapping(mappingId : String) : InjectionRule
		{
			return _mappings[mappingId] || getAncestorMapping(mappingId);
		}

		SsInternal function instantiateUnmapped(type : Class) : Object
		{
			var ctorInjectionPoint : ConstructorInjectionPoint =
					_classDescriptor.getDescription(type);
			if (!ctorInjectionPoint)
			{
				throw new InjectorError(
						"Can't instantiate interface " + getQualifiedClassName(type));
			}
			var instance : Object = ctorInjectionPoint.createInstance(type, this);
			applyInjectionPoints(instance, type, ctorInjectionPoint.next);
			return instance;
		}


		//----------------------         Private / Protected Methods        ----------------------//
		private function createRule(type : Class, mappingId : String) : InjectionRule
		{
			return new InjectionRule(this, type, mappingId);
		}

		private function applyInjectionPoints(
				target : Object, targetType : Class, injectionPoint : InjectionPoint) : void
		{
			while (injectionPoint)
			{
				injectionPoint.applyInjection(target, targetType, this);
				injectionPoint = injectionPoint.next;
			}
		}
	}
}