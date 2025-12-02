// Script to check AssetRes constant usage
void main() {
  // Icons defined in AssetRes
  const List<String> iconConstants = [
    'invalid', 'pdfRemove', 'inboxLogo', 'emailLogo', 'home', 'application', 
    'chat', 'profile1', 'menuIcon', 'bookMarkBorderIcon', 'bookMarkFillIcon',
    'uploadIcon', 'pdfIcon', 'userIcon', 'wantJob', 'person', 'cloud',
    'chatSend', 'applies', 'search', 'del', 'dateIcon', 'dropIcon',
    'currencyIcon', 'addIcon', 'checkIcon', 'notification', 'add',
    'calender', 'time', 'seePdf', 'applicationIcon'
  ];

  // Images defined in AssetRes
  const List<String> imageConstants = [
    'splashScreen', 'splashFullImage', 'firstScreenBack', 'facebookImage',
    'googleLogo', 'congratsLogo', 'splashBoyImg', 'girlImage', 'airBnbLogo',
    'twitterLogo', 'lookingForYou', 'resumeImage', 'notificationDetail',
    'successImage', 'failedImage', 'chatImage', 'dropDown', 'detailsImage',
    'chatBoxMenImage', 'roundAirbnb', 'galleryImage', 'settingArrow',
    'settingHelp', 'logout', 'rightLogo', 'add1', 'facebook',
    'userprofileLogo', 'failedImages', 'unSave', 'homeLogo', 'home2',
    'appliesLogo', 'inbox', 'profileLogo', 'companyProfile', 'userImage',
    'page1', 'page2', 'page3', 'logo', 'searchJobImage'
  ];

  print('Icons: ${iconConstants.length}');
  print('Images: ${imageConstants.length}');
  print('Total constants: ${iconConstants.length + imageConstants.length}');
}