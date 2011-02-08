/*
 * Copyright (c) 2010-2011 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.dependencyproviders
{
	import org.swiftsuspenders.Injector;

	public interface DependencyProvider
	{
		function apply(injector : Injector) : Object;
	}
}