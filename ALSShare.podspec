#
# Be sure to run `pod lib lint ALSShare.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ALSShare'
  s.version          = '0.0.10'
  s.summary          = 'This is a description of ALSShare.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
This is a long description of the pod here.This is a long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/AltairEven/ALSShare.git'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'AltairEven' => 'qianye.qy@alibaba-inc.com' }
  s.source           = { :git => 'https://github.com/AltairEven/ALSShare.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  s.pod_target_xcconfig = {
    'FRAMEWORK_SEARCH_PATHS' => '$(inherited) $(PODS_ROOT)/**',
    'OTHER_LDFLAGS'          => '$(inherited) -undefined dynamic_lookup',
    'ENABLE_BITCODE'         => 'NO',
    'MACH_O_TYPE'            => 'staticlib'
  }
    
  s.subspec 'Public' do |pub|
    pub.source_files = 'ALSShare/Classes/Public/*'
  end
  s.subspec 'Interface' do |int|
    int.dependency 'ALSShare/Public'
    int.source_files = 'ALSShare/Classes/Interface/*'
  end
  s.subspec 'Plug' do |pl|
    pl.dependency 'ALSShare/Public'
    pl.subspec 'Wechat' do |wx|
        wx.dependency 'AEDataKit'
        wx.source_files = 'ALSShare/Classes/Plug/Wechat/*'
        #wx.dependency 'WechatOpenSDK_NoPay'
    end
    pl.subspec 'Weibo' do |wb|
        wb.dependency 'AEDataKit'
        wb.source_files = 'ALSShare/Classes/Plug/Weibo/*'
        #wb.dependency 'UMengUShare/Social/Sina'#, '6.4.1'
    end
    pl.subspec 'Tencent' do |qq|
        qq.dependency 'AEDataKit'
        qq.source_files = 'ALSShare/Classes/Plug/Tencent/*'
        #qq.dependency 'UMengUShare/Social/QQ'#, '6.4.1'
    end
  end
end
