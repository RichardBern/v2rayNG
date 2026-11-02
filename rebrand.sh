#!/bin/bash
# Rebrands the v2rayNG source to RichVPN. Runs inside the GitHub build, before compiling.
# Safe to run more than once. Edit ONLY the five lines below.
set -euo pipefail

GH_USER="RichardBern"          # your GitHub username (the fork lives at github.com/GH_USER/v2rayNG)
APP_NAME="RichVPN"
APP_ID="com.richvpn.app"                # the app's unique id on the phone; do not change it after customers install
SUPPORT_URL="https://t.me/richardbernier"
BOT_URL="https://t.me/RichVPNServicebot"

if [ "$GH_USER" = "YOUR_GITHUB_USERNAME" ]; then
  echo "rebrand.sh: set GH_USER first" >&2; exit 1
fi

APP=V2rayNG/app
CFG=$APP/src/main/java/com/v2ray/ang/AppConfig.kt
PROMO_B64=$(printf '%s' "$BOT_URL" | base64 -w0)

# App name (all languages) and the output file names
sed -i "s#\(<string name=\"app_name\"[^>]*>\)v2rayNG\(</string>\)#\1${APP_NAME}\2#" $APP/src/main/res/values*/strings.xml
sed -i "s#applicationId = \"com.v2ray.ang\"#applicationId = \"${APP_ID}\"#" $APP/build.gradle.kts
sed -i "s#v2rayNG_#${APP_NAME}_#g" $APP/build.gradle.kts

# Links inside the app: updates, About page, privacy page, support, and the "Promotion" menu item
sed -i "s#const val APP_URL = .*#const val APP_URL = \"\$GITHUB_URL/${GH_USER}/v2rayNG\"#" $CFG
sed -i "s#const val APP_API_URL = .*#const val APP_API_URL = \"https://api.github.com/repos/${GH_USER}/v2rayNG/releases\"#" $CFG
sed -i "s#const val APP_PRIVACY_POLICY = .*#const val APP_PRIVACY_POLICY = \"\$GITHUB_RAW_URL/${GH_USER}/v2rayNG/master/CR.md\"#" $CFG
sed -i "s#const val TG_CHANNEL_URL = .*#const val TG_CHANNEL_URL = \"${SUPPORT_URL}\"#" $CFG
sed -i "s#const val APP_PROMOTION_URL = .*#const val APP_PROMOTION_URL = \"${PROMO_B64}\"#" $CFG

echo "Rebranded to ${APP_NAME} (${APP_ID})"
