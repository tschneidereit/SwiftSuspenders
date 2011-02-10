/*
 * Copyright (c) 2011 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders
{
	public class NamedInjectionRule extends InjectionRule
	{
		/*******************************************************************************************
		 *								private properties										   *
		 *******************************************************************************************/
		private var _requestName : String;


		/*******************************************************************************************
		 *								public methods											   *
		 *******************************************************************************************/
		public function NamedInjectionRule(requestClass : Class, requestName : String)
		{
			super(requestClass);
			_requestName = requestName;
		}

		override protected function getParentRule(injector : Injector) : InjectionRule
		{
			return (_injector || injector).getNamedAncestorMapping(_requestClass, _requestName);
		}

		override protected function describeInjection() : String
		{
			return super.describeInjection() + ', named "' + _requestName + '"';
		}
	}
}