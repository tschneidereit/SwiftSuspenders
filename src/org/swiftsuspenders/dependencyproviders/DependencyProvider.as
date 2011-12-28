/*
 * Copyright (c) 2011 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.dependencyproviders
{
	import flash.utils.Dictionary;

	import org.swiftsuspenders.Injector;

	public interface DependencyProvider
	{
		/**
		 * Provides a response that, if required, is created using the appropriate given injector
		 *
		 * @param targetType The type of the object the dependency is to be injected into
		 * @param activeInjector The injector through which this DependencyProvider is currently
		 * invoked
		 * @param injectParameters Dictionary containing all parameters for the current injection point
		 * @return The result of the specific DependencyProvider's mechanism
		 */
		function apply(
			targetType : Class, activeInjector : Injector, injectParameters : Dictionary) : Object;
	}
}