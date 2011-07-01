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

	import org.swiftsuspenders.injectionpoints.InjectionPoint;
	import org.swiftsuspenders.injectionpoints.InjectionPointConfig;
	import org.swiftsuspenders.utils.ClassDescription;
	import org.swiftsuspenders.utils.ClassDescriptor;
	import org.swiftsuspenders.utils.SsInternal;
	import org.swiftsuspenders.utils.XMLClassDescriptor;
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
		public function Injector(xmlConfig : XML = null)
		{
			_mappings = new Dictionary();
			_namedInjectionsManager = new NamedInjectionsManager(this);
			if (xmlConfig != null)
			{
				_classDescriptor = new XMLClassDescriptor(new Dictionary(true), xmlConfig);
			}
			else
			{
				_classDescriptor = new ClassDescriptor(INJECTION_POINTS_CACHE);
			}
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
		 * @param dependency The dependency to return the mapped rule for
		 * @return The rule mapped to the specified dependency class
		 * @throws InjectorError when no rule was found for the specified dependency
		 */
		public function getRule(dependency : Class) : InjectionRule
		{
			var rule : InjectionRule = _mappings[dependency];
			if (!rule)
			{
				throw new InjectorError('Error while retrieving an injector mapping: ' +
						'No rule defined for dependency ' + getQualifiedClassName(dependency));
			}
			return rule;
		}

		public function injectInto(target : Object) : void
		{
			var injecteeDescription : ClassDescription =
					_classDescriptor.getDescription(getConstructor(target));

			var injectionPoints : Array = injecteeDescription.injectionPoints;
			var length : int = injectionPoints.length;
			for (var i : int = 0; i < length; i++)
			{
				var injectionPoint : InjectionPoint = injectionPoints[i];
				injectionPoint.applyInjection(target, this);
			}
		}

		public function getInstance(type : Class) : *
		{
			var mapping : InjectionRule = getMapping(type);
			if (!mapping || !mapping.hasProvider())
			{
				return instantiateUnmapped(type);
			}
			return mapping.apply(this);
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
			_applicationDomain = applicationDomain;
		}
		public function get applicationDomain() : ApplicationDomain
		{
			return _applicationDomain ? _applicationDomain : ApplicationDomain.currentDomain;
		}

		public function usingName(name : String) : NamedInjectionsManager
		{
			_namedInjectionsManager.setRequestName(name);
			return _namedInjectionsManager;
		}

		public static function purgeInjectionPointsCache() : void
		{
			INJECTION_POINTS_CACHE = new Dictionary(true);
		}


		//----------------------             Internal Methods               ----------------------//
		SsInternal function getMapping(requestType : Class) : InjectionRule
		{
			return _mappings[requestType] || getAncestorMapping(requestType);
		}

		SsInternal function getAncestorMapping(whenAskedFor : Class) : InjectionRule
		{
			return _parentInjector ? _parentInjector.getMapping(whenAskedFor) : null;
		}

		SsInternal function getRuleForInjectionPointConfig(
				config : InjectionPointConfig) : InjectionRule
		{
			var type : Class = Class(applicationDomain.getDefinition(config.typeName));
			if (config.injectionName)
			{
				return usingName(config.injectionName).getMapping(type);
			}
			return getMapping(type);
		}

		SsInternal function instantiateUnmapped(type : Class) : *
		{
			var typeDescription : ClassDescription = _classDescriptor.getDescription(type);
			var injectionPoint : InjectionPoint = typeDescription.ctor;
			if (!injectionPoint)
			{
				throw new InjectorError("Can't instantiate interface " + getQualifiedClassName(type));
			}
			var instance : * = injectionPoint.applyInjection(type, this);
			injectInto(instance);
			return instance;
		}


		//----------------------         Private / Protected Methods        ----------------------//
		private function createRule(requestType : Class) : InjectionRule
		{
			return new InjectionRule(this, requestType);
		}
	}
}