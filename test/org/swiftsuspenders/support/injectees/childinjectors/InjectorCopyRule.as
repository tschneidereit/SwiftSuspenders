/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.support.injectees.childinjectors
{
	import org.swiftsuspenders.InjectionRule;
	import org.swiftsuspenders.Injector;

	public class InjectorCopyRule extends InjectionRule
	{
		public function InjectorCopyRule(creatingInjector : Injector)
		{
			super(creatingInjector, Injector, '', null);
		}

		override public function apply(targetType : Class, injector : Injector):Object
		{
			return injector.createChildInjector();
		}
	}
}