/*
* Copyright (c) 2009 the original author or authors
*
* Permission is hereby granted to use, modify, and distribute this file
* in accordance with the terms of the license agreement accompanying it.
*/

package org.swiftsuspenders
{
	import flash.utils.getQualifiedClassName;

	import org.swiftsuspenders.injectionresults.InjectionResult;

	public class InjectionRule
	{
		/*******************************************************************************************
		 *								public properties										   *
		 *******************************************************************************************/
		public var request : Class;
		public var injectionName : String;


		/*******************************************************************************************
		 *								private properties										   *
		 *******************************************************************************************/
		private var _injector : Injector;
		private var _result : InjectionResult;


		/*******************************************************************************************
		 *								public methods											   *
		 *******************************************************************************************/
		public function InjectionRule(request : Class, injectionName : String)
		{
			this.request = request;
			this.injectionName = injectionName;
		}

		public function getResponse(injector : Injector) : Object
		{
			if (_result)
			{
				return _result.getResponse(_injector || injector);
			}
			var parentConfig : InjectionRule =
				(_injector || injector).getAncestorMapping(request, injectionName);
			if (parentConfig)
			{
				return parentConfig.getResponse(injector);
			}
			return null;
		}

		public function hasResponse(injector : Injector) : Boolean
		{
			if (_result)
			{
				return true;
			}
			var parentConfig : InjectionRule =
				(_injector || injector).getAncestorMapping(request, injectionName);
			return parentConfig != null;
		}

		public function hasOwnResponse() : Boolean
		{
			return _result != null;
		}

		public function setResult(result : InjectionResult) : void
		{
			if (_result != null && result != null)
			{
				trace('Warning: Injector already has a rule for type "' +
						getQualifiedClassName(request) + '", named "' + injectionName + '".\n ' +
						'If you have overwritten this mapping intentionally you can use ' +
						'"injector.unmap()" prior to your replacement mapping in order to ' +
						'avoid seeing this message.');
			}
			_result = result;
		}

		public function setInjector(injector : Injector) : void
		{
			_injector = injector;
		}
	}
}