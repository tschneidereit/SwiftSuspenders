/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.support.injectees.childinjectors
{
	import org.swiftsuspenders.InjectionMapping;
	import org.swiftsuspenders.Injector;

	public class InjectorCopyMapping extends InjectionMapping
	{
		public function InjectorCopyMapping(creatingInjector : Injector)
		{
			super(creatingInjector, Injector, '');
		}

		override public function apply(targetType : Class, injector : Injector):Object
		{
			return injector.createChildInjector();
		}
	}
}