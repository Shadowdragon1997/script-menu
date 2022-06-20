#!/usr/bin/bash

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

# check root
[[ $EUID -ne 0 ]] && echo -e "${red}Lỗi: ${plain} Tập lệnh này phải được chạy với tư cách người dùng root!\n" && exit 1

# check os
if [[ -f /etc/redhat-release ]]; then
    release="centos"
elif cat /etc/issue | grep -Eqi "debian"; then
    release="debian"
elif cat /etc/issue | grep -Eqi "ubuntu"; then
    release="ubuntu"
elif cat /etc/issue | grep -Eqi "centos|red hat|redhat|rocky|alma|oracle linux"; then
    release="centos"
elif cat /proc/version | grep -Eqi "debian"; then
    release="debian"
elif cat /proc/version | grep -Eqi "ubuntu"; then
    release="ubuntu"
elif cat /proc/version | grep -Eqi "centos|red hat|redhat|rocky|alma|oracle linux"; then
    release="centos"
else
    echo -e "${red}Phiên bản hệ thống không được phát hiện, vui lòng liên hệ với tác giả kịch bản!${plain}\n" && exit 1
fi

# os version
if [[ -f /etc/os-release ]]; then
    os_version=$(awk -F'[= ."]' '/VERSION_ID/{print $3}' /etc/os-release)
fi
if [[ -z "$os_version" && -f /etc/lsb-release ]]; then
    os_version=$(awk -F'[= ."]+' '/DISTRIB_RELEASE/{print $2}' /etc/lsb-release)
fi

if [[ x"${release}" == x"centos" ]]; then
    if [[ ${os_version} -le 6 ]]; then
        echo -e "${red}Vui lòng sử dụng CentOS 7 trở lên!${plain}\n" && exit 1
    fi
elif [[ x"${release}" == x"ubuntu" ]]; then
    if [[ ${os_version} -lt 16 ]]; then
        echo -e "${red}Vui lòng sử dụng Ubuntu 16 hoặc cao hơn!${plain}\n" && exit 1
    fi
elif [[ x"${release}" == x"debian" ]]; then
    if [[ ${os_version} -lt 8 ]]; then
        echo -e "${red}Vui lòng sử dụng Debian 8 trở lên!${plain}\n" && exit 1
    fi
fi

close_menu() {
    clear
    exit
}

install() {
    bash <(curl -Ls https://raw.githubusercontent.com/Shadowdragon1997/script/main/installdev.sh)
    if [[ $? == 0 ]]; then
        if [[ $# == 0 ]]; then
            start
        else
            start 0
        fi
    fi
}

update() {
    if [[ $# == 0 ]]; then
        echo && echo -n -e "Nhập phiên bản được chỉ định (phiên bản mới nhất mặc định): " && read version
    else
        version=$2
    fi
    bash <(curl -Ls https://raw.githubusercontent.com/Shadowdragon1997/script/main/updatedev.sh) $version
    if [[ $? == 0 ]]; then
        echo -e "${green}Cập nhật hoàn tất, AikoXrayR đã được khởi động lại tự động, vui lòng sử dụng nhật ký XrayR để xem nhật ký chạy${plain}"
        exit
    fi

    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

uninstall() {
    confirm "Bạn có chắc chắn muốn gỡ cài đặt AikoXrayR không?" "n"
    if [[ $? != 0 ]]; then
        if [[ $# == 0 ]]; then
            show_menu
        fi
        return 0
    fi
    systemctl stop XrayR
    systemctl disable XrayR
    rm /etc/systemd/system/XrayR.service -f
    systemctl daemon-reload
    systemctl reset-failed
    rm /etc/XrayR/ -rf
    rm /usr/local/XrayR/ -rf
    rm /usr/bin/XrayR -f

    echo ""
    echo -e "${green} Đã gỡ thành công AikoXrayR hoàn toàn ${plain}"
    echo ""

    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

status() {
    systemctl status XrayR --no-pager -l
    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

show_log() {
    journalctl -u XrayR.service -e --no-pager -f
    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

install_TLS() {
read -p "Vui lòng chọn config CertFile và KeyFile: " choose_node

if [ "$choose_node" == "quabnv_1" ]; then
      wget https://raw.githubusercontent.com/Shadowdragon1997/pem_key/quabnv/pem/vt1/vt1.pem -O /etc/XrayR/server.pem
      wget https://raw.githubusercontent.com/Shadowdragon1997/pem_key/quabnv/pem/vt1/vt1.privkey.pem -O /etc/XrayR/privkey.pem

elif [ "$choose_node" == "quabnv_2" ]; then
      wget https://raw.githubusercontent.com/Shadowdragon1997/pem_key/quabnv/pem/vt2/vt2.pem -O /etc/XrayR/server.pem
      wget https://raw.githubusercontent.com/Shadowdragon1997/pem_key/quabnv/pem/vt2/vt2.privkey.pem -O /etc/XrayR/privkey.pem
      
elif [ "$choose_node" == "khoa_1" ]; then
      wget https://raw.githubusercontent.com/Shadowdragon1997/pem_key/anhkhoa/pem/vt1/vt1.pem -O /etc/XrayR/server.pem
      wget https://raw.githubusercontent.com/Shadowdragon1997/pem_key/anhkhoa/pem/vt1/vt1.privkey.pem -O /etc/XrayR/privkey.pem
      
elif [ "$choose_node" == "khoa_2" ]; then
      wget https://raw.githubusercontent.com/Shadowdragon1997/pem_key/anhkhoa/pem/vt2/vt2.pem -O /etc/XrayR/server.pem
      wget https://raw.githubusercontent.com/Shadowdragon1997/pem_key/anhkhoa/pem/vt2/vt2.privkey.pem -O /etc/XrayR/privkey.pem

elif [ "$choose_node" == "khoa_3" ]; then
      wget https://raw.githubusercontent.com/Shadowdragon1997/pem_key/anhkhoa/pem/vt3/vt3.pem -O /etc/XrayR/server.pem
      wget https://raw.githubusercontent.com/Shadowdragon1997/pem_key/anhkhoa/pem/vt3/vt3.privkey.pem -O /etc/XrayR/privkey.pem

elif [ "$choose_node" == "khoa_4" ]; then
      wget https://raw.githubusercontent.com/Shadowdragon1997/pem_key/anhkhoa/pem/vt4/vt4.pem -O /etc/XrayR/server.pem
      wget https://raw.githubusercontent.com/Shadowdragon1997/pem_key/anhkhoa/pem/vt4/vt4.privkey.pem -O /etc/XrayR/privkey.pem
      
elif [ "$choose_node" == "khoa_5" ]; then
      wget https://raw.githubusercontent.com/Shadowdragon1997/pem_key/anhkhoa/pem/vt5/vt5.pem -O /etc/XrayR/server.pem
      wget https://raw.githubusercontent.com/Shadowdragon1997/pem_key/anhkhoa/pem/vt5/vt5.privkey.pem -O /etc/XrayR/privkey.pem

elif [ "$choose_node" == "khoa_6" ]; then
      wget https://raw.githubusercontent.com/Shadowdragon1997/pem_key/anhkhoa/pem/vt6/vt6.pem -O /etc/XrayR/server.pem
      wget https://raw.githubusercontent.com/Shadowdragon1997/pem_key/anhkhoa/pem/vt6/vt6.privkey.pem -O /etc/XrayR/privkey.pem
      
elif [ "$choose_node" == "khoa_7" ]; then
      wget https://raw.githubusercontent.com/Shadowdragon1997/pem_key/anhkhoa/pem/vt7/vt7.pem -O /etc/XrayR/server.pem
      wget https://raw.githubusercontent.com/Shadowdragon1997/pem_key/anhkhoa/pem/vt7/vt7.privkey.pem -O /etc/XrayR/privkey.pem
      
elif [ "$choose_node" == "khoa_gaming_1" ]; then
      wget https://raw.githubusercontent.com/Shadowdragon1997/pem_key/anhkhoa/pem/gaming1/gaming1.pem -O /etc/XrayR/server.pem
      wget https://raw.githubusercontent.com/Shadowdragon1997/pem_key/anhkhoa/pem/gaming1/gaming1.privkey.pem -O /etc/XrayR/privkey.pem

elif [ "$choose_node" == "khoa_gaming_2" ]; then
      wget https://raw.githubusercontent.com/Shadowdragon1997/pem_key/anhkhoa/pem/gaming2/gaming2.pem -O /etc/XrayR/server.pem
      wget https://raw.githubusercontent.com/Shadowdragon1997/pem_key/anhkhoa/pem/gaming2/gaming2.privkey.pem -O /etc/XrayR/privkey.pem

elif [ "$choose_node" == "khoa_gaming_3" ]; then
      wget https://raw.githubusercontent.com/Shadowdragon1997/pem_key/anhkhoa/pem/gaming3/gaming3.pem -O /etc/XrayR/server.pem
      wget https://raw.githubusercontent.com/Shadowdragon1997/pem_key/anhkhoa/pem/gaming3/gaming3.privkey.pem -O /etc/XrayR/privkey.pem

elif [ "$choose_node" == "khoa_gaming_4" ]; then
      wget https://raw.githubusercontent.com/Shadowdragon1997/pem_key/anhkhoa/pem/gaming4/gaming4.pem -O /etc/XrayR/server.pem
      wget https://raw.githubusercontent.com/Shadowdragon1997/pem_key/anhkhoa/pem/gaming4/gaming4.privkey.pem -O /etc/XrayR/privkey.pem

fi
}

install_bbr() {
    bash <(curl -L -s https://raw.githubusercontent.com/AikoCute/BBR-1/aiko/tcp.sh)
}

open_ports() {
    systemctl stop firewalld.service 2>/dev/null
    systemctl disable firewalld.service 2>/dev/null
    setenforce 0 2>/dev/null
    ufw disable 2>/dev/null
    iptables -P INPUT ACCEPT 2>/dev/null
    iptables -P FORWARD ACCEPT 2>/dev/null
    iptables -P OUTPUT ACCEPT 2>/dev/null
    iptables -t nat -F 2>/dev/null
    iptables -t mangle -F 2>/dev/null
    iptables -F 2>/dev/null
    iptables -X 2>/dev/null
    netfilter-persistent save 2>/dev/null
    echo -e "${green}Giải phóng cổng tường lửa thành công!${plain}"
}

benchmark() {
    wget -qO- bench.sh | bash
}

update_shell() {
    wget -O /usr/bin/menu -N --no-check-certificate https://raw.githubusercontent.com/Shadowdragon1997/script-menu/main/menu.sh
    if [[ $? != 0 ]]; then
        echo ""
        echo -e "${red}Không tải được script xuống, vui lòng kiểm tra xem máy có thể kết nối với Github không${plain}"
        before_show_menu
    else
        chmod +x /usr/bin/menu
        echo -e "${green}Tập lệnh nâng cấp thành công, vui lòng chạy lại tập lệnh${plain}" && exit 0
    fi
}

check_install() {
    check_status
    if [[ $? == 2 ]]; then
        echo ""
        echo -e "${red}Vui lòng cài đặt AikoXrayR trước${plain}"
        if [[ $# == 0 ]]; then
            before_show_menu
        fi
        return 1
    else
        return 0
    fi
}

check_uninstall() {
    check_status
    if [[ $? != 2 ]]; then
        echo ""
        echo -e "${red}AikoXrayR đã được cài đặt, vui lòng không cài đặt lại${plain}"
        if [[ $# == 0 ]]; then
            before_show_menu
        fi
        return 1
    else
        return 0
    fi
}

# 0: running, 1: not running, 2: not installed
check_status() {
    if [[ ! -f /etc/systemd/system/XrayR.service ]]; then
        return 2
    fi
    temp=$(systemctl status XrayR | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
    if [[ x"${temp}" == x"running" ]]; then
        return 0
    else
        return 1
    fi
}

show_status() {
    check_status
    case $? in
        0)
            echo -e "Trạng thái AikoXrayR: ${green}Đã được chạy${plain}"
            show_enable_status
            ;;
        1)
            echo -e "Trạng thái AikoXrayR: ${yellow}Không được chạy${plain}"
            show_enable_status
            ;;
        2)
            echo -e "Trạng thái AikoXrayR: ${red}Chưa cài đặt${plain}"
    esac
}

show_enable_status() {
    check_enabled
    if [[ $? == 0 ]]; then
        echo -e "Có tự động bắt đầu không: ${green}CÓ${plain}"
    else
        echo -e "Có tự động bắt đầu không: ${red}Không${plain}"
    fi
}

check_enabled() {
    temp=$(systemctl is-enabled XrayR)
    if [[ x"${temp}" == x"enabled" ]]; then
        return 0
    else
        return 1;
    fi
}

before_show_menu() {
    echo && echo -n -e "${yellow}Nhấn enter để quay lại menu chính: ${plain}" && read temp
    show_menu
}

show_menu() {
    echo -e "
  ${green}Menu hỗ trợ cài đặt nhanh XrayR，${plain}${red}không hoạt động với docker${plain}
--- https://github.com/AikoCute/XrayR ---
  ${green}0.${plain} Thoát Menu
————————————————
  ${green}1.${plain} Cài đặt AikoXrayR
  ${green}2.${plain} Cập nhật AikoXrayR
  ${green}3.${plain} Gỡ cài đặt AikoXrayR
  ${green}4.${plain} Xem trạng thái AikoXrayR
  ${green}5.${plain} Xem nhật ký AikoXrayR (log)
————————————————
  ${green}6.${plain} Cài đặt chứng chỉ TLS
  ${green}7.${plain} Một cú nhấp chuột cài đặt bbr (hạt nhân mới nhất)
  ${green}8.${plain} Cho phép tất cả các cổng mạng của VPS
  ${green}9.${plain} Benchmark kiểm tra thông số CPU, RAM, IO và Speedtest
————————————————
  ${green}10.${plain} Cập nhật lại Script-Menu
 "
 #Các bản cập nhật tiếp theo có thể được thêm vào chuỗi trên
    show_status
    echo && read -p "Vui lòng nhập một lựa chọn [0-10]: " num

    case "${num}" in
        0) close_menu ;;
        1) check_uninstall && install ;;
        2) check_install && update ;;
        3) check_install && uninstall ;;
        4) check_install && status ;;
        5) check_install && show_log ;;
        6) install_TLS ;;
        7) install_bbr ;;
        8) open_ports ;;
        9) benchmark ;;
        10) update_shell ;;
        *) echo -e "${red}Vui lòng nhập số chính xác [0-10]${plain}" ;;
    esac
}


if [[ $# > 0 ]]; then
    case $1 in
        "status") check_install 0 && status 0 ;;
        "log") check_install 0 && show_log 0 ;;
        "update") check_install 0 && update 0 $2 ;;
        "install") check_uninstall 0 && install 0 ;;
        "uninstall") check_install 0 && uninstall 0 ;;
        "version") check_install 0 && show_XrayR_version 0 ;;
        "update_shell") update_shell ;;
        "benchmark") benchmark ;;
        "bbr") install_bbr ;;
        "TLS") install_TLS ;;
        *) show_usage
    esac
else
    show_menu
fi
