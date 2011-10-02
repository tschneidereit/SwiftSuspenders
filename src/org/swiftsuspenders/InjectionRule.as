/*
 * Copyright (c) 2011 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders
{
	import org.swiftsuspenders.dependencyproviders.ClassProvider;
	import org.swiftsuspenders.dependencyproviders.DependencyProvider;
	import org.swiftsuspenders.dependencyproviders.InjectorUsingProvider;
	import org.swiftsuspenders.dependencyproviders.OtherRuleProvider;
	import org.swiftsuspenders.dependencyproviders.SingletonProvider;
	import org.swiftsuspenders.dependencyproviders.ValueProvider;
	import org.swiftsuspenders.injectionpoints.InjectionPointConfig;
	import org.swiftsuspenders.utils.SsInternal;

	public class InjectionRule
	{
		//----------------------       Private / Protected Properties       ----------------------//
		private var _requestClass : Class;
		private var _mappingId : String;
		private var _injector : Injector;

		private var _creatingInjector : Injector;
		private var _config : InjectionPointConfig;
		private var _defaultProviderSet : Boolean;


		//----------------------               Public Methods               ----------------------//
		public function InjectionRule(
				creatingInjector : Injector, type : Class, mappingId : String,
				config : InjectionPointConfig)
		{
			_creatingInjector = creatingInjector;
			_requestClass = type;
			_mappingId = mappingId;
			_config = config;
			_defaultProviderSet = true;
			mapProvider(new ClassProvider(type));
		}

		/**
		 * Syntactic sugar method wholly equivalent to using
		 * <code>injector.map(Type).toSingleton(Type);<code>. Removes the need to repeat the type.
		 * @return The <code>DependencyProvider</code> that will be used to satisfy the dependency
		 */
		public function asSingleton() : void
		{
			toSingleton(_requestClass);
		}

		public function toType(type : Class) : void
		{
			setProvider(new ClassProvider(type));
		}

		public function toSingleton(type : Class) : void
		{
			setProvider(new SingletonProvider(type, _creatingInjector));
		}

		public function toValue(value : Object) : void
		{
			setProvider(new ValueProvider(value));
		}

		public function toRule(rule : InjectionRule) : void
		{
			setProvider(new OtherRuleProvider(rule));
		}

		public function apply(targetType : Class, injector : Injector) : Object
		{
			return _config.apply(targetType, injector);
		}

		public function hasProvider() : Boolean
		{
			return _creatingInjector.SsInternal::providerMappings[_mappingId] != null;
		}

		public function setProvider(provider : DependencyProvider) : void
		{
			if (hasProvider() && provider != null && !_defaultProviderSet)
			{
				//TODO: consider making this throw
				trace('Warning: Injector already has a rule for ' + _mappingId + '.\n ' +
						'If you have overwritten this mapping intentionally you can use ' +
						'"injector.unmap()" prior to your replacement mapping in order to ' +
						'avoid seeing this message.');
			}
			_defaultProviderSet = false;
			if (_injector)
			{
				provider = new InjectorUsingProvider(_injector, provider);
			}
			mapProvider(provider);
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
			var oldInjector : Injector = _injector;
			_injector = injector;
			const provider : DependencyProvider = getProvider();
			if (oldInjector)
			{
				if (injector)
				{
					InjectorUsingProvider(provider).injector = injector;
				}
				else
				{
					mapProvider(InjectorUsingProvider(provider).provider);
				}
			}
			else
			{
				mapProvider(new InjectorUsingProvider(injector, provider));
			}
		}


		//----------------------         Private / Protected Methods        ----------------------//
		private function getProvider() : DependencyProvider
		{
			return _creatingInjector.SsInternal::providerMappings[_mappingId];
		}
		private function mapProvider(provider : DependencyProvider) : void
		{
			_creatingInjector.SsInternal::providerMappings[_mappingId] = provider;
		}
	}
}