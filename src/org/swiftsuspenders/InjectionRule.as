/*
* Copyright (c) 2009-2011 the original author or authors
*
* Permission is hereby granted to use, modify, and distribute this file
* in accordance with the terms of the license agreement accompanying it.
*/

package org.swiftsuspenders
{
	import flash.utils.getQualifiedClassName;

	import org.swiftsuspenders.dependencyproviders.ClassProvider;
	import org.swiftsuspenders.dependencyproviders.DependencyProvider;

	public class InjectionRule
	{
		/*******************************************************************************************
		 *								private properties										   *
		 *******************************************************************************************/
		private var _requestClass : Class;
		private var _requestName : String;

		private var _provider : DependencyProvider;
		private var _injector : Injector;


		/*******************************************************************************************
		 *								public methods											   *
		 *******************************************************************************************/
		public function InjectionRule(requestClass : Class, requestName : String)
		{
			_requestClass = requestClass;
			_requestName = requestName;
		}

		public function toType(type : Class) : DependencyProvider
		{
			setProvider(new ClassProvider(type));
			return _provider;
		}

		public function apply(injector : Injector) : Object
		{
			if (_provider)
			{
				return _provider.apply(_injector || injector);
			}
			var parentRule : InjectionRule =
				(_injector || injector).getAncestorMapping(_requestClass, _requestName);
			if (parentRule)
			{
				return parentRule.apply(injector);
			}
			return null;
		}

		public function hasProvider(injector : Injector) : Boolean
		{
			if (_provider)
			{
				return true;
			}
			var parentRule : InjectionRule =
				(_injector || injector).getAncestorMapping(_requestClass, _requestName);
			return parentRule != null && parentRule.hasProvider(_injector || injector);
		}

		public function hasOwnProvider() : Boolean
		{
			return _provider != null;
		}

		public function setProvider(provider : DependencyProvider) : void
		{
			if (_provider != null && provider != null)
			{
				trace('Warning: Injector already has a rule for type "' +
						getQualifiedClassName(_requestClass) + '", named "' + _requestName + '".\n ' +
						'If you have overwritten this mapping intentionally you can use ' +
						'"injector.unmap()" prior to your replacement mapping in order to ' +
						'avoid seeing this message.');
			}
			_provider = provider;
		}

		/**
		 * Sets the Injector to supply to the mapped DependencyProvider or to query for ancestor
		 * mappings.
		 *
		 * An Injector is always provided when calling apply, but if one is also set using
		 * setInjector, it takes precedence. This is used to implement forks in a dependency graph,
		 * allowing to use a different injector from a certain point in the constructed object
		 * graph on.
		 *
		 * @param injector - The Injector to use in the rule. Set to null to reset.
		 */
		public function setInjector(injector : Injector) : void
		{
			_injector = injector;
		}
	}
}