/*
 * Copyright (c) 2012 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.support.injectees
{
	import org.swiftsuspenders.support.types.Interface;

	public class TwoOptionalParametersConstructorInjectee
	{
		private var m_dependency : Interface;
		private var m_dependency2 : String;
		
		public function getDependency() : Interface
		{
			return m_dependency;
		}
		public function getDependency2() : String
		{
			return m_dependency2;
		}
		
		public function TwoOptionalParametersConstructorInjectee(dependency:Interface = null, dependency2:String = null)
		{
			m_dependency = dependency;
			m_dependency2 = dependency2;
		}
	}
}