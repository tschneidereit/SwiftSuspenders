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
	import org.swiftsuspenders.dependencyproviders.ForwardingProvider;
	import org.swiftsuspenders.dependencyproviders.InjectorUsingProvider;
	import org.swiftsuspenders.dependencyproviders.LocalOnlyProvider;
	import org.swiftsuspenders.dependencyproviders.SingletonProvider;
	import org.swiftsuspenders.dependencyproviders.SoftDependencyProvider;
	import org.swiftsuspenders.dependencyproviders.ValueProvider;
	import org.swiftsuspenders.injectionpoints.InjectionPointConfig;
	import org.swiftsuspenders.utils.SsInternal;

	public class InjectionRule
	{
		//----------------------       Private / Protected Properties       ----------------------//
		private var _type : Class;
		private var _mappingId : String;
		private var _config : InjectionPointConfig;
		private var _creatingInjector : Injector;
		private var _defaultProviderSet : Boolean;

		private var _overridingInjector : Injector;
		private var _soft : Boolean;
		private var _local : Boolean;


		//----------------------               Public Methods               ----------------------//
		public function InjectionRule(creatingInjector : Injector, type : Class, mappingId : String,
				config : InjectionPointConfig)
		{
			_creatingInjector = creatingInjector;
			_type = type;
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
		public function asSingleton() : InjectionRule
		{
			toSingleton(_type);
			return this;
		}

		public function toType(type : Class) : InjectionRule
		{
			setProvider(new ClassProvider(type));
			return this;
		}

		public function toSingleton(type : Class) : InjectionRule
		{
			setProvider(new SingletonProvider(type, _creatingInjector));
			return this;
		}

		public function toValue(value : Object) : InjectionRule
		{
			setProvider(new ValueProvider(value));
			return this;
		}

		public function setProvider(provider : DependencyProvider) : InjectionRule
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
			mapProvider(provider);
			return this;
		}

		public function soft() : InjectionRule
		{
			if (!_soft)
			{
				const provider : DependencyProvider = getProvider();
				_soft = true;
				mapProvider(provider);
			}
			return this;
		}

		public function strong() : InjectionRule
		{
			if (_soft)
			{
				const provider : DependencyProvider = getProvider();
				_soft = false;
				mapProvider(provider);
			}
			return this;
		}

		/**
		 * Disables sharing the mapping with child injectors of the injector it is defined in
		 * @return The mapping the method is invoked on, allowing for a fluent usage of the
		 * different options
		 */
		public function local() : InjectionRule
		{
			if (_local)
			{
				return this;
			}
			const provider : DependencyProvider = getProvider();
			_local = true;
			mapProvider(provider);
			return this;
		}

		/**
		 * Enables sharing the mapping with child injectors of the injector it is defined in
		 * @return The mapping the method is invoked on, allowing for a fluent usage of the
		 * different options
		 */
		public function shared() : InjectionRule
		{
			if (!_local)
			{
				return this;
			}
			const provider : DependencyProvider = getProvider();
			_local = false;
			mapProvider(provider);
			return this;
		}

		public function hasProvider() : Boolean
		{
			return _creatingInjector.SsInternal::providerMappings[_mappingId] != null;
		}

		public function apply(targetType : Class, injector : Injector) : Object
		{
			return _config.apply(targetType, injector);
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
			if (injector == _overridingInjector)
			{
				return;
			}
			const provider : DependencyProvider = getProvider();
			_overridingInjector = injector;
			mapProvider(provider);
		}


		//----------------------         Private / Protected Methods        ----------------------//
		private function getProvider() : DependencyProvider
		{
			var provider : DependencyProvider =
					_creatingInjector.SsInternal::providerMappings[_mappingId];
			while (provider is ForwardingProvider)
			{
				provider = ForwardingProvider(provider).provider;
			}
			return provider;
		}
		
		private function mapProvider(provider : DependencyProvider) : void
		{
			if (_soft)
			{
				provider = new SoftDependencyProvider(provider);
			}
			if (_local)
			{
				provider = new LocalOnlyProvider(provider);
			}
			if (_overridingInjector)
			{
				provider = new InjectorUsingProvider(_overridingInjector, provider);
			}
			_creatingInjector.SsInternal::providerMappings[_mappingId] = provider;
		}
	}
}