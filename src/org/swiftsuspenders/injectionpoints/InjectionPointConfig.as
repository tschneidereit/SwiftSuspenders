/*
 * Copyright (c) 2011 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.injectionpoints
{
	import org.swiftsuspenders.Injector;
	import org.swiftsuspenders.dependencyproviders.DependencyProvider;
	import org.swiftsuspenders.dependencyproviders.LocalOnlyProvider;
	import org.swiftsuspenders.dependencyproviders.SoftDependencyProvider;
	import org.swiftsuspenders.utils.SsInternal;

	public class InjectionPointConfig
	{
		//----------------------              Public Properties             ----------------------//
		public var mappingId : String;


		//----------------------               Public Methods               ----------------------//
		public function InjectionPointConfig(mappingId : String)
		{
			this.mappingId = mappingId;
		}
	}
}