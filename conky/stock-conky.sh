#!/bin/sh

URL="http://hq.sinajs.cn/list=sh000001,sz000910,sh600717,sz002148"
# s_sh000001,s_sh600036,s_sh600000,s_sh600030,hk03968


curl -s --connect-timeout 30 $URL | iconv -f gb2312 -t utf-8 \
    | awk -F \" '{print $2}' \
    | awk \
'BEGIN {
   FS=","
   printf("%-30s %-30s %-30s %-30s %-30s %-30s %-30s \n", "Name", "昨收", "今开", "最高", "最低", "现价", "成交量")
}
{
   printf("%-30s %-30.2f %-30.2f %-30.2f %-30.2f %-30.2f %-30.2f万手\n", $1, $3, $2, $5, $6, $4, $9/10000)
}'
