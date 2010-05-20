/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.support.injectees.childinjectors
{
	import org.swiftsuspenders.Injector;

	public class InjectorInjectee
	{
		[Inject] public var injector : Injector;
		public var nestedInjectee : NestedInjectorInjectee;

		[PostConstruct]
		public function createAnotherChildInjector() : void
		{
			nestedInjectee = injector.instantiate(NestedInjectorInjectee);
		}
	}
}