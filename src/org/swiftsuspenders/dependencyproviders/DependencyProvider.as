/*
 * Copyright (c) 2011 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.dependencyproviders
{
	import org.swiftsuspenders.Injector;

	public interface DependencyProvider
	{
		/**
		 * Provides a response that, if required, is created using the appropriate given injector
		 *
		 * @param targetType The type of the object the dependency is to be injected into
		 * @param activeInjector The injector through which this DependencyProvider is currently
		 * invoked
		 * @return The result of the specific DependencyProvider's mechanism
		 */
		function apply(targetType : Class, activeInjector : Injector) : Object;
	}
}