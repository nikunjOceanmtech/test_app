import 'package:googleapis_auth/auth_io.dart';

class GetAccessToken {
  static String firebaseMessagingScope = "https://www.googleapis.com/auth/firebase.messaging";
  static Future<String> getAccessToken() async {
    final client = await clientViaServiceAccount(
        ServiceAccountCredentials.fromJson(
          {
            "type": "service_account",
            "project_id": "test-project-dc65a",
            "private_key_id": "cf5b99fa318e414218437c46d296f3dfa16d69ec",
            "private_key":
                "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQChFM1JGtA2/AS6\nZbWC472OVY5UgY0u4Gmo8Uvyau114XRmxLCuniujpskMXeEvgUyPppyziu1E4/95\nTxqvaKSpAaFhPhchwI3QOhjVlcSyCmt4CVF3P41jmcap2zoQIglVFEqhL37A+Rl0\nZf/OFNen0lgmIod/tHP0tu8eHc1h7UyhFJtfi1a2GJIeJqG4CcnMujU5wb5UPUh+\nvu2fDbFzw8fFrjOJsYFW0zqZSGKhh0eOK8+Bx1YVuzbnNszndbbcUWYy8yRx+CNh\nqHN7bEiea0HbFRD1grxJtXLFddrvP5Ra14NDlZ1Hv/6fo4TGST304G9tC1mDybJ4\nH68q7pCHAgMBAAECggEAGKBpCDGwvo9GG8c7+mBeFRowcewCjTWjAcCuR0gguMJ4\nvNN6XZ/x9QmlOB5MNKqUbWvgDjUBtGQVJVM6NbIOZoZIyWioObFKHRkcvd6xXTTp\nnEb0bQJK1/zlGgfZtyi0+4xoIn9z5gXPZfPIKZYXKGGot1/VDmmkxreHFDgjM8LJ\nJM5aGQxWPzMqj3sKLBuS+W9RUBpRVnr1MltCgHFadH9P6mtz0QMm7hYBmvTFcu6l\nIO2+PNtk/i4Rg2ow2BYWzb3iGGAHvez/xTPJxgFAUkbgE1w5HfY2UVCYyBbvUIGF\n0EXFlg6ZGpET6Ix87jCRgBEq/iOige+7+EhOLZxSQQKBgQDV4t/890T2Jvx/eeqV\nkhEtcnoFSIrez0AWwFRnnPyOlH20HmCcJGhqWLElF6Z89xXensCcK8yErhY0WznE\n2ExLEUazHpX0zBzP82YOLXmJTs6vBRB9Oq1XXXquPuT+eiqJWHrXCKqgsr7mqAiC\nuC7m9/F/mLIxHf/6525kUyg3xwKBgQDAzD7XX74pYenit+sdBTwtFM+HvBRUr1tA\ntUu58kfXfXyDflY1YtVf4ZulmPnEQPTqRLIcXRrZVhcMWIMpzc5gNeAFqfUD2yKu\nuqckBCvlDEGeZDWyp1FOMfiQkImlS8jU2RvrYbyYoCO2+bqTZ89BeKfhWPNPoMo3\nuXauZrphQQKBgDlFAkytuN1gGwPXFSTvc4IDwQBhKC34uGRfIzqLImTbBb2Q1LV6\nWir/jI8uAfo7/rMZNuGaKKzuICvssU8vy13eRlv3uJdPf/d+aLkrG/vUCit646tk\nZr2Z3huB47bv5yvXcSzauTVGJy+DlqPJxWU6xoMv06arLbt09G4QhhhJAoGAWZoS\n0pGilST2R/HmCRS3xNPZJ2IXqMvegxI+4WpiTRn61jnO4vzN4cO+TJXt7nGp4X6P\nsHLs2XkTOR+hxbnqYfhn5vn37xTW55HDwA9YPxkVHgHAmwj71nWO6dDix7mS2qkU\nOq6vsdcrAgzJ01v5jJoAm9B1M9qsYH2HVMJVeIECgYAaayZRibUNxPEKalMKSjeJ\np17ykKG+0M/GR20eRT9ROeadysu6+lmpxxzeDG4OfGgQzQa6E/5DZ5PAA7zG+KSN\nrm3YOuPivA0s+t16WBgjG/ZDQUv02l+fa7peZBpslPkMjee1I+w24fvVDW/ncMLg\nP7i4N4z7xcdfH2MzH3842g==\n-----END PRIVATE KEY-----\n",
            "client_email": "firebase-adminsdk-psjz8@test-project-dc65a.iam.gserviceaccount.com",
            "client_id": "116165647811431434589",
            "auth_uri": "https://accounts.google.com/o/oauth2/auth",
            "token_uri": "https://oauth2.googleapis.com/token",
            "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
            "client_x509_cert_url":
                "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-psjz8%40test-project-dc65a.iam.gserviceaccount.com",
            "universe_domain": "googleapis.com"
          },
        ),
        [firebaseMessagingScope]);

    final accessToken = client.credentials.accessToken.data;
    return accessToken;
  }
}
