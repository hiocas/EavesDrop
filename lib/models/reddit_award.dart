import 'package:draw/draw.dart';

class RedditAllAwardings {
  List<RedditAward> awards;

  RedditAllAwardings.fromSubmission(Submission submission) {
    final List<dynamic> data = submission.data['all_awardings'];
    this.awards = [];
    for (Map<dynamic, dynamic> award in data) {
      this.awards.add(RedditAward.fromJson(award));
    }
  }

}


class RedditAward {
  int count;
  var giverCoinReward;
  String subredditId;
  bool isNew;
  int daysOfDripExtension;
  int coinPrice;
  String id;
  var pennyDonate;
  int coinReward;
  String iconUrl;
  int daysOfPremium;
  int iconHeight;
  var tiersByRequiredAwardings;
  List<RedditResizedIcon> resizedIcons;

  RedditAward(
      this.count,
      this.subredditId,
      this.isNew,
      this.daysOfDripExtension,
      this.coinPrice,
      this.id,
      this.pennyDonate,
      this.coinReward,
      this.iconUrl,
      this.daysOfPremium,
      this.iconHeight,
      this.tiersByRequiredAwardings,
      this.resizedIcons,
      {this.giverCoinReward});

  RedditAward.fromJson(Map<dynamic, dynamic> data) {
    this.count = data['count'];
    this.giverCoinReward = data['giver_coin_reward'];
    this.subredditId = data['subreddit_id'];
    this.isNew = data['is_new'];
    this.daysOfDripExtension = data['days_of_drip_extension'];
    this.coinPrice = data['coin_price'];
    this.id = data['id'];
    this.pennyDonate = data['penny_donate'];
    this.coinReward = data['coin_reward'];
    this.iconUrl = data['icon_url'];
    this.iconUrl = this.iconUrl.replaceAll('&amp;', '&');
    this.daysOfPremium = data['days_of_premium'];
    this.iconHeight = data['icon_height'];
    this.tiersByRequiredAwardings = data['tiers_by_required_awardings'];
    this.resizedIcons = [];
    final List<dynamic> resizedIconsData = data['resized_icons'];
    for (Map<dynamic, dynamic> resizedIcon in resizedIconsData) {
      resizedIcons.add(RedditResizedIcon.fromJson(resizedIcon));
    }
  }

// var t = {
//   'giver_coin_reward': null,
//   'subreddit_id': null,
//   'is_new': false,
//   'days_of_drip_extension': 0,
//   'coin_price': 150,
//   'id': 'award_f44611f1-b89e-46dc-97fe-892280b13b82',
//   'penny_donate': null,
//   'coin_reward': 0,
//   'icon_url':
//       'https://i.redd.it/award_images/t5_22cerq/klvxk1wggfd41_Helpful.png',
//   'days_of_premium': 0,
//   'icon_height': 2048,
//   'tiers_by_required_awardings': null,
//   'resized_icons': [
//     {
//       'url':
//           'https://preview.redd.it/award_images/t5_22cerq/klvxk1wggfd41_Helpful.png?width=16&amp;height=16&amp;auto=webp&amp;s=a5662dfbdb402bf67866c050aa76c31c147c2f45',
//       'width': 16,
//       'height': 16
//     }
//   ]
// };
}

class RedditResizedIcon {
  String url;
  int width;
  int height;

  RedditResizedIcon({this.url, this.width, this.height});

  RedditResizedIcon.fromJson(Map<dynamic, dynamic> data) {
    this.url = data['url'];
    this.url = this.url.replaceAll('&amp;', '&');
    this.width = data['width'];
    this.height = data['height'];
  }
}