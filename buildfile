require "fileutils"
require "buildr/as3" # needs buildr-as3 v0.2.27.pre

# Installation: https://github.com/devboy/buildr_as3/wiki/Installation

repositories.remote << "http://artifacts.devboy.org" << "http://repo2.maven.org/maven2"
repositories.release_to[:url] = 'http://snapshot.artifacts.devboy.org/'
repositories.release_to[:username] = ENV["ruser"]
repositories.release_to[:password] = ENV["rpass"]

layout = Layout::Default.new
layout[:source, :main, :as3] = "src"
layout[:source, :test, :as3] = "test"

THIS_VERSION = "2.1.0"

define "Swiftsuspenders", :layout => layout do
  
  project.group = "org.swiftsuspenders"  
  project.version = THIS_VERSION  

  compile.using( :compc, :flexsdk => flexsdk, :args => ["-static-link-runtime-shared-libraries=true", "-target-player=10.2" ] )
  compile.with _(:build,:libs,"hamcrest-as3-only-1.1.3.swc")

  testrunner = _(:source, :test, :as3, "SwiftSuspendersTestRunner.as" )
  
  test.using( :flexunit4 => true, :verbose => true, :localTrusted => false, :version => "4.1.0-8" )
  test.compile.using( :main => testrunner ).with( FlexUnit4.swcs("4.1.0-8","4.1.0.16076") )
  
  doc_title = "#{project.name} #{project.version}"
  doc.using :maintitle => doc_title,
            :windowtitle => doc_title
  
  package :swc
  
end

def flexsdk
  @flexsdk ||= begin
    flexsdk = FlexSDK.new("4.5.1.21328")
    flexsdk.default_options << "-keep-as3-metadata+=Inject" << "-keep-as3-metadata+=PostConstruct" << "-keep-as3-metadata+=PreDestroy" << "-verbose-stacktraces=true"
    flexsdk
  end
end
