/*
 * Copyright (c) 2012 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.dependencyproviders
{
	public interface FallbackDependencyProvider extends DependencyProvider
	{
		/**
		 * Instructs the fallback provider to interpret the next call to <code>apply</code> as
		 * being a request for the given <code>mappingId</code>. The provider must return
		 * <code>false</code> if it can't satisfy a request for the given mappingId.
		 *
		 * While this is far from ideal, it's the cleanest low-overhead way to implement multiple-
		 * type fallback providers in the injector's architecture.
		 *
		 * @param mappingId The type + mapping name to provide a result for
		 * @return True if the provider can provide a result, false otherwise
		 */
		function prepareNextRequest(mappingId : String) : Boolean;
	}
}