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


		//----------------------               Public Methods               ----------------------//
		public function Injector(xmlConfig : XML = null)
		{
			_mappings = new Dictionary();
			if (xmlConfig != null)
			{
				_classDescriptor = new XMLClassDescriptor(new Dictionary(true), xmlConfig);
			}
			else
			{
				_classDescriptor = new ClassDescriptor(INJECTION_POINTS_CACHE);
			}
			_attendedToInjectees = new Dictionary(true);
		}

		public function map(type : Class) : InjectionRule
		{
			return _mappings[getQualifiedClassName(type) + ''] || createRule(type);
		}

		public function mapNamed(type : Class, name : String) : InjectionRule
		{
			return _mappings[getQualifiedClassName(type) + name] || createRule(type, name);
		}
		
		public function getMapping(requestType : Class, named : String = "") : InjectionRule
		{
			return _mappings[getQualifiedClassName(requestType) + named] ||
					getAncestorMapping(requestType, named);
		}
		
		public function injectInto(target : Object) : void
		{
			if (_attendedToInjectees[target])
			{
				return;
			}
			_attendedToInjectees[target] = true;

			var targetClass : Class = getConstructor(target);
			var injecteeDescription : ClassDescription =
					_classDescriptor.getDescription(targetClass);

			var injectionPoints : Array = injecteeDescription.injectionPoints;
			var length : int = injectionPoints.length;
			for (var i : int = 0; i < length; i++)
			{
				var injectionPoint : InjectionPoint = injectionPoints[i];
				injectionPoint.applyInjection(target, this);
			}
		}
		
		public function instantiate(type : Class) : *
		{
			var typeDescription : ClassDescription = _classDescriptor.getDescription(type);
			var injectionPoint : InjectionPoint = typeDescription.ctor;
			var instance : * = injectionPoint.applyInjection(type, this);
			injectInto(instance);
			return instance;
		}
		
		public function unmap(type : Class, named : String = "") : void
		{
			var mapping : InjectionRule = _mappings[getQualifiedClassName(type) + named];
			if (!mapping)
			{
				throw new InjectorError('Error while removing an injector mapping: ' +
					'No mapping defined for class ' + getQualifiedClassName(type) +
					', named "' + named + '"');
			}
			mapping.setProvider(null);
		}

		public function hasMapping(clazz : Class, named : String = '') : Boolean
		{
			var mapping : InjectionRule = getMapping(clazz, named);
			return mapping && mapping.hasProvider();
		}

		public function getInstance(clazz : Class, named : String = '') : *
		{
			var mapping : InjectionRule = getMapping(clazz, named);
			if (!mapping || !mapping.hasProvider())
			{
				throw new InjectorError('Error while getting mapping response: ' +
					'No mapping defined for class ' + getQualifiedClassName(clazz) +
					', named "' + named + '"');
			}
			return mapping.apply(this);
		}
		
		public function createChildInjector(applicationDomain:ApplicationDomain=null) : Injector
		{
			var injector : Injector = new Injector();
            injector.setApplicationDomain(applicationDomain);
			injector.setParentInjector(this);
			return injector;
		}
        
        public function setApplicationDomain(applicationDomain:ApplicationDomain):void
        {
            _applicationDomain = applicationDomain;
        }
        
        public function getApplicationDomain():ApplicationDomain
        {
            return _applicationDomain ? _applicationDomain : ApplicationDomain.currentDomain;
        }

		public function setParentInjector(parentInjector : Injector) : void
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
		
		public function getParentInjector() : Injector
		{
			return _parentInjector;
		}

		public static function purgeInjectionPointsCache() : void
		{
			INJECTION_POINTS_CACHE = new Dictionary(true);
		}


		//----------------------             Internal Methods               ----------------------//
		internal function getAncestorMapping(
				whenAskedFor : Class, named : String = null) : InjectionRule
		{
			return _parentInjector ? _parentInjector.getMapping(whenAskedFor, named) : null;
		}


		//----------------------         Private / Protected Methods        ----------------------//
		private function createRule(requestType : Class, name : String = '') : InjectionRule
		{
			//TODO: check if it's ok to use the Class itself as the key here
			return (_mappings[getQualifiedClassName(requestType) + name] =
					new InjectionRule(requestType, ''));
		}
	}
}