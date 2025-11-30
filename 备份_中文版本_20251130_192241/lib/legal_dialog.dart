import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 法律协议对话框
class LegalAgreementDialog extends StatelessWidget {
  const LegalAgreementDialog({super.key});

  /// 检查用户是否已同意协议
  static Future<bool> hasAgreed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('legal_agreement_accepted') ?? false;
    } catch (e) {
      return false;
    }
  }

  /// 设置用户同意状态
  static Future<void> setAgreed(bool agreed) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('legal_agreement_accepted', agreed);
    } catch (e) {
      // 忽略错误
    }
  }

  /// 打开用户协议页面
  static void openTerms(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('用户协议'),
        contentPadding: EdgeInsets.zero,
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: const Text(
                    '《小船用户协议》\n\n'
                    '生效日期：2025年11月27日\n\n'
                    '一、本服务的功能\n\n'
                    '1.小船（下称"本服务"）由个人开发者智慧令爱运营，为用户提供原创视频、原创音乐的在线播放、分享功能。\n\n'
                    '2.本服务向用户提供内容浏览、播放控制、内容分享能力。\n\n'
                    '3.用户在使用本服务时，应遵守相关法律法规，不得利用本服务从事违法违规活动。\n\n'
                    '4.未经我们书面许可，用户不得对本服务进行反向工程、非法抓取、批量下载、商业使用或其他超出本协议约定目的的行为。\n\n'
                    '二、责任范围与限制\n\n'
                    '1.我们将尽力保持服务稳定、安全、可靠，但受网络、设备、第三方服务等因素影响，可能出现中断、延迟、数据丢失等；对以下原因造成的损失，我们不承担责任：\n'
                    '·不可抗力或无法预见、避免、克服的事件；\n'
                    '·用户违反法律法规、本协议或相关政策的行为。\n\n'
                    '2.本服务展示的内容均由提供者负责。\n\n'
                    '3.用户应对其在本服务上传、发布、传播的内容自行负责，不得侵犯第三方权利。如有侵权或违法情形，由用户自行承担全部责任，我们保留移除内容及追究责任的权利。\n\n'
                    '三、隐私保护\n\n'
                    '1.我们不会自动收集您的设备信息、使用数据、日志信息等个人信息。\n\n'
                    '2.当您使用"上传视频"或"上传音乐"功能时，您主动选择的视频或音乐文件会被上传到我们的服务器，用于内容分享和播放服务。\n\n'
                    '3.我们不会收集或上传您的其他个人数据，如设备标识符、位置信息、联系人信息等。\n\n'
                    '4.应用设置数据（如授权状态）仅存储在您的设备本地，不会上传到服务器。\n\n'
                    '5.关于隐私保护的详细说明，请参阅《小船隐私政策》。\n\n'
                    '四、其他\n\n'
                    '1.本协议的签订地为中华人民共和国，适用中华人民共和国法律。\n\n'
                    '2.与本协议有关的争议，如协商不成，提交仲裁机构或法院解决。\n\n'
                    '3.我们有权根据业务发展、法律政策变化等对本协议进行调整，并通过应用内等方式通知。用户继续使用视为接受修改后的协议。\n\n'
                    '4.若本协议任何条款被认定无效或不可执行，不影响其他条款的效力。\n\n'
                    '联系渠道\n\n'
                    '如对本协议有任何疑问，请通过以下方式联系我们：\n\n'
                    '邮箱：zhihuilingai4@outlook.com',
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  /// 打开隐私政策页面
  static void openPrivacy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '隐私政策',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: const Text(
                    '《小船隐私政策》\n\n'
                    '生效日期：2025年11月27日\n\n'
                    '一、信息收集\n\n'
                    '1.我们不会自动收集您的设备信息、使用数据、日志信息等个人信息。\n\n'
                    '2.当您使用"上传视频"或"上传音乐"功能时，您主动选择的视频或音乐文件会被上传到我们的服务器，用于内容分享和播放服务。\n\n'
                    '3.我们不会收集或上传您的其他个人数据，如设备标识符、位置信息、联系人信息等。\n\n'
                    '二、数据存储\n\n'
                    '1.您主动上传的视频和音乐文件存储在服务器上，用于提供内容分享和播放服务。\n\n'
                    '2.应用设置数据（如授权状态）仅存储在您的设备本地，不会上传到服务器。\n\n'
                    '三、数据使用\n\n'
                    '1.您上传的视频和音乐文件仅用于提供本应用的内容分享和播放服务。\n\n'
                    '2.我们不会将您上传的内容用于其他商业目的，也不会向第三方出售或分享您的数据。\n\n'
                    '3.我们不会使用您的数据进行用户画像、广告推送或其他数据分析活动。\n\n'
                    '四、数据安全\n\n'
                    '1.我们采用合理的技术手段保护您上传的内容安全。\n\n'
                    '2.您可以通过应用内的删除功能删除您上传的内容。\n\n'
                    '3.应用设置数据存储在您的设备本地，由您的设备安全措施保障。\n\n'
                    '五、第三方服务\n\n'
                    '本应用不集成任何第三方数据分析服务、广告服务或其他可能收集用户信息的服务。\n\n'
                    '六、隐私政策更新\n\n'
                    '我们有权根据业务发展、法律政策变化等对本政策进行调整，并通过应用内等方式通知。用户继续使用视为接受修改后的政策。\n\n'
                    '联系渠道\n\n'
                    '如对本政策有任何疑问，请通过以下方式联系我们：\n\n'
                    '邮箱：zhihuilingai4@outlook.com',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('关闭'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题 - 固定高度
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: const Row(
                children: [
                  Expanded(
                    child: Text(
                      '用户协议与隐私政策',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            // 可滚动内容区域 - 显示完整的用户协议和隐私政策
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '《小船用户协议》',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '生效日期：2025年11月27日\n\n'
                      '一、本服务的功能\n\n'
                      '1.小船（下称"本服务"）由个人开发者智慧令爱运营，为用户提供原创视频、原创音乐的在线播放、分享功能。\n\n'
                      '2.本服务向用户提供内容浏览、播放控制、内容分享能力。\n\n'
                      '3.用户在使用本服务时，应遵守相关法律法规，不得利用本服务从事违法违规活动。\n\n'
                      '4.未经我们书面许可，用户不得对本服务进行反向工程、非法抓取、批量下载、商业使用或其他超出本协议约定目的的行为。\n\n'
                      '二、责任范围与限制\n\n'
                      '1.我们将尽力保持服务稳定、安全、可靠，但受网络、设备、第三方服务等因素影响，可能出现中断、延迟、数据丢失等；对以下原因造成的损失，我们不承担责任：\n'
                      '·不可抗力或无法预见、避免、克服的事件；\n'
                      '·用户违反法律法规、本协议或相关政策的行为。\n\n'
                      '2.本服务展示的内容均由提供者负责。\n\n'
                      '3.用户应对其在本服务上传、发布、传播的内容自行负责，不得侵犯第三方权利。如有侵权或违法情形，由用户自行承担全部责任，我们保留移除内容及追究责任的权利。\n\n'
                      '三、隐私保护\n\n'
                      '1.我们不会自动收集您的设备信息、使用数据、日志信息等个人信息。\n\n'
                      '2.当您使用"上传视频"或"上传音乐"功能时，您主动选择的视频或音乐文件会被上传到我们的服务器，用于内容分享和播放服务。\n\n'
                      '3.我们不会收集或上传您的其他个人数据，如设备标识符、位置信息、联系人信息等。\n\n'
                      '4.应用设置数据（如授权状态）仅存储在您的设备本地，不会上传到服务器。\n\n'
                      '5.关于隐私保护的详细说明，请参阅《小船隐私政策》。\n\n'
                      '四、其他\n\n'
                      '1.本协议的签订地为中华人民共和国，适用中华人民共和国法律。\n\n'
                      '2.与本协议有关的争议，如协商不成，提交仲裁机构或法院解决。\n\n'
                      '3.我们有权根据业务发展、法律政策变化等对本协议进行调整，并通过应用内等方式通知。用户继续使用视为接受修改后的协议。\n\n'
                      '4.若本协议任何条款被认定无效或不可执行，不影响其他条款的效力。\n\n'
                      '联系渠道\n\n'
                      '如对本协议有任何疑问，请通过以下方式联系我们：\n\n'
                      '邮箱：zhihuilingai4@outlook.com',
                      style: TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    const Text(
                      '《小船隐私政策》',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '生效日期：2025年11月27日\n\n'
                      '一、信息收集\n\n'
                      '1.我们不会自动收集您的设备信息、使用数据、日志信息等个人信息。\n\n'
                      '2.当您使用"上传视频"或"上传音乐"功能时，您主动选择的视频或音乐文件会被上传到我们的服务器，用于内容分享和播放服务。\n\n'
                      '3.我们不会收集或上传您的其他个人数据，如设备标识符、位置信息、联系人信息等。\n\n'
                      '二、数据存储\n\n'
                      '1.您主动上传的视频和音乐文件存储在服务器上，用于提供内容分享和播放服务。\n\n'
                      '2.应用设置数据（如授权状态）仅存储在您的设备本地，不会上传到服务器。\n\n'
                      '三、数据使用\n\n'
                      '1.您上传的视频和音乐文件仅用于提供本应用的内容分享和播放服务。\n\n'
                      '2.我们不会将您上传的内容用于其他商业目的，也不会向第三方出售或分享您的数据。\n\n'
                      '3.我们不会使用您的数据进行用户画像、广告推送或其他数据分析活动。\n\n'
                      '四、数据安全\n\n'
                      '1.我们采用合理的技术手段保护您上传的内容安全。\n\n'
                      '2.您可以通过应用内的删除功能删除您上传的内容。\n\n'
                      '3.应用设置数据存储在您的设备本地，由您的设备安全措施保障。\n\n'
                      '五、第三方服务\n\n'
                      '本应用不集成任何第三方数据分析服务、广告服务或其他可能收集用户信息的服务。\n\n'
                      '六、隐私政策更新\n\n'
                      '我们有权根据业务发展、法律政策变化等对本政策进行调整，并通过应用内等方式通知。用户继续使用视为接受修改后的政策。\n\n'
                      '联系渠道\n\n'
                      '如对本政策有任何疑问，请通过以下方式联系我们：\n\n'
                      '邮箱：zhihuilingai4@outlook.com',
                      style: TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '点击"同意"即表示您已阅读并同意上述协议和政策。',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            // 按钮区域 - 固定高度
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: const Text('不同意'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: const Text('同意'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

