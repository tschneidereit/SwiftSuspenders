/*
 * Copyright (c) 2011 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders
{
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;

	public class NamedInjectionsManager
	{
		//----------------------       Private / Protected Properties       ----------------------//
		private var _injector : Injector;
		private var _mappings : Dictionary;
		
		private var _requestName : String;


		//----------------------               Public Methods               ----------------------//
		public function NamedInjectionsManager(injector : Injector)
		{
			_injector = injector;
			_mappings = new Dictionary();
		}

		public function map(type : Class) : InjectionRule
		{
			return _mappings[getQualifiedClassName(type) + _requestName] || createRule(type);
		}

		public function getMapping(requestType : Class) : InjectionRule
		{
			return _mappings[getQualifiedClassName(requestType) + _requestName] ||
					getAncestorMapping(requestType);
		}
		
		public function hasMapping(type : Class) : Boolean
		{
			var rule : InjectionRule = getMapping(type);
			return rule && rule.hasProvider();
		}

		public function unmap(type : Class) : void
		{
			var mapping : InjectionRule = _mappings[getQualifiedClassName(type) + _requestName];
			if (!mapping)
			{
				throw new InjectorError('Error while removing an injector mapping: ' +
						'No mapping defined for class ' + getQualifiedClassName(type) +
						', _requestName "' + _requestName + '"');
			}
			mapping.setProvider(null);
		}

		public function getInstance(type : Class) : *
		{
			var mapping : InjectionRule = getMapping(type);
			if (!mapping || !mapping.hasProvider())
			{
				throw new InjectorError('Error while getting mapping response: ' +
						'No mapping defined for class ' + getQualifiedClassName(type) +
						', _requestName "' + _requestName + '"');
			}
			return mapping.apply(_injector);
		}

		internal function getAncestorMapping(whenAskedFor : Class) : InjectionRule
		{
			return _injector.parentInjector ? _injector.parentInjector.usingName(_requestName).
					getMapping(whenAskedFor) : null;
		}


		//----------------------         Private / Protected Methods        ----------------------//
		private function createRule(requestType : Class) : InjectionRule
		{
			return (_mappings[getQualifiedClassName(requestType) + _requestName] =
					new NamedInjectionRule(requestType, ''));
		}

		internal function setRequestName(name : String) : void
		{
			_requestName = name;
		}
	}
}