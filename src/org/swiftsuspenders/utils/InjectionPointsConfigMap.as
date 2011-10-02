/*
 * Copyright (c) 2011 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.utils
{
	import org.swiftsuspenders.injectionpoints.InjectionPointConfig;

	public interface InjectionPointsConfigMap
	{
		function getInjectionPointConfig(
				typeName : String, injectionName : String) : InjectionPointConfig;
	}
}