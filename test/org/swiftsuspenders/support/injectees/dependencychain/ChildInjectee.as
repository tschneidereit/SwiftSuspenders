/*
 * Copyright (c) 2011 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.support.injectees.dependencychain
{

	public class ChildInjectee
	{
		[Inject]
		public var grandchild:GrandchildInjectee;
		
		[Inject]
		public var shared:SharedInjectee;
	}

}