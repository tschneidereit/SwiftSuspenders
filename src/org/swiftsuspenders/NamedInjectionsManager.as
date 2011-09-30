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

	import org.hamcrest.text.re;

	import org.swiftsuspenders.utils.SsInternal;

	use namespace SsInternal;

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

		/**
		 * @copy org.swiftsuspenders.Injector#map()
		 */
		public function map(type : Class) : InjectionRule
		{
			return _mappings[getQualifiedClassName(type) + _requestName] || createRule(type);
		}

		/**
		 * @copy org.swiftsuspenders.Injector#unmap()
		 */
		public function unmap(dependency : Class) : void
		{
			var mapping : InjectionRule =
					_mappings[getQualifiedClassName(dependency) + _requestName];
			if (!mapping)
			{
				throw new InjectorError('Error while removing an injector mapping: ' +
						'No mapping defined for class ' + getQualifiedClassName(dependency) +
						', _requestName "' + _requestName + '"');
			}
			mapping.setProvider(null);
		}

		/**
		 * @copy org.swiftsuspenders.Injector#satisfies()
		 */
		public function satisfies(dependency : Class) : Boolean
		{
			var rule : InjectionRule = getMapping(dependency);
			return rule && rule.hasProvider();
		}

		/**
		 * @copy org.swiftsuspenders.Injector#satisfiesDirectly()
		 */
		public function satisfiesDirectly(dependency : Class) : Boolean
		{
			var rule : InjectionRule = _mappings[dependency];
			return rule && rule.hasProvider();
		}

		/**
		 * @copy org.swiftsuspenders.Injector#getRule()
		 */
		public function getRule(dependency : Class) : InjectionRule
		{
			var rule : InjectionRule = _mappings[dependency];
			if (!rule)
			{
				throw new InjectorError('Error while retrieving an injector mapping: ' +
						'No rule defined for dependency ' + getQualifiedClassName(dependency) +
						', named "' + _requestName + '"');
			}
			return rule;
		}

		/**
		 * @copy org.swiftsuspenders.Injector#getInstance()
		 */
		public function getInstance(type : Class) : *
		{
			var mapping : InjectionRule = getMapping(type);
			if (!mapping || !mapping.hasProvider())
			{
				throw new InjectorError('Error while getting mapping response: ' +
						'No mapping defined for dependency ' + getQualifiedClassName(type) +
						', named "' + _requestName + '"');
			}
			return mapping.apply(type, _injector);
		}

		//----------------------             Internal Methods               ----------------------//
		SsInternal function getMappingByName(requestTypeName : String) : InjectionRule
		{
			return _mappings[requestTypeName + _requestName]
					|| getAncestorMappingByName(requestTypeName);
		}

		SsInternal function getAncestorMapping(requestType : Class) : InjectionRule
		{
			return getAncestorMappingByName(getQualifiedClassName(requestType));
		}

		SsInternal function setRequestName(name : String) : void
		{
			_requestName = name;
		}


		//----------------------         Private / Protected Methods        ----------------------//
		private function createRule(requestType : Class) : InjectionRule
		{
			return (_mappings[getQualifiedClassName(requestType) + _requestName] =
					new NamedInjectionRule(_injector, requestType, ''));
		}
		private function getMapping(requestType : Class) : InjectionRule
		{
			return getMappingByName(getQualifiedClassName(requestType));
		}

		private function getAncestorMappingByName(requestTypeName : String) : InjectionRule
		{
			return _injector.parentInjector ? _injector.parentInjector.usingName(_requestName)
					.getMappingByName(requestTypeName) : null;
		}
	}
}