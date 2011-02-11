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
	import org.swiftsuspenders.utils.XMLClassDescriptor;
	import org.swiftsuspenders.utils.getConstructor;

	public class Injector
	{
		//----------------------       Private / Protected Properties       ----------------------//
		private static var INJECTION_POINTS_CACHE : Dictionary = new Dictionary(true);


		private var _parentInjector : Injector;
        private var _applicationDomain:ApplicationDomain;
		private var _classDescriptor : ClassDescriptor;
		private var _mappings : Dictionary;
		private var _attendedToInjectees : Dictionary;
		private var _namedInjectionsManager : NamedInjectionsManager;


		//----------------------               Public Methods               ----------------------//
		public function Injector(xmlConfig : XML = null)
		{
			_mappings = new Dictionary();
			_attendedToInjectees = new Dictionary(true);
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

		public function map(type : Class) : InjectionRule
		{
			return _mappings[type] || createRule(type);
		}

		public function getMapping(requestType : Class) : InjectionRule
		{
			return _mappings[requestType] || getAncestorMapping(requestType);
		}

		public function hasMapping(type : Class) : Boolean
		{
			var rule : InjectionRule = getMapping(type);
			return rule && rule.hasProvider();
		}

		public function unmap(type : Class) : void
		{
			var rule : InjectionRule = _mappings[type];
			if (!rule)
			{
				throw new InjectorError('Error while removing an injector mapping: ' +
						'No mapping defined for class ' + getQualifiedClassName(type));
			}
			rule.setProvider(null);
		}

		public function injectInto(target : Object) : void
		{
			if (_attendedToInjectees[target])
			{
				return;
			}
			_attendedToInjectees[target] = true;

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
			//restore own map of worked injectees if parent injector is removed
			if (_parentInjector && !parentInjector)
			{
				_attendedToInjectees = new Dictionary(true);
			}
			_parentInjector = parentInjector;
			//use parent's map of worked injectees
			if (parentInjector)
			{
				_attendedToInjectees = parentInjector._attendedToInjectees;
			}
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
		internal function getAncestorMapping(whenAskedFor : Class) : InjectionRule
		{
			return _parentInjector ? _parentInjector.getMapping(whenAskedFor) : null;
		}

		public function getRuleForInjectionPointConfig(
				config : InjectionPointConfig) : InjectionRule
		{
			var type : Class = Class(applicationDomain.getDefinition(config.typeName));
			if (config.injectionName)
			{
				return usingName(config.injectionName).getMapping(type);
			}
			return getMapping(type);
		}


		//----------------------         Private / Protected Methods        ----------------------//
		private function createRule(requestType : Class) : InjectionRule
		{
			return (_mappings[requestType] = new InjectionRule(requestType));
		}

		public function instantiateUnmapped(type : Class) : *
		{
			var typeDescription : ClassDescription = _classDescriptor.getDescription(type);
			var injectionPoint : InjectionPoint = typeDescription.ctor;
			var instance : * = injectionPoint.applyInjection(type, this);
			injectInto(instance);
			return instance;
		}
	}
}