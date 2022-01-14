echo -e "\n该小工具可以为你检查本服务器到中国北京、上海、深圳的[回程网络]类型\n"
read -p "按Enter(回车)开始启动检查..." sdad

nodelist=(
    "219.141.136.12 北京电信"
    "202.106.50.1 北京联通"
    "221.179.155.161 北京移动"
    "202.96.209.133 上海电信"
    "210.22.97.1 上海联通"
    "211.136.112.200 上海移动"
    "58.60.188.222 深圳电信"
    "210.21.196.6 深圳联通"
    "120.196.165.24 深圳移动"
    
    "101.227.255.45 上海电信(天翼云)"
    "117.28.254.129 厦门电信CN"
    "58.51.94.106 湖北襄阳电信"
    "182.98.238.226 江西南昌电信"
    "119.147.52.35 广东深圳电信"
    "14.215.116.1 广州电信(天翼云)"
    
    "221.13.70.244 西藏拉萨联通"
    "113.207.32.65 重庆联通"
    "61.168.23.74 河南郑州联通"
    "112.122.10.26 安徽合肥联通"
    "58.240.53.78 江苏南京联通"
    "101.71.241.238 浙江杭州联通"
    
    "221.130.188.251 上海移动"
    "183.221.247.9 四川成都移动"
    "120.209.140.60 安徽合肥移动"
    "112.17.0.106 浙江杭州移动"
    
    "202.205.6.30 北京教育网"
)
Font_Suffix="\033[0m";
Font_PLUS="\033[38;5;027m+${Font_Suffix}"
CT_CN2_GIA="\033[38;5;046m电信CN2 GIA${Font_Suffix}"
CT_CN2_GT="\033[38;5;208m电信CN2 GT${Font_Suffix}"
CT_163="\033[38;5;160m电信163${Font_Suffix}"
CU_AS9929="\033[38;5;040m联通AS9929${Font_Suffix}"
CU_AS4837="\033[38;5;190m联通AS4837${Font_Suffix}"
CU_169="\033[38;5;202m联通169${Font_Suffix}"
CM_CMI="\033[38;5;041m移动CMI${Font_Suffix}"
SB="\033[38;5;204m软银${Font_Suffix}"
EDU="\033[38;5;213m教育网${Font_Suffix}"
OTHER="\033[38;5;015m其他${Font_Suffix}"

testlog=/tmp/traceroute_testlog

function checkresult(){
    result=${OTHER}

    HAS_CT_CN2_GIA=0
    HAS_CT_CN2_GT=0
    HAS_CU_AS10099=0
    HAS_CU_AS9929=0
    HAS_CU_AS4837=0
    HAS_CU_169=0
    HAS_CM_CMI=0
    HAS_EDU=0
    
    # CT_CN2_GIA
    grep -q "59\.43\." $testlog
    if [ $? == 0 ];then
        HAS_CT_CN2_GIA=1
    fi
    
    # CT_CN2_GT
    grep -q "202\.97\." $testlog
    if [ $? == 0 ];then
        HAS_CT_CN2_GT=1
    fi
    
    # CU_AS9929
    grep -q "218\.105\." $testlog
    if [ $? == 0 ];then
        HAS_CU_AS9929=1
    fi
    
    # CU_AS4837
    grep -q -E "219\.158\.(9[6-9]|1[0-1][0-9]|12[0-7])\." $testlog
    if [ $? == 0 ];then
        HAS_CU_AS4837=1
    fi
    
    # CU_169
    grep -q "219\.158\." $testlog
    if [ $? == 0 ];then
        HAS_CU_169=1
    fi
    
    # CU_AS10099
    grep -q -E "203\.160\.|162\.2(19|55)\." $testlog
    if [ $? == 0 ];then
        HAS_CU_AS10099=1
    fi
    
    # CM_CMI
    grep -q -E "223\.120\.|221\.1(81|83|76)\." $testlog
    if [ $? == 0 ];then
        HAS_CM_CMI=1
    fi
    
    # 教育网
    grep -q "101\.4\." $testlog
    if [ $? == 0 ];then
        HAS_EDU=1
    fi
    
    # 计算线路
    if [ $HAS_CU_169 -eq 1 ];then
        if [ $HAS_CU_AS4837 -eq 1 ];then
            result=${CU_AS4837}
        else
            result=${CU_169}
        fi
    fi
    
    if [ $HAS_CT_CN2_GT -eq 1 ];then
        if [ $HAS_CU_169 -eq 1 ];then
            result=${CU_169}
        else
            result=${CT_163}
        fi
    fi
    
    if [ $HAS_CT_CN2_GIA -eq 1 ];then
        if [ $HAS_CT_CN2_GT -eq 1 ];then
            result=${CT_CN2_GT}
        else
            result=${CT_CN2_GIA}
        fi
    fi
    
    if [ $HAS_CU_AS10099 -eq 1 ] || [ $HAS_CU_AS9929 -eq 1 ];then
        result=${CU_AS9929}
    fi
    
    if [ $HAS_CM_CMI -eq 1 ];then
        result=${CM_CMI}
    fi

    if [ $HAS_EDU -eq 1 ];then
        result=${EDU}
    fi
    
    echo ${result}
}

echo "开始安装mtr命令..."
yum install mtr -y >> /dev/null 2>&1
clear
echo -e "\n正在测试,请稍等...v1.25\n本脚本测试结果为TCP回程路由,非ICMP回程路由 仅供参考 谢谢"
echo -e "——————————————————————————————\n"
for node in "${nodelist[@]}"; do
    nodesplit=(${node})
    nodeinfo="目标:${nodesplit[1]}[${nodesplit[0]}]"
    chrlen=`echo -n ${nodeinfo} | wc -c`
    if [ $chrlen -gt 39 ];then
        echo -n -e "${nodeinfo}\t\t\t回程线路:\c";
    else
        echo -n -e "${nodeinfo}\t\t\t\t回程线路:\c";
    fi
    mtr -r --n --tcp ${nodesplit[0]} > $testlog
    result=$(checkresult)

    HAS_SB=0
    
    # SoftBank
    grep -q -E "221\.1(10|11)\." $testlog
    if [ $? == 0 ];then
        HAS_SB=1
    fi
    
    if [ $HAS_SB -eq 1 ];then
        getresult=$(checkresult)
        result="${SB}${Font_PLUS}${getresult}"
    fi
    
    if [ $chrlen -gt 39 ];then
        echo -n -e "\r${nodeinfo}\t\t\t回程线路:${result}\n";
    else
        echo -n -e "\r${nodeinfo}\t\t\t\t回程线路:${result}\n";
    fi
done
rm -f $testlog
echo -e "\n——————————————————————————————\n"
