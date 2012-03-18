/*
 * Copyright (c) 2012 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.support.injectees.childinjectors
{
	import flash.utils.Dictionary;

	import org.swiftsuspenders.injection.Injector;
	import org.swiftsuspenders.injection.dependencyproviders.DependencyProvider;

	public class ChildInjectorCreatingProvider implements DependencyProvider
	{
		public function apply(
			targetType : Class, activeInjector : Injector,
			injectParameters : Dictionary):Object
		{
			return activeInjector.createChildInjector();
		}
	}
}