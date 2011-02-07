/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.injectionresults
{
	import org.swiftsuspenders.InjectionConfig;
	import org.swiftsuspenders.Injector;

	public class InjectOtherRuleResult extends InjectionResult
	{
		/*******************************************************************************************
		 *								private properties										   *
		 *******************************************************************************************/
		private var _rule : InjectionConfig;
		
		
		/*******************************************************************************************
		 *								public methods											   *
		 *******************************************************************************************/
		public function InjectOtherRuleResult(rule : InjectionConfig)
		{
			_rule = rule;
		}
		
		override public function getResponse(injector : Injector) : Object
		{
			return _rule.getResponse(injector);
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