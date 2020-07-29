#!/bin/sh
# 该脚本使用方法
# step 1. 在工程根目录新建AutoPacking文件夹，在该文件夹中新建文件autopacking.sh，将该脚本复制到autopacking.sh文件并保存(或者直接复制该文件);
# step 2. 设置该脚本;
# step 2. cd 该脚本目录，运行chmod +x autopacking.sh;
# step 3. 终端运行 sh autopacking.sh;
# step 4. 选择不同选项....
# step 5. Success  🎉 🎉 🎉!
# 注意：可以全文搜索“配置”，看相关注释选择配置，因为不同的项目配置不同，最好有相关的基础知识
# 钉钉开放平台 https://ding-doc.dingtalk.com/doc#/serverapi2/qf2nxq

# ************************* 需要配置 Start ********************************

# 【配置上传到蒲公英相关信息】(可选)
# 蒲公英账号1
__PGYER_U_KEY="adf6b648ddfa4c8e9b0a732a67ab8b76"
__PGYER_API_KEY="9a94d94d5a40c648a9ba0f73f584f4dd"

# 蒲公英账号2
__PGYER_U_KEY2="ff9d3505cad3bb2f31c910443fcf4aa8"
__PGYER_API_KEY2="b3c558664563817255690e616bc5c6c9"

# 【配置上传到 Fir】(可选)
__FIR_API_TOKEN="xKKdjdldlodeikK626266skdkkddK"

# 【配置证书】(如果只有一个证书时该项 可选)
__CODE_SIGN_DISTRIBUTION="Apple Distribution"
__CODE_SIGN_DEVELOPMENT="Apple Development"

# 发布APP Store 账号密码
__IOS_SUBMIT_ACCOUNT="highyoung1990@gmail.com"
__IOS_SUBMIT_PASSWORD="xxxxxx"

# ==================== 公共部分 =====================
# ######### 脚本样式 #############
__TITLE_LEFT_COLOR="\033[36;1m==== "
__TITLE_RIGHT_COLOR=" ====\033[0m"

__OPTION_LEFT_COLOR="\033[33;1m"
__OPTION_RIGHT_COLOR="\033[0m"

__LINE_BREAK_LEFT="\033[32;1m"
__LINE_BREAK_RIGHT="\033[0m"

# 红底白字
__ERROR_MESSAGE_LEFT="\033[41m ! ! ! "
__ERROR_MESSAGE_RIGHT=" ! ! ! \033[0m"

# xcode version
XCODE_BUILD_VERSION=$(xcodebuild -version)
echo "-------------- Xcode版本: $XCODE_BUILD_VERSION -------------------"



# 等待用户输入时间
__WAIT_ELECT_TIME=0.2

# 选择项输入方法 接收3个参数：1、选项标题 2、选项数组 3、选项数组的长度(0~256)
function READ_USER_INPUT() {
  title=$1
  options=$2
  maxValue=$3
  echo "${__TITLE_LEFT_COLOR}${title}${__TITLE_RIGHT_COLOR}"
  for option in ${options[*]}; do
    echo "${__OPTION_LEFT_COLOR}${option}${__OPTION_RIGHT_COLOR}"
  done
  read
  __INPUT=$REPLY
  expr $__INPUT "+" 10 &> /dev/null
  if [[ $? -eq 0 ]]; then
    if [[ $__INPUT -gt 0 && $__INPUT -le $maxValue ]]; then
      return $__INPUT
    else
      echo "${__ERROR_MESSAGE_LEFT}输入越界了，请重新输入${__ERROR_MESSAGE_RIGHT}"
      READ_USER_INPUT $title "${options[*]}" $maxValue
    fi
  else
    echo "${__ERROR_MESSAGE_LEFT}输入有误，请输入0~256之间的数字序号${__ERROR_MESSAGE_RIGHT}"
    READ_USER_INPUT $title "${options[*]}" $maxValue
  fi
}

# 打印信息
function printMessage() {
  pMessage=$1
  echo "${__LINE_BREAK_LEFT}${pMessage}${__LINE_BREAK_RIGHT}"
}

# 工程是否WORKSPACE
__IS_WORKSPACE_OPTION=1
# 上传ipa方式
__UPLOAD_IPA_OPTION=2
# 已经指定Target的Info.plist文件路径 【配置Info.plist的名称】
__CURRENT_INFO_PLIST_NAME="Info.plist"

# 1. 请选择 SCHEME
__SELECT_TARGET_OPTIONS=("1.MTest环境" "2.Dev1环境" "3.生产环境" "4.Dev2环境")
READ_USER_INPUT "请选择对应的Target: " "${__SELECT_TARGET_OPTIONS[*]}" ${#__SELECT_TARGET_OPTIONS[*]}

__SELECT_TARGET_OPTION=$?
__BUILD_CONFIGURATION="Debug"
__EXPORT_OPTIONS_PLIST_PATH=""
__BUILD_METHOD_NAME=""
__ipaUrl=""
__dingdingMsgTitle=""


if [[ $__SELECT_TARGET_OPTION -eq 1 ]]; then
    __BUILD_CONFIGURATION="Debug"
    __BUILD_TARGET="Premom-Test"
    __SCHEME_NAME="Premom-Test"
    __EXPORT_OPTIONS_PLIST_PATH="./AutoPacking/Plist/MTestExportOptions.plist"
    __BUILD_METHOD_NAME="Development"
    __CURRENT_INFO_PLIST_NAME="Info.plist"
    __ipaUrl="https://www.pgyer.com/QznT"
    __dingdingMsgTitle="Premom-MTest环境"
elif [[ $__SELECT_TARGET_OPTION -eq 2 ]]; then
    __BUILD_CONFIGURATION="Debug"
    __BUILD_TARGET="Premom-Dev1"
    __SCHEME_NAME="Premom-Dev1"
    __EXPORT_OPTIONS_PLIST_PATH="./AutoPacking/Plist/Dev1ExportOptions.plist"
    __BUILD_METHOD_NAME="Development"
    __CURRENT_INFO_PLIST_NAME="Premom-Dev1.plist"
    __ipaUrl="https://www.pgyer.com/Fz78"
    __dingdingMsgTitle="Premom-Dev1环境"
elif [[ $__SELECT_TARGET_OPTION -eq 3 ]]; then
    __BUILD_CONFIGURATION="Release"
    __BUILD_TARGET="Premom"
    __SCHEME_NAME="Premom"
    __EXPORT_OPTIONS_PLIST_PATH="./AutoPacking/Plist/ProExportOptions.plist"
    __BUILD_METHOD_NAME="AdHoc"
    __CURRENT_INFO_PLIST_NAME="Premom.plist"
    __ipaUrl="https://www.pgyer.com/YTOC"
    __dingdingMsgTitle="Premom-生产环境"
elif [[ $__SELECT_TARGET_OPTION -eq 4 ]]; then
    __BUILD_CONFIGURATION="Debug"
    __BUILD_TARGET="Premom-Dev2"
    __SCHEME_NAME="Premom-Dev2"
    __EXPORT_OPTIONS_PLIST_PATH="./AutoPacking/Plist/Dev2ExportOptions.plist"
    __BUILD_METHOD_NAME="Development"
    __CURRENT_INFO_PLIST_NAME="Premom-Dev2.plist"
    __ipaUrl="https://www.pgyer.com/MQYh"
    __dingdingMsgTitle="Premom-Dev2环境"
else
printMessage "这里请填写好你工程的所有target"
exit 1
fi


__IS_NOW_STAR_PACKINGS=1
if [[ $__IS_NOW_STAR_PACKING -eq 1 ]]; then
  printMessage "已开始打包"
elif [[ $__IS_NOW_STAR_PACKING -eq 2 ]]; then
  printMessage "您退出了自动打包脚本"
  exit 1
fi

# ===============================自动打包部分=============================
# 打包计时
__CONSUME_TIME=0
# 回退到工程目录
cd ../
__PROGECT_PATH=`pwd`

# 获取项目名称
__PROJECT_NAME=`find . -name *.xcodeproj | awk -F "[/.]" '{print $(NF-1)}'`


# 获取 Info.plist 路径  【配置Info.plist的路径】
__CURRENT_INFO_PLIST_PATH="${__PROJECT_NAME}/${__CURRENT_INFO_PLIST_NAME}"
# 获取版本号
__BUNDLE_VERSION=`/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" ${__CURRENT_INFO_PLIST_PATH}`
# 获取编译版本号
__BUNDLE_BUILD_VERSION=`/usr/libexec/PlistBuddy -c "Print CFBundleVersion" ${__CURRENT_INFO_PLIST_PATH}`

# Xcode11 以上版本
if [[ $XCODE_BUILD_VERSION =~ "Xcode 11" || $XCODE_BUILD_VERSION =~ "Xcode11" ]]; then
  __BUNDLE_VERSION_TAG="MARKETING_VERSION"
  __BUNDLE_BUILD_VERSION_TAG="CURRENT_PROJECT_VERSION"
  __PROJECT_ROOT_PATH=`find . -name *.xcodeproj`
  __PBXPROJ_PATH="$__PROJECT_ROOT_PATH/project.pbxproj"
  __BUNDLE_VERSION_11=$(grep "${__BUNDLE_VERSION_TAG}" $__PBXPROJ_PATH | head -1 | awk -F '=' '{print $2}' | awk -F ';' '{print $1}' | sed s/[[:space:]]//g)
  __BUNDLE_BUILD_VERSION_11=$(grep "${__BUNDLE_BUILD_VERSION_TAG}" $__PBXPROJ_PATH | head -1 | awk -F '=' '{print $2}' | awk -F ';' '{print $1}' | sed s/[[:space:]]//g)

  if [[ -n "$__BUNDLE_VERSION_11" ]]; then
    __BUNDLE_VERSION="$__BUNDLE_VERSION_11";
  fi

  if [[ -n "$__BUNDLE_BUILD_VERSION_11" ]]; then
    __BUNDLE_BUILD_VERSION="$__BUNDLE_BUILD_VERSION_11";
  fi
fi

# 编译生成文件目录
__EXPORT_PATH="./build"

# 指定输出文件目录不存在则创建
if test -d "${__EXPORT_PATH}" ; then
rm -rf ${__EXPORT_PATH}
else
mkdir -pv ${__EXPORT_PATH}
fi

# 归档文件路径
__EXPORT_ARCHIVE_PATH="${__EXPORT_PATH}/${__SCHEME_NAME}.xcarchive"
# ipa 导出路径
__EXPORT_IPA_PATH="${__EXPORT_PATH}"
# 获取时间 如:2020-06-13 15:06:51
__CURRENT_DATE="$(date +'%Y-%m-%d %T')"
# ipa 名字
__IPA_NAME="${__SCHEME_NAME}"

function print_packing_message() {

  printMessage "打包类型 = ${__BUILD_CONFIGURATION}"
  printMessage "打包导出Plist路径 = ${__EXPORT_OPTIONS_PLIST_PATH}"
  printMessage "工程目录 = ${__PROGECT_PATH}"
  printMessage "当前Info.plist路径 = ${__CURRENT_INFO_PLIST_PATH}"
  printMessage "归档路径 = ${__EXPORT_ARCHIVE_PATH}"
  printMessage "ipa名字 = ${__IPA_NAME}"
}

print_packing_message


if [[ $__IS_WORKSPACE_OPTION -eq 1 ]]; then
  # pod install --verbose --no-repo-update
 
  if [[ ${__BUILD_CONFIGURATION} == "Debug" ]]; then
    # step 1. Clean
    xcodebuild clean  -workspace ${__PROJECT_NAME}.xcworkspace \
    -scheme ${__SCHEME_NAME} \
    -configuration ${__BUILD_CONFIGURATION}

    # step 2. Archive
    xcodebuild archive  -workspace ${__PROJECT_NAME}.xcworkspace \
    -scheme ${__SCHEME_NAME} \
    -configuration ${__BUILD_CONFIGURATION} \
    -archivePath ${__EXPORT_ARCHIVE_PATH} \
    CFBundleVersion=${__BUNDLE_BUILD_VERSION} \
    -destination generic/platform=ios \
    #CODE_SIGN_IDENTITY="${__CODE_SIGN_DEVELOPMENT}"

  elif [[ ${__BUILD_CONFIGURATION} == "Release" ]]; then
    # step 1. Clean
    xcodebuild clean  -workspace ${__PROJECT_NAME}.xcworkspace \
    -scheme ${__SCHEME_NAME} \
    -configuration ${__BUILD_CONFIGURATION}

    # step 2. Archive
    xcodebuild archive  -workspace ${__PROJECT_NAME}.xcworkspace \
    -scheme ${__SCHEME_NAME} \
    -configuration ${__BUILD_CONFIGURATION} \
    -archivePath ${__EXPORT_ARCHIVE_PATH} \
    CFBundleVersion=${__BUNDLE_BUILD_VERSION} \
    -destination generic/platform=ios \
    #CODE_SIGN_IDENTITY="${__CODE_SIGN_DISTRIBUTION}"
  fi

else

  if [[ ${__BUILD_CONFIGURATION} == "Debug" ]] ; then
  
    # step 1. Clean
    xcodebuild clean  -project ${__PROJECT_NAME}.xcodeproj \
    -scheme ${__SCHEME_NAME} \
    -configuration ${__BUILD_CONFIGURATION} \
    #-alltargets

    # step 2. Archive
    xcodebuild archive  -project ${__PROJECT_NAME}.xcodeproj \
    -scheme ${__SCHEME_NAME} \
    -configuration ${__BUILD_CONFIGURATION} \
    -archivePath ${__EXPORT_ARCHIVE_PATH} \
    CFBundleVersion=${__BUNDLE_BUILD_VERSION} \
    -destination generic/platform=ios \
    #CODE_SIGN_IDENTITY="${__CODE_SIGN_DEVELOPMENT}"

  elif [[ ${__BUILD_CONFIGURATION} == "Release" ]]; then
    # step 1. Clean
    xcodebuild clean  -project ${__PROJECT_NAME}.xcodeproj \
    -scheme ${__SCHEME_NAME} \
    -configuration ${__BUILD_CONFIGURATION} \
    -alltargets
    # step 2. Archive
    xcodebuild archive  -project ${__PROJECT_NAME}.xcodeproj \
    -scheme ${__SCHEME_NAME} \
    -configuration ${__BUILD_CONFIGURATION} \
    -archivePath ${__EXPORT_ARCHIVE_PATH} \
    CFBundleVersion=${__BUNDLE_BUILD_VERSION} \
    -destination generic/platform=ios \
    #CODE_SIGN_IDENTITY="${__CODE_SIGN_DISTRIBUTION}"
  fi
fi

# 检查是否构建成功
# xcarchive 实际是一个文件夹不是一个文件所以使用 -d 判断
if test -d "${__EXPORT_ARCHIVE_PATH}" ; then
  printMessage "项目构建成功 🚀 🚀 🚀"
else
  printMessage "项目构建失败 😢 😢 😢"
  exit 1
fi

printMessage "开始导出ipa文件"

xcodebuild -exportArchive -archivePath ${__EXPORT_ARCHIVE_PATH} \
-exportPath ${__EXPORT_IPA_PATH} \
-destination generic/platform=ios \
-exportOptionsPlist ${__EXPORT_OPTIONS_PLIST_PATH} \
-allowProvisioningUpdates

# 修改ipa文件名称
mv ${__EXPORT_IPA_PATH}/${__SCHEME_NAME}.ipa ${__EXPORT_IPA_PATH}/${__IPA_NAME}.ipa

# 检查文件是否存在
if test -f "${__EXPORT_IPA_PATH}/${__IPA_NAME}.ipa" ; then

  printMessage "导出 ${__IPA_NAME}.ipa 包成功 🎉 🎉 🎉"
  printMessage "开始上传到蒲公英 🚀 🚀 🚀"
  if [[ $__UPLOAD_IPA_OPTION -eq 1 ]]; then
    printMessage "您选择了不上传到内测网站"
  elif [[ $__UPLOAD_IPA_OPTION -eq 2 ]]; then


    if [[ $__SELECT_TARGET_OPTION -eq 4 ]]; then
    #dev2环境
    curl -F "file=@${__EXPORT_IPA_PATH}/${__IPA_NAME}.ipa" \
    -F "uKey=$__PGYER_U_KEY2" \
    -F "_api_key=$__PGYER_API_KEY2" \
    "http://www.pgyer.com/apiv1/app/upload"
    
    else
    #非dev2环境
    curl -F "file=@${__EXPORT_IPA_PATH}/${__IPA_NAME}.ipa" \
    -F "uKey=$__PGYER_U_KEY" \
    -F "_api_key=$__PGYER_API_KEY" \
    "http://www.pgyer.com/apiv1/app/upload"
    fi

    printMessage "上传 ${__IPA_NAME}.ipa 包 到 pgyer 成功 🎉 🎉 🎉"
    
  elif [[ $__UPLOAD_IPA_OPTION -eq 3 ]]; then

    fir login -T ${__FIR_API_TOKEN}
    fir publish "${__EXPORT_IPA_PATH}/${__IPA_NAME}.ipa"

    printMessage "上传 ${__IPA_NAME}.ipa 包 到 fir 成功 🎉 🎉 🎉"

  elif [[ $__UPLOAD_IPA_OPTION -eq 4 ]]; then

    fir login -T ${__FIR_API_TOKEN}
    fir publish "${__EXPORT_IPA_PATH}/${__IPA_NAME}.ipa"

    printMessage "上传 ${__IPA_NAME}.ipa 包 到 fir 成功 🎉 🎉 🎉"

    curl -F "file=@{${__EXPORT_IPA_PATH}/${__IPA_NAME}.ipa}" \
    -F "uKey=$__PGYER_U_KEY" \
    -F "_api_key=$__PGYER_API_KEY" \
    "http://www.pgyer.com/apiv1/app/upload"

    printMessage "上传 ${__IPA_NAME}.ipa 包 到 pgyer 成功 🎉 🎉 🎉"

  fi
  
  # 钉钉机器发送成功消息
  textContent="${__dingdingMsgTitle}打包成功\n[${__ipaUrl}](${__ipaUrl})\n密码：123456"
  curl 'https://oapi.dingtalk.com/robot/send?access_token=b570b3b3ed29d2883dcbfda2c97e2f1e286bb95660307e05bce1ca1e9ad3b7ef' \
  -H 'Content-Type: application/json' \
  -d '{"msgtype":"markdown","markdown":{"title":"'${__dingdingMsgTitle}'打包成功","text":"'${textContent}'"},"at":{"atMobiles":["13539467126"],"isAtAll":true}}'


  # 自动打开文件夹
  if [[ $__IS_AUTO_OPENT_FILE_OPTION -eq 1 ]]; then
    open ${__EXPORT_IPA_PATH}
  fi

else
  printMessage "导出 ${__IPA_NAME}.ipa 包失败 😢 😢 😢"
  exit 1
fi

# 输出打包总用时
printMessage "使用Shell脚本打包总耗时: ${SECONDS}s"
