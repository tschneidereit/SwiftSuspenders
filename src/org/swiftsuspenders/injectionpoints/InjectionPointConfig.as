/*
 * Copyright (c) 2011 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.injectionpoints
{
	import org.swiftsuspenders.Injector;
	import org.swiftsuspenders.dependencyproviders.DependencyProvider;
	import org.swiftsuspenders.dependencyproviders.SoftDependencyProvider;
	import org.swiftsuspenders.utils.SsInternal;

	use namespace SsInternal;

	public class InjectionPointConfig
	{
		//----------------------              Public Properties             ----------------------//
		public var mappingId : String;


		//----------------------               Public Methods               ----------------------//
		public function InjectionPointConfig(mappingId : String)
		{
			this.mappingId = mappingId;
		}

		public function apply(targetType : Class, injector : Injector) : Object
		{
			var softProvider : DependencyProvider;
			var usingInjector : Injector = injector;
			while (injector)
			{
				var provider : DependencyProvider =
						injector.SsInternal::providerMappings[mappingId];
				if (provider)
				{
					if (provider is SoftDependencyProvider)
					{
						softProvider = provider;
						injector = injector.parentInjector;
						continue;
					}
					return provider.apply(targetType, usingInjector);
				}
				injector = injector.parentInjector;
			}
			return softProvider && softProvider.apply(targetType, usingInjector);
		}
	}
}