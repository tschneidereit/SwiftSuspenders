/*
 * Copyright (c) 2010-2011 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.support.injectees.childinjectors
{
	import org.swiftsuspenders.Injector;
	import org.swiftsuspenders.dependencyproviders.DependencyProvider;

	public class ChildInjectorCreatingProvider implements DependencyProvider
	{
		public function apply(targetType : Class, injector : Injector):Object
		{
			return injector.createChildInjector();
		}
	}
}