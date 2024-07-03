#!/bin/bash


# i.e.
# ./apns_push_live_activity.sh XXX com.apple.example L2LXXXXX $HOME/Documents/APNS/L2LXXXXX.p8 80ad93efXXXXXXXeea6
# ./apns_push_live_activity.sh teamId=XXX bundleId=com.apple.example authKeyId=L2LXXXXX authKeyFile=$HOME/Documents/APNS/L2LXXXXX.p8 deviceToken=80ad93efXXXXXXXeea6
# 
# do with for loop:
# for i in {1..24}; do ./apns_push_live_activity.sh XXX com.apple.example L2LXXXXX $HOME/Documents/APNS/L2LXXXXX.p8 80ad93efXXXXXXXeea666666 $((i * 5)); sleep 5; done;


# Reference:
# https://zhuanlan.zhihu.com/p/656876946
# https://pub.dev/packages/live_activities
# https://github.com/batikansosun/iOS-16-Live-Activities-Dynamic-Island.git
# https://xujiwei.com/blog/2022/10/update-dynamic-island-and-live-activity-with-push-notification/
# https://betterprogramming.pub/ios-live-activities-updating-remotely-using-push-notification-34911a1bcc5e
# https://ohdarling88.medium.com/update-dynamic-island-and-live-activity-with-push-notification-38779803c145
# https://developer.apple.com/documentation/usernotifications/establishing-a-token-based-connection-to-apns
# https://developer.apple.com/documentation/activitykit/starting-and-updating-live-activities-with-activitykit-push-notifications

# Free icon:
# https://www.flaticon.com



echo "------------------------------------------------------------------"
for arg in "$@"; do echo "$arg"; done
YOUR_TEAM_ID=$1
YOUR_BUNDLE_ID=$2
YOUR_AUTHKEY_ID=$3
YOUR_AUTHKEY_FILE=$4
YOUR_DEVICE_TOKEN=$5
# Optional
YOUR_PROGRESS_VALUE=$6
echo "------------------------------------------------------------------"

for arg in "$@"
do
    IFS='=' read -r key value <<< "$arg"

    case "$key" in
        teamId)
            YOUR_TEAM_ID="$value"
            ;;
        bundleId)
            YOUR_BUNDLE_ID="$value"
            ;;
        authKeyId)
            YOUR_AUTHKEY_ID="$value"
            ;;
        authKeyFile)
            YOUR_AUTHKEY_FILE="$value"
            ;;
        deviceToken)
            YOUR_DEVICE_TOKEN="$value"
            ;;
        # Optional
        progress)
            YOUR_PROGRESS_VALUE="$value"
            ;;
        *)
            # echo "Error: Unknown key $key" >&2
            # exit 1
            ;;
    esac
done

echo "------------------------------------------------------------------"
echo "✅ YOUR_TEAM_ID: $YOUR_TEAM_ID"
echo "✅ YOUR_BUNDLE_ID: $YOUR_BUNDLE_ID"
echo "✅ YOUR_AUTHKEY_ID: $YOUR_AUTHKEY_ID"
echo "✅ YOUR_AUTHKEY_FILE: $YOUR_AUTHKEY_FILE"
echo "✅ YOUR_DEVICE_TOKEN: $YOUR_DEVICE_TOKEN"
echo "------------------------------------------------------------------"


echo -e "\nReplaceing with the current timestamp ..."
# Replace with the current timestamp ...
read -r -d '' YOUR_HTTP_BODY <<- EOF
{
  "aps": {
    "timestamp": __Timestamp_In_Second__,
    "event": "update",
    "content-state": {
      "courierName": "Iron Man",
      "progress": 55,
      "deliveryTime": 10086
    },
    "alert": {
      "title": "Track Update",
      "body": "Tony Stark is now handling the delivery!"
    }
  }
}
EOF


timestamp=$(date +%s)
YOUR_HTTP_BODY=${YOUR_HTTP_BODY//__Timestamp_In_Second__/${timestamp}}

# Replace with the progress value ...
if [ -n "$YOUR_PROGRESS_VALUE" ]; then
  echo -e "\nReplacing the progress value: $YOUR_PROGRESS_VALUE ..."
  YOUR_HTTP_BODY=${YOUR_HTTP_BODY//55/$YOUR_PROGRESS_VALUE}
fi


echo ""
echo -e "$YOUR_HTTP_BODY"


echo ""
echo "Signing and start the apns request ..."


export TEAM_ID=$YOUR_TEAM_ID
export BUNDLE_ID=$YOUR_BUNDLE_ID
export TOKEN_KEY_FILE_NAME=$YOUR_AUTHKEY_FILE
export AUTH_KEY_ID=$YOUR_AUTHKEY_ID
export DEVICE_TOKEN=$YOUR_DEVICE_TOKEN
export APNS_HOST_NAME=api.sandbox.push.apple.com

export JWT_ISSUE_TIME=$(date +%s)
export JWT_HEADER=$(printf '{ "alg": "ES256", "kid": "%s" }' "${AUTH_KEY_ID}" | openssl base64 -e -A | tr -- '+/' '-_' | tr -d =)
export JWT_CLAIMS=$(printf '{ "iss": "%s", "iat": %d }' "${TEAM_ID}" "${JWT_ISSUE_TIME}" | openssl base64 -e -A | tr -- '+/' '-_' | tr -d =)
export JWT_HEADER_CLAIMS="${JWT_HEADER}.${JWT_CLAIMS}"
export JWT_SIGNED_HEADER_CLAIMS=$(printf "${JWT_HEADER_CLAIMS}" | openssl dgst -binary -sha256 -sign "${TOKEN_KEY_FILE_NAME}" | openssl base64 -e -A | tr -- '+/' '-_' | tr -d =)
export AUTHENTICATION_TOKEN="${JWT_HEADER}.${JWT_CLAIMS}.${JWT_SIGNED_HEADER_CLAIMS}"


curl -v \
--header "apns-topic:${BUNDLE_ID}.push-type.liveactivity" \
--header "apns-push-type:liveactivity" \
--header "authorization: bearer $AUTHENTICATION_TOKEN" \
--data \
"${YOUR_HTTP_BODY}" \
--http2 \
https://${APNS_HOST_NAME}/3/device/$DEVICE_TOKEN
