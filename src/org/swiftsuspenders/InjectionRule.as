/*
 * Copyright (c) 2011 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders
{
	import flash.utils.getQualifiedClassName;

	import org.swiftsuspenders.Injector;
	import org.swiftsuspenders.dependencyproviders.ClassProvider;
	import org.swiftsuspenders.dependencyproviders.DependencyProvider;
	import org.swiftsuspenders.dependencyproviders.OtherRuleProvider;
	import org.swiftsuspenders.dependencyproviders.SingletonProvider;
	import org.swiftsuspenders.dependencyproviders.ValueProvider;
	import org.swiftsuspenders.utils.SsInternal;

	public class InjectionRule
	{
		//----------------------       Private / Protected Properties       ----------------------//
		protected var _requestClass : Class;
		protected var _injector : Injector;

		private var _creatingInjector : Injector;
		private var _provider : DependencyProvider;


		//----------------------               Public Methods               ----------------------//
		public function InjectionRule(creatingInjector : Injector, requestClass : Class)
		{
			_creatingInjector = creatingInjector;
			_requestClass = requestClass;
		}

		public function toType(type : Class) : DependencyProvider
		{
			setProvider(new ClassProvider(type));
			return _provider;
		}

		public function toSingleton(type : Class) : DependencyProvider
		{
			setProvider(new SingletonProvider(type));
			return _provider;
		}

		public function toValue(value : Object) : DependencyProvider
		{
			setProvider(new ValueProvider(value));
			return _provider;
		}

		public function toRule(rule : InjectionRule) : DependencyProvider
		{
			setProvider(new OtherRuleProvider(rule));
			return _provider;
		}

		public function apply(injector : Injector) : Object
		{
			if (_provider)
			{
				return _provider.apply(_creatingInjector, _injector || injector);
			}
			var parentRule : InjectionRule = getParentRule(injector);
			if (parentRule)
			{
				return parentRule.apply(injector);
			}
			return null;
		}

		public function hasProvider() : Boolean
		{
			return _provider != null;
		}

		public function setProvider(provider : DependencyProvider) : void
		{
			if (_provider != null && provider != null)
			{
				//TODO: consider making this throw
				trace('Warning: Injector already has a rule for ' + describeInjection() + '.\n ' +
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
		 * allowing the use of a different Injector from a certain point in the constructed object
		 * graph on.
		 *
		 * @param injector - The Injector to use in the rule. Set to null to reset.
		 */
		public function setInjector(injector : Injector) : void
		{
			_injector = injector;
		}


		//----------------------         Private / Protected Methods        ----------------------//
		protected function getParentRule(injector : Injector) : InjectionRule
		{
			return (_injector || injector).SsInternal::getAncestorMapping(_requestClass);
		}

		protected function describeInjection() : String
		{
			return 'type "' + getQualifiedClassName(_requestClass) + '"';
		}
	}
}