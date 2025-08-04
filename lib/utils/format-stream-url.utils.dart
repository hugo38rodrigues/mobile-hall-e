
getStreamName(String streamUrl) {
  List<String> splitStreamUrl = streamUrl.split('/');
  String platformName = splitStreamUrl[2].replaceAll('www.', '');
  int index = splitStreamUrl.indexOf(splitStreamUrl[2]);
  String newStreamUrl = splitStreamUrl.sublist(index + 1).join('/');
  return '$platformName/$newStreamUrl';
}
