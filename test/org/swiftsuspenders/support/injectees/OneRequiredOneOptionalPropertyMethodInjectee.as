/*
 * Copyright (c) 2012 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.support.injectees
{
	import org.swiftsuspenders.support.types.Clazz;
	import org.swiftsuspenders.support.types.Interface;

	public class OneRequiredOneOptionalPropertyMethodInjectee
	{
		private var m_dependency : Clazz;
		private var m_dependency2 : Interface;
		
		[Inject]
		public function setDependencies(dependency:Clazz, dependency2:Interface = null):void
		{
			m_dependency = dependency;
			m_dependency2 = dependency2;
		}
		public function getDependency() : Clazz
		{
			return m_dependency;
		}
		public function getDependency2() : Interface
		{
			return m_dependency2;
		}
		
		public function OneRequiredOneOptionalPropertyMethodInjectee()
		{
		}
	}
}