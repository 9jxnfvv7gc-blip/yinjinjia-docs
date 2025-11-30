import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// 应用名称
  ///
  /// In zh, this message translates to:
  /// **'小船'**
  String get appName;

  /// 用户协议标题
  ///
  /// In zh, this message translates to:
  /// **'用户协议'**
  String get userAgreement;

  /// 隐私政策标题
  ///
  /// In zh, this message translates to:
  /// **'隐私政策'**
  String get privacyPolicy;

  /// 用户协议与隐私政策标题
  ///
  /// In zh, this message translates to:
  /// **'用户协议与隐私政策'**
  String get userAgreementAndPrivacyPolicy;

  /// 同意按钮
  ///
  /// In zh, this message translates to:
  /// **'同意'**
  String get agree;

  /// 不同意按钮
  ///
  /// In zh, this message translates to:
  /// **'不同意'**
  String get disagree;

  /// 关闭按钮
  ///
  /// In zh, this message translates to:
  /// **'关闭'**
  String get close;

  /// 设置标题
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settings;

  /// 查看用户协议
  ///
  /// In zh, this message translates to:
  /// **'查看用户协议'**
  String get viewUserAgreement;

  /// 查看隐私政策
  ///
  /// In zh, this message translates to:
  /// **'查看隐私政策'**
  String get viewPrivacyPolicy;

  /// 用户协议标题
  ///
  /// In zh, this message translates to:
  /// **'《小船用户协议》'**
  String get termsOfServiceTitle;

  /// 隐私政策标题
  ///
  /// In zh, this message translates to:
  /// **'《小船隐私政策》'**
  String get privacyPolicyTitle;

  /// 生效日期
  ///
  /// In zh, this message translates to:
  /// **'生效日期：2025年11月27日'**
  String get effectiveDate;

  /// 同意提示
  ///
  /// In zh, this message translates to:
  /// **'点击\"同意\"即表示您已阅读并同意上述协议和政策。'**
  String get clickAgreeToAccept;

  /// 联系邮箱
  ///
  /// In zh, this message translates to:
  /// **'邮箱：zhihuilingai4@outlook.com'**
  String get contactEmail;

  /// 用户协议完整内容
  ///
  /// In zh, this message translates to:
  /// **'《小船用户协议》\n\n生效日期：2025年11月27日\n\n一、本服务的功能\n\n1.小船（下称\"本服务\"）由个人开发者智慧令爱运营，为用户提供原创视频、原创音乐的在线播放、分享功能。\n\n2.本服务向用户提供内容浏览、播放控制、内容分享能力。\n\n3.用户在使用本服务时，应遵守相关法律法规，不得利用本服务从事违法违规活动。\n\n4.未经我们书面许可，用户不得对本服务进行反向工程、非法抓取、批量下载、商业使用或其他超出本协议约定目的的行为。\n\n二、责任范围与限制\n\n1.我们将尽力保持服务稳定、安全、可靠，但受网络、设备、第三方服务等因素影响，可能出现中断、延迟、数据丢失等；对以下原因造成的损失，我们不承担责任：\n·不可抗力或无法预见、避免、克服的事件；\n·用户违反法律法规、本协议或相关政策的行为。\n\n2.本服务展示的内容均由提供者负责。\n\n3.用户应对其在本服务上传、发布、传播的内容自行负责，不得侵犯第三方权利。如有侵权或违法情形，由用户自行承担全部责任，我们保留移除内容及追究责任的权利。\n\n三、隐私保护\n\n1.我们不会自动收集您的设备信息、使用数据、日志信息等个人信息。\n\n2.当您使用\"上传视频\"或\"上传音乐\"功能时，您主动选择的视频或音乐文件会被上传到我们的服务器，用于内容分享和播放服务。\n\n3.我们不会收集或上传您的其他个人数据，如设备标识符、位置信息、联系人信息等。\n\n4.应用设置数据（如授权状态）仅存储在您的设备本地，不会上传到服务器。\n\n5.关于隐私保护的详细说明，请参阅《小船隐私政策》。\n\n四、其他\n\n1.本协议的签订地为中华人民共和国，适用中华人民共和国法律。\n\n2.与本协议有关的争议，如协商不成，提交仲裁机构或法院解决。\n\n3.我们有权根据业务发展、法律政策变化等对本协议进行调整，并通过应用内等方式通知。用户继续使用视为接受修改后的协议。\n\n4.若本协议任何条款被认定无效或不可执行，不影响其他条款的效力。\n\n联系渠道\n\n如对本协议有任何疑问，请通过以下方式联系我们：\n\n邮箱：zhihuilingai4@outlook.com'**
  String get termsOfServiceContent;

  /// 隐私政策完整内容
  ///
  /// In zh, this message translates to:
  /// **'《小船隐私政策》\n\n生效日期：2025年11月27日\n\n一、信息收集\n\n1.我们不会自动收集您的设备信息、使用数据、日志信息等个人信息。\n\n2.当您使用\"上传视频\"或\"上传音乐\"功能时，您主动选择的视频或音乐文件会被上传到我们的服务器，用于内容分享和播放服务。\n\n3.我们不会收集或上传您的其他个人数据，如设备标识符、位置信息、联系人信息等。\n\n二、数据存储\n\n1.您主动上传的视频和音乐文件存储在服务器上，用于提供内容分享和播放服务。\n\n2.应用设置数据（如授权状态）仅存储在您的设备本地，不会上传到服务器。\n\n三、数据使用\n\n1.您上传的视频和音乐文件仅用于提供本应用的内容分享和播放服务。\n\n2.我们不会将您上传的内容用于其他商业目的，也不会向第三方出售或分享您的数据。\n\n3.我们不会使用您的数据进行用户画像、广告推送或其他数据分析活动。\n\n四、数据安全\n\n1.我们采用合理的技术手段保护您上传的内容安全。\n\n2.您可以通过应用内的删除功能删除您上传的内容。\n\n3.应用设置数据存储在您的设备本地，由您的设备安全措施保障。\n\n五、第三方服务\n\n本应用不集成任何第三方数据分析服务、广告服务或其他可能收集用户信息的服务。\n\n六、隐私政策更新\n\n我们有权根据业务发展、法律政策变化等对本政策进行调整，并通过应用内等方式通知。用户继续使用视为接受修改后的政策。\n\n联系渠道\n\n如对本政策有任何疑问，请通过以下方式联系我们：\n\n邮箱：zhihuilingai4@outlook.com'**
  String get privacyPolicyContent;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
