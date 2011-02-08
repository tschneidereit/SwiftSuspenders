/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.dependencyproviders
{
	import org.swiftsuspenders.InjectionRule;
	import org.swiftsuspenders.Injector;

	public class OtherRuleProvider implements DependencyProvider
	{
		/*******************************************************************************************
		 *								private properties										   *
		 *******************************************************************************************/
		private var _rule : InjectionRule;
		
		
		/*******************************************************************************************
		 *								public methods											   *
		 *******************************************************************************************/
		public function OtherRuleProvider(rule : InjectionRule)
		{
			_rule = rule;
		}
		
		public function apply(injector : Injector) : Object
		{
			return _rule.apply(injector);
		}

		override public function equals(otherResult : InjectionResult) : Boolean
		{
			if (otherResult == this)
			{
				return true;
			}
			if (!(otherResult is InjectOtherRuleResult))
			{
				return false;
			}
			var castedResult : InjectOtherRuleResult =  InjectOtherRuleResult(otherResult);
			return castedResult.m_rule == m_rule;
		}
	}
}