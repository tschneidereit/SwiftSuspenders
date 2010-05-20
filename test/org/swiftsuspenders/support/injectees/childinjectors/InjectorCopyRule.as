/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.support.injectees.childinjectors
{
	import org.swiftsuspenders.InjectionConfig;
	import org.swiftsuspenders.Injector;

	public class InjectorCopyRule extends InjectionConfig
	{
		public function InjectorCopyRule()
		{
			super(Injector, "");
		}

		override public function getResponse(injector:Injector):Object
		{
			return injector.createChildInjector();
		}
	}
}