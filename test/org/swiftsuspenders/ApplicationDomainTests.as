/*
* Copyright (c) 2009 the original author or authors
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

package org.swiftsuspenders
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.System;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.getQualifiedClassName;

	import flexunit.framework.Assert;

	import org.flexunit.async.Async;
	import org.swiftsuspenders.support.injectees.ClassInjectee;
	import org.swiftsuspenders.support.types.Clazz;
	import org.swiftsuspenders.utils.SsInternal;

	use namespace SsInternal;

	/**
	 * Note: All tests in this class require an up-to-date version of the file
	 * "build/support/app-domain-test-files/app-domain-support.swf
	 */
	public class ApplicationDomainTests
	{
		protected var injector:Injector;
		protected var _loader : Loader;
		protected var _loaderDomain : ApplicationDomain;
		protected var _weaklyKeyedDomainHolder : Dictionary;
		protected var _timer : Timer;
		protected var _supportSWFLoadingCallback : Function;

		[Before]
		public function runBeforeEachTest():void
		{
			injector = new Injector();
		}
		
		[After]
		public function runAfterEachTest():void
		{
			Injector.SsInternal::purgeInjectionPointsCache();
			injector = null;
			_weaklyKeyedDomainHolder = null;
			_supportSWFLoadingCallback = null;
			if (_timer)
			{
				_timer.reset();
				_timer = null;
			}
			if (_loader)
			{
				_loaderDomain = null;
				_loader.unloadAndStop(true);
				_loader = null;
			}
			System.gc();
		}
		
		[Test(async, timeout=5000)]
		public function injectorWorksForTypesInChildAppDomains() : void
		{
			loadSupportSWFIntoDomainWithCallback(new ApplicationDomain(), function() : void
			{
				var className : String = getQualifiedClassName(ClassInjectee);
				var injecteeType : Class = Class(_loaderDomain.getDefinition(className));
				var injectee : Object = new injecteeType();
				injector.map(Clazz).toType(
						Class(_loaderDomain.getDefinition(getQualifiedClassName(Clazz))));
				injector.injectInto(injectee);
				
				Assert.assertNotNull(
						'Injection into instance of class from child domain child domain succeeds',
						injectee.property);
			});
			Async.handleEvent(this, _timer, TimerEvent.TIMER,
					injectorWorksForTypesInChildAppDomains_result, 5000);
		}
		private function injectorWorksForTypesInChildAppDomains_result(...args) : void
		{
			//no need to assert anything here, this method is only needed to make Flexunit happy
		}

		/**
		 * disabled for now because I can't find a way to force the player to perform both the
		 * mark and the sweep parts of GC in a reliable way inside the test harness, resulting in
		 * false negatives.
		 */
//		[Test(async, timeout=5000)]
//		public function mappingsInReleasedChildInjectorDontKeepChildAppDomainAlive() : void
//		{
//			loadSupportSWFIntoDomainWithCallback(new ApplicationDomain(), function() : void
//			{
//				var childInjector : Injector = injector.createChildInjector(_loaderDomain);
//				childInjector.mapClass(Clazz,
//						Class(_loaderDomain.getDefinition(getQualifiedClassName(Clazz))));
//			});
//			Async.handleEvent(this, _timer, TimerEvent.TIMER,
//					mappingsInReleasedChildInjectorDontKeepChildAppDomainAlive_result, 5000);
//		}
//		private function mappingsInReleasedChildInjectorDontKeepChildAppDomainAlive_result(
//				...args) : void
//		{
//			Assert.assertTrue('Mapping a class from a child ApplicationDomain doesn\'t prevent ' +
//					'it from being collected', weaklyKeyedDictionaryIsEmpty());
//		}

		[Embed(source="/../build/support/app-domain-test-files/app-domain-support.swf")]
		private var supportSWF : Class;

		private function loadSupportSWFIntoDomainWithCallback(
				domain:ApplicationDomain, callback:Function) : void
		{
			_supportSWFLoadingCallback = callback;
			_timer = new Timer(0, 1);
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, supportSWFLoading_complete);
			var context : LoaderContext = new LoaderContext(false, domain);
			const bytes : ByteArray = ByteArray((new supportSWF())['movieClipData']);
			_loader.loadBytes(bytes, context);
		}

		private function supportSWFLoading_complete(event:Event):void
		{
			_loaderDomain = _loader.contentLoaderInfo.applicationDomain;
			_weaklyKeyedDomainHolder = new Dictionary(true);
			_weaklyKeyedDomainHolder[_loaderDomain] = true;
			_supportSWFLoadingCallback.call(this);
			_loaderDomain = null;
			_loader = null;
			System.gc();
			_timer.start();
		}

		private function weaklyKeyedDictionaryIsEmpty() : Boolean
		{
			for (var item : Object in _weaklyKeyedDomainHolder)
			{
				return false;
			}
			return true;
		}
	}
}