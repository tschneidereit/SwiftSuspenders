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
	import org.swiftsuspenders.utils.SsInternal;

	public class InjectionMapping
	{
		//----------------------       Private / Protected Properties       ----------------------//
		private var _type : Class;
		private var _name : String;
		private var _mappingId : String;
		private var _creatingInjector : Injector;
		private var _defaultProviderSet : Boolean;

		private var _overridingInjector : Injector;
		private var _soft : Boolean;
		private var _local : Boolean;
		private var _sealed : Boolean;
		private var _sealKey : Object;


		//----------------------               Public Methods               ----------------------//
		public function InjectionMapping(
			creatingInjector : Injector, type : Class, name : String, mappingId : String)
		{
			_creatingInjector = creatingInjector;
			_type = type;
			_name = name;
			_mappingId = mappingId;
			_defaultProviderSet = true;
			mapProvider(new ClassProvider(type));
		}

		/**
		 * Syntactic sugar method wholly equivalent to using
		 * <code>injector.map(Type).toSingleton(Type);<code>. Removes the need to repeat the type.
		 * @return The <code>DependencyProvider</code> that will be used to satisfy the dependency
		 */
		public function asSingleton() : InjectionMapping
		{
			toSingleton(_type);
			return this;
		}

		public function toType(type : Class) : InjectionMapping
		{
			toProvider(new ClassProvider(type));
			return this;
		}

		public function toSingleton(type : Class) : InjectionMapping
		{
			toProvider(new SingletonProvider(type, _creatingInjector));
			return this;
		}

		public function toValue(value : Object) : InjectionMapping
		{
			toProvider(new ValueProvider(value));
			return this;
		}

		public function toProvider(provider : DependencyProvider) : InjectionMapping
		{
			_sealed && throwSealedError();
			if (hasProvider() && provider != null && !_defaultProviderSet)
			{
				//TODO: consider making this throw
				trace('Warning: Injector already has a mapping for ' + _mappingId + '.\n ' +
						'If you have overwritten this mapping intentionally you can use ' +
						'"injector.unmap()" prior to your replacement mapping in order to ' +
						'avoid seeing this message.');
			}
			dispatchPreChangeEvent();
			_defaultProviderSet = false;
			mapProvider(provider);
			dispatchPostChangeEvent();
			return this;
		}

		public function soft() : InjectionMapping
		{
			_sealed && throwSealedError();
			if (!_soft)
			{
				const provider : DependencyProvider = getProvider();
				dispatchPreChangeEvent();
				_soft = true;
				mapProvider(provider);
				dispatchPostChangeEvent();
			}
			return this;
		}

		public function strong() : InjectionMapping
		{
			_sealed && throwSealedError();
			if (_soft)
			{
				const provider : DependencyProvider = getProvider();
				dispatchPreChangeEvent();
				_soft = false;
				mapProvider(provider);
				dispatchPostChangeEvent();
			}
			return this;
		}

		/**
		 * Disables sharing the mapping with child injectors of the injector it is defined in
		 * @return The mapping the method is invoked on, allowing for a fluent usage of the
		 * different options
		 */
		public function local() : InjectionMapping
		{
			_sealed && throwSealedError();
			if (_local)
			{
				return this;
			}
			const provider : DependencyProvider = getProvider();
			dispatchPreChangeEvent();
			_local = true;
			mapProvider(provider);
			dispatchPostChangeEvent();
			return this;
		}

		/**
		 * Enables sharing the mapping with child injectors of the injector it is defined in
		 * @return The mapping the method is invoked on, allowing for a fluent usage of the
		 * different options
		 */
		public function shared() : InjectionMapping
		{
			_sealed && throwSealedError();
			if (!_local)
			{
				return this;
			}
			const provider : DependencyProvider = getProvider();
			dispatchPreChangeEvent();
			_local = false;
			mapProvider(provider);
			dispatchPostChangeEvent();
			return this;
		}

		/**
		 * Prevents all subsequent changes to the mapping, including removal. Trying to change it
		 * in any way at all will throw an <code>InjectorError</code>.
		 *
		 * @returns An internally created object that can be used as the key for unseal
		 */
		public function seal() : Object
		{
			if (_sealed)
			{
				throw new InjectorError('Mapping is already sealed.');
			}
			_sealed = true;
			_sealKey = {};
			return _sealKey;
		}

		/**
		 * Makes the mapping changable again.
		 *
		 * @param key The key to unseal the mapping. Has to be the instance returned by
		 * <code>seal()</code>
		 * @throws InjectorError if the mapping isn't sealed or if no or the wrong key is given
		 */
		public function unseal(key : Object) : void
		{
			if (!_sealed)
			{
				throw new InjectorError('Can\'t unseal a non-sealed mapping.');
			}
			if (key !== _sealKey)
			{
				throw new InjectorError('Can\'t unseal mapping without the correct key.');
			}
			_sealed = false;
			_sealKey = null;
		}

		public function get isSealed() : Boolean
		{
			return _sealed;
		}

		public function hasProvider() : Boolean
		{
			return Boolean(_creatingInjector.SsInternal::providerMappings[_mappingId]);
		}

		public function apply(targetType : Class, injector : Injector) : Object
		{
			return injector.SsInternal::applyMapping(targetType, _mappingId);
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
		 * @param injector - The Injector to use in the mapping. Set to null to reset.
		 */
		public function setInjector(injector : Injector) : void
		{
			_sealed && throwSealedError();
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

		private function throwSealedError() : void
		{
			throw new InjectorError('Can\'t change a sealed mapping');
		}

		private function dispatchPreChangeEvent() : void
		{
			_creatingInjector.hasEventListener(MappingEvent.PRE_MAPPING_CHANGE)
				&& _creatingInjector.dispatchEvent(
				new MappingEvent(MappingEvent.PRE_MAPPING_CHANGE, _type, _name, this));
		}

		private function dispatchPostChangeEvent() : void
		{
			_creatingInjector.hasEventListener(MappingEvent.POST_MAPPING_CHANGE)
				&& _creatingInjector.dispatchEvent(
				new MappingEvent(MappingEvent.POST_MAPPING_CHANGE, _type, _name, this));
		}
	}
}